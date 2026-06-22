import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/shell_screen_header.dart';
import '../../../core/constants/app_product_flags.dart';
import '../../../core/utils/biz_date.dart';
import '../../../features/dashboard/data/family_api_client.dart';
import '../../../features/dashboard/providers/family_api_base_url_provider.dart';
import '../../../shared/providers/timemachine_ui_providers.dart';
import '../data/timemachine_prototype_models.dart';
import '../data/timemachine_remote_write.dart';

const Color _kTmCard = Color(0xFF1E1E1E);
const Color _kTmGold = Color(0xFFD4AF37);
/// 第二行「按日」筛选：冷色强调，与第一行金色区分
const Color _kTmDayAccent = Color(0xFF81D4FA);
const Color _kTmDayCard = Color(0xFF232B36);
const Color _kTmRow1StripBg = Color(0xFF1A1A22);
const Color _kTmRow2StripBg = Color(0xFF151922);

enum _TmFilterTier { month, day }

class TimemachinePage extends ConsumerWidget {
  const TimemachinePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final apiOn = ref.watch(familyApiIsConfiguredProvider);
    if (apiOn) {
      final chipsAsync = ref.watch(timemachineMonthChipsAsyncProvider);
      ref.listen(timemachineMonthChipsAsyncProvider, (prev, next) {
        next.whenData((chips) {
          if (chips.isEmpty) return;
          final curM = ref.read(timemachineSelectedMonthKeyProvider);
          final curD = ref.read(timemachineSelectedBizDateProvider);
          if (curM == null && curD == null) {
            ref.read(timemachineSelectedMonthKeyProvider.notifier).state =
                chips.first.monthKey;
          }
        });
      });
      if (chipsAsync.isLoading) {
        return Scaffold(
          backgroundColor: AppTheme.shellBackground,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ShellScreenHeader(
                  onBack: () => context.pop(),
                  icon: Icons.hourglass_top_rounded,
                  title: '时光机',
                ),
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                ),
              ],
            ),
          ),
        );
      }
      if (chipsAsync.hasError) {
        return Scaffold(
          backgroundColor: AppTheme.shellBackground,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ShellScreenHeader(
                  onBack: () => context.pop(),
                  icon: Icons.hourglass_top_rounded,
                  title: '时光机',
                ),
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        '时光机加载失败：${chipsAsync.error}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }

    final months = ref.watch(timemachineSidebarMonthsProvider);
    final total = months.fold<int>(0, (sum, m) => sum + m.entryCount);
    final secondRowDays = ref.watch(timemachineSecondRowDaysProvider);
    final feedSections = ref.watch(timemachineFeedSectionsProvider);
    final selectedDay = ref.watch(timemachineSelectedBizDateProvider);
    final selectedMonth = ref.watch(timemachineSelectedMonthKeyProvider);
    final filteredCount = ref.watch(filteredTimemachineEntriesProvider).length;
    final query = ref.watch(timemachineActiveQueryProvider);
    final entriesLoading = apiOn &&
        query.hasFilter &&
        ref.watch(timemachineEntriesAsyncProvider(query)).isLoading;

    final summaryPrefix = selectedDay != null
        ? '${timemachineSidebarDayLabel(selectedDay)} 的记录'
        : selectedMonth != null
            ? '${timemachineMonthChipLabel(selectedMonth)} 全部'
            : '全部记录';
    final summaryText = '$summaryPrefix · 共 $filteredCount 条';

    void selectAll() {
      ref.read(timemachineSelectedMonthKeyProvider.notifier).state = null;
      ref.read(timemachineSelectedBizDateProvider.notifier).state = null;
    }

    void selectMonth(String mk) {
      final curM = ref.read(timemachineSelectedMonthKeyProvider);
      final curD = ref.read(timemachineSelectedBizDateProvider);
      if (curM == mk && curD != null) {
        ref.read(timemachineSelectedBizDateProvider.notifier).state = null;
        return;
      }
      if (curM == mk && curD == null) return;
      ref.read(timemachineSelectedMonthKeyProvider.notifier).state = mk;
      ref.read(timemachineSelectedBizDateProvider.notifier).state = null;
    }

    void selectDay(String bd) {
      ref.read(timemachineSelectedMonthKeyProvider.notifier).state =
          bd.substring(0, 7);
      ref.read(timemachineSelectedBizDateProvider.notifier).state = bd;
    }

    final allowWrite = apiOn && !kEffectiveReadOnlyDataMode;

    return Scaffold(
      backgroundColor: AppTheme.shellBackground,
      floatingActionButton: allowWrite
          ? FloatingActionButton(
              onPressed: () => _showAddTimelineEntryDialog(context, ref),
              backgroundColor: _kTmGold,
              child: const Icon(Icons.add_rounded, color: Colors.black87),
            )
          : null,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ShellScreenHeader(
              onBack: () => context.pop(),
              icon: Icons.hourglass_top_rounded,
              title: '时光机',
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, c) {
                  final wide = c.maxWidth >= 720;
                  if (wide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          width: 158,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: _TimeMachineFilterBlock(
                                  totalCount: total,
                                  months: months,
                                  secondRowDays: secondRowDays,
                                  selectedMonthKey: selectedMonth,
                                  selectedBizDate: selectedDay,
                                  onSelectAll: selectAll,
                                  onSelectMonth: selectMonth,
                                  onSelectDay: selectDay,
                                  sidebarVerticalScroll: true,
                                ),
                              ),
                            ],
                          ),
                        ),
                        VerticalDivider(
                          width: 1,
                          thickness: 1,
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                        Expanded(
                          child: _FeedColumn(
                            summaryText: summaryText,
                            feedSections: feedSections,
                            loading: entriesLoading,
                            emptyHint: query.hasFilter
                                ? '暂无记录'
                                : '请选择月份或日期',
                          ),
                        ),
                      ],
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _TimeMachineFilterBlock(
                        totalCount: total,
                        months: months,
                        secondRowDays: secondRowDays,
                        selectedMonthKey: selectedMonth,
                        selectedBizDate: selectedDay,
                        onSelectAll: selectAll,
                        onSelectMonth: selectMonth,
                        onSelectDay: selectDay,
                        sidebarVerticalScroll: false,
                      ),
                      Divider(
                        height: 1,
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                      Expanded(
                        child: _FeedColumn(
                          summaryText: summaryText,
                          feedSections: feedSections,
                          loading: entriesLoading,
                          emptyHint: query.hasFilter
                              ? '暂无记录'
                              : '请选择月份或日期',
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeMachineFilterBlock extends StatelessWidget {
  const _TimeMachineFilterBlock({
    required this.totalCount,
    required this.months,
    required this.secondRowDays,
    required this.selectedMonthKey,
    required this.selectedBizDate,
    required this.onSelectAll,
    required this.onSelectMonth,
    required this.onSelectDay,
    required this.sidebarVerticalScroll,
  });

  final int totalCount;
  final List<TimemachineMonthChip> months;
  final List<TimemachineSidebarDay> secondRowDays;
  final String? selectedMonthKey;
  final String? selectedBizDate;
  final VoidCallback onSelectAll;
  final void Function(String monthKey) onSelectMonth;
  final void Function(String bizDate) onSelectDay;
  /// 宽屏侧栏内纵向列表，避免窄列里横向滑动手势难用（尤其横屏）
  final bool sidebarVerticalScroll;

  bool get _allSelected =>
      selectedMonthKey == null && selectedBizDate == null;

  @override
  Widget build(BuildContext context) {
    if (sidebarVerticalScroll) {
      return Scrollbar(
        thumbVisibility: true,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(4, 6, 6, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _tier1Strip(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: _AllButton(
                          totalCount: totalCount,
                          selected: _allSelected,
                          onTap: onSelectAll,
                        ),
                      ),
                    ),
                    ...months.map(
                      (m) => Padding(
                        padding: const EdgeInsets.fromLTRB(8, 0, 8, 6),
                        child: SizedBox(
                          width: double.infinity,
                          child: _DayTile(
                            tier: _TmFilterTier.month,
                            label: m.label,
                            count: m.entryCount,
                            selected: selectedMonthKey == m.monthKey &&
                                selectedBizDate == null,
                            vertical: true,
                            onTap: () => onSelectMonth(m.monthKey),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (selectedMonthKey != null) ...[
                const SizedBox(height: 10),
                _tier2Strip(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 8, 10, 4),
                        child: Text(
                          '选择日期',
                          style: TextStyle(
                            color: _kTmDayAccent.withValues(alpha: 0.75),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      ...secondRowDays.map(
                        (d) => Padding(
                          padding: const EdgeInsets.fromLTRB(8, 0, 8, 6),
                          child: SizedBox(
                            width: double.infinity,
                            child: _DayTile(
                              tier: _TmFilterTier.day,
                              label: d.label,
                              count: d.entryCount,
                              selected: selectedBizDate == d.bizDate,
                              vertical: true,
                              onTap: () => onSelectDay(d.bizDate),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _tier1Strip(
          child: SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _AllButton(
                    totalCount: totalCount,
                    selected: _allSelected,
                    onTap: onSelectAll,
                  ),
                ),
                ...months.map(
                  (m) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _DayTile(
                      tier: _TmFilterTier.month,
                      label: m.label,
                      count: m.entryCount,
                      selected: selectedMonthKey == m.monthKey &&
                          selectedBizDate == null,
                      vertical: false,
                      onTap: () => onSelectMonth(m.monthKey),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (selectedMonthKey != null) ...[
          const SizedBox(height: 8),
          _tier2Strip(
            child: SizedBox(
              height: 42,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                children: secondRowDays
                    .map(
                      (d) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _DayTile(
                          tier: _TmFilterTier.day,
                          label: d.label,
                          count: d.entryCount,
                          selected: selectedBizDate == d.bizDate,
                          vertical: false,
                          onTap: () => onSelectDay(d.bizDate),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _tier1Strip({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: _kTmRow1StripBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _kTmGold.withValues(alpha: 0.12),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 2),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }

  Widget _tier2Strip({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: _kTmRow2StripBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _kTmDayAccent.withValues(alpha: 0.22),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 2),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

class _AllButton extends StatelessWidget {
  const _AllButton({
    required this.totalCount,
    required this.selected,
    required this.onTap,
  });

  final int totalCount;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: _kTmCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? _kTmGold : Colors.white.withValues(alpha: 0.1),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '全部',
                style: TextStyle(
                  color: selected ? _kTmGold : Colors.white70,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: _kTmGold.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _kTmGold.withValues(alpha: 0.55),
                  ),
                ),
                child: Text(
                  '$totalCount',
                  style: const TextStyle(
                    color: _kTmGold,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DayTile extends StatelessWidget {
  const _DayTile({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
    this.tier = _TmFilterTier.month,
    this.vertical = true,
  });

  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;
  final _TmFilterTier tier;
  final bool vertical;

  Color get _accent =>
      tier == _TmFilterTier.month ? _kTmGold : _kTmDayAccent;

  Color get _cardBg =>
      tier == _TmFilterTier.month ? _kTmCard : _kTmDayCard;

  @override
  Widget build(BuildContext context) {
    final borderColor = selected
        ? _accent.withValues(alpha: 0.85)
        : Colors.white.withValues(alpha: tier == _TmFilterTier.day ? 0.1 : 0.08);
    final labelColor = selected
        ? Colors.white
        : Colors.white.withValues(alpha: 0.68);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor, width: selected ? 1.25 : 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  label,
                  maxLines: vertical ? 2 : 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: labelColor,
                    fontSize: tier == _TmFilterTier.day ? 11.5 : 12,
                    height: 1.2,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
              if (count > 1) ...[
                const SizedBox(width: 5),
                Container(
                  width: 19,
                  height: 19,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _accent.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _accent.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      color: _accent,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _FeedColumn extends StatelessWidget {
  const _FeedColumn({
    required this.summaryText,
    required this.feedSections,
    this.loading = false,
    this.emptyHint = '暂无记录',
  });

  final String summaryText;
  final List<TimemachineFeedSection> feedSections;
  final bool loading;
  final String emptyHint;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (feedSections.isEmpty) {
      return Center(
        child: Text(
          emptyHint,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.35)),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: _kTmGold,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                summaryText,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.55),
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        ...feedSections.expand((sec) {
          return [
            Padding(
              padding: const EdgeInsets.only(bottom: 10, top: 4),
              child: Text(
                sec.monthLabel,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.45),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ...sec.entries.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _EntryCard(entry: e),
              ),
            ),
          ];
        }),
      ],
    );
  }
}

class _EntryCard extends StatelessWidget {
  const _EntryCard({required this.entry});

  final TimemachineEntry entry;

  @override
  Widget build(BuildContext context) {
    final pill = timemachineCardPillLabel(entry.bizDate);
    return Container(
      decoration: BoxDecoration(
        color: _kTmCard,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(
            color: _kTmGold.withValues(alpha: 0.9),
            width: 3,
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _kTmGold.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _kTmGold.withValues(alpha: 0.55)),
                ),
                child: Text(
                  pill,
                  style: const TextStyle(
                    color: _kTmGold,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  entry.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            entry.body,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.78),
              fontSize: 14,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _showAddTimelineEntryDialog(BuildContext context, WidgetRef ref) async {
  final titleCtrl = TextEditingController();
  final contentCtrl = TextEditingController();
  final bizDate = formatBizDate(DateTime.now());
  await showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('新增时光机记录'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('业务日：$bizDate', style: const TextStyle(fontSize: 13)),
          const SizedBox(height: 12),
          TextField(
            controller: titleCtrl,
            decoration: const InputDecoration(labelText: '标题'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: contentCtrl,
            maxLines: 4,
            decoration: const InputDecoration(labelText: '内容'),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
        TextButton(
          onPressed: () async {
            try {
              await syncTimelineEntryRemote(
                ref,
                bizDate: bizDate,
                title: titleCtrl.text,
                content: contentCtrl.text,
              );
              if (ctx.mounted) Navigator.pop(ctx);
            } on FamilyApiException catch (e) {
              if (ctx.mounted) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  SnackBar(content: Text(e.message)),
                );
              }
            }
          },
          child: const Text('保存'),
        ),
      ],
    ),
  );
  titleCtrl.dispose();
  contentCtrl.dispose();
}
