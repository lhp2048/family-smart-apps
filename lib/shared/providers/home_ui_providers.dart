import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/mock/mock_data_notifier.dart';
import '../../core/utils/biz_date.dart';
import '../../features/dashboard/data/feature_entries_api_mapper.dart';
import '../../features/dashboard/providers/dashboard_remote_providers.dart';
import '../../features/dashboard/providers/family_api_base_url_provider.dart';
import '../models/feature_entry_entity.dart';
import '../models/home_summary_entity.dart';
import '../models/member_entity.dart';
import 'task_ui_providers.dart';

/// 当前用于首页摘要的业务日（默认今天）
final dashboardBizDateProvider = Provider<String>((ref) {
  final now = DateTime.now();
  return formatBizDate(DateTime(now.year, now.month, now.day));
});

final homeSummaryProvider =
    Provider.family<HomeSummaryEntity?, String>((ref, bizDate) {
  return ref.watch(mockDataNotifierProvider).homeSummaries[bizDate];
});

final featureEntriesAsyncProvider =
    FutureProvider<List<FeatureEntryEntity>>((ref) async {
  ref.watch(taskRemoteRefreshProvider);
  if (!ref.watch(familyApiIsConfiguredProvider)) {
    return ref.read(mockDataNotifierProvider).featureEntries;
  }
  final client = ref.watch(familyApiClientProvider);
  return fetchFeatureEntriesRemote(client);
});

final featureEntriesProvider = Provider<List<FeatureEntryEntity>>((ref) {
  return ref.watch(featureEntriesAsyncProvider).valueOrNull ??
      (ref.watch(familyApiIsConfiguredProvider)
          ? const <FeatureEntryEntity>[]
          : ref.watch(mockDataNotifierProvider).featureEntries);
});

final activeMembersProvider = Provider<List<MemberEntity>>((ref) {
  if (ref.watch(familyApiIsConfiguredProvider)) {
    final async = ref.watch(familyMembersAllAsyncProvider);
    return async.valueOrNull ?? const [];
  }
  return ref.watch(mockDataNotifierProvider).members;
});
