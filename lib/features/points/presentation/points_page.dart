import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/shell_screen_header.dart';
import '../../../shared/models/member_entity.dart';
import '../../../shared/providers/points_ui_providers.dart';
import '../../../shared/providers/task_ui_providers.dart';
import '../data/points_prototype_models.dart';

const Color _kGold = Color(0xFFE6C358);
const Color _kGreenPoints = Color(0xFF69F0AE);
const Color _kPinkBadge = Color(0xFFFF8BC4);
const Color _kCardBg = Color(0xFF252536);

class PointsPage extends ConsumerWidget {
  const PointsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cyclesAsync = ref.watch(pointsWeekCyclesAsyncProvider);
    final rulesAsync = ref.watch(pointsRulesAsyncProvider);
    final selectedId = ref.watch(selectedPointsWeekIdProvider);
    final childrenAsync = ref.watch(homeworkChildrenAsyncProvider);

    ref.listen(pointsWeekCyclesAsyncProvider, (prev, next) {
      next.whenData((cycles) {
        if (cycles.isEmpty) return;
        final sel = ref.read(selectedPointsWeekIdProvider);
        final ok = cycles.any((c) => c.id == sel);
        if (!ok) {
          PointsWeekCycle pick;
          try {
            pick = cycles.firstWhere((c) => c.isCurrentWeek);
          } catch (_) {
            pick = cycles.first;
          }
          ref.read(selectedPointsWeekIdProvider.notifier).state = pick.id;
        }
      });
    });

    Widget body() {
      return childrenAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(
            '成员加载失败：$e',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
        ),
        data: (children) => cyclesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                '积分榜加载失败：$e',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                ),
              ),
            ),
          ),
          data: (cycles) => rulesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  '积分规则加载失败：$e',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
            data: (rules) {
              if (cycles.isEmpty) {
                return Center(
                  child: Text(
                    '暂无积分数据',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                );
              }
              return LayoutBuilder(
                builder: (context, c) {
                  final wide = c.maxWidth >= 720;
                  if (wide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          width: 148,
                          child: _WeekSidebar(
                            cycles: cycles,
                            selectedId: selectedId,
                            children: children,
                            onSelect: (id) {
                              ref
                                  .read(selectedPointsWeekIdProvider.notifier)
                                  .state = id;
                            },
                          ),
                        ),
                        VerticalDivider(
                          width: 1,
                          thickness: 1,
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                        Expanded(
                          child: _PointsWeekSwipePanel(
                            cycles: cycles,
                            rules: rules,
                            children: children,
                          ),
                        ),
                      ],
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height: 96,
                        child: _WeekSidebar(
                          cycles: cycles,
                          selectedId: selectedId,
                          children: children,
                          horizontal: true,
                          onSelect: (id) {
                            ref
                                .read(selectedPointsWeekIdProvider.notifier)
                                .state = id;
                          },
                        ),
                      ),
                      Divider(
                        height: 1,
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                      Expanded(
                        child: _PointsWeekSwipePanel(
                          cycles: cycles,
                          rules: rules,
                          children: children,
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.shellBackground,
      body: SafeArea(
        child: Column(
          children: [
            ShellScreenHeader(
              onBack: () => context.pop(),
              icon: Icons.emoji_events_rounded,
              title: '积分榜',
            ),
            Expanded(child: body()),
          ],
        ),
      ),
    );
  }
}

class _PointsWeekSwipePanel extends ConsumerStatefulWidget {
  const _PointsWeekSwipePanel({
    required this.cycles,
    required this.rules,
    required this.children,
  });

  final List<PointsWeekCycle> cycles;
  final List<PointsRuleLine> rules;
  final List<MemberEntity> children;

  @override
  ConsumerState<_PointsWeekSwipePanel> createState() =>
      _PointsWeekSwipePanelState();
}

class _PointsWeekSwipePanelState extends ConsumerState<_PointsWeekSwipePanel> {
  late final PageController _pageController;

  int _indexForSelected() {
    final id = ref.read(selectedPointsWeekIdProvider);
    final i = widget.cycles.indexWhere((c) => c.id == id);
    return i >= 0 ? i : 0;
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _indexForSelected());
  }

  @override
  void didUpdateWidget(covariant _PointsWeekSwipePanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cycles.length != widget.cycles.length &&
        _pageController.hasClients) {
      final i = _indexForSelected().clamp(0, widget.cycles.length - 1);
      _pageController.jumpToPage(i);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cycles = widget.cycles;

    ref.listen<String>(selectedPointsWeekIdProvider, (previous, next) {
      final i = cycles.indexWhere((c) => c.id == next);
      if (i < 0 || !_pageController.hasClients) return;
      final page = _pageController.page;
      if (page == null) return;
      if (page.round() != i) {
        _pageController.animateToPage(
          i,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
        );
      }
    });

    return PageView.builder(
      controller: _pageController,
      itemCount: cycles.length,
      onPageChanged: (i) {
        ref.read(selectedPointsWeekIdProvider.notifier).state = cycles[i].id;
      },
      itemBuilder: (context, i) {
        return _PointsMainContent(
          week: cycles[i],
          rules: widget.rules,
          children: widget.children,
        );
      },
    );
  }
}

class _WeekSidebar extends ConsumerStatefulWidget {
  const _WeekSidebar({
    required this.cycles,
    required this.selectedId,
    required this.children,
    required this.onSelect,
    this.horizontal = false,
  });

  final List<PointsWeekCycle> cycles;
  final String selectedId;
  final List<MemberEntity> children;
  final void Function(String id) onSelect;
  final bool horizontal;

  @override
  ConsumerState<_WeekSidebar> createState() => _WeekSidebarState();
}

class _WeekSidebarState extends ConsumerState<_WeekSidebar> {
  final GlobalKey _selectedVisibleKey = GlobalKey(debugLabel: 'pointsWeekSelected');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollSelectedIntoView());
  }

  @override
  void didUpdateWidget(covariant _WeekSidebar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedId != widget.selectedId) {
      _scrollSelectedIntoView();
    }
  }

  void _scrollSelectedIntoView() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final ctx = _selectedVisibleKey.currentContext;
      if (ctx == null) return;
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        alignment: widget.horizontal ? 0.5 : 0.25,
        alignmentPolicy: ScrollPositionAlignmentPolicy.explicit,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final cycles = widget.cycles;
    final horizontal = widget.horizontal;

    Widget miniScores(PointsWeekCycle c) {
      final ch = widget.children;
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < ch.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            Icon(Icons.monetization_on_rounded,
                size: 14, color: Colors.amber.shade300),
            const SizedBox(width: 2),
            Text(
              '${c.totalsByMemberCode[ch[i].memberCode] ?? 0}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      );
    }

    Widget tile(int index) {
      final c = cycles[index];
      final sel = c.id == widget.selectedId;
      return Padding(
        key: sel ? _selectedVisibleKey : ValueKey<String>('pointsWeek_${c.id}'),
        padding: horizontal
            ? const EdgeInsets.only(left: 10, right: 4, top: 6, bottom: 8)
            : const EdgeInsets.fromLTRB(10, 0, 10, 8),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => widget.onSelect(c.id),
            borderRadius: BorderRadius.circular(14),
            child: Ink(
              decoration: BoxDecoration(
                color: sel ? const Color(0xFF3D3566) : _kCardBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: sel
                      ? _kPinkBadge.withValues(alpha: 0.5)
                      : Colors.white.withValues(alpha: 0.06),
                ),
              ),
              padding: EdgeInsets.fromLTRB(
                10,
                horizontal ? 8 : 10,
                10,
                horizontal ? 8 : 10,
              ),
              child: horizontal
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  c.rangeShort,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (c.isCurrentWeek) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: _kPinkBadge.withValues(alpha: 0.35),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      '本周',
                                      style: TextStyle(
                                        color: _kPinkBadge,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            miniScores(c),
                          ],
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                c.rangeShort,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (c.isCurrentWeek)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _kPinkBadge.withValues(alpha: 0.35),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  '本周',
                                  style: TextStyle(
                                    color: _kPinkBadge,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        miniScores(c),
                      ],
                    ),
            ),
          ),
        ),
      );
    }

    if (horizontal) {
      return ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        itemCount: cycles.length,
        itemBuilder: (context, i) => tile(i),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
      itemCount: cycles.length,
      itemBuilder: (context, i) => tile(i),
    );
  }
}

class _PointsMainContent extends StatelessWidget {
  const _PointsMainContent({
    required this.week,
    required this.rules,
    required this.children,
  });

  final PointsWeekCycle week;
  final List<PointsRuleLine> rules;
  final List<MemberEntity> children;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                week.rangeTitleLong,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (week.isCurrentWeek)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _kPinkBadge.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '本周',
                  style: TextStyle(
                    color: _kPinkBadge,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        _WeeklySummaryCard(week: week, children: children),
        const SizedBox(height: 22),
        Text(
          '积分明细',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.85),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        if (week.dailyLogs.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                '该周期暂无流水记录',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 14,
                ),
              ),
            ),
          )
        else
          ...week.dailyLogs.map(
            (g) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _DayLogCard(group: g, children: children),
            ),
          ),
        const SizedBox(height: 24),
        _RulesCard(rules: rules),
      ],
    );
  }
}

class _RulesCard extends StatelessWidget {
  const _RulesCard({required this.rules});

  final List<PointsRuleLine> rules;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _kGold.withValues(alpha: 0.65), width: 1.5),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.track_changes_rounded, color: _kGold, size: 22),
              const SizedBox(width: 8),
              Text(
                '积分规则',
                style: TextStyle(
                  color: _kGold,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...rules.map(
            (r) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Icon(
                      r.isPositive
                          ? Icons.check_box_rounded
                          : Icons.change_history_rounded,
                      size: 20,
                      color: r.isPositive
                          ? const Color(0xFF66BB6A)
                          : const Color(0xFFFFD54F),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      r.description,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.88),
                        fontSize: 14,
                        height: 1.35,
                      ),
                    ),
                  ),
                  Text(
                    '${r.isPositive ? '+' : '-'}${r.value} 分',
                    style: TextStyle(
                      color: r.isPositive ? _kGreenPoints : const Color(0xFFFFD54F),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklySummaryCard extends StatelessWidget {
  const _WeeklySummaryCard({
    required this.week,
    required this.children,
  });

  final PointsWeekCycle week;
  final List<MemberEntity> children;

  @override
  Widget build(BuildContext context) {
    final title = week.isCurrentWeek ? '本周总积分' : '该周总积分';
    final codesFromWeek = week.totalsByMemberCode.keys.toList()..sort();
    final ordered = <MemberEntity>[];
    final seen = <String>{};
    for (final c in children) {
      if (week.totalsByMemberCode.containsKey(c.memberCode)) {
        final dn = week.displayNameByMemberCode[c.memberCode];
        if (dn != null && dn.isNotEmpty && dn != c.name) {
          ordered.add(
            MemberEntity()
              ..memberCode = c.memberCode
              ..name = dn
              ..avatar = c.avatar
              ..role = c.role
              ..status = c.status
              ..createdAt = c.createdAt
              ..updatedAt = c.updatedAt,
          );
        } else {
          ordered.add(c);
        }
        seen.add(c.memberCode);
      }
    }
    final now = DateTime.now();
    for (final code in codesFromWeek) {
      if (seen.contains(code)) continue;
      final label = week.displayNameByMemberCode[code];
      ordered.add(
        MemberEntity()
          ..memberCode = code
          ..name = (label != null && label.isNotEmpty) ? label : code
          ..role = 'child'
          ..status = 'active'
          ..createdAt = now
          ..updatedAt = now,
      );
    }
    if (ordered.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: _kCardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
        child: Text(
          '本周暂无成员汇总',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.45),
            fontSize: 14,
          ),
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '🏆 $title',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < ordered.length; i++) ...[
                if (i > 0)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    width: 1,
                    height: 100,
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                Expanded(
                  child: _ChildWeekColumn(
                    member: ordered[i],
                    total: week.totalsByMemberCode[ordered[i].memberCode] ?? 0,
                    net: week.netGainByMemberCode[ordered[i].memberCode] ?? 0,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _ChildWeekColumn extends StatelessWidget {
  const _ChildWeekColumn({
    required this.member,
    required this.total,
    required this.net,
  });

  final MemberEntity member;
  final int total;
  final int net;

  @override
  Widget build(BuildContext context) {
    final netStr = net >= 0 ? '+$net 分' : '$net 分';
    return Column(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: Colors.white.withValues(alpha: 0.12),
          child: Text(
            member.avatar?.isNotEmpty == true ? member.avatar! : '·',
            style: const TextStyle(fontSize: 24),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          member.name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '$total',
          style: const TextStyle(
            color: _kGreenPoints,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          netStr,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.45),
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _DayLogCard extends StatelessWidget {
  const _DayLogCard({
    required this.group,
    required this.children,
  });

  final PointsDayLogGroup group;
  final List<MemberEntity> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                '${group.dayKey} ${group.weekdayLabel}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              ...children.expand((m) {
                final d = group.dayDeltaByMemberCode[m.memberCode] ?? 0;
                final label =
                    d > 0 ? '+$d' : (d == 0 ? '+0' : '$d');
                return [
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          m.name,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.45),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          label,
                          style: TextStyle(
                            color: d >= 0 ? _kGreenPoints : Colors.redAccent,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ];
              }),
            ],
          ),
          const SizedBox(height: 10),
          _LogTableHeader(),
          const SizedBox(height: 6),
          ...group.rows.map((r) => _LogTableRow(row: r)),
        ],
      ),
    );
  }
}

class _LogTableHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    TextStyle th() => TextStyle(
          color: Colors.white.withValues(alpha: 0.4),
          fontSize: 11,
          fontWeight: FontWeight.w600,
        );
    return Row(
      children: [
        SizedBox(width: 48, child: Text('时间', style: th())),
        SizedBox(width: 56, child: Text('人员', style: th())),
        Expanded(
          flex: 3,
          child: Text('项目', style: th()),
        ),
        SizedBox(
          width: 44,
          child: Text('积分', textAlign: TextAlign.end, style: th()),
        ),
        SizedBox(width: 6),
        Expanded(
          flex: 2,
          child: Text('备注', style: th()),
        ),
      ],
    );
  }
}

class _LogTableRow extends StatelessWidget {
  const _LogTableRow({required this.row});

  final PointsLogRow row;

  @override
  Widget build(BuildContext context) {
    final pos = row.pointsDelta >= 0;
    final pts = pos ? '+${row.pointsDelta}' : '${row.pointsDelta}';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 48,
            child: Text(
              row.time,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.75),
                fontSize: 12,
              ),
            ),
          ),
          SizedBox(
            width: 56,
            child: Text(
              row.person,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              row.item,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          SizedBox(
            width: 44,
            child: Text(
              pts,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: pos ? _kGreenPoints : Colors.redAccent,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            flex: 2,
            child: Text(
              row.remark,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.45),
                fontSize: 11,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
