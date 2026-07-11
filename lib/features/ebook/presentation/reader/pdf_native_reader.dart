import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfx/pdfx.dart';

import '../../data/pdf_document_open.dart';
import '../../data/pdf_load_progress.dart';
import '../../providers/ebook_reader_providers.dart';
import 'ebook_reader_zoom_viewport.dart';

class PdfNativeReader extends ConsumerStatefulWidget {
  const PdfNativeReader({
    super.key,
    this.bytes,
    this.url,
    this.onPageCountReady,
    this.onLoadProgress,
  }) : assert(bytes != null || url != null, 'bytes or url is required');

  final Uint8List? bytes;
  final String? url;
  final ValueChanged<int>? onPageCountReady;
  final ValueChanged<PdfLoadProgress>? onLoadProgress;

  bool get _usesUrl => url != null && url!.trim().isNotEmpty;

  @override
  ConsumerState<PdfNativeReader> createState() => _PdfNativeReaderState();
}

class _PdfNativeReaderState extends ConsumerState<PdfNativeReader> {
  late final PdfController _controller;
  var _firstPagePainted = false;

  void _report(PdfLoadStage stage, int percent, String message) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.onLoadProgress?.call(
        PdfLoadProgress(stage: stage, percent: percent, message: message),
      );
    });
  }

  void _onLoadingStateChanged() {
    switch (_controller.loadingState.value) {
      case PdfLoadingState.loading:
        if (widget._usesUrl) {
          _report(PdfLoadStage.stream, 35, '正在解析 PDF 结构…');
        } else {
          _report(PdfLoadStage.document, 78, '正在解析 PDF 结构…');
        }
      case PdfLoadingState.success:
      case PdfLoadingState.error:
        break;
    }
  }

  void _onStreamBytesProgress(int loaded, int total) {
    final percent = mapStreamPercent(loaded, total);
    final detail = total > 0
        ? '正在按需加载 ${formatByteProgress(loaded, null)}（全书 ${formatByteProgress(total, null)}）'
        : '正在按需加载 ${formatByteProgress(loaded, null)}…';
    _report(PdfLoadStage.stream, percent, detail);
  }

  @override
  void initState() {
    super.initState();
    if (widget._usesUrl) {
      _report(PdfLoadStage.stream, 18, '正在流式加载 PDF…');
    } else {
      _report(PdfLoadStage.document, 74, '正在打开 PDF 文档…');
    }
    _controller = PdfController(
      document: openEbookPdfDocument(
        bytes: widget.bytes,
        url: widget.url,
        onStreamProgress: widget._usesUrl ? _onStreamBytesProgress : null,
      ),
    );
    _controller.loadingState.addListener(_onLoadingStateChanged);
  }

  @override
  void dispose() {
    _controller.loadingState.removeListener(_onLoadingStateChanged);
    _controller.dispose();
    super.dispose();
  }

  void _markPageReady() {
    if (_firstPagePainted) return;
    _firstPagePainted = true;
    _report(PdfLoadStage.done, 100, '加载完成');
  }

  @override
  Widget build(BuildContext context) {
    final viewMode = ref.watch(ebookReaderViewModeProvider);
    ref.listen(ebookReaderPdfPageProvider, (previous, next) {
      if (_controller.page == next) return;
      _controller.jumpToPage(next);
    });

    final isPageMode = viewMode == EbookReaderViewMode.page;
    final renderPercent = widget._usesUrl ? 72 : 88;

    return EbookReaderZoomViewport(
      contentHandlesPageSwipe: isPageMode,
      allowVerticalScroll: !isPageMode,
      child: PdfView(
        controller: _controller,
        scrollDirection: isPageMode ? Axis.horizontal : Axis.vertical,
        pageSnapping: isPageMode,
        builders: const PdfViewBuilders<DefaultBuilderOptions>(
          options: DefaultBuilderOptions(),
          documentLoaderBuilder: _hiddenLoader,
          pageLoaderBuilder: _hiddenLoader,
        ),
        onPageChanged: (page) {
          ref.read(ebookReaderPdfPageProvider.notifier).state = page;
          _markPageReady();
        },
        onDocumentLoaded: (document) {
          widget.onPageCountReady?.call(document.pagesCount);
          _report(
            PdfLoadStage.pageRender,
            renderPercent,
            document.pagesCount <= 1
                ? '正在渲染第 1 页…'
                : '正在渲染第 1 / ${document.pagesCount} 页…',
          );
          // PhotoViewGallery 初次展示不会触发 onPageChanged(1)，需主动结束 loading。
          SchedulerBinding.instance.addPostFrameCallback((_) {
            if (!mounted || _firstPagePainted) return;
            _markPageReady();
          });
        },
        onDocumentError: (error) {
          widget.onLoadProgress?.call(
            PdfLoadProgress(
              stage: PdfLoadStage.error,
              percent: 0,
              message: formatPdfOpenError(error),
            ),
          );
        },
      ),
    );
  }
}

Widget _hiddenLoader(BuildContext context) => const SizedBox.shrink();
