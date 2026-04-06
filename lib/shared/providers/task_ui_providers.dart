import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/mock/mock_data_notifier.dart';
import '../../core/utils/biz_date.dart';
import '../../features/dashboard/providers/dashboard_remote_providers.dart';
import '../../features/dashboard/providers/family_api_base_url_provider.dart';
import '../../features/tasks/data/homework_items_bundle.dart';
import '../../features/tasks/data/models/task_date_entity.dart';
import '../../features/tasks/data/models/task_item_entity.dart';
import '../../features/tasks/data/task_api_mappers.dart';
import '../../features/tasks/data/task_member_status.dart';
import '../models/member_entity.dart';

/// 多分组下可能对每组返回重叠列表，或同一任务跨组出现；保留首次出现顺序。
List<TaskItemEntity> _dedupeFlatHomeworkItems(List<TaskItemEntity> items) {
  final seen = <String>{};
  final out = <TaskItemEntity>[];
  for (final e in items) {
    late final String key;
    if (e.taskCode.isNotEmpty) {
      key = '${e.bizDate}|${e.taskCode}';
    } else if (e.bizDateGroupTaskKey.isNotEmpty) {
      key = e.bizDateGroupTaskKey;
    } else {
      out.add(e);
      continue;
    }
    if (seen.add(key)) out.add(e);
  }
  return out;
}

/// 变更站点或手动刷新时递增，使作业相关 [FutureProvider] 重新拉取。
final taskRemoteRefreshProvider = StateProvider<int>((ref) => 0);

/// 作业日期列表（未配置站点 → Mock；已配置 → `GET /v1/task-dates`）。
final taskDatesAsyncProvider =
    FutureProvider<List<TaskDateEntity>>((ref) async {
  ref.watch(taskRemoteRefreshProvider);
  if (!ref.watch(familyApiIsConfiguredProvider)) {
    return ref.read(mockDataNotifierProvider).taskDates;
  }
  final client = ref.watch(familyApiClientProvider);
  final raw = await client.fetchTaskDates();
  final list = raw.map(taskDateFromApiMap).where((e) => e.bizDate.isNotEmpty).toList();
  list.sort((a, b) => b.bizDate.compareTo(a.bizDate));
  return list;
});

/// 孩子成员（未配置 → Mock；已配置 → `GET /v1/members` 中 `role=child`）。
final homeworkChildrenAsyncProvider =
    FutureProvider<List<MemberEntity>>((ref) async {
  ref.watch(taskRemoteRefreshProvider);
  if (!ref.watch(familyApiIsConfiguredProvider)) {
    final list = ref
        .read(mockDataNotifierProvider)
        .members
        .where((m) => m.role == 'child')
        .toList();
    list.sort((a, b) => a.memberCode.compareTo(b.memberCode));
    return list;
  }
  final client = ref.watch(familyApiClientProvider);
  final raw = await client.fetchMembers();
  final list = raw.map(memberFromApiMap).where((m) => m.role == 'child').toList();
  list.sort((a, b) => a.memberCode.compareTo(b.memberCode));
  return list;
});

/// 家长优先，其余角色次之，同角色按 [MemberEntity.memberCode]。
int _roleRankForSettingsMemberSort(String role) {
  switch (role) {
    case 'parent':
      return 0;
    case 'child':
      return 1;
    default:
      return 2;
  }
}

/// 设置页：全部成员（未配置 → 空；已配置 → `GET /v1/members`）。
final familyMembersAllAsyncProvider =
    FutureProvider<List<MemberEntity>>((ref) async {
  ref.watch(taskRemoteRefreshProvider);
  if (!ref.watch(familyApiIsConfiguredProvider)) {
    return const [];
  }
  final client = ref.watch(familyApiClientProvider);
  final raw = await client.fetchMembers();
  final list = raw.map(memberFromApiMap).toList();
  list.sort((a, b) {
    final byRole = _roleRankForSettingsMemberSort(a.role)
        .compareTo(_roleRankForSettingsMemberSort(b.role));
    if (byRole != 0) return byRole;
    return a.memberCode.compareTo(b.memberCode);
  });
  return list;
});

/// 某日作业数据：Mock/经典接口为扁平；「每人一行」接口按 `groupCode`（成员）分块，组内按 `taskName` 字典序排序。
final homeworkItemsBundleForDateAsyncProvider =
    FutureProvider.family<HomeworkItemsBundle, String>((ref, bizDate) async {
  ref.watch(taskRemoteRefreshProvider);
  if (!ref.watch(familyApiIsConfiguredProvider)) {
    final mock = ref.read(mockDataNotifierProvider);
    final groups = mock.taskGroupsFor(bizDate);
    final out = <TaskItemEntity>[];
    for (final g in groups) {
      out.addAll(mock.taskItemsFor(bizDate, g.groupCode));
    }
    return HomeworkItemsBundle.flat(_dedupeFlatHomeworkItems(out));
  }
  final client = ref.watch(familyApiClientProvider);
  final groupMaps = await client.fetchTaskGroups(bizDate);
  var groups = groupMaps.map(taskGroupFromApiMap).toList();
  groups.sort((a, b) => a.sort.compareTo(b.sort));
  if (groups.isEmpty) {
    final flat = await client.fetchTaskItems(bizDate);
    return homeworkItemsBundleFromApiRawList(flat, bizDate);
  }
  final parts = <HomeworkItemsBundle>[];
  for (final g in groups) {
    final raw = await client.fetchTaskItems(bizDate, groupCode: g.groupCode);
    parts.add(homeworkItemsBundleFromApiRawList(raw, bizDate));
  }
  return HomeworkItemsBundle.mergeGroupFetches(parts, _dedupeFlatHomeworkItems);
});

/// 该日两名孩子是否全部任务均完成（侧边栏奖杯）。
final homeworkDayAllDoneProvider = Provider.family<bool, String>((ref, bizDate) {
  final bundleAsync = ref.watch(homeworkItemsBundleForDateAsyncProvider(bizDate));
  final childrenAsync = ref.watch(homeworkChildrenAsyncProvider);
  if (!bundleAsync.hasValue || !childrenAsync.hasValue) {
    return false;
  }
  final bundle = bundleAsync.requireValue;
  final children = childrenAsync.requireValue;
  if (!bundle.hasAnyItems || children.isEmpty) {
    return false;
  }
  for (final c in children) {
    final items = bundle.itemsForMemberCode(c.memberCode);
    if (items.isEmpty) {
      return false;
    }
    for (final item in items) {
      Map<String, dynamic> st = {};
      try {
        st = Map<String, dynamic>.from(
          jsonDecode(item.statusByMemberJson) as Map<dynamic, dynamic>,
        );
      } catch (_) {}
      if (!memberTaskDoneForMember(c, st)) {
        return false;
      }
    }
  }
  return true;
});

/// 作业页当前选中日；占位为今天，实际在 [TasksPage] 根据持久化与日期列表解析。
final selectedTaskBizDateProvider = StateProvider<String>((ref) {
  final now = DateTime.now();
  return formatBizDate(DateTime(now.year, now.month, now.day));
});
