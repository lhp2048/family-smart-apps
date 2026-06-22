import 'package:flutter/material.dart';

import '../layout/home_layout_models.dart';

/// 编辑态单项 overlay：左上拖柄 + 右上工具条，卡片内容禁点击。
class HomeLayoutEditableTile extends StatelessWidget {
  const HomeLayoutEditableTile({
    super.key,
    required this.listIndex,
    required this.child,
    this.featureToolbar,
    this.featureToolbarBuilder,
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
  /// 按卡片可用宽度构建功能卡工具条（优先于 [featureToolbar]）。
  final Widget Function(double tileWidth)? featureToolbarBuilder;
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
    final radius = borderRadius;
    Widget buildTile(Widget? toolbar) => Stack(
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

    final tile = featureToolbarBuilder != null
        ? LayoutBuilder(
            builder: (context, constraints) {
              return buildTile(
                featureToolbarBuilder!(constraints.maxWidth),
              );
            },
          )
        : buildTile(featureToolbar ?? separatorToolbar);

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

/// 平铺形态按钮所需最小宽度（4 个图标槽 + chip 内边距）。
const kHomeFeatureEditToolbarExpandedMinWidth = 112.0;

enum _FeatureToolbarMenuAction { small, medium, large, hide }

/// 功能卡右上角：切换小 / 中 / 大 / 隐藏。
/// 宽度不足时收成单按钮 + 弹出菜单。
class HomeFeatureEditToolbar extends StatelessWidget {
  const HomeFeatureEditToolbar({
    super.key,
    required this.size,
    required this.onSelectSize,
    required this.onHide,
    this.availableWidth = double.infinity,
  });

  final HomeCardSize size;
  final ValueChanged<HomeCardSize> onSelectSize;
  final VoidCallback onHide;
  final double availableWidth;

  static IconData iconForSize(HomeCardSize size) => switch (size) {
        HomeCardSize.small => Icons.view_headline_rounded,
        HomeCardSize.medium => Icons.view_agenda_outlined,
        HomeCardSize.large => Icons.view_day_outlined,
      };

  bool get _useCompactMenu =>
      availableWidth.isFinite &&
      availableWidth < kHomeFeatureEditToolbarExpandedMinWidth;

  @override
  Widget build(BuildContext context) {
    if (_useCompactMenu) {
      return _CompactFeatureEditToolbar(
        size: size,
        onSelectSize: onSelectSize,
        onHide: onHide,
      );
    }

    final primary = Theme.of(context).colorScheme.primary;
    return _OverlayChip(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToolbarIcon(
            icon: iconForSize(HomeCardSize.small),
            tooltip: HomeCardSize.small.label,
            selected: size.isSmall,
            selectedColor: primary,
            onTap: () => onSelectSize(HomeCardSize.small),
          ),
          _ToolbarIcon(
            icon: iconForSize(HomeCardSize.medium),
            tooltip: HomeCardSize.medium.label,
            selected: size.isMedium,
            selectedColor: primary,
            onTap: () => onSelectSize(HomeCardSize.medium),
          ),
          _ToolbarIcon(
            icon: iconForSize(HomeCardSize.large),
            tooltip: HomeCardSize.large.label,
            selected: size.isLarge,
            selectedColor: primary,
            onTap: () => onSelectSize(HomeCardSize.large),
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

class _CompactFeatureEditToolbar extends StatelessWidget {
  const _CompactFeatureEditToolbar({
    required this.size,
    required this.onSelectSize,
    required this.onHide,
  });

  final HomeCardSize size;
  final ValueChanged<HomeCardSize> onSelectSize;
  final VoidCallback onHide;

  void _onMenuSelected(_FeatureToolbarMenuAction action) {
    switch (action) {
      case _FeatureToolbarMenuAction.small:
        onSelectSize(HomeCardSize.small);
      case _FeatureToolbarMenuAction.medium:
        onSelectSize(HomeCardSize.medium);
      case _FeatureToolbarMenuAction.large:
        onSelectSize(HomeCardSize.large);
      case _FeatureToolbarMenuAction.hide:
        onHide();
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return _OverlayChip(
      child: PopupMenuButton<_FeatureToolbarMenuAction>(
        padding: EdgeInsets.zero,
        tooltip: '切换形态',
        offset: const Offset(0, 28),
        color: const Color(0xFF2A2A2A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        onSelected: _onMenuSelected,
        itemBuilder: (context) => [
          _sizeMenuItem(
            action: _FeatureToolbarMenuAction.small,
            cardSize: HomeCardSize.small,
            selected: size.isSmall,
            primary: primary,
          ),
          _sizeMenuItem(
            action: _FeatureToolbarMenuAction.medium,
            cardSize: HomeCardSize.medium,
            selected: size.isMedium,
            primary: primary,
          ),
          _sizeMenuItem(
            action: _FeatureToolbarMenuAction.large,
            cardSize: HomeCardSize.large,
            selected: size.isLarge,
            primary: primary,
          ),
          const PopupMenuDivider(height: 8),
          PopupMenuItem<_FeatureToolbarMenuAction>(
            value: _FeatureToolbarMenuAction.hide,
            height: 36,
            child: _ToolbarMenuRow(
              icon: Icons.visibility_off_outlined,
              label: '隐藏',
              iconColor: Colors.white.withValues(alpha: 0.85),
            ),
          ),
        ],
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(
            HomeFeatureEditToolbar.iconForSize(size),
            size: 18,
            color: primary,
          ),
        ),
      ),
    );
  }

  PopupMenuItem<_FeatureToolbarMenuAction> _sizeMenuItem({
    required _FeatureToolbarMenuAction action,
    required HomeCardSize cardSize,
    required bool selected,
    required Color primary,
  }) {
    return PopupMenuItem<_FeatureToolbarMenuAction>(
      value: action,
      height: 36,
      child: _ToolbarMenuRow(
        icon: HomeFeatureEditToolbar.iconForSize(cardSize),
        label: cardSize.label,
        iconColor: selected ? primary : Colors.white.withValues(alpha: 0.85),
        labelColor: selected ? primary : Colors.white.withValues(alpha: 0.92),
      ),
    );
  }
}

class _ToolbarMenuRow extends StatelessWidget {
  const _ToolbarMenuRow({
    required this.icon,
    required this.label,
    required this.iconColor,
    this.labelColor,
  });

  final IconData icon;
  final String label;
  final Color iconColor;
  final Color? labelColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: labelColor ?? iconColor,
          ),
        ),
      ],
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
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(icon, size: 18, color: color),
        ),
      ),
    );
  }
}

