import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/ebook_models.dart';
import '../../providers/ebook_reader_providers.dart';

/// 仅缩放/平移阅读内容（顶部居中）。
/// 翻页模式 + 未放大：横向滑动翻页；放大后：单指拖动平移；双指捏合缩放。
class EbookReaderZoomViewport extends ConsumerStatefulWidget {
  const EbookReaderZoomViewport({
    super.key,
    required this.child,
    this.onPageTurn,
    this.pageSwipeEnabled = true,
    this.contentHandlesPageSwipe = false,
    this.allowVerticalScroll = false,
  });

  final Widget child;

  /// true = 下一页（左滑），false = 上一页（右滑）。
  final ValueChanged<bool>? onPageTurn;

  /// 是否允许视口层处理横向滑动翻页（MD/TXT/EPUB）。
  final bool pageSwipeEnabled;

  /// PDF 翻页模式：单指横向滑动交给子组件 PdfView，视口只做双指缩放。
  final bool contentHandlesPageSwipe;

  /// 滚动模式下为 true，避免单指手势与内部 ScrollView 冲突。
  final bool allowVerticalScroll;

  @override
  ConsumerState<EbookReaderZoomViewport> createState() =>
      _EbookReaderZoomViewportState();
}

class _EbookReaderZoomViewportState
    extends ConsumerState<EbookReaderZoomViewport> {
  static const double _minScale = 0.5;
  static const double _maxScale = 3.0;
  static const double _pageSwipeScaleThreshold = 1.05;
  static const double _pageSwipeDistanceThreshold = 52;
  static const double _pageSwipeVelocityThreshold = 280;

  Offset _panOffset = Offset.zero;
  double _pinchStartScale = 1;
  double _horizontalDragDelta = 0;

  final Map<int, Offset> _activePointers = {};
  double? _pinchStartDistance;

  double get _zoom => ref.watch(ebookReaderZoomProvider);

  bool get _isZoomedForPan => _zoom > _pageSwipeScaleThreshold;

  /// 未放大时允许滑动翻页（不与平移冲突）。
  bool get _allowViewportPageSwipe =>
      widget.pageSwipeEnabled &&
      !widget.contentHandlesPageSwipe &&
      !widget.allowVerticalScroll &&
      widget.onPageTurn != null &&
      !_isZoomedForPan;

  bool get _blockChildPointer =>
      widget.contentHandlesPageSwipe && _isZoomedForPan;

  void _setZoom(double value) {
    ref.read(ebookReaderZoomProvider.notifier).state =
        value.clamp(_minScale, _maxScale);
  }

  void _resetView() {
    _setZoom(1);
    setState(() {
      _panOffset = Offset.zero;
      _horizontalDragDelta = 0;
    });
  }

  void _handleDoubleTap() {
    if (_zoom > 1.05) {
      _resetView();
    } else {
      _setZoom(2);
      setState(() => _panOffset = Offset.zero);
    }
  }

  void _onHorizontalDragStart(DragStartDetails details) {
    if (!_allowViewportPageSwipe) return;
    _horizontalDragDelta = 0;
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (!_allowViewportPageSwipe) return;
    _horizontalDragDelta += details.delta.dx;
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (!_allowViewportPageSwipe) return;
    _emitPageTurnFromDrag(
      delta: _horizontalDragDelta,
      velocity: details.primaryVelocity ?? 0,
    );
    _horizontalDragDelta = 0;
  }

  void _emitPageTurnFromDrag({required double delta, required double velocity}) {
    final v = velocity;
    final d = delta;
    if (v <= -_pageSwipeVelocityThreshold ||
        d <= -_pageSwipeDistanceThreshold) {
      widget.onPageTurn?.call(true);
      return;
    }
    if (v >= _pageSwipeVelocityThreshold ||
        d >= _pageSwipeDistanceThreshold) {
      widget.onPageTurn?.call(false);
    }
  }

  void _onScaleStart(ScaleStartDetails details) {
    _pinchStartScale = _zoom;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (details.pointerCount >= 2) {
      _setZoom(_pinchStartScale * details.scale);
    }
  }

  void _onPointerDown(PointerDownEvent event) {
    _activePointers[event.pointer] = event.localPosition;
    if (_activePointers.length == 2) {
      _pinchStartDistance = _pointerDistance();
      _pinchStartScale = _zoom;
    }
  }

  void _onPointerMove(PointerMoveEvent event) {
    _activePointers[event.pointer] = event.localPosition;

    if (_activePointers.length >= 2 && widget.contentHandlesPageSwipe) {
      final distance = _pointerDistance();
      final start = _pinchStartDistance;
      if (start != null && start > 0) {
        _setZoom(_pinchStartScale * (distance / start));
      }
      return;
    }

    if (_isZoomedForPan &&
        _activePointers.length == 1 &&
        !widget.allowVerticalScroll) {
      setState(() => _panOffset += event.delta);
    }
  }

  void _onPointerUp(PointerUpEvent event) {
    _activePointers.remove(event.pointer);
    if (_activePointers.length < 2) {
      _pinchStartDistance = null;
    }
  }

  void _onPointerCancel(PointerCancelEvent event) {
    _activePointers.remove(event.pointer);
    if (_activePointers.length < 2) {
      _pinchStartDistance = null;
    }
  }

  double _pointerDistance() {
    final points = _activePointers.values.toList(growable: false);
    if (points.length < 2) return 0;
    return (points[0] - points[1]).distance;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<double>(ebookReaderZoomProvider, (previous, next) {
      if ((next - 1).abs() < 0.01) {
        setState(() => _panOffset = Offset.zero);
      }
    });

    Widget content = Transform.translate(
      offset: _panOffset,
      child: Transform.scale(
        scale: _zoom,
        alignment: Alignment.topCenter,
        child: widget.child,
      ),
    );

    if (_blockChildPointer) {
      content = IgnorePointer(child: content);
    }

    if (widget.contentHandlesPageSwipe || _isZoomedForPan) {
      content = Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: _onPointerDown,
        onPointerMove: _onPointerMove,
        onPointerUp: _onPointerUp,
        onPointerCancel: _onPointerCancel,
        child: content,
      );
    }

    return ClipRect(
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onDoubleTap: _handleDoubleTap,
        onScaleStart: widget.contentHandlesPageSwipe ? null : _onScaleStart,
        onScaleUpdate: widget.contentHandlesPageSwipe
            ? null
            : (details) {
                if (details.pointerCount >= 2) {
                  _onScaleUpdate(details);
                }
              },
        onHorizontalDragStart:
            _allowViewportPageSwipe ? _onHorizontalDragStart : null,
        onHorizontalDragUpdate:
            _allowViewportPageSwipe ? _onHorizontalDragUpdate : null,
        onHorizontalDragEnd:
            _allowViewportPageSwipe ? _onHorizontalDragEnd : null,
        child: content,
      ),
    );
  }
}

/// 键盘方向键、桌面滚轮翻页。
class EbookReaderGestureHost extends ConsumerWidget {
  const EbookReaderGestureHost({
    super.key,
    required this.kind,
    required this.child,
    required this.onPrevPage,
    required this.onNextPage,
  });

  final EbookKind kind;
  final Widget child;
  final VoidCallback onPrevPage;
  final VoidCallback onNextPage;

  bool get _supportsPageTurn {
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
    final pageTurnEnabled = viewMode == EbookReaderViewMode.page &&
        _supportsPageTurn &&
        zoom <= 1.05;

    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (!pageTurnEnabled || event is! KeyDownEvent) {
          return KeyEventResult.ignored;
        }
        if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
          onPrevPage();
          return KeyEventResult.handled;
        }
        if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
          onNextPage();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Listener(
        onPointerSignal: (event) {
          if (!pageTurnEnabled || event is! PointerScrollEvent) return;
          final dy = event.scrollDelta.dy;
          if (dy > 16) {
            onNextPage();
          } else if (dy < -16) {
            onPrevPage();
          }
        },
        child: child,
      ),
    );
  }
}
