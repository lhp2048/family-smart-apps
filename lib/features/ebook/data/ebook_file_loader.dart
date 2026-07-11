import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ebook_file_cache.dart';
import '../presentation/reader/epub_native_reader.dart';

class EbookFileLoaderException implements Exception {
  EbookFileLoaderException(this.message);

  final String message;

  @override
  String toString() => message;
}

final ebookFileBytesProvider =
    FutureProvider.autoDispose.family<Uint8List, String>((ref, url) async {
  return downloadEbookBytes(url);
});

/// 带下载进度回调的字节加载（PDF 预览等场景）。
///
/// Web：由调用方决定是否流式；本函数仍可用于 EPUB/文本。
/// IO（Android / iOS / Windows / macOS）：优先读本地缓存，未命中则整包下载并写入缓存。
Future<Uint8List> downloadEbookBytes(
  String url, {
  void Function(int received, int? total)? onProgress,
  void Function(int byteLength)? onLoadedFromCache,
}) async {
  final trimmed = url.trim();
  if (trimmed.isEmpty) {
    throw EbookFileLoaderException('文件地址为空');
  }

  if (ebookFileCacheEnabled) {
    final cached = await readEbookFileCache(trimmed);
    if (cached != null && cached.isNotEmpty) {
      onLoadedFromCache?.call(cached.length);
      onProgress?.call(cached.length, cached.length);
      return cached;
    }
  }

  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(minutes: 2),
      responseType: ResponseType.bytes,
      headers: const {'Accept': '*/*'},
    ),
  );
  try {
    final res = await dio.get<List<int>>(
      trimmed,
      onReceiveProgress: onProgress,
    );
    final data = res.data;
    if (data == null || data.isEmpty) {
      throw EbookFileLoaderException('文件内容为空');
    }
    onProgress?.call(data.length, data.length);
    final bytes = Uint8List.fromList(data);
    if (ebookFileCacheEnabled) {
      await writeEbookFileCache(trimmed, bytes);
    }
    return bytes;
  } on DioException catch (e) {
    throw EbookFileLoaderException(
      e.response?.statusCode != null
          ? '加载失败 (${e.response!.statusCode})'
          : '无法加载文件',
    );
  } finally {
    dio.close();
  }
}

final ebookFileTextProvider =
    FutureProvider.autoDispose.family<String, String>((ref, url) async {
  final bytes = await ref.watch(ebookFileBytesProvider(url).future);
  return String.fromCharCodes(bytes);
});

final ebookEpubChaptersProvider =
    FutureProvider.autoDispose.family<List<NativeEpubChapter>, String>(
        (ref, url) async {
  final bytes = await ref.watch(ebookFileBytesProvider(url).future);
  return parseEpubChapters(bytes);
});
