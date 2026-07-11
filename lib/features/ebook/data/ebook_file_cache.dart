import 'dart:typed_data';

import 'ebook_file_cache_stub.dart'
    if (dart.library.io) 'ebook_file_cache_io.dart';

/// Whether ebook files are persisted to disk after download (IO only).
bool get ebookFileCacheEnabled => ebookFileCacheEnabledImpl;

Future<Uint8List?> readEbookFileCache(String url) => readEbookFileCacheImpl(url);

Future<void> writeEbookFileCache(String url, Uint8List bytes) =>
    writeEbookFileCacheImpl(url, bytes);
