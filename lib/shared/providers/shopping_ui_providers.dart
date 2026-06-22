import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/dashboard/providers/dashboard_remote_providers.dart';
import '../../features/dashboard/providers/family_api_base_url_provider.dart';
import '../../features/shopping/data/shopping_api_mappers.dart';
import '../../features/shopping/data/shopping_models.dart';
import 'task_ui_providers.dart';

final shoppingRemoteRefreshProvider = taskRemoteRefreshProvider;

final shoppingFilterPurchasedProvider = StateProvider<String>((ref) => 'false');

final shoppingItemsAsyncProvider =
    FutureProvider<List<ShoppingItem>>((ref) async {
  ref.watch(shoppingRemoteRefreshProvider);
  if (!ref.watch(familyApiIsConfiguredProvider)) {
    return const [];
  }
  final client = ref.watch(familyApiClientProvider);
  final filter = ref.watch(shoppingFilterPurchasedProvider);
  final purchased = filter == 'all' ? null : filter;
  return fetchAllShoppingItemsRemote(client, purchased: purchased);
});

final shoppingItemsProvider = Provider<List<ShoppingItem>>((ref) {
  return ref.watch(shoppingItemsAsyncProvider).valueOrNull ?? const [];
});

final shoppingItemDetailAsyncProvider =
    FutureProvider.family<ShoppingItem?, String>((ref, itemId) async {
  ref.watch(shoppingRemoteRefreshProvider);
  if (!ref.watch(familyApiIsConfiguredProvider)) return null;
  final client = ref.watch(familyApiClientProvider);
  final data = await client.fetchShoppingItem(itemId);
  return shoppingItemFromMap(data);
});

final shoppingPriceHistoryAsyncProvider =
    FutureProvider.family<List<ShoppingPriceRecord>, String>((ref, itemId) async {
  ref.watch(shoppingRemoteRefreshProvider);
  if (!ref.watch(familyApiIsConfiguredProvider)) return const [];
  final client = ref.watch(familyApiClientProvider);
  final data = await client.fetchShoppingPriceHistory(itemId, view: 'trend');
  return priceRecordsFromHistoryData(data);
});

final shoppingPriceHistoryAuditAsyncProvider =
    FutureProvider.family<List<ShoppingPriceRecord>, String>((ref, itemId) async {
  ref.watch(shoppingRemoteRefreshProvider);
  if (!ref.watch(familyApiIsConfiguredProvider)) return const [];
  final client = ref.watch(familyApiClientProvider);
  final data = await client.fetchShoppingPriceHistory(itemId, view: 'audit');
  return priceRecordsFromHistoryData(data);
});

final shoppingCompareItemIdsProvider =
    StateProvider<List<String>>((ref) => const []);

final shoppingPriceTrendsAsyncProvider =
    FutureProvider<List<ShoppingPriceSeries>>((ref) async {
  ref.watch(shoppingRemoteRefreshProvider);
  final ids = ref.watch(shoppingCompareItemIdsProvider);
  if (ids.isEmpty || !ref.watch(familyApiIsConfiguredProvider)) {
    return const [];
  }
  final client = ref.watch(familyApiClientProvider);
  final data = await client.fetchShoppingPriceTrends(ids);
  if (data['currencyConflict'] == true) {
    throw StateError('currencyConflict');
  }
  return priceSeriesFromTrendsData(data);
});
