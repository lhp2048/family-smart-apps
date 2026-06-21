import 'package:flutter/material.dart';

import '../layout/home_layout_models.dart';

/// 编辑态单项 overlay：左上拖柄 + 右上工具条，卡片内容禁点击。
class HomeLayoutEditableTile extends StatelessWidget {
  const HomeLayoutEditableTile({
    super.key,
    required this.listIndex,
    required this.child,
    this.featureToolbar,
    this.separatorToolbar,
    this.isDragging = false,
    this.isDropTarget = false,
    this.outerPadding = true,
    this.borderRadius,
    this.onDragStarted,
    this.onDragEnded,
  });

  final int listIndex;
  final Widget child;
  final Widget? featureToolbar;
  final Widget? separatorToolbar;
  final bool isDragging;
  final bool isDropTarget;
  final bool outerPadding;
  /// 与卡片圆角一致时描边才贴合背景；分隔标题传 null 不描边。
  final double? borderRadius;
  final VoidCallback? onDragStarted;
  final VoidCallback? onDragEnded;

  @override
  Widget build(BuildContext context) {
    final toolbar = featureToolbar ?? separatorToolbar;
    final radius = borderRadius;
    final tile = Stack(
      clipBehavior: Clip.none,
      children: [
        Opacity(
          opacity: isDragging ? 0.35 : 1,
          child: IgnorePointer(child: child),
        ),
        if (radius != null)
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(radius),
                  border: Border.all(
                    color: isDropTarget
                        ? Theme.of(context).colorScheme.primary
                        : Colors.white.withValues(alpha: 0.12),
                    width: isDropTarget ? 2 : 1,
                  ),
                ),
              ),
            ),
          ),
        Positioned(
          top: 6,
          left: 6,
          child: _DragHandle(
            listIndex: listIndex,
            borderRadius: radius ?? 18,
            previewChild: child,
            onDragStarted: onDragStarted,
            onDragEnded: onDragEnded,
          ),
        ),
        if (toolbar != null)
          Positioned(
            top: 6,
            right: 6,
            child: toolbar,
          ),
      ],
    );

    if (!outerPadding) return tile;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: tile,
    );
  }
}

/// 仅拖柄发起拖拽：按下并移动即可（Web / 桌面 / 触摸均可用）。
class _DragHandle extends StatelessWidget {
  const _DragHandle({
    required this.listIndex,
    required this.borderRadius,
    required this.previewChild,
    this.onDragStarted,
    this.onDragEnded,
  });

  final int listIndex;
  final double borderRadius;
  final Widget previewChild;
  final VoidCallback? onDragStarted;
  final VoidCallback? onDragEnded;

  @override
  Widget build(BuildContext context) {
    const handle = _OverlayChip(
      child: Icon(
        Icons.drag_handle,
        size: 20,
        color: Colors.white,
      ),
    );

    return Draggable<int>(
      data: listIndex,
      axis: Axis.vertical,
      dragAnchorStrategy: pointerDragAnchorStrategy,
      onDragStarted: onDragStarted,
      onDragEnd: (_) => onDragEnded?.call(),
      onDraggableCanceled: (_, _) => onDragEnded?.call(),
      feedback: Material(
        color: Colors.transparent,
        elevation: 8,
        child: Opacity(
          opacity: 0.92,
          child: SizedBox(
            width: MediaQuery.sizeOf(context).width * 0.82,
            child: _EditDragFeedback(
              borderRadius: borderRadius,
              child: previewChild,
            ),
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.35,
        child: handle,
      ),
      child: handle,
    );
  }
}

class _EditDragFeedback extends StatelessWidget {
  const _EditDragFeedback({
    required this.borderRadius,
    required this.child,
  });

  final double borderRadius;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _OverlayChip extends StatelessWidget {
  const _OverlayChip({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.45),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: child,
      ),
    );
  }
}

/// 功能卡右上角：切换摘要 / 入口 / 隐藏。
class HomeFeatureEditToolbar extends StatelessWidget {
  const HomeFeatureEditToolbar({
    super.key,
    required this.size,
    required this.onSelectSize,
    required this.onHide,
  });

  final HomeCardSize size;
  final ValueChanged<HomeCardSize> onSelectSize;
  final VoidCallback onHide;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return _OverlayChip(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToolbarIcon(
            icon: Icons.view_agenda_outlined,
            tooltip: HomeCardSize.summary.label,
            selected: size == HomeCardSize.summary,
            selectedColor: primary,
            onTap: () => onSelectSize(HomeCardSize.summary),
          ),
          _ToolbarIcon(
            icon: Icons.list_alt_outlined,
            tooltip: HomeCardSize.entry.label,
            selected: size == HomeCardSize.entry,
            selectedColor: primary,
            onTap: () => onSelectSize(HomeCardSize.entry),
          ),
          _ToolbarIcon(
            icon: Icons.visibility_off_outlined,
            tooltip: '隐藏',
            onTap: onHide,
          ),
        ],
      ),
    );
  }
}

/// 分隔标题右上角：编辑 / 隐藏 / 删除。
class HomeSeparatorEditToolbar extends StatelessWidget {
  const HomeSeparatorEditToolbar({
    super.key,
    required this.onEditTitle,
    required this.onHide,
    required this.onDelete,
  });

  final VoidCallback onEditTitle;
  final VoidCallback onHide;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return _OverlayChip(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToolbarIcon(
            icon: Icons.edit_outlined,
            tooltip: '编辑标题',
            onTap: onEditTitle,
          ),
          _ToolbarIcon(
            icon: Icons.visibility_off_outlined,
            tooltip: '隐藏',
            onTap: onHide,
          ),
          _ToolbarIcon(
            icon: Icons.delete_outline,
            tooltip: '删除',
            onTap: onDelete,
          ),
        ],
      ),
    );
  }
}

class _ToolbarIcon extends StatelessWidget {
  const _ToolbarIcon({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.selected = false,
    this.selectedColor,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool selected;
  final Color? selectedColor;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? (selectedColor ?? Colors.white)
        : Colors.white.withValues(alpha: 0.75);
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, size: 18, color: color),
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.all(4),
      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
    );
  }
}
