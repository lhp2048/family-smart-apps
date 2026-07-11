import 'dart:typed_data';

import 'package:epub_plus/epub_plus.dart' as epub;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

import '../../providers/ebook_reader_providers.dart';
import 'ebook_reader_zoom_viewport.dart';

class NativeEpubChapter {
  const NativeEpubChapter({required this.title, required this.html});

  final String title;
  final String html;
}

Future<List<NativeEpubChapter>> parseEpubChapters(Uint8List bytes) async {
  final book = await epub.EpubReader.readBook(bytes);
  final chapters = <NativeEpubChapter>[];

  void walk(epub.EpubChapter chapter) {
    final html = chapter.htmlContent?.trim() ?? '';
    if (html.isNotEmpty) {
      chapters.add(
        NativeEpubChapter(
          title: chapter.title?.trim().isNotEmpty == true
              ? chapter.title!.trim()
              : '章节',
          html: html,
        ),
      );
    }
    for (final child in chapter.subChapters) {
      walk(child);
    }
  }

  for (final chapter in book.chapters) {
    walk(chapter);
  }

  if (chapters.isEmpty) {
    chapters.add(
      const NativeEpubChapter(title: '正文', html: '<p>暂无章节内容</p>'),
    );
  }
  return chapters;
}

class EpubNativeReader extends ConsumerWidget {
  const EpubNativeReader({
    super.key,
    required this.chapters,
  });

  final List<NativeEpubChapter> chapters;

  void _prevPage(WidgetRef ref) {
    final current = ref.read(ebookReaderEpubChapterProvider);
    if (current <= 0) return;
    ref.read(ebookReaderEpubChapterProvider.notifier).state = current - 1;
  }

  void _nextPage(WidgetRef ref) {
    final current = ref.read(ebookReaderEpubChapterProvider);
    if (current >= chapters.length - 1) return;
    ref.read(ebookReaderEpubChapterProvider.notifier).state = current + 1;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewMode = ref.watch(ebookReaderViewModeProvider);
    final index = ref
        .watch(ebookReaderEpubChapterProvider)
        .clamp(0, chapters.length - 1);

    if (viewMode == EbookReaderViewMode.scroll) {
      return EbookReaderZoomViewport(
        allowVerticalScroll: true,
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: chapters.length,
          separatorBuilder: (context, index) => const SizedBox(height: 24),
          itemBuilder: (context, i) {
            final chapter = chapters[i];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chapter.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                HtmlWidget(
                  chapter.html,
                  textStyle: const TextStyle(color: Colors.white, height: 1.65),
                ),
              ],
            );
          },
        ),
      );
    }

    final chapter = chapters[index];
    return EbookReaderZoomViewport(
      onPageTurn: (forward) {
        if (forward) {
          _nextPage(ref);
        } else {
          _prevPage(ref);
        }
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              chapter.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            HtmlWidget(
              chapter.html,
              textStyle: const TextStyle(color: Colors.white, height: 1.65),
            ),
          ],
        ),
      ),
    );
  }
}
