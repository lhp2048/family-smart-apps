import 'dart:async';
import 'dart:typed_data';

import 'package:pdfx/src/renderer/interfaces/document.dart';
import 'package:pdfx/src/renderer/web/platform.dart';

Future<PdfDocument>? openPdfFileOnWeb(String filePath, {String? password}) {
  return PdfxWeb().openFile(filePath, password: password);
}

Future<PdfDocument>? openPdfDataOnWeb(
  FutureOr<Uint8List> data, {
  String? password,
}) {
  return PdfxWeb().openData(data, password: password);
}
