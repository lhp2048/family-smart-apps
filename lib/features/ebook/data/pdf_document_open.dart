import 'dart:typed_data';

import 'package:pdfx/pdfx.dart';

import 'pdfjs_web_loader.dart';

/// Opens a PDF for native reading: URL stream on Web, bytes on IO.
Future<PdfDocument> openEbookPdfDocument({
  Uint8List? bytes,
  String? url,
  void Function(int loaded, int total)? onStreamProgress,
}) async {
  await ensurePdfJsReady();

  final trimmedUrl = url?.trim() ?? '';
  if (trimmedUrl.isNotEmpty) {
    final scope = PdfjsUrlLoadProgressScope.start(onStreamProgress);
    try {
      return await PdfDocument.openFile(trimmedUrl);
    } finally {
      scope.end();
    }
  }
  if (bytes == null || bytes.isEmpty) {
    throw ArgumentError('bytes or url is required');
  }
  return PdfDocument.openData(bytes);
}
