import 'package:flutter_riverpod/flutter_riverpod.dart';

enum EbookReaderViewMode { page, scroll }

final ebookReaderViewModeProvider =
    StateProvider.autoDispose<EbookReaderViewMode>(
  (ref) => EbookReaderViewMode.page,
);

final ebookReaderZoomProvider = StateProvider.autoDispose<double>((ref) => 1.0);

final ebookReaderPdfPageProvider = StateProvider.autoDispose<int>((ref) => 1);

final ebookReaderTextPageProvider = StateProvider.autoDispose<int>((ref) => 1);

final ebookReaderEpubChapterProvider = StateProvider.autoDispose<int>((ref) => 0);

final ebookReaderPdfPageCountProvider =
    StateProvider.autoDispose<int>((ref) => 0);

final ebookReaderTextPageCountProvider =
    StateProvider.autoDispose<int>((ref) => 1);

final ebookReaderEpubChapterCountProvider =
    StateProvider.autoDispose<int>((ref) => 0);

final ebookReaderPanEnabledProvider = Provider.autoDispose<bool>((ref) {
  return ref.watch(ebookReaderZoomProvider) > 1.01;
});
