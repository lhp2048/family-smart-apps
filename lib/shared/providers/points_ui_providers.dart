import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/mock/mock_data_notifier.dart';
import '../../features/dashboard/providers/family_api_base_url_provider.dart';
import '../../features/points/data/points_api_mappers.dart';
import '../../features/points/data/points_prototype_models.dart';
import '../../features/tasks/data/task_api_mappers.dart';
import '../../shared/models/member_entity.dart';
import 'task_ui_providers.dart';
import '../../features/dashboard/providers/dashboard_remote_providers.dart';

/// 与作业页共用刷新计数，便于设置里「校验站点」后一并重拉。
final pointsRemoteRefreshProvider = taskRemoteRefreshProvider;

/// 积分榜参与成员：active 的 child 与 parent（作业页仍仅 child）。
final pointsMembersAsyncProvider =
    FutureProvider<List<MemberEntity>>((ref) async {
  ref.watch(pointsRemoteRefreshProvider);
  if (!ref.watch(familyApiIsConfiguredProvider)) {
    final list = ref
        .read(mockDataNotifierProvider)
        .members
        .where(isActivePointsParticipant)
        .toList();
    list.sort((a, b) => a.memberCode.compareTo(b.memberCode));
    return list;
  }
  final client = ref.watch(familyApiClientProvider);
  final raw = await client.fetchMembers();
  final list = raw
      .map(memberFromApiMap)
      .where(isActivePointsParticipant)
      .toList();
  list.sort((a, b) => a.memberCode.compareTo(b.memberCode));
  return list;
});

final pointsRulesAsyncProvider =
    FutureProvider<List<PointsRuleLine>>((ref) async {
  ref.watch(pointsRemoteRefreshProvider);
  if (!ref.watch(familyApiIsConfiguredProvider)) {
    return ref.read(mockDataNotifierProvider).pointsRules;
  }
  final client = ref.watch(familyApiClientProvider);
  return fetchPointsRulesRemote(client);
});

final pointsWeekCyclesAsyncProvider =
    FutureProvider<List<PointsWeekCycle>>((ref) async {
  ref.watch(pointsRemoteRefreshProvider);
  if (!ref.watch(familyApiIsConfiguredProvider)) {
    return ref.read(mockDataNotifierProvider).pointsWeekCycles;
  }
  final client = ref.watch(familyApiClientProvider);
  return fetchPointsWeekCyclesRemote(client);
});

/// 供 [selectedPointsWeekProvider] 等与周列表同步；加载中为空列表（页面用 Async 展示进度）
final pointsWeekCyclesProvider = Provider<List<PointsWeekCycle>>((ref) {
  final async = ref.watch(pointsWeekCyclesAsyncProvider);
  return async.maybeWhen(data: (d) => d, orElse: () => const []);
});

/// 当前选中的周周期 id；远程数据到达后由页面 [ref.listen] 校正到有效值
final selectedPointsWeekIdProvider = StateProvider<String>((ref) => '');

final selectedPointsWeekProvider = Provider<PointsWeekCycle?>((ref) {
  final id = ref.watch(selectedPointsWeekIdProvider);
  final cycles = ref.watch(pointsWeekCyclesProvider);
  for (final c in cycles) {
    if (c.id == id) return c;
  }
  return cycles.isEmpty ? null : cycles.first;
});
