import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/mock/mock_data_notifier.dart';
import '../../features/dashboard/providers/dashboard_remote_providers.dart';
import '../../features/dashboard/providers/family_api_base_url_provider.dart';
import '../../features/extracurricular/data/extracurricular_api_mappers.dart';
import '../../features/extracurricular/data/extracurricular_models.dart';
import 'task_ui_providers.dart';

/// 未配置 API 时左侧筛选项（与历史 Mock 一致）
final kMockExtracurricularSidebarEntries = <ExtracurricularSidebarEntry>[
  const ExtracurricularSidebarEntry(
    filterId: ExtracurricularFilterIds.all,
    label: '全部',
    icon: Icons.apps_rounded,
  ),
  const ExtracurricularSidebarEntry(
    filterId: ExtracurricularFilterIds.golden,
    label: '黄金屋',
    icon: Icons.menu_book_rounded,
  ),
  const ExtracurricularSidebarEntry(
    filterId: ExtracurricularFilterIds.seventh,
    label: '第七艺术',
    icon: Icons.movie_filter_rounded,
  ),
  const ExtracurricularSidebarEntry(
    filterId: ExtracurricularFilterIds.tv,
    label: '电视剧',
    icon: Icons.tv_rounded,
  ),
  const ExtracurricularSidebarEntry(
    filterId: ExtracurricularFilterIds.anime,
    label: '动漫/漫画',
    icon: Icons.sports_esports_rounded,
  ),
  const ExtracurricularSidebarEntry(
    filterId: ExtracurricularFilterIds.doc,
    label: '纪录片/其他',
    icon: Icons.movie_creation_rounded,
  ),
];

final extracurricularRemoteRefreshProvider = taskRemoteRefreshProvider;

final extracurricularRemoteFiltersAsyncProvider =
    FutureProvider<List<ExtracurricularSidebarEntry>>((ref) async {
  ref.watch(extracurricularRemoteRefreshProvider);
  if (!ref.watch(familyApiIsConfiguredProvider)) {
    return kMockExtracurricularSidebarEntries;
  }
  final client = ref.watch(familyApiClientProvider);
  return fetchExtracurricularFiltersRemote(client);
});

final extracurricularSidebarEntriesProvider =
    Provider<List<ExtracurricularSidebarEntry>>((ref) {
  if (!ref.watch(familyApiIsConfiguredProvider)) {
    return kMockExtracurricularSidebarEntries;
  }
  return ref.watch(extracurricularRemoteFiltersAsyncProvider).valueOrNull ??
      const [];
});

final extracurricularItemsProvider = Provider<List<ExtracurricularItem>>((ref) {
  return ref.watch(mockDataNotifierProvider).extracurricularItems;
});

final extracurricularFilterIdProvider =
    StateProvider<String>((ref) => ExtracurricularFilterIds.all);

final extracurricularUnwatchedOnlyProvider = StateProvider<bool>((ref) => false);

final filteredExtracurricularItemsProvider =
    Provider<List<ExtracurricularItem>>((ref) {
  final items = ref.watch(extracurricularItemsProvider);
  final filter = ref.watch(extracurricularFilterIdProvider);
  final onlyUnwatched = ref.watch(extracurricularUnwatchedOnlyProvider);

  return items.where((e) {
    if (filter != ExtracurricularFilterIds.all && e.filterId != filter) {
      return false;
    }
    if (onlyUnwatched && e.watched) return false;
    return true;
  }).toList();
});

final extracurricularRemoteItemsAsyncProvider =
    FutureProvider.family<List<ExtracurricularItem>, String>(
  (ref, filterId) async {
    ref.watch(extracurricularRemoteRefreshProvider);
    if (!ref.watch(familyApiIsConfiguredProvider)) {
      return const [];
    }
    final client = ref.watch(familyApiClientProvider);
    return fetchAllExtracurricularItemsRemote(client, filterId);
  },
);

/// Mock：[filteredExtracurricularItemsProvider]；远程：按当前 [filterId] 拉取列表（未看筛在 UI 层处理）
///
/// 站点根 [familyApiOriginNotifierProvider] 仍在加载时返回 [AsyncLoading]，避免误用 Mock
/// （否则首帧 `isConfigured==false` 会短暂显示「家有儿女」等演示数据）。
final extracurricularItemsAsyncProvider =
    Provider<AsyncValue<List<ExtracurricularItem>>>((ref) {
  final originAsync = ref.watch(familyApiOriginNotifierProvider);
  if (originAsync.isLoading) {
    return const AsyncLoading<List<ExtracurricularItem>>();
  }
  if (originAsync.hasError) {
    return AsyncData(ref.watch(filteredExtracurricularItemsProvider));
  }
  final origin = originAsync.requireValue;
  if (origin.trim().isEmpty) {
    return AsyncData(ref.watch(filteredExtracurricularItemsProvider));
  }
  final filterId = ref.watch(extracurricularFilterIdProvider);
  return ref.watch(extracurricularRemoteItemsAsyncProvider(filterId));
});
