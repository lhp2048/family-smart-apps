import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/shell_screen_header.dart';
import '../../dashboard/providers/family_api_base_url_provider.dart';
import '../data/ebook_api_mappers.dart';
import '../data/ebook_models.dart';
import '../../../shared/providers/ebook_ui_providers.dart';

const Color _kCard = Color(0xFF1A1A1F);

class EbookLibraryPage extends ConsumerWidget {
  const EbookLibraryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mcConfigured = ref.watch(familyMediacenterIsConfiguredProvider);
    final browseAsync = ref.watch(ebookBrowseAsyncProvider);
    final currentPath = ref.watch(ebookCurrentPathProvider);
    final page = ref.watch(ebookPageProvider);

    return Scaffold(
      backgroundColor: AppTheme.shellBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ShellScreenHeader(
              onBack: () => context.pop(),
              icon: Icons.menu_book_rounded,
              title: '电子图书',
            ),
            if (!mcConfigured)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(
                  '未连接 mediacenter，当前为示例书库。请在设置中配置门户地址。',
                  style: TextStyle(
                    color: Colors.amber.shade200,
                    fontSize: 13,
                  ),
                ),
              ),
            Expanded(
              child: browseAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      '$err',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                      ),
                    ),
                  ),
                ),
                data: (result) => _EbookLibraryBody(
                  result: result,
                  currentPath: currentPath,
                  page: page,
                  viewMode: ref.watch(ebookListViewModeProvider),
                  onViewModeChanged: (mode) {
                    ref.read(ebookListViewModeProvider.notifier).state = mode;
                  },
                  onNavigate: (path) {
                    ref.read(ebookCurrentPathProvider.notifier).state = path;
                    ref.read(ebookPageProvider.notifier).state = 1;
                  },
                  onPage: (p) {
                    ref.read(ebookPageProvider.notifier).state = p;
                  },
                  onOpenEntry: (entry) {
                    if (entry.isDir) {
                      ref.read(ebookCurrentPathProvider.notifier).state =
                          entry.subPath;
                      ref.read(ebookPageProvider.notifier).state = 1;
                      return;
                    }
                    context.push(
                      '/ebook/read?path=${Uri.encodeComponent(entry.subPath)}'
                      '&title=${Uri.encodeComponent(entry.name)}'
                      '&url=${Uri.encodeComponent(entry.publicUrl)}'
                      '&kind=${Uri.encodeComponent(entry.kind.name)}',
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EbookLibraryBody extends StatelessWidget {
  const _EbookLibraryBody({
    required this.result,
    required this.currentPath,
    required this.page,
    required this.viewMode,
    required this.onViewModeChanged,
    required this.onNavigate,
    required this.onPage,
    required this.onOpenEntry,
  });

  final EbookBrowseResult result;
  final String currentPath;
  final int page;
  final EbookListViewMode viewMode;
  final ValueChanged<EbookListViewMode> onViewModeChanged;
  final ValueChanged<String> onNavigate;
  final ValueChanged<int> onPage;
  final ValueChanged<EbookEntry> onOpenEntry;

  @override
  Widget build(BuildContext context) {
    final parts = currentPath.split('/').where((p) => p.isNotEmpty).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Text(
            '书库：${result.root}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.45),
              fontSize: 12,
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              _BreadcrumbChip(
                label: '书库',
                active: currentPath.isEmpty,
                onTap: () => onNavigate(''),
              ),
              for (var i = 0; i < parts.length; i++) ...[
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: Colors.white.withValues(alpha: 0.35),
                ),
                _BreadcrumbChip(
                  label: parts[i],
                  active: i == parts.length - 1,
                  onTap: () => onNavigate(parts.sublist(0, i + 1).join('/')),
                ),
              ],
            ],
          ),
        ),
        if (result.folder.title.isNotEmpty ||
            result.folder.description.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (result.folder.title.isNotEmpty)
                  Text(
                    result.folder.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                if (result.folder.description.isNotEmpty)
                  Text(
                    result.folder.description,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.65),
                      fontSize: 13,
                    ),
                  ),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  result.total > 0 ? '${result.total} 项' : '',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.55),
                    fontSize: 13,
                  ),
                ),
              ),
              _EbookViewModeToggle(
                mode: viewMode,
                onChanged: onViewModeChanged,
              ),
            ],
          ),
        ),
        Expanded(
          child: result.entries.isEmpty
              ? Center(
                  child: Text(
                    '此目录为空',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.55),
                    ),
                  ),
                )
              : viewMode == EbookListViewMode.grid
                  ? GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 220,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.78,
                      ),
                      itemCount: result.entries.length,
                      itemBuilder: (context, index) {
                        final entry = result.entries[index];
                        return _EbookEntryCard(
                          entry: entry,
                          onTap: () => onOpenEntry(entry),
                        );
                      },
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      itemCount: result.entries.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final entry = result.entries[index];
                        return _EbookEntryListTile(
                          entry: entry,
                          onTap: () => onOpenEntry(entry),
                        );
                      },
                    ),
        ),
        if (result.totalPages > 1)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: page > 1 ? () => onPage(page - 1) : null,
                  icon: const Icon(Icons.chevron_left_rounded),
                  color: Colors.white70,
                ),
                Text(
                  '第 $page / ${result.totalPages} 页 · 共 ${result.total} 项',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 13,
                  ),
                ),
                IconButton(
                  onPressed:
                      page < result.totalPages ? () => onPage(page + 1) : null,
                  icon: const Icon(Icons.chevron_right_rounded),
                  color: Colors.white70,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _BreadcrumbChip extends StatelessWidget {
  const _BreadcrumbChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
      backgroundColor: active
          ? Colors.white.withValues(alpha: 0.14)
          : Colors.white.withValues(alpha: 0.06),
      labelStyle: TextStyle(
        color: active ? Colors.white : Colors.white.withValues(alpha: 0.75),
        fontSize: 13,
      ),
    );
  }
}

class _EbookViewModeToggle extends StatelessWidget {
  const _EbookViewModeToggle({
    required this.mode,
    required this.onChanged,
  });

  final EbookListViewMode mode;
  final ValueChanged<EbookListViewMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _EbookViewModeButton(
            icon: Icons.view_list_rounded,
            selected: mode == EbookListViewMode.list,
            tooltip: '列表',
            onTap: () => onChanged(EbookListViewMode.list),
          ),
          _EbookViewModeButton(
            icon: Icons.grid_view_rounded,
            selected: mode == EbookListViewMode.grid,
            tooltip: '图标',
            onTap: () => onChanged(EbookListViewMode.grid),
          ),
        ],
      ),
    );
  }
}

class _EbookViewModeButton extends StatelessWidget {
  const _EbookViewModeButton({
    required this.icon,
    required this.selected,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final bool selected;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(
            icon,
            size: 20,
            color: selected
                ? Colors.white
                : Colors.white.withValues(alpha: 0.45),
          ),
        ),
      ),
    );
  }
}

class _EbookEntryListTile extends StatelessWidget {
  const _EbookEntryListTile({
    required this.entry,
    required this.onTap,
  });

  final EbookEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _kCard,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  ebookKindEmoji(entry.kind),
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ebookKindLabel(entry.kind),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.55),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                entry.isDir
                    ? Icons.chevron_right_rounded
                    : Icons.open_in_new_rounded,
                color: Colors.white.withValues(alpha: 0.35),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EbookEntryCard extends StatelessWidget {
  const _EbookEntryCard({
    required this.entry,
    required this.onTap,
  });

  final EbookEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _kCard,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Center(
                  child: Text(
                    ebookKindEmoji(entry.kind),
                    style: const TextStyle(fontSize: 42),
                  ),
                ),
              ),
              Text(
                entry.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                ebookKindLabel(entry.kind),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.55),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
