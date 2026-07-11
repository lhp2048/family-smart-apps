import 'dart:js_interop';

import 'package:pdfx/src/renderer/interfaces/platform.dart';
import 'package:pdfx/src/renderer/web/platform.dart';

@JS('ensureFamilyPdfJs')
external JSPromise<JSAny?> _ensureFamilyPdfJs();

var _pdfxWebRegistered = false;

Future<void> ensurePdfJsReady() async {
  await _ensureFamilyPdfJs().toDart;
  if (!_pdfxWebRegistered) {
    PdfxPlatform.instance = PdfxWeb();
    _pdfxWebRegistered = true;
  }
}
