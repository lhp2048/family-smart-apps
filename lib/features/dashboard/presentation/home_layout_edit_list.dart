import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../layout/home_layout_models.dart';
import '../layout/home_layout_provider.dart';
import '../layout/home_layout_renderer.dart';
import 'home_layout_editable_tile.dart';

/// 编辑态：与浏览态相同的流式排版（中号可并排），每项带 overlay；支持拖拽排序。
class HomeLayoutEditList extends ConsumerStatefulWidget {
  const HomeLayoutEditList({
    super.key,
    required this.data,
    required this.onEditSeparatorTitle,
    required this.onDeleteSeparator,
    this.onDragActiveChanged,
  });

  final HomeLayoutRenderData data;
  final Future<void> Function(HomeSeparatorLayoutItem item) onEditSeparatorTitle;
  final Future<void> Function(HomeSeparatorLayoutItem item) onDeleteSeparator;
  final ValueChanged<bool>? onDragActiveChanged;

  @override
  ConsumerState<HomeLayoutEditList> createState() => _HomeLayoutEditListState();
}

class _HomeLayoutEditListState extends ConsumerState<HomeLayoutEditList> {
  int? _draggingIndex;
  int? _dropTargetIndex;

  bool _canDropAt(int from, int insertIndex) {
    return from != insertIndex && from + 1 != insertIndex;
  }

  void _setDragging(int? index) {
    setState(() => _draggingIndex = index);
    widget.onDragActiveChanged?.call(index != null);
  }

  Future<void> _reorder(int from, int to) async {
    final config = ref.read(homeLayoutConfigProvider).valueOrNull;
    if (config == null) return;
    final items = List<HomeLayoutItem>.from(config.visibleItems);
    if (from < 0 || from >= items.length || to < 0 || to > items.length) {
      return;
    }
    if (!_canDropAt(from, to)) return;
    final moved = items.removeAt(from);
    final insertAt = to > from ? to - 1 : to;
    items.insert(insertAt, moved);
    await ref.read(homeLayoutConfigProvider.notifier).reorderVisible(items);
  }

  Widget _dropSlot(int insertIndex) {
    final active = _dropTargetIndex == insertIndex;
    return DragTarget<int>(
      onWillAcceptWithDetails: (d) => _canDropAt(d.data, insertIndex),
      onMove: (d) {
        if (_dropTargetIndex != insertIndex) {
          setState(() => _dropTargetIndex = insertIndex);
        }
      },
      onLeave: (_) {
        if (_dropTargetIndex == insertIndex) {
          setState(() => _dropTargetIndex = null);
        }
      },
      onAcceptWithDetails: (d) {
        setState(() => _dropTargetIndex = null);
        _reorder(d.data, insertIndex);
      },
      builder: (context, candidate, rejected) {
        final highlight = candidate.isNotEmpty || active;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          height: highlight ? 32 : (_draggingIndex != null ? 20 : 10),
          margin: const EdgeInsets.symmetric(vertical: 2),
          decoration: BoxDecoration(
            color: highlight
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.45)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
        );
      },
    );
  }

  Widget _wrapDropTarget(int insertIndex, Widget child) {
    return DragTarget<int>(
      onWillAcceptWithDetails: (d) => _canDropAt(d.data, insertIndex),
      onMove: (_) {
        if (_dropTargetIndex != insertIndex) {
          setState(() => _dropTargetIndex = insertIndex);
        }
      },
      onLeave: (_) {
        if (_dropTargetIndex == insertIndex) {
          setState(() => _dropTargetIndex = null);
        }
      },
      onAcceptWithDetails: (d) {
        setState(() => _dropTargetIndex = null);
        _reorder(d.data, insertIndex);
      },
      builder: (context, candidate, rejected) => child,
    );
  }

  Widget _wrapFeature(
    HomeFeatureLayoutItem item,
    int listIndex,
    Widget child, {
    bool outerPadding = true,
  }) {
    final notifier = ref.read(homeLayoutConfigProvider.notifier);
    final borderRadius = item.size.isSmall ? 16.0 : 18.0;
    return _wrapDropTarget(
      listIndex,
      HomeLayoutEditableTile(
        listIndex: listIndex,
        isDragging: _draggingIndex == listIndex,
        isDropTarget: _dropTargetIndex == listIndex,
        outerPadding: outerPadding,
        borderRadius: borderRadius,
        onDragStarted: () => _setDragging(listIndex),
        onDragEnded: () {
          _setDragging(null);
          setState(() => _dropTargetIndex = null);
        },
        featureToolbarBuilder: (tileWidth) => HomeFeatureEditToolbar(
          size: item.size,
          availableWidth: tileWidth,
          onSelectSize: (size) => notifier.toggleFeatureSize(item.itemId, size),
          onHide: () => notifier.setFeatureHidden(item.itemId, true),
        ),
        child: child,
      ),
    );
  }

  Widget _wrapSeparator(HomeSeparatorLayoutItem item, int listIndex, Widget child) {
    final notifier = ref.read(homeLayoutConfigProvider.notifier);
    return _wrapDropTarget(
      listIndex,
      HomeLayoutEditableTile(
        listIndex: listIndex,
        isDragging: _draggingIndex == listIndex,
        isDropTarget: _dropTargetIndex == listIndex,
        onDragStarted: () => _setDragging(listIndex),
        onDragEnded: () {
          _setDragging(null);
          setState(() => _dropTargetIndex = null);
        },
        separatorToolbar: HomeSeparatorEditToolbar(
          onEditTitle: () => widget.onEditSeparatorTitle(item),
          onHide: () => notifier.setFeatureHidden(item.itemId, true),
          onDelete: () => widget.onDeleteSeparator(item),
        ),
        child: child,
      ),
    );
  }

  List<Widget> _buildEditColumn(
    BuildContext context,
    List<HomeLayoutItem> visibleItems,
  ) {
    final out = <Widget>[];
    var separatorCount = 0;
    var i = 0;

    while (i < visibleItems.length) {
      out.add(_dropSlot(i));
      final item = visibleItems[i];

      if (item is HomeSeparatorLayoutItem) {
        final content = buildSingleLayoutItem(
          context: context,
          item: item,
          data: widget.data,
          separatorIndexBefore: separatorCount,
          omitBottomPadding: true,
        );
        out.add(_wrapSeparator(item, i, content));
        separatorCount++;
        i++;
        continue;
      }

      if (item is! HomeFeatureLayoutItem) {
        i++;
        continue;
      }

      if (item.size.isLarge) {
        final content = buildSingleLayoutItem(
          context: context,
          item: item,
          data: widget.data,
          separatorIndexBefore: separatorCount,
          omitBottomPadding: true,
        );
        out.add(_wrapFeature(item, i, content));
        i++;
        continue;
      }

      if (item.size.isSmall) {
        final run = nextSmallFeatureRun(visibleItems, i);
        out.add(
          buildSmallCardsRow(
            context: context,
            run: run,
            data: widget.data,
            separatorIndexBefore: separatorCount,
            startListIndex: i,
            wrapChild: (listIndex, child) => _wrapFeature(
              visibleItems[listIndex] as HomeFeatureLayoutItem,
              listIndex,
              child,
              outerPadding: false,
            ),
          ),
        );
        i += run.length;
        continue;
      }

      final pair = nextMediumFeaturePair(visibleItems, i);
      if (pair.length == 2) {
        out.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _wrapFeature(
                    pair[0],
                    i,
                    buildSingleLayoutItem(
                      context: context,
                      item: pair[0],
                      data: widget.data,
                      separatorIndexBefore: separatorCount,
                      omitBottomPadding: true,
                    ),
                    outerPadding: false,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _wrapFeature(
                    pair[1],
                    i + 1,
                    buildSingleLayoutItem(
                      context: context,
                      item: pair[1],
                      data: widget.data,
                      separatorIndexBefore: separatorCount,
                      omitBottomPadding: true,
                    ),
                    outerPadding: false,
                  ),
                ),
              ],
            ),
          ),
        );
        i += 2;
      } else {
        final content = buildSingleLayoutItem(
          context: context,
          item: item,
          data: widget.data,
          separatorIndexBefore: separatorCount,
          omitBottomPadding: true,
        );
        out.add(_wrapFeature(item, i, content));
        i++;
      }
    }
    out.add(_dropSlot(visibleItems.length));
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final visibleItems =
        ref.watch(homeLayoutConfigProvider).valueOrNull?.visibleItems ??
            const <HomeLayoutItem>[];

    if (visibleItems.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Text(
          '没有可编辑的卡片，请从底部恢复已隐藏项',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 14,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: _buildEditColumn(context, visibleItems),
    );
  }
}
