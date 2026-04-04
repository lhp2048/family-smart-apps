import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/shell_screen_header.dart';
import '../../../shared/providers/extracurricular_ui_providers.dart';
import '../data/extracurricular_models.dart';

const Color _kCard = Color(0xFF1A1A1F);
const Color _kCardTop = Color(0xFF2A2A30);
const Color _kSelectedRed = Color(0xFF5C1F1F);
const Color _kPinkAccent = Color(0xFFFF80AB);

class ExtracurricularPage extends ConsumerWidget {
  const ExtracurricularPage({super.key});

  static const _sidebarEntries = <ExtracurricularSidebarEntry>[
    ExtracurricularSidebarEntry(
      filterId: ExtracurricularFilterIds.all,
      label: '全部',
      icon: Icons.apps_rounded,
    ),
    ExtracurricularSidebarEntry(
      filterId: ExtracurricularFilterIds.golden,
      label: '黄金屋',
      icon: Icons.menu_book_rounded,
    ),
    ExtracurricularSidebarEntry(
      filterId: ExtracurricularFilterIds.seventh,
      label: '第七艺术',
      icon: Icons.movie_filter_rounded,
    ),
    ExtracurricularSidebarEntry(
      filterId: ExtracurricularFilterIds.tv,
      label: '电视剧',
      icon: Icons.tv_rounded,
    ),
    ExtracurricularSidebarEntry(
      filterId: ExtracurricularFilterIds.anime,
      label: '动漫/漫画',
      icon: Icons.sports_esports_rounded,
    ),
    ExtracurricularSidebarEntry(
      filterId: ExtracurricularFilterIds.doc,
      label: '纪录片/其他',
      icon: Icons.movie_creation_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(extracurricularFilterIdProvider);
    final unwatchedOnly = ref.watch(extracurricularUnwatchedOnlyProvider);
    final items = ref.watch(filteredExtracurricularItemsProvider);

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
                  if (wide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          width: 200,
                          child: _TypeSidebar(
                            entries: _sidebarEntries,
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
                        Expanded(
                          child: _MediaGrid(items: items),
                        ),
                      ],
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _TypeSidebar(
                        entries: _sidebarEntries,
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
                      Expanded(child: _MediaGrid(items: items)),
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
              Icon(
                entry.icon,
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
        var cross = 1;
        if (c.maxWidth > 520) cross = 2;
        if (c.maxWidth > 960) cross = 3;

        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cross,
            mainAxisSpacing: 18,
            crossAxisSpacing: 18,
            childAspectRatio: cross >= 3 ? 0.62 : 0.58,
          ),
          itemCount: items.length,
          itemBuilder: (context, i) => _MediaCard(item: items[i]),
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

class _MediaCard extends StatelessWidget {
  const _MediaCard({required this.item});

  final ExtracurricularItem item;

  @override
  Widget build(BuildContext context) {
    final pillBg = _pillColor(item.mediumKind);
    final pillFg = _pillTextColor(item.mediumKind);

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 11,
            child: Container(
              color: _kCardTop,
              alignment: Alignment.center,
              child: Text(
                item.emoji,
                style: const TextStyle(fontSize: 52),
              ),
            ),
          ),
          Expanded(
            flex: 16,
            child: Container(
              color: _kCard,
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Column(
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
                          const SizedBox(width: 56),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
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
                      Expanded(
                        child: Text(
                          item.description,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.82),
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
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
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.12),
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
                              color: Colors.white.withValues(alpha: 0.55),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
