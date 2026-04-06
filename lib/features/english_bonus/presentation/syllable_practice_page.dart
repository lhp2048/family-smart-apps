import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app.dart' show rootScaffoldMessengerKey;
import '../../../core/mock/mock_data_notifier.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/shell_screen_header.dart';
import '../../../features/dashboard/providers/family_api_base_url_provider.dart';
import '../../../shared/providers/syllable_remote_providers.dart';
import '../data/syllable_generated_sheet_record.dart';
import '../data/syllable_sheet_api_mapper.dart';
import '../data/syllable_sheet_item.dart';
import '../data/syllable_sheet_latest.dart';
import '../data/syllable_sheet_preview_args.dart';
import '../data/syllable_worksheet_mock.dart';
import '../data/syllable_worksheet_word.dart';
import '../services/syllable_worksheet_image_generator.dart';
import 'widgets/syllable_worksheet_paper.dart';

const Color _kCard = Color(0xFF1E1E28);
const Color _kPaperBorder = Color(0xFFBDBDBD);
const double _kA4Ratio = 210 / 297;
const Color _kAccent = Color(0xFF81D4FA);

class SyllablePracticePage extends ConsumerStatefulWidget {
  const SyllablePracticePage({super.key});

  static String chineseTitleFromSheetDateId(String id) {
    if (id.length != 8) return id;
    final y = int.tryParse(id.substring(0, 4));
    final m = int.tryParse(id.substring(4, 6));
    final d = int.tryParse(id.substring(6, 8));
    if (y == null || m == null || d == null) return id;
    return '$y年$m月$d日';
  }

  static List<SyllableSheetItem> itemsFromRecords(
    List<SyllableGeneratedSheetRecord> records,
  ) {
    return records
        .map(
          (r) => SyllableSheetItem(
            id: r.sheetDateId,
            title: chineseTitleFromSheetDateId(r.sheetDateId),
            subtitle: '英语音节分割 · 15 题',
          ),
        )
        .toList();
  }

  @override
  ConsumerState<SyllablePracticePage> createState() =>
      _SyllablePracticePageState();
}

String _remoteSheetDisplayTitle(SyllableLatestSheet s) {
  final id = s.sheetId.trim();
  if (id.length == 8 && RegExp(r'^\d{8}$').hasMatch(id)) {
    return SyllablePracticePage.chineseTitleFromSheetDateId(id);
  }
  if (id.isNotEmpty) return id;
  return '最新练习卷';
}

class _SyllablePracticePageState extends ConsumerState<SyllablePracticePage> {
  bool _generating = false;
  bool _exportBusy = false;
  OverlayEntry? _exportOverlayEntry;
  final ValueNotifier<String> _exportOverlayLine = ValueNotifier<String>('');

  @override
  void dispose() {
    _removeExportOverlay();
    _exportOverlayLine.dispose();
    super.dispose();
  }

  void _removeExportOverlay() {
    _exportOverlayEntry?.remove();
    _exportOverlayEntry = null;
  }

  void _ensureExportOverlayMounted(BuildContext anchor) {
    if (_exportOverlayEntry != null) return;
    final nav = Navigator.maybeOf(anchor, rootNavigator: true);
    final overlay = Overlay.maybeOf(anchor, rootOverlay: true) ??
        nav?.overlay ??
        Overlay.maybeOf(anchor);
    if (overlay == null) return;
    _exportOverlayEntry = OverlayEntry(
      builder: (ctx) => ValueListenableBuilder<String>(
        valueListenable: _exportOverlayLine,
        builder: (ctx, text, _) {
          return Positioned.fill(
            child: ColoredBox(
              color: Colors.black.withValues(alpha: 0.45),
              child: Center(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 24,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 18),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 260),
                          child: Text(
                            text,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey.shade900,
                              fontSize: 15,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
    overlay.insert(_exportOverlayEntry!);
  }

  void _syllableGenSnack(
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    rootScaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: duration,
      ),
    );
  }

  void _syllableHideSnack() {
    rootScaffoldMessengerKey.currentState?.hideCurrentSnackBar();
  }

  Future<void> _openPreviewWithWords(
    BuildContext context,
    String previewTitle,
    List<SyllableWorksheetWord> words,
  ) async {
    if (_exportBusy) return;
    if (syllableFilledWordCount(words) == 0) {
      if (!mounted) return;
      _syllableGenSnack('没有可用的单词，无法生成试卷');
      return;
    }
    final padded = padSyllableWordsForWorksheet(words);
    if (!mounted) return;
    setState(() => _exportBusy = true);
    _syllableHideSnack();
    _exportOverlayLine.value = '开始生成试卷图片…';
    _ensureExportOverlayMounted(context);
    // 与下一条提示须间隔开，否则 Scaffold 会立刻顶替上一条，用户看不到「开始生成」
    _syllableGenSnack(
      '开始生成试卷图片…',
      duration: const Duration(seconds: 3),
    );
    try {
      await Future<void>.delayed(const Duration(milliseconds: 900));
      if (!mounted) return;
      await WidgetsBinding.instance.endOfFrame;
      _exportOverlayLine.value = '正在渲染 A4 版面，请稍候…';
      _syllableGenSnack(
        '正在渲染 A4 版面，请稍候…',
        duration: const Duration(seconds: 12),
      );
      // 给一帧时间画出遮罩文案与 SnackBar，再进入可能长时间阻塞主线程的离屏渲染
      await Future<void>.delayed(const Duration(milliseconds: 280));
      if (!mounted) return;
      await WidgetsBinding.instance.endOfFrame;
      final bytes = await SyllableWorksheetImageGenerator.generatePng(padded);
      if (!mounted) return;
      _removeExportOverlay();
      _syllableGenSnack('试卷图片已生成，正在打开预览');
      await Future<void>.delayed(const Duration(milliseconds: 400));
      if (!context.mounted) return;
      context.push(
        '/english-bonus/sheet-preview',
        extra: SyllableSheetPreviewArgs(
          title: previewTitle,
          pngBytes: bytes,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      _syllableGenSnack(
        '试卷生成失败：$e',
        duration: const Duration(seconds: 8),
      );
    } finally {
      if (mounted) {
        _removeExportOverlay();
        setState(() => _exportBusy = false);
      }
    }
  }

  Future<void> _openPreview(BuildContext context, SyllableSheetItem item) async {
    final words = SyllableWorksheetMock.wordsForSheet(item.id);
    await _openPreviewWithWords(context, '${item.title} 练习卷', words);
  }

  void _openPreviewFromMemoryCache() {
    var snap = ref.read(syllableLatestSheetMemoryCacheProvider);
    snap ??= ref.read(syllableLatestSheetAsyncProvider).valueOrNull;
    if (snap == null) {
      _syllableGenSnack('暂无已缓存的词表，请等待拉取完成');
      return;
    }
    if (syllableFilledWordCount(snap.words) == 0) {
      _syllableGenSnack('没有可用的单词，无法生成试卷');
      return;
    }
    final title = _remoteSheetDisplayTitle(snap);
    final paperWords = padSyllableWordsForWorksheet(snap.words);
    _openPreviewWithWords(context, '$title 练习卷', paperWords);
  }

  Future<void> _generateToday() async {
    final notifier = ref.read(mockDataNotifierProvider.notifier);
    if (notifier.hasSyllableSheetForDate(DateTime.now())) {
      if (!mounted) return;
      rootScaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(content: Text('今日练习卷已生成，请在列表中打开')),
      );
      return;
    }
    setState(() => _generating = true);
    try {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      notifier.recordSyllableSheetGenerated(DateTime.now());
      if (!mounted) return;
      rootScaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(content: Text('今日练习卷已生成')),
      );
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  Widget _remoteWordSheetCard(SyllableLatestSheet sheet) {
    final n = syllableFilledWordCount(sheet.words);
    if (n == 0) return const SizedBox.shrink();
    final title = _remoteSheetDisplayTitle(sheet);
    final paperWords = padSyllableWordsForWorksheet(sheet.words);
    return _RemotePracticeWordSheetCard(
      sheetTitle: title,
      paperWords: paperWords,
      filledWordCount: n,
      exportBusy: _exportBusy,
      onWordRowTap: _openPreviewFromMemoryCache,
    );
  }

  Widget _remoteWordListView(SyllableLatestSheet sheet) {
    final n = syllableFilledWordCount(sheet.words);
    if (n == 0) {
      return _RemoteEmptyState(
        onRefresh: () => ref.invalidate(syllableLatestSheetAsyncProvider),
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [_remoteWordSheetCard(sheet)],
    );
  }

  Widget _buildRemoteBody(
    AsyncValue<SyllableLatestSheet> asyncSheet,
    SyllableLatestSheet? cached,
  ) {
    if (asyncSheet.isLoading) {
      if (cached != null && syllableFilledWordCount(cached.words) > 0) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const LinearProgressIndicator(minHeight: 2),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [_remoteWordSheetCard(cached)],
              ),
            ),
          ],
        );
      }
      return const Center(child: CircularProgressIndicator());
    }

    return asyncSheet.when(
      error: (e, _) {
        if (cached != null && syllableFilledWordCount(cached.words) > 0) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  '刷新失败，以下为已缓存词表：$e',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.55),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ),
              _remoteWordSheetCard(cached),
            ],
          );
        }
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '加载失败：$e',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () =>
                      ref.invalidate(syllableLatestSheetAsyncProvider),
                  child: const Text('重试'),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      data: (sheet) {
        final n = syllableFilledWordCount(sheet.words);
        if (n == 0) {
          return _RemoteEmptyState(
            onRefresh: () => ref.invalidate(syllableLatestSheetAsyncProvider),
          );
        }
        return _remoteWordListView(sheet);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final apiOn = ref.watch(familyApiIsConfiguredProvider);

    if (apiOn) {
      final asyncSheet = ref.watch(syllableLatestSheetAsyncProvider);
      final cachedSheet = ref.watch(syllableLatestSheetMemoryCacheProvider);
      ref.listen(syllableLatestSheetAsyncProvider, (prev, next) {
        if (next.hasError && (prev?.isLoading == true || prev == null)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!context.mounted) return;
            rootScaffoldMessengerKey.currentState?.showSnackBar(
              SnackBar(
                content: Text('练习词加载失败：${next.error}'),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 4),
              ),
            );
          });
          return;
        }
        next.whenData((sheet) {
          ref.read(syllableLatestSheetMemoryCacheProvider.notifier).state =
              sheet;
          final justFinished =
              prev?.isLoading == true || prev == null || prev.hasError;
          if (!justFinished) return;
          final n = syllableFilledWordCount(sheet.words);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!context.mounted) return;
            rootScaffoldMessengerKey.currentState?.showSnackBar(
              SnackBar(
                content: Text(
                  n > 0
                      ? '已获取最新练习词 $n 个（已缓存，点击单词生成图片）'
                      : '暂无练习词',
                ),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 3),
              ),
            );
          });
        });
      });
      return Scaffold(
        backgroundColor: AppTheme.shellBackground,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ShellScreenHeader(
                onBack: () => context.pop(),
                icon: Icons.splitscreen_rounded,
                title: '英语音节分割练习',
                trailing: IconButton(
                  tooltip: '重新拉取',
                  onPressed: () =>
                      ref.invalidate(syllableLatestSheetAsyncProvider),
                  icon: const Icon(Icons.refresh_rounded),
                  color: Colors.white70,
                ),
              ),
              Expanded(
                child: _buildRemoteBody(asyncSheet, cachedSheet),
              ),
            ],
          ),
        ),
      );
    }

    final records = ref.watch(
      mockDataNotifierProvider.select((s) => s.syllableGeneratedSheets),
    );
    final sheets = SyllablePracticePage.itemsFromRecords(records);
    final hasToday = ref
        .read(mockDataNotifierProvider.notifier)
        .hasSyllableSheetForDate(DateTime.now());

    return Scaffold(
      backgroundColor: AppTheme.shellBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ShellScreenHeader(
              onBack: () => context.pop(),
              icon: Icons.splitscreen_rounded,
              title: '英语音节分割练习',
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                '未配置家庭 API 时为演示数据。配置后将从后台读取最新词表并生成试卷。',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 13,
                  height: 1.35,
                ),
              ),
            ),
            if (sheets.isNotEmpty && !hasToday)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Material(
                  color: _kCard,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: _kAccent.withValues(alpha: 0.9),
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '今日尚未生成练习卷',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 13,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: _generating ? null : _generateToday,
                          child: _generating
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('去生成'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            Expanded(
              child: sheets.isEmpty
                  ? _EmptyGenerateState(
                      busy: _generating,
                      onGenerate: _generateToday,
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        childAspectRatio: 0.72,
                      ),
                      itemCount: sheets.length,
                      itemBuilder: (listCtx, index) {
                        final item = sheets[index];
                        return _SheetThumbnailCard(
                          item: item,
                          paperWords: SyllableWorksheetMock.wordsForSheet(
                            item.id,
                          ),
                          onTap: () => _openPreview(context, item),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 远程词表展示：数据已缓存在内存；仅点击**有单词的一行**才生成 PNG 并进入预览页。
class _RemotePracticeWordSheetCard extends StatelessWidget {
  const _RemotePracticeWordSheetCard({
    required this.sheetTitle,
    required this.paperWords,
    required this.filledWordCount,
    required this.exportBusy,
    required this.onWordRowTap,
  });

  final String sheetTitle;
  final List<SyllableWorksheetWord> paperWords;
  final int filledWordCount;
  final bool exportBusy;
  final VoidCallback onWordRowTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _kCard,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (exportBusy)
            const LinearProgressIndicator(minHeight: 2),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 10, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.table_rows_rounded, color: _kAccent, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sheetTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '已缓存 $filledWordCount 个有效词 · 共 15 行 · 点击下方任意单词生成整页图片并预览',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 12,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.white.withValues(alpha: 0.08)),
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 2, 4, 8),
            child: Column(
              children: [
                for (var i = 0; i < paperWords.length; i++) ...[
                  if (i > 0)
                    Divider(
                      height: 1,
                      color: Colors.white.withValues(alpha: 0.06),
                    ),
                  _RemoteWordListRow(
                    index: i,
                    word: paperWords[i],
                    exportBusy: exportBusy,
                    onTap: onWordRowTap,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RemoteWordListRow extends StatelessWidget {
  const _RemoteWordListRow({
    required this.index,
    required this.word,
    required this.exportBusy,
    required this.onTap,
  });

  final int index;
  final SyllableWorksheetWord word;
  final bool exportBusy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final empty = word.word.trim().isEmpty;
    final canTap = !exportBusy && !empty;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: canTap ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 30,
                child: Text(
                  '${index + 1}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.38),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                flex: 5,
                child: Text(
                  empty ? '—' : word.word,
                  style: TextStyle(
                    color: empty
                        ? Colors.white.withValues(alpha: 0.25)
                        : _kAccent,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                ),
              ),
              Expanded(
                flex: 7,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      word.phonetic.trim().isEmpty ? '—' : word.phonetic,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.55),
                        fontSize: 11.5,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      word.definition.trim().isEmpty ? '—' : word.definition,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 12,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RemoteEmptyState extends StatelessWidget {
  const _RemoteEmptyState({required this.onRefresh});

  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: 56,
              color: Colors.white.withValues(alpha: 0.25),
            ),
            const SizedBox(height: 16),
            Text(
              '暂无练习词表',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '后台尚未生成全局练习纸，或当前家庭暂无记录。可稍后点击右上角刷新重试。',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 14,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('重新拉取'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyGenerateState extends StatelessWidget {
  const _EmptyGenerateState({
    required this.busy,
    required this.onGenerate,
  });

  final bool busy;
  final VoidCallback onGenerate;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.article_outlined,
              size: 56,
              color: Colors.white.withValues(alpha: 0.25),
            ),
            const SizedBox(height: 16),
            Text(
              '暂无练习卷',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '演示模式下可点击下方按钮模拟「生成今日试卷」。\n配置家庭 API 后将改为从后台读取最新词表。',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 14,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: busy ? null : onGenerate,
              icon: busy
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white70,
                      ),
                    )
                  : const Icon(Icons.auto_awesome_rounded),
              label: Text(busy ? '生成中…' : '生成今日练习卷'),
              style: FilledButton.styleFrom(
                backgroundColor: _kAccent.withValues(alpha: 0.85),
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetThumbnailCard extends StatelessWidget {
  const _SheetThumbnailCard({
    required this.item,
    required this.paperWords,
    required this.onTap,
  });

  final SyllableSheetItem item;
  final List<SyllableWorksheetWord> paperWords;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: _kCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: AspectRatio(
                    aspectRatio: _kA4Ratio,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          border: Border.all(color: _kPaperBorder, width: 1),
                          color: Colors.white,
                        ),
                        child: FittedBox(
                          fit: BoxFit.cover,
                          alignment: Alignment.topCenter,
                          clipBehavior: Clip.hardEdge,
                          child: SizedBox(
                            width: SyllableWorksheetPaper.sheetWidth,
                            height: SyllableWorksheetPaper.sheetHeight,
                            child: SyllableWorksheetPaper(words: paperWords),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              item.subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.45),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
