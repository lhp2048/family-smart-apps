import 'dart:convert';

import 'package:isar/isar.dart';

import 'isar_query_compat.dart';
import '../../features/tasks/data/models/task_date_entity_io.dart';
import '../../features/tasks/data/models/task_group_entity_io.dart';
import '../../features/tasks/data/models/task_item_entity_io.dart';
import '../../features/tasks/data/task_keys.dart';
import '../../features/tasks/data/task_progress.dart';
import '../../shared/models/feature_entry_entity_io.dart';
import '../../shared/models/home_summary_entity_io.dart';
import '../../shared/models/member_entity_io.dart';
import '../utils/biz_date.dart';

/// 首次安装写入种子数据（需求文档 §9）
Future<void> seedIfEmpty(Isar isar) async {
  final hasEntries = await isar.featureEntryEntitys.count() > 0;
  if (hasEntries) return;

  final now = DateTime.now();
  await isar.writeTxn(() async {
    await _seedMembers(isar, now);
    await _seedFeatureEntries(isar, now);
    await _seedTaskDates(isar, now);
    await _seedTasks(isar, now);
    await _seedHomeSummary(isar, now);
  });
}

Future<void> _seedMembers(Isar isar, DateTime now) async {
  final m1 = MemberEntity()
    ..memberCode = 'parent1'
    ..name = '家长'
    ..role = 'parent'
    ..status = 'active'
    ..createdAt = now
    ..updatedAt = now;
  final m2 = MemberEntity()
    ..memberCode = 'child1'
    ..name = '孩子'
    ..role = 'child'
    ..status = 'active'
    ..createdAt = now
    ..updatedAt = now;
  await isar.memberEntitys.putAll([m1, m2]);
}

Future<void> _seedFeatureEntries(Isar isar, DateTime now) async {
  final entries = <FeatureEntryEntity>[
    FeatureEntryEntity()
      ..entryKey = 'tasks'
      ..title = '作业进度'
      ..icon = 'fact_check_outlined'
      ..sort = 10
      ..enabled = true
      ..updatedAt = now,
    FeatureEntryEntity()
      ..entryKey = 'points'
      ..title = '游戏积分'
      ..icon = 'emoji_events_outlined'
      ..sort = 20
      ..enabled = true
      ..updatedAt = now,
    FeatureEntryEntity()
      ..entryKey = 'wishwall'
      ..title = '心愿墙'
      ..icon = 'favorite_border'
      ..sort = 30
      ..enabled = true
      ..updatedAt = now,
    FeatureEntryEntity()
      ..entryKey = 'timemachine'
      ..title = '时光机'
      ..icon = 'history_edu_outlined'
      ..sort = 40
      ..enabled = true
      ..updatedAt = now,
    FeatureEntryEntity()
      ..entryKey = 'debate'
      ..title = '话题辩论'
      ..icon = 'forum_outlined'
      ..sort = 50
      ..enabled = true
      ..updatedAt = now,
  ];
  await isar.featureEntryEntitys.putAll(entries);
}

Future<void> _seedTaskDates(Isar isar, DateTime now) async {
  final list = <TaskDateEntity>[];
  for (var i = 0; i < 7; i++) {
    final d = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: i));
    final bd = formatBizDate(d);
    list.add(
      TaskDateEntity()
        ..bizDate = bd
        ..weekday = weekdayCn(d)
        ..hasReward = i == 0
        ..updatedAt = now,
    );
  }
  await isar.taskDateEntitys.putAll(list);
}

Future<void> _seedTasks(Isar isar, DateTime now) async {
  final today = formatBizDate(DateTime(now.year, now.month, now.day));
  const members = ['parent1', 'child1'];

  String statusJson(bool p, bool c) =>
      jsonEncode(<String, bool>{members[0]: p, members[1]: c});

  final g1 = TaskGroupEntity()
    ..bizDateGroupKey = taskGroupKey(today, 'school')
    ..bizDate = today
    ..groupCode = 'school'
    ..title = '校内作业'
    ..progress = 0
    ..sort = 1
    ..updatedAt = now;

  final g2 = TaskGroupEntity()
    ..bizDateGroupKey = taskGroupKey(today, 'extra')
    ..bizDate = today
    ..groupCode = 'extra'
    ..title = '拓展任务'
    ..progress = 0
    ..sort = 2
    ..updatedAt = now;

  await isar.taskGroupEntitys.putAll([g1, g2]);

  final items = <TaskItemEntity>[
    TaskItemEntity()
      ..bizDateGroupTaskKey = taskItemKey(today, 'school', 't1')
      ..bizDate = today
      ..groupCode = 'school'
      ..taskCode = 't1'
      ..name = '语文练习册 P12–14'
      ..score = 10
      ..statusByMemberJson = statusJson(true, false)
      ..completedAtByMemberJson = '{}'
      ..sort = 1
      ..updatedAt = now,
    TaskItemEntity()
      ..bizDateGroupTaskKey = taskItemKey(today, 'school', 't2')
      ..bizDate = today
      ..groupCode = 'school'
      ..taskCode = 't2'
      ..name = '数学口算一页'
      ..score = 5
      ..statusByMemberJson = statusJson(true, true)
      ..completedAtByMemberJson = '{}'
      ..sort = 2
      ..updatedAt = now,
    TaskItemEntity()
      ..bizDateGroupTaskKey = taskItemKey(today, 'extra', 'e1')
      ..bizDate = today
      ..groupCode = 'extra'
      ..taskCode = 'e1'
      ..name = '英语听读 15 分钟'
      ..score = 8
      ..statusByMemberJson = statusJson(false, false)
      ..completedAtByMemberJson = '{}'
      ..sort = 1
      ..updatedAt = now,
  ];
  await isar.taskItemEntitys.putAll(items);

  await _recalcGroupProgress(isar, today, 'school');
  await _recalcGroupProgress(isar, today, 'extra');
}

Future<void> _recalcGroupProgress(
  Isar isar,
  String bizDate,
  String groupCode,
) async {
  final items = await isar.taskItemEntitys
      .filter()
      .bizDateEqualTo(bizDate)
      .groupCodeEqualTo(groupCode)
      .sortBySort()
      .findAllCompat();
  final p = computeTaskGroupProgress(items, (e) => e.statusByMemberJson);
  final key = taskGroupKey(bizDate, groupCode);
  final g = await isar.taskGroupEntitys
      .filter()
      .bizDateGroupKeyEqualTo(key)
      .findFirstCompat();
  if (g != null) {
    g.progress = p;
    g.updatedAt = DateTime.now();
    await isar.taskGroupEntitys.put(g);
  }
}

Future<void> _seedHomeSummary(Isar isar, DateTime now) async {
  final today = formatBizDate(DateTime(now.year, now.month, now.day));
  final items = await isar.taskItemEntitys
      .filter()
      .bizDateEqualTo(today)
      .findAllCompat();
  final p = computeDayTaskProgress(items, (e) => e.statusByMemberJson);
  final scores = jsonEncode(<String, int>{'parent1': 12, 'child1': 48});
  final h = HomeSummaryEntity()
    ..bizDate = today
    ..taskProgress = p
    ..memberScoresJson = scores
    ..updatedAt = now;
  await isar.homeSummaryEntitys.put(h);
}
