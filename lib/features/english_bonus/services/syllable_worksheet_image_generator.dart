import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';

import '../data/syllable_worksheet_word.dart';
import '../presentation/widgets/syllable_worksheet_paper.dart';

/// 将 [SyllableWorksheetPaper] 栅格化为 PNG（A4 逻辑尺寸 595×842 pt）
class SyllableWorksheetImageGenerator {
  SyllableWorksheetImageGenerator._();

  static final Size _a4Logical = Size(
    SyllableWorksheetPaper.sheetWidth,
    SyllableWorksheetPaper.sheetHeight,
  );

  static final BoxConstraints _a4Tight = BoxConstraints.tight(_a4Logical);

  static Widget _tree(List<SyllableWorksheetWord> words) {
    return MediaQuery(
      data: MediaQueryData(
        size: _a4Logical,
        textScaler: TextScaler.linear(1),
      ),
      child: Material(
        color: Colors.white,
        child: SyllableWorksheetPaper(words: words),
      ),
    );
  }

  static bool _looksLikePng(Uint8List bytes) {
    return bytes.length >= 8 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47;
  }

  static Future<Uint8List> _pngFromImage(ui.Image image, String tag) async {
    try {
      final bd = await image.toByteData(format: ui.ImageByteFormat.png);
      if (bd == null) {
        throw StateError('PNG 编码失败：toByteData 返回 null（$tag）');
      }
      final out = bd.buffer.asUint8List();
      if (!_looksLikePng(out)) {
        throw StateError('输出不是有效 PNG 头（$tag，长度 ${out.length}）');
      }
      return out;
    } finally {
      image.dispose();
    }
  }

  /// [ScreenshotController.widgetToUiImage] + 安全 dispose / 空 byteData。
  static Future<Uint8List> _tryWidgetToUiImage(
    List<SyllableWorksheetWord> words, {
    required double pixelRatio,
  }) async {
    final w = _tree(words);
    final image = await ScreenshotController.widgetToUiImage(
      w,
      delay: const Duration(milliseconds: 2000),
      pixelRatio: pixelRatio,
      context: null,
      targetSize: _a4Logical,
    );
    return _pngFromImage(image, 'widgetToUiImage pr=$pixelRatio');
  }

  /// 测量 + 截图（兼容复杂约束）；内部仍可能因 byteData 为 null 失败。
  static Future<Uint8List> _tryCaptureFromLongWidget(
    List<SyllableWorksheetWord> words, {
    required double pixelRatio,
  }) async {
    final controller = ScreenshotController();
    final w = _tree(words);
    final bytes = await controller.captureFromLongWidget(
      w,
      delay: const Duration(milliseconds: 2000),
      pixelRatio: pixelRatio,
      context: null,
      constraints: _a4Tight,
    );
    if (!_looksLikePng(bytes)) {
      throw StateError('captureFromLongWidget 输出不是有效 PNG（长度 ${bytes.length}）');
    }
    return bytes;
  }

  /// 多策略、多 [pixelRatio]，解决部分桌面端 `toByteData` 为 null 或截图包单一路径失败的问题。
  static Future<Uint8List> generatePng(
    List<SyllableWorksheetWord> words, {
    double pixelRatio = 3,
  }) async {
    assert(words.length == 15);
    final ratios = <double>[];
    final seen = <double>{};
    for (final r in <double>[pixelRatio, 2.0, 1.0]) {
      if (seen.add(r)) ratios.add(r);
    }

    Object? last;
    for (final pr in ratios) {
      try {
        return await _tryWidgetToUiImage(words, pixelRatio: pr);
      } on Object catch (e) {
        last = e;
      }
      try {
        return await _tryCaptureFromLongWidget(words, pixelRatio: pr);
      } on Object catch (e) {
        last = e;
      }
    }
    throw StateError(
      '练习卷图片生成失败（已尝试 widgetToUiImage / captureFromLongWidget 与多档清晰度）。'
      '最后错误：$last',
    );
  }
}
