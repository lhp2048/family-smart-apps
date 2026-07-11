import 'package:flutter/material.dart';

/// 可拖动、可折叠的迷你浮动工具栏。
class EbookReaderFloatingToolbarHost extends StatefulWidget {
  const EbookReaderFloatingToolbarHost({
    super.key,
    required this.reader,
    required this.toolbar,
  });

  final Widget reader;
  final Widget toolbar;

  @override
  State<EbookReaderFloatingToolbarHost> createState() =>
      _EbookReaderFloatingToolbarHostState();
}

class _EbookReaderFloatingToolbarHostState
    extends State<EbookReaderFloatingToolbarHost> {
  static const double _edgePadding = 8;
  static const double _collapsedSize = 36;
  static const Size _fallbackPanelSize = Size(220, 36);

  final GlobalKey _panelKey = GlobalKey();

  Offset? _position;
  bool _collapsed = false;

  Size _panelSize(BoxConstraints constraints) {
    if (_collapsed) {
      return const Size(_collapsedSize, _collapsedSize);
    }
    final box = _panelKey.currentContext?.findRenderObject() as RenderBox?;
    return box?.size ?? _fallbackPanelSize;
  }

  Offset _defaultPosition(BoxConstraints constraints) {
    final size = _panelSize(constraints);
    return Offset(
      ((constraints.maxWidth - size.width) * 0.5)
          .clamp(_edgePadding, constraints.maxWidth - size.width - _edgePadding),
      constraints.maxHeight - size.height - _edgePadding,
    );
  }

  Offset _effectivePosition(BoxConstraints constraints) {
    final size = _panelSize(constraints);
    final raw = _position ?? _defaultPosition(constraints);
    final maxX = (constraints.maxWidth - size.width - _edgePadding)
        .clamp(_edgePadding, constraints.maxWidth);
    final maxY = (constraints.maxHeight - size.height - _edgePadding)
        .clamp(_edgePadding, constraints.maxHeight);
    return Offset(
      raw.dx.clamp(_edgePadding, maxX),
      raw.dy.clamp(_edgePadding, maxY),
    );
  }

  void _onDragUpdate(DragUpdateDetails details, BoxConstraints constraints) {
    final size = _panelSize(constraints);
    final current = _effectivePosition(constraints);
    final maxX = constraints.maxWidth - size.width - _edgePadding;
    final maxY = constraints.maxHeight - size.height - _edgePadding;
    setState(() {
      _position = Offset(
        (current.dx + details.delta.dx).clamp(_edgePadding, maxX),
        (current.dy + details.delta.dy).clamp(_edgePadding, maxY),
      );
    });
  }

  void _toggleCollapsed(bool value) {
    setState(() => _collapsed = value);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted || _collapsed) return;
          setState(() {});
        });

        final pos = _effectivePosition(constraints);

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(child: widget.reader),
            Positioned(
              left: pos.dx,
              top: pos.dy,
              child: _collapsed
                  ? _CollapsedToolbarButton(
                      onTap: () => _toggleCollapsed(false),
                      onPanUpdate: (d) => _onDragUpdate(d, constraints),
                    )
                  : _MiniFloatingToolbarPanel(
                      key: _panelKey,
                      onPanUpdate: (d) => _onDragUpdate(d, constraints),
                      onCollapse: () => _toggleCollapsed(true),
                      child: widget.toolbar,
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _MiniFloatingToolbarPanel extends StatelessWidget {
  const _MiniFloatingToolbarPanel({
    super.key,
    required this.child,
    required this.onPanUpdate,
    required this.onCollapse,
  });

  final Widget child;
  final ValueChanged<DragUpdateDetails> onPanUpdate;
  final VoidCallback onCollapse;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      shadowColor: Colors.black45,
      color: const Color(0xEE141418),
      borderRadius: BorderRadius.circular(10),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanUpdate: onPanUpdate,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Icon(
                  Icons.drag_indicator_rounded,
                  size: 16,
                  color: Colors.white.withValues(alpha: 0.4),
                ),
              ),
            ),
            child,
            InkWell(
              onTap: onCollapse,
              borderRadius: BorderRadius.circular(6),
              child: const SizedBox(
                width: 24,
                height: 28,
                child: Icon(
                  Icons.minimize_rounded,
                  size: 16,
                  color: Colors.white54,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CollapsedToolbarButton extends StatelessWidget {
  const _CollapsedToolbarButton({
    required this.onTap,
    required this.onPanUpdate,
  });

  final VoidCallback onTap;
  final ValueChanged<DragUpdateDetails> onPanUpdate;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 6,
      shadowColor: Colors.black45,
      color: const Color(0xEE181824),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: SizedBox(
          width: 36,
          height: 36,
          child: GestureDetector(
            onPanUpdate: onPanUpdate,
            behavior: HitTestBehavior.translucent,
            child: const Icon(
              Icons.tune_rounded,
              color: Colors.white70,
              size: 18,
            ),
          ),
        ),
      ),
    );
  }
}
