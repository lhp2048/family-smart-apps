import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

bool get ebookFileCacheEnabledImpl => true;

Future<Directory> _ebookCacheDir() async {
  final base = await getApplicationCacheDirectory();
  final dir = Directory(p.join(base.path, 'ebook_files'));
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
  }
  return dir;
}

String _cacheFileName(String url) {
  final trimmed = url.trim();
  final uri = Uri.tryParse(trimmed);
  final ext = p.extension(uri?.path ?? '');
  final hash = base64Url.encode(utf8.encode(trimmed)).replaceAll('=', '');
  final safeExt = ext.isNotEmpty && ext.length <= 8 ? ext : '.bin';
  return '$hash$safeExt';
}

Future<Uint8List?> readEbookFileCacheImpl(String url) async {
  final trimmed = url.trim();
  if (trimmed.isEmpty) return null;
  try {
    final file = File(p.join((await _ebookCacheDir()).path, _cacheFileName(trimmed)));
    if (!file.existsSync()) return null;
    final stat = file.statSync();
    if (stat.size <= 0) return null;
    return file.readAsBytesSync();
  } catch (_) {
    return null;
  }
}

Future<void> writeEbookFileCacheImpl(String url, Uint8List bytes) async {
  final trimmed = url.trim();
  if (trimmed.isEmpty || bytes.isEmpty) return;
  try {
    final file = File(p.join((await _ebookCacheDir()).path, _cacheFileName(trimmed)));
    await file.writeAsBytes(bytes, flush: true);
  } catch (_) {
    // Cache write failure must not block reading.
  }
}
