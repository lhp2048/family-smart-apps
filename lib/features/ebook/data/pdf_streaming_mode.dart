import 'pdf_streaming_mode_stub.dart'
    if (dart.library.html) 'pdf_streaming_mode_web.dart';

/// Platform PDF loading strategy:
/// - **Web**: HTTP Range + pdf.js URL streaming ([ebookPdfPreferUrlStreaming]).
/// - **IO** (Android / iOS / Windows / macOS): full download + disk cache
///   ([downloadEbookBytes] → [openData]), better for native pdfx and offline re-read.
bool get ebookPdfPreferUrlStreaming => ebookPdfPreferUrlStreamingImpl();
