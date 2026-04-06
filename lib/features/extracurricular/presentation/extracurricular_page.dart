import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/shell_screen_header.dart';
import '../../../features/dashboard/providers/family_api_base_url_provider.dart';
import '../../../shared/providers/extracurricular_ui_providers.dart';
import '../data/extracurricular_models.dart';

const Color _kCard = Color(0xFF1A1A1F);
const Color _kSelectedRed = Color(0xFF5C1F1F);
const Color _kPinkAccent = Color(0xFFFF80AB);

class ExtracurricularPage extends ConsumerWidget {
  const ExtracurricularPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final originAsync = ref.watch(familyApiOriginNotifierProvider);
    if (originAsync.isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.shellBackground,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ShellScreenHeader(
                onBack: () => context.pop(),
                icon: Icons.auto_stories_rounded,
                title: '精彩课外',
              ),
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              ),
            ],
          ),
        ),
      );
    }
    final apiOn = originAsync.requireValue.trim().isNotEmpty;

    if (apiOn) {
      ref.listen(extracurricularRemoteFiltersAsyncProvider, (prev, next) {
        next.whenData((entries) {
          if (entries.isEmpty) return;
          final ids = entries.map((e) => e.filterId).toSet();
          final sel = ref.read(extracurricularFilterIdProvider);
          if (!ids.contains(sel)) {
            ref.read(extracurricularFilterIdProvider.notifier).state =
                entries.first.filterId;
          }
        });
      });

      final filtersAsync = ref.watch(extracurricularRemoteFiltersAsyncProvider);
      if (filtersAsync.isLoading) {
        return Scaffold(
          backgroundColor: AppTheme.shellBackground,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ShellScreenHeader(
                  onBack: () => context.pop(),
                  icon: Icons.auto_stories_rounded,
                  title: '精彩课外',
                ),
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                ),
              ],
            ),
          ),
        );
      }
      if (filtersAsync.hasError) {
        return Scaffold(
          backgroundColor: AppTheme.shellBackground,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ShellScreenHeader(
                  onBack: () => context.pop(),
                  icon: Icons.auto_stories_rounded,
                  title: '精彩课外',
                ),
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        '筛选项加载失败：${filtersAsync.error}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }

    final sidebar = ref.watch(extracurricularSidebarEntriesProvider);
    final filter = ref.watch(extracurricularFilterIdProvider);
    final unwatchedOnly = ref.watch(extracurricularUnwatchedOnlyProvider);
    final itemsAsync = ref.watch(extracurricularItemsAsyncProvider);

    return Scaffold(
      backgroundColor: AppTheme.shellBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ShellScreenHeader(
              onBack: () => context.pop(),
              icon: Icons.auto_stories_rounded,
              title: '精彩课外',
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, c) {
                  final wide = c.maxWidth >= 760;
                  Widget gridArea() {
                    return itemsAsync.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            '内容加载失败：$e',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                      data: (list) {
                        final items = apiOn && unwatchedOnly
                            ? list.where((e) => !e.watched).toList()
                            : list;
                        return _MediaGrid(items: items);
                      },
                    );
                  }

                  if (wide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          width: 200,
                          child: _TypeSidebar(
                            entries: sidebar,
                            selectedFilter: filter,
                            unwatchedOnly: unwatchedOnly,
                            onFilter: (id) {
                              ref
                                  .read(extracurricularFilterIdProvider.notifier)
                                  .state = id;
                            },
                            onUnwatchedChanged: (v) {
                              ref
                                  .read(
                                      extracurricularUnwatchedOnlyProvider
                                          .notifier)
                                  .state = v;
                            },
                          ),
                        ),
                        VerticalDivider(
                          width: 1,
                          thickness: 1,
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                        Expanded(child: gridArea()),
                      ],
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _TypeSidebar(
                        entries: sidebar,
                        selectedFilter: filter,
                        unwatchedOnly: unwatchedOnly,
                        scrollableHorizontal: true,
                        onFilter: (id) {
                          ref
                              .read(extracurricularFilterIdProvider.notifier)
                              .state = id;
                        },
                        onUnwatchedChanged: (v) {
                          ref
                              .read(
                                  extracurricularUnwatchedOnlyProvider.notifier)
                              .state = v;
                        },
                      ),
                      Divider(
                        height: 1,
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                      Expanded(child: gridArea()),
                    ],
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

class _TypeSidebar extends StatelessWidget {
  const _TypeSidebar({
    required this.entries,
    required this.selectedFilter,
    required this.unwatchedOnly,
    required this.onFilter,
    required this.onUnwatchedChanged,
    this.scrollableHorizontal = false,
  });

  final List<ExtracurricularSidebarEntry> entries;
  final String selectedFilter;
  final bool unwatchedOnly;
  final void Function(String id) onFilter;
  final void Function(bool v) onUnwatchedChanged;
  final bool scrollableHorizontal;

  @override
  Widget build(BuildContext context) {
    final filterSection = scrollableHorizontal
        ? SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: entries.length,
              separatorBuilder: (_, index) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final e = entries[i];
                final sel = e.filterId == selectedFilter;
                return _SidebarTile(
                  entry: e,
                  selected: sel,
                  compact: true,
                  onTap: () => onFilter(e.filterId),
                );
              },
            ),
          )
        : ListView.separated(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            itemCount: entries.length,
            separatorBuilder: (_, index) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final e = entries[i];
              final sel = e.filterId == selectedFilter;
              return _SidebarTile(
                entry: e,
                selected: sel,
                onTap: () => onFilter(e.filterId),
              );
            },
          );

    final watchRow = Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
      child: Row(
        children: [
          SizedBox(
            height: 32,
            width: 32,
            child: Checkbox(
              value: unwatchedOnly,
              onChanged: (v) => onUnwatchedChanged(v ?? false),
              activeColor: _kPinkAccent,
              side: BorderSide(color: Colors.white.withValues(alpha: 0.35)),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => onUnwatchedChanged(!unwatchedOnly),
              child: Text(
                '只看未看',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    final watchTitle = Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: Text(
        '观看状态',
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.45),
          fontSize: 12,
        ),
      ),
    );

    if (scrollableHorizontal) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          filterSection,
          watchTitle,
          watchRow,
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: filterSection),
        watchTitle,
        watchRow,
      ],
    );
  }
}

class _SidebarTile extends StatelessWidget {
  const _SidebarTile({
    required this.entry,
    required this.selected,
    required this.onTap,
    this.compact = false,
  });

  final ExtracurricularSidebarEntry entry;
  final bool selected;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final emoji = entry.iconEmoji;
    final hasEmoji = emoji != null && emoji.isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Ink(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 12 : 12,
            vertical: compact ? 10 : 12,
          ),
          decoration: BoxDecoration(
            color: selected ? _kSelectedRed : _kCard,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected
                  ? Colors.redAccent.withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.06),
            ),
          ),
          child: Row(
            mainAxisSize: compact ? MainAxisSize.min : MainAxisSize.max,
            children: [
              if (hasEmoji)
                Text(
                  emoji,
                  style: TextStyle(fontSize: compact ? 18 : 20),
                )
              else
                Icon(
                  entry.icon ?? Icons.folder_outlined,
                  size: 20,
                  color: selected ? Colors.white : Colors.white60,
                ),
              SizedBox(width: compact ? 6 : 10),
              Text(
                entry.label,
                style: TextStyle(
                  color: selected ? Colors.white : Colors.white70,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: compact ? 12 : 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MediaGrid extends StatelessWidget {
  const _MediaGrid({required this.items});

  final List<ExtracurricularItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Text(
          '暂无内容',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.35)),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, c) {
        var columns = 1;
        if (c.maxWidth > 520) columns = 2;
        if (c.maxWidth > 960) columns = 3;
        const horizontal = 16.0;
        const gap = 18.0;
        final innerW = c.maxWidth - horizontal * 2;
        final tileW = (innerW - gap * (columns - 1)) / columns;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Wrap(
            spacing: gap,
            runSpacing: gap,
            children: [
              for (final item in items)
                SizedBox(
                  width: tileW,
                  child: _MediaCard(item: item),
                ),
            ],
          ),
        );
      },
    );
  }
}

Color _pillColor(ExtracurricularMediumKind k) {
  switch (k) {
    case ExtracurricularMediumKind.tvSeries:
      return const Color(0xFF42A5F5);
    case ExtracurricularMediumKind.documentary:
      return const Color(0xFFFFCA28);
    case ExtracurricularMediumKind.movie:
      return const Color(0xFFEF5350);
    case ExtracurricularMediumKind.book:
      return const Color(0xFFFFB74D);
    case ExtracurricularMediumKind.anime:
      return const Color(0xFFEC407A);
  }
}

Color _pillTextColor(ExtracurricularMediumKind k) {
  switch (k) {
    case ExtracurricularMediumKind.tvSeries:
      return Colors.white;
    case ExtracurricularMediumKind.documentary:
      return Colors.black87;
    case ExtracurricularMediumKind.movie:
      return Colors.white;
    case ExtracurricularMediumKind.book:
      return Colors.black87;
    case ExtracurricularMediumKind.anime:
      return Colors.white;
  }
}

class _MediaCard extends StatefulWidget {
  const _MediaCard({required this.item});

  final ExtracurricularItem item;

  @override
  State<_MediaCard> createState() => _MediaCardState();
}

class _MediaCardState extends State<_MediaCard> {
  bool _expanded = false;
  /// `null`：尚未测量；`true`：超过两行，可展开；`false`：两行至多，不显示展开。
  bool? _overflowsTwoLines;
  double? _lastMeasureWidth;
  String? _lastMeasureDesc;

  TextStyle _descriptionStyle(BuildContext context) {
    return TextStyle(
      color: Colors.white.withValues(alpha: 0.82),
      fontSize: 12,
      height: 1.4,
    );
  }

  void _measureDescriptionOverflow(BuildContext context, double maxWidth) {
    final d = widget.item.description.trim();
    if (d.isEmpty) {
      if (_overflowsTwoLines != false) {
        setState(() {
          _overflowsTwoLines = false;
          _expanded = false;
        });
      }
      return;
    }
    if (maxWidth <= 0) return;
    if (_lastMeasureWidth == maxWidth &&
        _lastMeasureDesc == d &&
        _overflowsTwoLines != null) {
      return;
    }
    _lastMeasureWidth = maxWidth;
    _lastMeasureDesc = d;
    final tp = TextPainter(
      text: TextSpan(text: d, style: _descriptionStyle(context)),
      textDirection: Directionality.of(context),
      maxLines: 2,
      textScaler: MediaQuery.textScalerOf(context),
    );
    tp.layout(maxWidth: maxWidth);
    final exceeds = tp.didExceedMaxLines;
    if (_overflowsTwoLines != exceeds && mounted) {
      setState(() {
        _overflowsTwoLines = exceeds;
        if (!exceeds) {
          _expanded = false;
        }
      });
    }
  }

  @override
  void didUpdateWidget(covariant _MediaCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.id != widget.item.id ||
        oldWidget.item.description != widget.item.description) {
      _overflowsTwoLines = null;
      _expanded = false;
      _lastMeasureWidth = null;
      _lastMeasureDesc = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final pillBg = _pillColor(item.mediumKind);
    final pillFg = _pillTextColor(item.mediumKind);
    final canExpand = _overflowsTwoLines == true;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: canExpand ? () => setState(() => _expanded = !_expanded) : null,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(
            color: _kCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            child: LayoutBuilder(
              builder: (context, constraints) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!context.mounted) return;
                  _measureDescriptionOverflow(context, constraints.maxWidth);
                });
                return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.emoji,
                      style: const TextStyle(fontSize: 28, height: 1.1),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  item.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    height: 1.25,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color:
                                        Colors.white.withValues(alpha: 0.12),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.description_outlined,
                                      size: 12,
                                      color: Colors.white.withValues(alpha: 0.55),
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      item.watched ? '已看' : '未看',
                                      style: TextStyle(
                                        color:
                                            Colors.white.withValues(alpha: 0.55),
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: pillBg.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.mediumLabel,
                        style: TextStyle(
                          color: pillFg,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${item.year}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  item.genre,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.45),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: List.generate(5, (i) {
                    return Icon(
                      i < item.ratingStars
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      size: 16,
                      color: const Color(0xFFFFCA28),
                    );
                  }),
                ),
                const SizedBox(height: 8),
                Text(
                  item.description,
                  maxLines: _expanded ? null : 2,
                  overflow: _expanded
                      ? TextOverflow.visible
                      : TextOverflow.ellipsis,
                  style: _descriptionStyle(context),
                  textScaler: MediaQuery.textScalerOf(context),
                ),
                if (canExpand) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        _expanded
                            ? Icons.expand_less_rounded
                            : Icons.expand_more_rounded,
                        size: 16,
                        color: _kPinkAccent.withValues(alpha: 0.85),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        _expanded ? '收起' : '展开全文',
                        style: TextStyle(
                          color: _kPinkAccent.withValues(alpha: 0.85),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.groups_rounded,
                      size: 16,
                      color: Colors.white.withValues(alpha: 0.45),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '全家',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.45),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
