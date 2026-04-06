import 'dart:typed_data';

/// 练习卷大图预览参数（由列表页生成 PNG 后传入）
class SyllableSheetPreviewArgs {
  const SyllableSheetPreviewArgs({
    required this.title,
    required this.pngBytes,
  });

  final String title;
  final Uint8List pngBytes;
}
