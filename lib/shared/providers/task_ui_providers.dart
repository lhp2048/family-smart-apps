import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/mock/mock_data_notifier.dart';
import '../../core/utils/biz_date.dart';
import '../../features/tasks/data/models/task_date_entity.dart';
import '../../features/tasks/data/models/task_group_entity.dart';
import '../../features/tasks/data/models/task_item_entity.dart';
import '../models/member_entity.dart';

final taskDatesProvider = Provider<List<TaskDateEntity>>((ref) {
  return ref.watch(mockDataNotifierProvider).taskDates;
});

final taskGroupsForDateProvider =
    Provider.family<List<TaskGroupEntity>, String>((ref, bizDate) {
  return ref.watch(mockDataNotifierProvider).taskGroupsFor(bizDate);
});

/// 参数为 [taskGroupKey]：`bizDate|groupCode`
final taskItemsForGroupProvider =
    Provider.family<List<TaskItemEntity>, String>((ref, bizDateGroupKey) {
  final i = bizDateGroupKey.indexOf('|');
  final bizDate = bizDateGroupKey.substring(0, i);
  final groupCode = bizDateGroupKey.substring(i + 1);
  return ref.watch(mockDataNotifierProvider).taskItemsFor(bizDate, groupCode);
});

/// 作业完成情况页：仅孩子成员（曦曦、川川等）
final homeworkChildrenProvider = Provider<List<MemberEntity>>((ref) {
  final list = ref
      .watch(mockDataNotifierProvider)
      .members
      .where((m) => m.role == 'child')
      .toList();
  list.sort((a, b) => a.memberCode.compareTo(b.memberCode));
  return list;
});

/// 某日全部作业项（跨分组，顺序与分组 sort、任务 sort 一致）
final flatHomeworkItemsForDateProvider =
    Provider.family<List<TaskItemEntity>, String>((ref, bizDate) {
  final mock = ref.watch(mockDataNotifierProvider);
  final groups = mock.taskGroupsFor(bizDate);
  final out = <TaskItemEntity>[];
  for (final g in groups) {
    out.addAll(mock.taskItemsFor(bizDate, g.groupCode));
  }
  return out;
});

/// 该日两名孩子是否全部任务均完成（侧边栏奖杯）
final homeworkDayAllDoneProvider =
    Provider.family<bool, String>((ref, bizDate) {
  final items = ref.watch(flatHomeworkItemsForDateProvider(bizDate));
  final children = ref.watch(homeworkChildrenProvider);
  if (items.isEmpty || children.isEmpty) return false;
  for (final item in items) {
    Map<String, dynamic> st = {};
    try {
      st = jsonDecode(item.statusByMemberJson) as Map<String, dynamic>;
    } catch (_) {}
    for (final c in children) {
      if (st[c.memberCode] != true) return false;
    }
  }
  return true;
});

/// 作业页当前选中日（默认「昨天」，贴近原型默认选中上一日）
final selectedTaskBizDateProvider = StateProvider<String>((ref) {
  final dates = ref.read(taskDatesProvider);
  if (dates.isEmpty) {
    final now = DateTime.now();
    return formatBizDate(DateTime(now.year, now.month, now.day));
  }
  return dates.length >= 2 ? dates[1].bizDate : dates.first.bizDate;
});
