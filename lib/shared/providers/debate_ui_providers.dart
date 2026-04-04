import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/mock/mock_data_notifier.dart';
import '../../core/utils/biz_date.dart';
import '../../features/debate/data/debate_prototype_models.dart';

final debateDayBundlesProvider = Provider<List<DebateDayBundle>>((ref) {
  return ref.watch(mockDataNotifierProvider).debateDayBundles;
});

/// 当前选中的辩论业务日
final selectedDebateBizDateProvider = StateProvider<String>((ref) {
  final bundles = ref.read(mockDataNotifierProvider).debateDayBundles;
  if (bundles.isEmpty) {
    final n = DateTime.now();
    return formatBizDate(DateTime(n.year, n.month, n.day));
  }
  return bundles.first.bizDate;
});

final selectedDebateBundleProvider = Provider<DebateDayBundle?>((ref) {
  final sel = ref.watch(selectedDebateBizDateProvider);
  final bundles = ref.watch(debateDayBundlesProvider);
  for (final b in bundles) {
    if (b.bizDate == sel) return b;
  }
  return bundles.isEmpty ? null : bundles.first;
});

String debateSidebarLabel(String bizDate) {
  final d = DateTime.parse(bizDate);
  final mm = d.month.toString().padLeft(2, '0');
  final dd = d.day.toString().padLeft(2, '0');
  return '$mm-$dd ${weekdayCn(d)}';
}

String debateHeaderPillLabel(String bizDate) {
  final d = DateTime.parse(bizDate);
  final m = d.month;
  final day = d.day.toString().padLeft(2, '0');
  return '$m月$day日 ${weekdayCn(d)}';
}
