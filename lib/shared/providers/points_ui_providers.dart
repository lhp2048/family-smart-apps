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

/// 周列表 + summary（侧栏用，不拉 records）
final pointsWeekShellsAsyncProvider =
    FutureProvider<List<PointsWeekShell>>((ref) async {
  ref.watch(pointsRemoteRefreshProvider);
  if (!ref.watch(familyApiIsConfiguredProvider)) {
    return ref
        .read(mockDataNotifierProvider)
        .pointsWeekCycles
        .map(pointsWeekShellFromCycle)
        .toList();
  }
  final client = ref.watch(familyApiClientProvider);
  return fetchPointsWeekShellsRemote(client);
});

final pointsWeekShellsProvider = Provider<List<PointsWeekShell>>((ref) {
  final async = ref.watch(pointsWeekShellsAsyncProvider);
  return async.maybeWhen(data: (d) => d, orElse: () => const []);
});

/// 单周明细（选中 / PageView 可见周按需拉取）
final pointsWeekDetailAsyncProvider =
    FutureProvider.family<PointsWeekDetail, String>((ref, weekId) async {
  ref.watch(pointsRemoteRefreshProvider);
  if (!ref.watch(familyApiIsConfiguredProvider)) {
    for (final cycle in ref.read(mockDataNotifierProvider).pointsWeekCycles) {
      if (cycle.id == weekId) return pointsWeekDetailFromCycle(cycle);
    }
    return const PointsWeekDetail(dailyLogs: []);
  }
  final shells = ref.watch(pointsWeekShellsProvider);
  PointsWeekShell? shell;
  for (final s in shells) {
    if (s.id == weekId) {
      shell = s;
      break;
    }
  }
  if (shell == null) {
    return const PointsWeekDetail(dailyLogs: []);
  }
  final client = ref.watch(familyApiClientProvider);
  return fetchPointsWeekDetailRemote(client, shell);
});

/// 当前选中的周周期 id；远程数据到达后由页面 [ref.listen] 校正到有效值
final selectedPointsWeekIdProvider = StateProvider<String>((ref) => '');

final selectedPointsWeekShellProvider = Provider<PointsWeekShell?>((ref) {
  final id = ref.watch(selectedPointsWeekIdProvider);
  final shells = ref.watch(pointsWeekShellsProvider);
  for (final s in shells) {
    if (s.id == id) return s;
  }
  return shells.isEmpty ? null : shells.first;
});

/// 兼容旧引用：全量周（Mock 有明细；远程仅 shell 字段）
final pointsWeekCyclesAsyncProvider =
    FutureProvider<List<PointsWeekCycle>>((ref) async {
  ref.watch(pointsRemoteRefreshProvider);
  if (!ref.watch(familyApiIsConfiguredProvider)) {
    return ref.read(mockDataNotifierProvider).pointsWeekCycles;
  }
  final shells = await ref.watch(pointsWeekShellsAsyncProvider.future);
  return shells
      .map(
        (s) => PointsWeekCycle(
          id: s.id,
          periodStart: s.periodStart,
          periodEnd: s.periodEnd,
          rangeShort: s.rangeShort,
          rangeTitleLong: s.rangeTitleLong,
          isCurrentWeek: s.isCurrentWeek,
          totalsByMemberCode: s.totalsByMemberCode,
          netGainByMemberCode: s.netGainByMemberCode,
          dailyLogs: const [],
          displayNameByMemberCode: s.displayNameByMemberCode,
        ),
      )
      .toList();
});

final pointsWeekCyclesProvider = Provider<List<PointsWeekCycle>>((ref) {
  final async = ref.watch(pointsWeekCyclesAsyncProvider);
  return async.maybeWhen(data: (d) => d, orElse: () => const []);
});

final selectedPointsWeekProvider = Provider<PointsWeekCycle?>((ref) {
  final shell = ref.watch(selectedPointsWeekShellProvider);
  if (shell == null) return null;
  final detail = ref.watch(pointsWeekDetailAsyncProvider(shell.id)).valueOrNull;
  return PointsWeekCycle(
    id: shell.id,
    periodStart: shell.periodStart,
    periodEnd: shell.periodEnd,
    rangeShort: shell.rangeShort,
    rangeTitleLong: shell.rangeTitleLong,
    isCurrentWeek: shell.isCurrentWeek,
    totalsByMemberCode: shell.totalsByMemberCode,
    netGainByMemberCode: shell.netGainByMemberCode,
    dailyLogs: detail?.dailyLogs ?? const [],
    displayNameByMemberCode: {
      ...shell.displayNameByMemberCode,
      ...?detail?.displayNameByMemberCode,
    },
  );
});
