import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/home_card_remote_catalog.dart';
import 'dashboard_remote_providers.dart';
import 'family_api_base_url_provider.dart';
import 'home_card_refresh_provider.dart';

/// 远程首页卡片 catalog；下拉刷新时随 [homeCardPreviewRefreshProvider] 失效。
final remoteHomeCardCatalogProvider =
    FutureProvider<RemoteHomeCardCatalog>((ref) async {
  ref.watch(homeCardPreviewRefreshProvider);
  if (!ref.watch(familyApiIsConfiguredProvider)) {
    return const RemoteHomeCardCatalog(items: []);
  }
  final client = ref.watch(familyApiClientProvider);
  final body = await client.getHomeCardCatalog();
  return parseRemoteHomeCardCatalog(body);
});

/// 已启用 cardId；未配置 / 加载中 / 失败时为 null（不过滤 layout）。
final enabledRemoteHomeCardIdsProvider = Provider<Set<String>?>((ref) {
  if (!ref.watch(familyApiIsConfiguredProvider)) {
    return null;
  }
  final async = ref.watch(remoteHomeCardCatalogProvider);
  return async.when(
    data: (catalog) => catalog.enabledCardIds,
    loading: () => null,
    error: (_, _) => null,
  );
});
