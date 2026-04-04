import 'dart:convert';

import 'models/task_item_entity.dart';

/// 分组内所有成员勾选进度的完成率（完成格子数 / 总格子数）
double computeTaskGroupProgress(List<TaskItemEntity> items) {
  if (items.isEmpty) return 0;
  var total = 0;
  var done = 0;
  for (final item in items) {
    final map = jsonDecode(item.statusByMemberJson) as Map<String, dynamic>;
    for (final v in map.values) {
      total++;
      if (v == true) done++;
    }
  }
  if (total == 0) return 0;
  return done / total;
}

/// 某日所有任务项的整体完成率（跨分组）
double computeDayTaskProgress(List<TaskItemEntity> items) =>
    computeTaskGroupProgress(items);
