import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/ebook_reader_providers.dart';
import 'ebook_reader_zoom_viewport.dart';

class TextNativeReader extends ConsumerStatefulWidget {
  const TextNativeReader({super.key, required this.text});

  final String text;

  @override
  ConsumerState<TextNativeReader> createState() => _TextNativeReaderState();
}

class _TextNativeReaderState extends ConsumerState<TextNativeReader> {
  int _pageCount = 1;
  late double _pageHeight;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _pageHeight = MediaQuery.sizeOf(context).height * 0.55;
    _pageHeight = _pageHeight.clamp(320.0, 900.0);
    _pageCount = _estimatePageCount();
    ref.read(ebookReaderTextPageCountProvider.notifier).state = _pageCount;
  }

  int _estimatePageCount() {
    final charsPerPage = (_pageHeight / 18 * 42).round().clamp(400, 8000);
    return (widget.text.length / charsPerPage).ceil().clamp(1, 9999);
  }

  String _pageSlice(int page) {
    final charsPerPage = (_pageHeight / 18 * 42).round().clamp(400, 8000);
    final start = (page - 1) * charsPerPage;
    if (start >= widget.text.length) return '';
    final end = (start + charsPerPage).clamp(0, widget.text.length);
    return widget.text.substring(start, end);
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
    const style = TextStyle(
      color: Colors.white,
      height: 1.65,
      fontSize: 15,
      fontFamily: 'monospace',
    );

    if (viewMode == EbookReaderViewMode.scroll) {
      return EbookReaderZoomViewport(
        allowVerticalScroll: true,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: SelectableText(widget.text, style: style),
        ),
      );
    }

    return EbookReaderZoomViewport(
      onPageTurn: (forward) {
        if (forward) {
          _nextPage();
        } else {
          _prevPage();
        }
      },
      child: SizedBox(
        height: _pageHeight,
        width: double.infinity,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          physics: const NeverScrollableScrollPhysics(),
          child: SelectableText(_pageSlice(page), style: style),
        ),
      ),
    );
  }

  int get pageCount => _pageCount;
}
