import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/mock/mock_data_notifier.dart';
import '../../features/dashboard/providers/dashboard_remote_providers.dart';
import '../../features/dashboard/providers/family_api_base_url_provider.dart';
import '../../features/wishwall/data/wishwall_api_mappers.dart';
import '../../features/wishwall/data/wishwall_prototype_models.dart';
import 'task_ui_providers.dart';

/// 与作业/积分榜共用刷新。
final wishwallRemoteRefreshProvider = taskRemoteRefreshProvider;

final wishwallItemsAsyncProvider =
    FutureProvider<List<WishwallItem>>((ref) async {
  ref.watch(wishwallRemoteRefreshProvider);
  if (!ref.watch(familyApiIsConfiguredProvider)) {
    return ref.read(mockDataNotifierProvider).wishwallItems;
  }
  final client = ref.watch(familyApiClientProvider);
  return fetchAllWishesRemote(client);
});

/// 兼容：同步列表（加载中为空）
final wishwallItemsProvider = Provider<List<WishwallItem>>((ref) {
  return ref.watch(wishwallItemsAsyncProvider).valueOrNull ?? const [];
});

final wishwallFilterIdProvider = StateProvider<String>((ref) => 'all');

final filteredWishwallItemsProvider = Provider<List<WishwallItem>>((ref) {
  final items = ref.watch(wishwallItemsProvider);
  final filter = ref.watch(wishwallFilterIdProvider);
  switch (filter) {
    case 'all':
      return items;
    case 'unrealized':
      return items.where((e) => !e.fulfilled).toList();
    case 'realized':
      return items.where((e) => e.fulfilled).toList();
    default:
      return items.where((e) => e.memberCode == filter).toList();
  }
});
