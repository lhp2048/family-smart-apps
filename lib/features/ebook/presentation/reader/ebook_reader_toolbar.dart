import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/ebook_models.dart';
import '../../providers/ebook_reader_providers.dart';

class EbookReaderToolbar extends ConsumerWidget {
  const EbookReaderToolbar({
    super.key,
    required this.kind,
    this.pdfPageCount = 0,
    this.textPageCount = 1,
    this.epubChapterCount = 0,
    this.onPdfPrev,
    this.onPdfNext,
    this.onTextPrev,
    this.onTextNext,
    this.onEpubPrev,
    this.onEpubNext,
  });

  final EbookKind kind;
  final int pdfPageCount;
  final int textPageCount;
  final int epubChapterCount;
  final VoidCallback? onPdfPrev;
  final VoidCallback? onPdfNext;
  final VoidCallback? onTextPrev;
  final VoidCallback? onTextNext;
  final VoidCallback? onEpubPrev;
  final VoidCallback? onEpubNext;

  bool get _supportsPageMode {
    switch (kind) {
      case EbookKind.pdf:
      case EbookKind.epub:
      case EbookKind.markdown:
      case EbookKind.text:
        return true;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewMode = ref.watch(ebookReaderViewModeProvider);
    final zoom = ref.watch(ebookReaderZoomProvider);
    final pdfPage = ref.watch(ebookReaderPdfPageProvider);
    final textPage = ref.watch(ebookReaderTextPageProvider);
    final epubChapter = ref.watch(ebookReaderEpubChapterProvider);
    final zoomLabel = '${(zoom * 100).round()}%';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_supportsPageMode) ...[
          _IconTool(
            icon: Icons.view_stream_rounded,
            tooltip: '滚动',
            active: viewMode == EbookReaderViewMode.scroll,
            onTap: () {
              ref.read(ebookReaderZoomProvider.notifier).state = 1;
              ref.read(ebookReaderViewModeProvider.notifier).state =
                  EbookReaderViewMode.scroll;
            },
          ),
          _IconTool(
            icon: Icons.menu_book_rounded,
            tooltip: '翻页',
            active: viewMode == EbookReaderViewMode.page,
            onTap: () {
              ref.read(ebookReaderZoomProvider.notifier).state = 1;
              ref.read(ebookReaderViewModeProvider.notifier).state =
                  EbookReaderViewMode.page;
            },
          ),
          if (viewMode == EbookReaderViewMode.page) ...[
            _divider,
            _MiniIconButton(
              icon: Icons.chevron_left_rounded,
              onPressed: _canPrev(pdfPage, textPage, epubChapter)
                  ? _handlePrev
                  : null,
            ),
            Text(
              _pageIndicator(pdfPage, textPage, epubChapter),
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.72),
                fontSize: 11,
              ),
            ),
            _MiniIconButton(
              icon: Icons.chevron_right_rounded,
              onPressed: _canNext(pdfPage, textPage, epubChapter)
                  ? _handleNext
                  : null,
            ),
          ],
          _divider,
        ],
        _MiniIconButton(
          icon: Icons.remove_rounded,
          tooltip: '缩小',
          onPressed: () {
            ref.read(ebookReaderZoomProvider.notifier).state =
                (zoom - 0.25).clamp(0.5, 3.0);
          },
        ),
        Text(
          zoomLabel,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.72),
            fontSize: 11,
          ),
        ),
        _MiniIconButton(
          icon: Icons.add_rounded,
          tooltip: '放大',
          onPressed: () {
            ref.read(ebookReaderZoomProvider.notifier).state =
                (zoom + 0.25).clamp(0.5, 3.0);
          },
        ),
        _MiniIconButton(
          icon: Icons.fit_screen_rounded,
          tooltip: '重置缩放',
          onPressed: () {
            ref.read(ebookReaderZoomProvider.notifier).state = 1;
          },
        ),
      ],
    );
  }

  static const _divider = SizedBox(
    width: 1,
    height: 18,
    child: DecoratedBox(
      decoration: BoxDecoration(color: Color(0x22FFFFFF)),
    ),
  );

  bool _canPrev(int pdfPage, int textPage, int epubChapter) {
    switch (kind) {
      case EbookKind.pdf:
        return pdfPage > 1;
      case EbookKind.markdown:
      case EbookKind.text:
        return textPage > 1;
      case EbookKind.epub:
        return epubChapter > 0;
      default:
        return false;
    }
  }

  bool _canNext(int pdfPage, int textPage, int epubChapter) {
    switch (kind) {
      case EbookKind.pdf:
        return pdfPageCount > 0 && pdfPage < pdfPageCount;
      case EbookKind.markdown:
      case EbookKind.text:
        return textPage < textPageCount;
      case EbookKind.epub:
        return epubChapterCount > 0 && epubChapter < epubChapterCount - 1;
      default:
        return false;
    }
  }

  void _handlePrev() {
    switch (kind) {
      case EbookKind.pdf:
        onPdfPrev?.call();
      case EbookKind.markdown:
      case EbookKind.text:
        onTextPrev?.call();
      case EbookKind.epub:
        onEpubPrev?.call();
      default:
        break;
    }
  }

  void _handleNext() {
    switch (kind) {
      case EbookKind.pdf:
        onPdfNext?.call();
      case EbookKind.markdown:
      case EbookKind.text:
        onTextNext?.call();
      case EbookKind.epub:
        onEpubNext?.call();
      default:
        break;
    }
  }

  String _pageIndicator(int pdfPage, int textPage, int epubChapter) {
    switch (kind) {
      case EbookKind.pdf:
        return pdfPageCount > 0 ? '$pdfPage/$pdfPageCount' : 'PDF';
      case EbookKind.markdown:
      case EbookKind.text:
        return '$textPage/$textPageCount';
      case EbookKind.epub:
        return epubChapterCount > 0
            ? '${epubChapter + 1}/$epubChapterCount'
            : 'EP';
      default:
        return '';
    }
  }
}

class _IconTool extends StatelessWidget {
  const _IconTool({
    required this.icon,
    required this.tooltip,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? const Color(0x736366F1) : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            size: 16,
            color: active ? Colors.white : Colors.white54,
          ),
        ),
      ),
    );
  }
}

class _MiniIconButton extends StatelessWidget {
  const _MiniIconButton({
    required this.icon,
    required this.onPressed,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final btn = InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        width: 28,
        height: 28,
        child: Icon(
          icon,
          size: 18,
          color: onPressed != null ? Colors.white70 : Colors.white24,
        ),
      ),
    );
    if (tooltip == null) return btn;
    return Tooltip(message: tooltip!, child: btn);
  }
}
