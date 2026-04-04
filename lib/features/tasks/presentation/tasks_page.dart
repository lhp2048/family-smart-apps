import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/mock/mock_data_notifier.dart';
import '../../../core/widgets/app_empty.dart';
import '../../../shared/models/member_entity.dart';
import '../../../shared/providers/task_ui_providers.dart';
import '../data/models/task_date_entity.dart';
import '../data/models/task_item_entity.dart';

const Color _kHomeworkBg = Color(0xFF151525);
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

String _mainDateTitle(String bizDate, String weekdayCn) {
  final p = bizDate.split('-');
  if (p.length != 3) return '$bizDate $weekdayCn';
  final m = p[1];
  final d = p[2];
  return '$m月$d日 $weekdayCn';
}

Map<String, dynamic> _decodeMap(String json) {
  try {
    return Map<String, dynamic>.from(jsonDecode(json) as Map<dynamic, dynamic>);
  } catch (_) {
    return {};
  }
}

class TasksPage extends ConsumerWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedTaskBizDateProvider);
    final dates = ref.watch(taskDatesProvider);
    final children = ref.watch(homeworkChildrenProvider);
    final items = ref.watch(flatHomeworkItemsForDateProvider(selected));
    final selDates = dates.where((d) => d.bizDate == selected);
    final weekday = selDates.isEmpty ? '' : selDates.first.weekday;

    return Scaffold(
      backgroundColor: _kHomeworkBg,
      body: SafeArea(
        child: Column(
          children: [
            _HomeworkAppHeader(onBack: () => context.pop()),
            Expanded(
              child: dates.isEmpty
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
                                        .read(selectedTaskBizDateProvider.notifier)
                                        .state = bd;
                                  },
                                ),
                              ),
                              VerticalDivider(
                                width: 1,
                                thickness: 1,
                                color: Colors.white.withValues(alpha: 0.08),
                              ),
                              Expanded(
                                child: _HomeworkMainPanel(
                                  dateTitle: _mainDateTitle(selected, weekday),
                                  items: items,
                                  children: children,
                                  selectedBizDate: selected,
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
                              child: _HistorySidebar(
                                dates: dates,
                                selectedBizDate: selected,
                                onSelect: (bd) {
                                  ref
                                      .read(selectedTaskBizDateProvider.notifier)
                                      .state = bd;
                                },
                                horizontal: true,
                              ),
                            ),
                            Divider(
                              height: 1,
                              color: Colors.white.withValues(alpha: 0.08),
                            ),
                            Expanded(
                              child: _HomeworkMainPanel(
                                dateTitle: _mainDateTitle(selected, weekday),
                                items: items,
                                children: children,
                                selectedBizDate: selected,
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

class _HomeworkAppHeader extends StatelessWidget {
  const _HomeworkAppHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(4, 8, 16, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2D2654),
            Color(0xFF1A1A2E),
          ],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.layers_rounded,
                color: Colors.white.withValues(alpha: 0.95),
                size: 32,
              ),
              const SizedBox(height: 8),
              const Text(
                '作业完成情况',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '全部历史记录',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          Positioned(
            left: 0,
            top: 0,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              color: Colors.white70,
              onPressed: onBack,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistorySidebar extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final label = Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Text(
        '历史记录',
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.45),
          fontSize: 12,
        ),
      ),
    );

    Widget tile(int index) {
      final d = dates[index];
      final bd = d.bizDate;
      final wd = d.weekday;
      final sel = bd == selectedBizDate;
      final allDone = ref.watch(homeworkDayAllDoneProvider(bd));

      return Padding(
        padding: horizontal
            ? const EdgeInsets.only(left: 10, right: 4, top: 8, bottom: 8)
            : const EdgeInsets.fromLTRB(10, 0, 10, 8),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => onSelect(bd),
            borderRadius: BorderRadius.circular(14),
            child: Ink(
              decoration: BoxDecoration(
                color: sel
                    ? _kAccentPurple
                    : const Color(0xFF2C2C3E),
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
                        : (allDone
                            ? const Color(0xFFFFD54F)
                            : Colors.white38),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (horizontal) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          label,
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: dates.length,
              itemBuilder: (context, i) => tile(i),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        label,
        Expanded(
          child: ListView.builder(
            itemCount: dates.length,
            itemBuilder: (context, i) => tile(i),
          ),
        ),
      ],
    );
  }
}

class _HomeworkMainPanel extends StatelessWidget {
  const _HomeworkMainPanel({
    required this.dateTitle,
    required this.items,
    required this.children,
    required this.selectedBizDate,
  });

  final String dateTitle;
  final List<TaskItemEntity> items;
  final List<MemberEntity> children;
  final String selectedBizDate;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) {
      return const AppEmpty(message: '暂无孩子成员');
    }
    if (items.isEmpty) {
      return const AppEmpty(message: '该日暂无作业项');
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        Text(
          dateTitle,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 18),
        ...children.map(
          (m) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _MemberHomeworkCard(
              member: m,
              items: items,
              bizDate: selectedBizDate,
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
  });

  final MemberEntity member;
  final List<TaskItemEntity> items;
  final String bizDate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var done = 0;
    for (final item in items) {
      final st = _decodeMap(item.statusByMemberJson);
      if (st[member.memberCode] == true) done++;
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
              valueColor:
                  const AlwaysStoppedAnimation<Color>(_kProgressFill),
            ),
          ),
          const SizedBox(height: 16),
          _TableHeaderRow(),
          const SizedBox(height: 8),
          ...items.map(
            (item) => _TaskDataRow(
              item: item,
              memberCode: member.memberCode,
              onToggle: () {
                ref.read(mockDataNotifierProvider.notifier).toggleMemberStatus(
                      bizDate: bizDate,
                      groupCode: item.groupCode,
                      taskCode: item.taskCode,
                      memberCode: member.memberCode,
                    );
              },
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
    required this.memberCode,
    required this.onToggle,
  });

  final TaskItemEntity item;
  final String memberCode;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final st = _decodeMap(item.statusByMemberJson);
    final at = _decodeMap(item.completedAtByMemberJson);
    final done = st[memberCode] == true;
    final timeStr = (at[memberCode] as String?) ?? '';

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
              child: InkWell(
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
