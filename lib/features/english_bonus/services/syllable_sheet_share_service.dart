import 'dart:io';
import 'dart:ui' show Rect;

import 'package:flutter/foundation.dart';
import 'package:gal/gal.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// 练习卷 PNG：保存到相册/本机、系统分享（微信、QQ、邮件等由用户从分享面板选择）
class SyllableSheetShareService {
  SyllableSheetShareService._();

  static String _baseName(String title) {
    var t = title.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_').trim();
    t = t.replaceAll(RegExp(r'\s+'), '_');
    if (t.isEmpty) return 'syllable_sheet';
    return t.length > 48 ? t.substring(0, 48) : t;
  }

  /// 打开系统分享面板，可将图片发到微信、QQ、邮件等已安装应用
  static Future<void> sharePng({
    required Uint8List bytes,
    required String title,
    Rect? sharePositionOrigin,
  }) async {
    final name = '${_baseName(title)}.png';
    await SharePlus.instance.share(
      ShareParams(
        files: [
          XFile.fromData(
            bytes,
            mimeType: 'image/png',
            name: name,
          ),
        ],
        text: '英语音节分割练习卷',
        sharePositionOrigin: sharePositionOrigin,
        fileNameOverrides: [name],
      ),
    );
  }

  /// 保存图片：移动端 / macOS / Windows 写入系统相册（Gal）；Linux 或失败时写入下载/文档目录
  static Future<String> savePng({
    required Uint8List bytes,
    required String title,
  }) async {
    if (kIsWeb) {
      throw UnsupportedError('网页端请使用「分享」保存或发送');
    }

    final base = _baseName(title);

    if (Platform.isLinux) {
      return _saveToDownloadsOrDocuments(bytes, base);
    }

    try {
      final has = await Gal.hasAccess(toAlbum: true);
      final granted = has || await Gal.requestAccess(toAlbum: true);
      if (!granted) {
        throw Exception('未获得相册/媒体库写入权限');
      }
      await Gal.putImageBytes(bytes, name: base);
      return '已保存到相册';
    } on GalException catch (e) {
      if (Platform.isWindows || Platform.isMacOS) {
        return _saveToDownloadsOrDocuments(bytes, base);
      }
      throw Exception(_galErrorZh(e.type));
    }
  }

  static String _galErrorZh(GalExceptionType t) {
    return switch (t) {
      GalExceptionType.accessDenied => '没有相册访问权限',
      GalExceptionType.notEnoughSpace => '设备存储空间不足',
      GalExceptionType.notSupportedFormat => '不支持的图片格式',
      GalExceptionType.unexpected => '保存失败，请重试',
    };
  }

  static Future<String> _saveToDownloadsOrDocuments(
    Uint8List bytes,
    String base,
  ) async {
    final dir = await getDownloadsDirectory() ??
        await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, '$base.png');
    await File(path).writeAsBytes(bytes);
    return '已保存：$path';
  }
}
