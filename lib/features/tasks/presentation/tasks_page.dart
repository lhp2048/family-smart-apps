import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_product_flags.dart';
import '../../../core/storage/task_selected_biz_date_prefs.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/shell_screen_header.dart';
import '../../../core/mock/mock_data_notifier.dart';
import '../../../core/widgets/app_empty.dart';
import '../../dashboard/data/family_api_client.dart';
import '../../dashboard/providers/dashboard_remote_providers.dart';
import '../../dashboard/providers/family_api_base_url_provider.dart';
import '../../dashboard/providers/family_api_write_refresh.dart';
import '../../../shared/models/member_entity.dart';
import '../../../shared/providers/task_ui_providers.dart';
import '../data/homework_remote_write.dart';
import '../data/homework_items_bundle.dart';
import '../data/models/task_date_entity.dart';
import '../data/models/task_item_entity.dart';
import '../data/task_member_status.dart';

const Color _kAccentPurple = Color(0xFF7C4DFF);
const Color _kCardBg = Color(0xFF252536);
const Color _kProgressFill = Color(0xFFB388FF);

String _sidebarDateShort(String bizDate) {
  final p = bizDate.split('-');
  if (p.length == 3) {
    return '${p[1]}-${p[2]}';
  }
  return bizDate;
}

Map<String, dynamic> _decodeMap(String json) {
  try {
    return Map<String, dynamic>.from(
      jsonDecode(json) as Map<dynamic, dynamic>,
    );
  } catch (_) {
    return {};
  }
}

Future<void> _toggleHomeworkItem(
  WidgetRef ref,
  BuildContext context, {
  required String bizDate,
  required MemberEntity member,
  required List<TaskItemEntity> items,
  required TaskItemEntity item,
  required bool apiConfigured,
}) async {
  if (!apiConfigured) {
    ref.read(mockDataNotifierProvider.notifier).toggleMemberStatus(
          bizDate: bizDate,
          groupCode: item.groupCode,
          taskCode: item.taskCode,
          memberCode: member.memberCode,
        );
    return;
  }

  final messenger = ScaffoldMessenger.of(context);
  try {
    final client = ref.read(familyApiClientProvider);
    await syncHomeworkMemberDay(
      client: client,
      bizDate: bizDate,
      member: member,
      items: items,
      toggleTaskCode: item.taskCode,
      toggleGroupCode: item.groupCode,
    );
    ref.read(taskRemoteRefreshProvider.notifier).state++;
    refreshAfterFamilyApiWrite(ref);
  } on FamilyApiException catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(e.message)));
  } catch (e) {
    messenger.showSnackBar(SnackBar(content: Text('同步失败：$e')));
  }
}

/// 有持久化且仍在列表中 → 用持久化；否则用「最近一天」[dates.first]（列表已按 bizDate 降序）。
Future<void> _reconcileTaskBizDateSelection(
  WidgetRef ref,
  List<TaskDateEntity> dates,
) async {
  if (dates.isEmpty) return;
  final mostRecent = dates.first.bizDate;
  final persisted = await TaskSelectedBizDatePrefs.read();
  final String resolved;
  if (persisted != null && dates.any((d) => d.bizDate == persisted)) {
    resolved = persisted;
  } else {
    resolved = mostRecent;
  }
  final cur = ref.read(selectedTaskBizDateProvider);
  if (cur != resolved) {
    ref.read(selectedTaskBizDateProvider.notifier).state = resolved;
  }
}

class TasksPage extends ConsumerWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedTaskBizDateProvider);
    final datesAsync = ref.watch(taskDatesAsyncProvider);

    ref.listen<String>(selectedTaskBizDateProvider, (prev, next) {
      if (next.isEmpty) return;
      unawaited(TaskSelectedBizDatePrefs.write(next));
    });

    ref.listen<AsyncValue<List<TaskDateEntity>>>(taskDatesAsyncProvider, (
      prev,
      next,
    ) {
      next.whenData((dates) {
        if (dates.isEmpty) return;
        unawaited(_reconcileTaskBizDateSelection(ref, dates));
      });
    });

    return Scaffold(
      backgroundColor: AppTheme.shellBackground,
      body: SafeArea(
        child: Column(
          children: [
            ShellScreenHeader(
              onBack: () => context.pop(),
              icon: Icons.layers_rounded,
              title: '作业进度',
            ),
            Expanded(
              child: datesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => AppEmpty(message: '作业数据加载失败：$e'),
                data: (dates) => dates.isEmpty
                    ? const AppEmpty(message: '暂无作业日期数据')
                    : LayoutBuilder(
                        builder: (context, c) {
                          final wide = c.maxWidth >= 720;
                          if (wide) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                SizedBox(
                                  width: 128,
                                  child: _HistorySidebar(
                                    dates: dates,
                                    selectedBizDate: selected,
                                    onSelect: (bd) {
                                      ref
                                              .read(
                                                selectedTaskBizDateProvider
                                                    .notifier,
                                              )
                                              .state =
                                          bd;
                                    },
                                  ),
                                ),
                                VerticalDivider(
                                  width: 1,
                                  thickness: 1,
                                  color: Colors.white.withValues(alpha: 0.08),
                                ),
                                Expanded(
                                  child: _HomeworkDateSwipePanel(dates: dates),
                                ),
                              ],
                            );
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SizedBox(
                                height: 80,
                                child: _HistorySidebar(
                                  dates: dates,
                                  selectedBizDate: selected,
                                  onSelect: (bd) {
                                    ref
                                            .read(
                                              selectedTaskBizDateProvider
                                                  .notifier,
                                            )
                                            .state =
                                        bd;
                                  },
                                  horizontal: true,
                                ),
                              ),
                              Divider(
                                height: 1,
                                color: Colors.white.withValues(alpha: 0.08),
                              ),
                              Expanded(
                                child: _HomeworkDateSwipePanel(dates: dates),
                              ),
                            ],
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeworkDateSwipePanel extends ConsumerStatefulWidget {
  const _HomeworkDateSwipePanel({required this.dates});

  final List<TaskDateEntity> dates;

  @override
  ConsumerState<_HomeworkDateSwipePanel> createState() =>
      _HomeworkDateSwipePanelState();
}

class _HomeworkDateSwipePanelState
    extends ConsumerState<_HomeworkDateSwipePanel> {
  late final PageController _pageController;

  int _indexForSelected() {
    final sel = ref.read(selectedTaskBizDateProvider);
    final i = widget.dates.indexWhere((d) => d.bizDate == sel);
    return i >= 0 ? i : 0;
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _indexForSelected());
  }

  @override
  void didUpdateWidget(covariant _HomeworkDateSwipePanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dates.length != widget.dates.length &&
        _pageController.hasClients) {
      final i = _indexForSelected().clamp(0, widget.dates.length - 1);
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
    final dates = widget.dates;

    ref.listen<String>(selectedTaskBizDateProvider, (previous, next) {
      final i = dates.indexWhere((d) => d.bizDate == next);
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

    final childrenAsync = ref.watch(homeworkChildrenAsyncProvider);
    final apiConfigured = ref.watch(familyApiIsConfiguredProvider);

    return PageView.builder(
      controller: _pageController,
      itemCount: dates.length,
      onPageChanged: (i) {
        final bd = dates[i].bizDate;
        ref.read(selectedTaskBizDateProvider.notifier).state = bd;
      },
      itemBuilder: (context, i) {
        final d = dates[i];
        final bundleAsync = ref.watch(
          homeworkItemsBundleForDateAsyncProvider(d.bizDate),
        );
        return bundleAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => AppEmpty(message: '加载失败：$e'),
          data: (bundle) => childrenAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => AppEmpty(message: '成员加载失败：$e'),
            data: (children) => _HomeworkMainPanel(
              bundle: bundle,
              children: children,
              selectedBizDate: d.bizDate,
              readOnly: kEffectiveReadOnlyDataMode,
              apiConfigured: apiConfigured,
            ),
          ),
        );
      },
    );
  }
}

class _HistorySidebar extends ConsumerStatefulWidget {
  const _HistorySidebar({
    required this.dates,
    required this.selectedBizDate,
    required this.onSelect,
    this.horizontal = false,
  });

  final List<TaskDateEntity> dates;
  final String selectedBizDate;
  final void Function(String bizDate) onSelect;
  final bool horizontal;

  @override
  ConsumerState<_HistorySidebar> createState() => _HistorySidebarState();
}

class _HistorySidebarState extends ConsumerState<_HistorySidebar> {
  final GlobalKey _selectedVisibleKey = GlobalKey(
    debugLabel: 'taskDateSelected',
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _scrollSelectedIntoView(),
    );
  }

  @override
  void didUpdateWidget(covariant _HistorySidebar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedBizDate != widget.selectedBizDate) {
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
    final dates = widget.dates;
    final horizontal = widget.horizontal;

    Widget tile(int index) {
      final d = dates[index];
      final bd = d.bizDate;
      final wd = d.weekday;
      final sel = bd == widget.selectedBizDate;
      final allDone = ref.watch(homeworkDayAllDoneProvider(bd));

      return Padding(
        key: sel ? _selectedVisibleKey : ValueKey<String>('taskDate_$bd'),
        padding: horizontal
            ? const EdgeInsets.only(left: 10, right: 4, top: 8, bottom: 8)
            : const EdgeInsets.fromLTRB(10, 0, 10, 8),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => widget.onSelect(bd),
            borderRadius: BorderRadius.circular(14),
            child: Ink(
              decoration: BoxDecoration(
                color: sel ? _kAccentPurple : const Color(0xFF2C2C3E),
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                mainAxisSize: horizontal ? MainAxisSize.min : MainAxisSize.max,
                children: [
                  if (horizontal)
                    Text(
                      '${_sidebarDateShort(bd)} $wd',
                      style: TextStyle(
                        color: sel
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.85),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  else
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _sidebarDateShort(bd),
                            style: TextStyle(
                              color: sel
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.88),
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            wd,
                            style: TextStyle(
                              color: sel
                                  ? Colors.white70
                                  : Colors.white.withValues(alpha: 0.45),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (!horizontal) const SizedBox(width: 6),
                  Icon(
                    sel
                        ? Icons.description_outlined
                        : (allDone
                              ? Icons.emoji_events_rounded
                              : Icons.description_outlined),
                    size: 18,
                    color: sel
                        ? Colors.white
                        : (allDone ? const Color(0xFFFFD54F) : Colors.white38),
                  ),
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
        itemCount: dates.length,
        itemBuilder: (context, i) => tile(i),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
      itemCount: dates.length,
      itemBuilder: (context, i) => tile(i),
    );
  }
}

class _HomeworkMainPanel extends StatelessWidget {
  const _HomeworkMainPanel({
    required this.bundle,
    required this.children,
    required this.selectedBizDate,
    required this.readOnly,
    required this.apiConfigured,
  });

  final HomeworkItemsBundle bundle;
  final List<MemberEntity> children;
  final String selectedBizDate;
  final bool readOnly;
  final bool apiConfigured;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) {
      return const AppEmpty(message: '暂无孩子成员');
    }
    if (!bundle.hasAnyItems) {
      return const AppEmpty(message: '该日暂无作业项');
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        ...children.map(
          (m) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _MemberHomeworkCard(
              member: m,
              items: bundle.itemsForMemberCode(m.memberCode),
              bizDate: selectedBizDate,
              readOnly: readOnly,
              apiConfigured: apiConfigured,
            ),
          ),
        ),
      ],
    );
  }
}

class _MemberHomeworkCard extends ConsumerWidget {
  const _MemberHomeworkCard({
    required this.member,
    required this.items,
    required this.bizDate,
    required this.readOnly,
    required this.apiConfigured,
  });

  final MemberEntity member;
  final List<TaskItemEntity> items;
  final String bizDate;
  final bool readOnly;
  final bool apiConfigured;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var done = 0;
    for (final item in items) {
      final st = _decodeMap(item.statusByMemberJson);
      if (memberTaskDoneForMember(member, st)) done++;
    }
    final total = items.length;
    final ratio = total == 0 ? 0.0 : done / total;

    return Container(
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white.withValues(alpha: 0.12),
                child: Text(
                  member.avatar?.isNotEmpty == true ? member.avatar! : '·',
                  style: const TextStyle(fontSize: 22),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  member.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _kAccentPurple.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _kProgressFill.withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  '$done/$total 完成',
                  style: const TextStyle(
                    color: _kProgressFill,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: ratio.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.08),
              valueColor: const AlwaysStoppedAnimation<Color>(_kProgressFill),
            ),
          ),
          const SizedBox(height: 16),
          _TableHeaderRow(),
          const SizedBox(height: 8),
          ...items.map(
            (item) => _TaskDataRow(
              item: item,
              member: member,
              onToggle: readOnly
                  ? null
                  : () => _toggleHomeworkItem(
                        ref,
                        context,
                        bizDate: bizDate,
                        member: member,
                        items: items,
                        item: item,
                        apiConfigured: apiConfigured,
                      ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TableHeaderRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: Text(
            '作业项目',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.45),
              fontSize: 12,
            ),
          ),
        ),
        SizedBox(
          width: 52,
          child: Text(
            '状态',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.45),
              fontSize: 12,
            ),
          ),
        ),
        SizedBox(
          width: 52,
          child: Text(
            '时间',
            textAlign: TextAlign.end,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.45),
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

class _TaskDataRow extends StatelessWidget {
  const _TaskDataRow({
    required this.item,
    required this.member,
    required this.onToggle,
  });

  final TaskItemEntity item;
  final MemberEntity member;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    final st = _decodeMap(item.statusByMemberJson);
    final at = _decodeMap(item.completedAtByMemberJson);
    final done = memberTaskDoneForMember(member, st);
    final timeStr = memberTaskTimeDisplayForMember(member, at);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Text(
              item.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                height: 1.35,
              ),
            ),
          ),
          SizedBox(
            width: 52,
            child: Center(
              child: onToggle == null
                  ? Opacity(
                      opacity: 0.85,
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: done
                            ? Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4CAF50),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Icon(
                                  Icons.check,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              )
                            : Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: Colors.white54,
                                    width: 2,
                                  ),
                                ),
                              ),
                      ),
                    )
                  : InkWell(
                      onTap: onToggle,
                      borderRadius: BorderRadius.circular(6),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: done
                            ? Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4CAF50),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Icon(
                                  Icons.check,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              )
                            : Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: Colors.white54,
                                    width: 2,
                                  ),
                                ),
                              ),
                      ),
                    ),
            ),
          ),
          SizedBox(
            width: 52,
            child: Text(
              timeStr,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
