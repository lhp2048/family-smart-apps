import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/mock/mock_data_notifier.dart';
import '../../core/utils/biz_date.dart';
import '../models/feature_entry_entity.dart';
import '../models/home_summary_entity.dart';
import '../models/member_entity.dart';

/// 当前用于首页摘要的业务日（默认今天）
final dashboardBizDateProvider = Provider<String>((ref) {
  final now = DateTime.now();
  return formatBizDate(DateTime(now.year, now.month, now.day));
});

final homeSummaryProvider =
    Provider.family<HomeSummaryEntity?, String>((ref, bizDate) {
  return ref.watch(mockDataNotifierProvider).homeSummaries[bizDate];
});

final featureEntriesProvider = Provider<List<FeatureEntryEntity>>((ref) {
  return ref.watch(mockDataNotifierProvider).featureEntries;
});

final activeMembersProvider = Provider<List<MemberEntity>>((ref) {
  return ref.watch(mockDataNotifierProvider).members;
});
