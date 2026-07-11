import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/mock/mock_data_notifier.dart';
import '../../features/dashboard/providers/family_api_base_url_provider.dart';
import '../../features/ebook/data/ebook_models.dart';
import '../../features/ebook/providers/mediacenter_remote_providers.dart';

final ebookCurrentPathProvider = StateProvider<String>((ref) => '');

final ebookPageProvider = StateProvider<int>((ref) => 1);

enum EbookListViewMode { list, grid }

final ebookListViewModeProvider =
    StateProvider<EbookListViewMode>((ref) => EbookListViewMode.list);

class EbookBrowseQuery {
  const EbookBrowseQuery({required this.path, required this.page});

  final String path;
  final int page;

  @override
  bool operator ==(Object other) {
    return other is EbookBrowseQuery && other.path == path && other.page == page;
  }

  @override
  int get hashCode => Object.hash(path, page);
}

final ebookBrowseAsyncProvider =
    FutureProvider.autoDispose<EbookBrowseResult>((ref) async {
  final configured = ref.watch(familyMediacenterIsConfiguredProvider);
  final path = ref.watch(ebookCurrentPathProvider);
  final page = ref.watch(ebookPageProvider);
  if (!configured) {
    return ref.watch(mockDataNotifierProvider).ebookBrowse;
  }
  final client = ref.watch(mediacenterApiClientProvider);
  return client.browseMaterials(path: path, page: page, pageSize: 30);
});

final ebookBrowseQueryProvider = Provider<EbookBrowseQuery>((ref) {
  return EbookBrowseQuery(
    path: ref.watch(ebookCurrentPathProvider),
    page: ref.watch(ebookPageProvider),
  );
});
