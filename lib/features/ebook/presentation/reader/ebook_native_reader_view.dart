import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/app_error_view.dart';
import '../../data/ebook_file_loader.dart';
import '../../data/ebook_models.dart';
import '../../data/pdf_load_progress.dart';
import '../../data/pdf_streaming_mode.dart';
import '../../data/pdfjs_web_loader.dart';
import '../../providers/ebook_reader_providers.dart';
import 'ebook_pdf_loading_panel.dart';
import 'ebook_reader_floating_toolbar.dart';
import 'ebook_reader_toolbar.dart';
import 'ebook_reader_zoom_viewport.dart';
import 'epub_native_reader.dart';
import 'markdown_native_reader.dart';
import 'pdf_native_reader.dart';
import 'text_native_reader.dart';

class EbookNativeReaderView extends ConsumerWidget {
  const EbookNativeReaderView({
    super.key,
    required this.fileUrl,
    required this.kind,
  });

  final String fileUrl;
  final EbookKind kind;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pdfPageCount = ref.watch(ebookReaderPdfPageCountProvider);
    final textPageCount = ref.watch(ebookReaderTextPageCountProvider);
    final epubChapterCount = ref.watch(ebookReaderEpubChapterCountProvider);

    return EbookReaderFloatingToolbarHost(
      reader: ClipRect(
        child: EbookReaderGestureHost(
          kind: kind,
          onPrevPage: () => _turnPage(ref, kind, forward: false,
              pdfPageCount: pdfPageCount,
              textPageCount: textPageCount,
              epubChapterCount: epubChapterCount),
          onNextPage: () => _turnPage(ref, kind, forward: true,
              pdfPageCount: pdfPageCount,
              textPageCount: textPageCount,
              epubChapterCount: epubChapterCount),
          child: _ReaderBody(fileUrl: fileUrl, kind: kind),
        ),
      ),
      toolbar: EbookReaderToolbar(
        kind: kind,
        pdfPageCount: pdfPageCount,
        textPageCount: textPageCount,
        epubChapterCount: epubChapterCount,
        onPdfPrev: () {
          final page = ref.read(ebookReaderPdfPageProvider);
          if (page > 1) {
            ref.read(ebookReaderPdfPageProvider.notifier).state = page - 1;
          }
        },
        onPdfNext: () {
          final page = ref.read(ebookReaderPdfPageProvider);
          if (pdfPageCount > 0 && page < pdfPageCount) {
            ref.read(ebookReaderPdfPageProvider.notifier).state = page + 1;
          }
        },
        onTextPrev: () {
          final page = ref.read(ebookReaderTextPageProvider);
          if (page > 1) {
            ref.read(ebookReaderTextPageProvider.notifier).state = page - 1;
          }
        },
        onTextNext: () {
          final page = ref.read(ebookReaderTextPageProvider);
          if (page < textPageCount) {
            ref.read(ebookReaderTextPageProvider.notifier).state = page + 1;
          }
        },
        onEpubPrev: () {
          final chapter = ref.read(ebookReaderEpubChapterProvider);
          if (chapter > 0) {
            ref.read(ebookReaderEpubChapterProvider.notifier).state =
                chapter - 1;
          }
        },
        onEpubNext: () {
          final chapter = ref.read(ebookReaderEpubChapterProvider);
          if (epubChapterCount > 0 && chapter < epubChapterCount - 1) {
            ref.read(ebookReaderEpubChapterProvider.notifier).state =
                chapter + 1;
          }
        },
      ),
    );
  }
}

void _turnPage(
  WidgetRef ref,
  EbookKind kind, {
  required bool forward,
  required int pdfPageCount,
  required int textPageCount,
  required int epubChapterCount,
}) {
  switch (kind) {
    case EbookKind.pdf:
      final page = ref.read(ebookReaderPdfPageProvider);
      if (forward) {
        if (pdfPageCount > 0 && page < pdfPageCount) {
          ref.read(ebookReaderPdfPageProvider.notifier).state = page + 1;
        }
      } else if (page > 1) {
        ref.read(ebookReaderPdfPageProvider.notifier).state = page - 1;
      }
    case EbookKind.markdown:
    case EbookKind.text:
      final page = ref.read(ebookReaderTextPageProvider);
      if (forward) {
        if (page < textPageCount) {
          ref.read(ebookReaderTextPageProvider.notifier).state = page + 1;
        }
      } else if (page > 1) {
        ref.read(ebookReaderTextPageProvider.notifier).state = page - 1;
      }
    case EbookKind.epub:
      final chapter = ref.read(ebookReaderEpubChapterProvider);
      if (forward) {
        if (epubChapterCount > 0 && chapter < epubChapterCount - 1) {
          ref.read(ebookReaderEpubChapterProvider.notifier).state = chapter + 1;
        }
      } else if (chapter > 0) {
        ref.read(ebookReaderEpubChapterProvider.notifier).state = chapter - 1;
      }
    default:
      break;
  }
}

class _ReaderBody extends ConsumerWidget {
  const _ReaderBody({
    required this.fileUrl,
    required this.kind,
  });

  final String fileUrl;
  final EbookKind kind;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    switch (kind) {
      case EbookKind.markdown:
        return _TextContentReader(
          fileUrl: fileUrl,
          builder: (text) => MarkdownNativeReader(markdown: text),
        );
      case EbookKind.text:
        return _TextContentReader(
          fileUrl: fileUrl,
          builder: (text) => TextNativeReader(text: text),
        );
      case EbookKind.pdf:
        return _PdfContentReader(fileUrl: fileUrl);
      case EbookKind.epub:
        return _EpubContentReader(fileUrl: fileUrl);
      default:
        return Center(
          child: Text(
            '暂不支持此格式',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.75)),
          ),
        );
    }
  }
}

class _TextContentReader extends ConsumerWidget {
  const _TextContentReader({
    required this.fileUrl,
    required this.builder,
  });

  final String fileUrl;
  final Widget Function(String text) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textAsync = ref.watch(ebookFileTextProvider(fileUrl));
    return textAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(
        child: Text(
          '$err',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.75)),
        ),
      ),
      data: builder,
    );
  }
}

class _PdfContentReader extends ConsumerStatefulWidget {
  const _PdfContentReader({required this.fileUrl});

  final String fileUrl;

  @override
  ConsumerState<_PdfContentReader> createState() => _PdfContentReaderState();
}

class _PdfContentReaderState extends ConsumerState<_PdfContentReader> {
  PdfLoadProgress _progress = const PdfLoadProgress.initial();
  Uint8List? _bytes;
  String? _streamUrl;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  void _setProgress(PdfLoadProgress progress) {
    if (!mounted) return;
    setState(() => _progress = progress);
  }

  String _requireFileUrl() {
    final url = widget.fileUrl.trim();
    if (url.isEmpty) {
      throw StateError('PDF 文件地址无效，无法打开');
    }
    return url;
  }

  void _resetPdfReaderProviders() {
    ref.read(ebookReaderPdfPageProvider.notifier).state = 1;
    ref.read(ebookReaderPdfPageCountProvider.notifier).state = 0;
  }

  void _retry() {
    setState(() {
      _error = null;
      _bytes = null;
      _streamUrl = null;
      _progress = const PdfLoadProgress.initial();
    });
    _resetPdfReaderProviders();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    try {
      _setProgress(
        const PdfLoadProgress(
          stage: PdfLoadStage.engine,
          percent: 2,
          message: '正在加载 PDF 引擎…',
        ),
      );
      await ensurePdfJsReady();
      _setProgress(
        const PdfLoadProgress(
          stage: PdfLoadStage.engine,
          percent: 12,
          message: 'PDF 引擎就绪',
        ),
      );

      if (ebookPdfPreferUrlStreaming) {
        final url = _requireFileUrl();
        if (!mounted) return;
        setState(() {
          _streamUrl = url;
          _progress = const PdfLoadProgress(
            stage: PdfLoadStage.stream,
            percent: 15,
            message: '正在流式连接 PDF…',
          );
        });
        return;
      }

      _setProgress(
        const PdfLoadProgress(
          stage: PdfLoadStage.download,
          percent: 12,
          message: '正在连接文件…',
        ),
      );

      final url = _requireFileUrl();

      final bytes = await downloadEbookBytes(
        url,
        onLoadedFromCache: (length) {
          _setProgress(
            PdfLoadProgress(
              stage: PdfLoadStage.download,
              percent: 72,
              message: '已从本地缓存加载（${formatByteProgress(length, length)}）',
            ),
          );
        },
        onProgress: (received, total) {
          final percent = mapDownloadPercent(received, total);
          final detail = total != null && total > 0
              ? '正在下载 ${(received * 100 / total).round()}%（${formatByteProgress(received, total)}）'
              : '正在下载 ${formatByteProgress(received, total)}…';
          _setProgress(
            PdfLoadProgress(
              stage: PdfLoadStage.download,
              percent: percent,
              message: detail,
            ),
          );
        },
      );

      if (!mounted) return;
      setState(() {
        _bytes = bytes;
        _progress = const PdfLoadProgress(
          stage: PdfLoadStage.document,
          percent: 72,
          message: '下载完成，正在打开文档…',
        );
      });
    } catch (e) {
      if (!mounted) return;
      final message = _progress.stage == PdfLoadStage.engine
          ? 'PDF 引擎加载失败，请检查网络或刷新重试'
          : formatPdfOpenError(e);
      setState(() {
        _error = e;
        _progress = PdfLoadProgress(
          stage: PdfLoadStage.error,
          percent: _progress.percent,
          message: message,
        );
      });
    }
  }

  void _onReaderProgress(PdfLoadProgress progress) {
    if (progress.isComplete || progress.stage == PdfLoadStage.pageRender) {
      _setProgress(progress);
      return;
    }
    if (progress.isError) {
      if (!mounted) return;
      setState(() {
        _error = progress.message;
        _progress = progress;
      });
      return;
    }
    if (progress.percent >= _progress.percent) {
      _setProgress(progress);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Theme(
        data: ThemeData.dark(),
        child: AppErrorView(
          message: _progress.message,
          onRetry: _retry,
        ),
      );
    }

    if (_bytes == null && _streamUrl == null) {
      return EbookPdfLoadingPanel(progress: _progress);
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        PdfNativeReader(
          bytes: _bytes,
          url: _streamUrl,
          onPageCountReady: (count) {
            ref.read(ebookReaderPdfPageCountProvider.notifier).state = count;
          },
          onLoadProgress: _onReaderProgress,
        ),
        if (!_progress.isComplete)
          EbookPdfLoadingPanel(progress: _progress),
      ],
    );
  }
}

class _EpubContentReader extends ConsumerWidget {
  const _EpubContentReader({required this.fileUrl});

  final String fileUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chaptersAsync = ref.watch(ebookEpubChaptersProvider(fileUrl));
    return chaptersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(
        child: Text(
          '$err',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.75)),
        ),
      ),
      data: (chapters) {
        ref.read(ebookReaderEpubChapterCountProvider.notifier).state =
            chapters.length;
        return EpubNativeReader(chapters: chapters);
      },
    );
  }
}
