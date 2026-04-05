import 'dart:convert';

/// 分组内所有成员勾选进度的完成率（完成格子数 / 总格子数）
/// [statusJsonOf] 解耦 IO/Web 两套实体类型，避免条件 export 在静态分析下不一致。
double computeTaskGroupProgress<T>(
  List<T> items,
  String Function(T) statusJsonOf,
) {
  if (items.isEmpty) return 0;
  var total = 0;
  var done = 0;
  for (final item in items) {
    final map = jsonDecode(statusJsonOf(item)) as Map<String, dynamic>;
    for (final v in map.values) {
      total++;
      if (v == true) done++;
    }
  }
  if (total == 0) return 0;
  return done / total;
}

/// 某日所有任务项的整体完成率（跨分组）
double computeDayTaskProgress<T>(
  List<T> items,
  String Function(T) statusJsonOf,
) =>
    computeTaskGroupProgress(items, statusJsonOf);
