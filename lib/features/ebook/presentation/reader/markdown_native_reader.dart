import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/ebook_reader_providers.dart';
import 'ebook_reader_zoom_viewport.dart';

class MarkdownNativeReader extends ConsumerStatefulWidget {
  const MarkdownNativeReader({super.key, required this.markdown});

  final String markdown;

  @override
  ConsumerState<MarkdownNativeReader> createState() =>
      _MarkdownNativeReaderState();
}

class _MarkdownNativeReaderState extends ConsumerState<MarkdownNativeReader> {
  final GlobalKey _contentKey = GlobalKey();
  int _pageCount = 1;
  double _pageHeight = 640;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) => _measurePages());
  }

  void _measurePages() {
    final context = _contentKey.currentContext;
    if (context == null) return;
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    final viewportHeight = MediaQuery.sizeOf(this.context).height * 0.55;
    final height = viewportHeight.clamp(320.0, 900.0);
    final totalHeight = box.size.height;
    final count = (totalHeight / height).ceil().clamp(1, 9999);
    if (count != _pageCount || height != _pageHeight) {
      setState(() {
        _pageHeight = height;
        _pageCount = count;
      });
      ref.read(ebookReaderTextPageCountProvider.notifier).state = count;
    }
  }

  void _prevPage() {
    final current = ref.read(ebookReaderTextPageProvider);
    if (current <= 1) return;
    ref.read(ebookReaderTextPageProvider.notifier).state = current - 1;
  }

  void _nextPage() {
    final current = ref.read(ebookReaderTextPageProvider);
    if (current >= _pageCount) return;
    ref.read(ebookReaderTextPageProvider.notifier).state = current + 1;
  }

  @override
  Widget build(BuildContext context) {
    final viewMode = ref.watch(ebookReaderViewModeProvider);
    final page = ref.watch(ebookReaderTextPageProvider);
    final style = MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
      p: const TextStyle(color: Colors.white, height: 1.65, fontSize: 15),
      h1: const TextStyle(color: Colors.white, fontSize: 24),
      h2: const TextStyle(color: Colors.white, fontSize: 20),
      h3: const TextStyle(color: Colors.white, fontSize: 18),
      code: TextStyle(
        color: Colors.white.withValues(alpha: 0.9),
        backgroundColor: Colors.white.withValues(alpha: 0.08),
      ),
    );

    final body = MarkdownBody(
      key: _contentKey,
      data: widget.markdown,
      styleSheet: style,
      selectable: true,
    );

    if (viewMode == EbookReaderViewMode.scroll) {
      return EbookReaderZoomViewport(
        allowVerticalScroll: true,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: body,
        ),
      );
    }

    final offset = (page - 1) * _pageHeight;
    return EbookReaderZoomViewport(
      onPageTurn: (forward) {
        if (forward) {
          _nextPage();
        } else {
          _prevPage();
        }
      },
      child: ClipRect(
        child: SizedBox(
          height: _pageHeight,
          width: double.infinity,
          child: Transform.translate(
            offset: Offset(0, -offset),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: body,
            ),
          ),
        ),
      ),
    );
  }

  int get pageCount => _pageCount;
}
