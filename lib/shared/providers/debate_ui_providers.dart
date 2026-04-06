import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/mock/mock_data_notifier.dart';
import '../../core/utils/biz_date.dart';
import '../../features/dashboard/providers/dashboard_remote_providers.dart';
import '../../features/dashboard/providers/family_api_base_url_provider.dart';
import '../../features/debate/data/debate_api_mappers.dart';
import '../../features/debate/data/debate_prototype_models.dart';
import 'task_ui_providers.dart';

final debateRemoteRefreshProvider = taskRemoteRefreshProvider;

final debateRemoteDaysAsyncProvider =
    FutureProvider<List<String>>((ref) async {
  ref.watch(debateRemoteRefreshProvider);
  if (!ref.watch(familyApiIsConfiguredProvider)) {
    return const [];
  }
  final client = ref.watch(familyApiClientProvider);
  return fetchDebateDaysRemote(client);
});

/// 有辩论内容的业务日（新→旧）；Mock 来自本地 bundle
final debateBizDatesProvider = Provider<List<String>>((ref) {
  if (!ref.watch(familyApiIsConfiguredProvider)) {
    final bundles = ref.watch(mockDataNotifierProvider).debateDayBundles;
    final dates = bundles.map((b) => b.bizDate).toList()
      ..sort((a, b) => b.compareTo(a));
    return dates;
  }
  return ref.watch(debateRemoteDaysAsyncProvider).valueOrNull ?? const [];
});

/// 用户点选的业务日；空或不在列表中时由 [debateEffectiveBizDateProvider] 纠正
final selectedDebateBizDateProvider = StateProvider<String>((ref) => '');

final debateEffectiveBizDateProvider = Provider<String>((ref) {
  final dates = ref.watch(debateBizDatesProvider);
  final sel = ref.watch(selectedDebateBizDateProvider);
  if (dates.isEmpty) {
    if (sel.isNotEmpty) return sel;
    final n = DateTime.now();
    return formatBizDate(DateTime(n.year, n.month, n.day));
  }
  if (sel.isEmpty || !dates.contains(sel)) {
    return dates.first;
  }
  return sel;
});

final debateSelectedBundleAsyncProvider =
    FutureProvider<DebateDayBundle?>((ref) async {
  ref.watch(debateRemoteRefreshProvider);
  if (!ref.watch(familyApiIsConfiguredProvider)) {
    final bizDate = ref.watch(debateEffectiveBizDateProvider);
    final bundles = ref.read(mockDataNotifierProvider).debateDayBundles;
    for (final b in bundles) {
      if (b.bizDate == bizDate) return b;
    }
    return bundles.isEmpty ? null : bundles.first;
  }
  final dates = ref.watch(debateBizDatesProvider);
  if (dates.isEmpty) return null;
  final bizDate = ref.watch(debateEffectiveBizDateProvider);
  final client = ref.watch(familyApiClientProvider);
  return fetchDebateBundleForDateRemote(client, bizDate);
});

String debateSidebarLabel(String bizDate) {
  final d = DateTime.parse(bizDate);
  final mm = d.month.toString().padLeft(2, '0');
  final dd = d.day.toString().padLeft(2, '0');
  return '$mm-$dd ${weekdayCn(d)}';
}
