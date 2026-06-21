import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 首页是否处于内联布局编辑模式。
final homeLayoutEditModeProvider =
    NotifierProvider<HomeLayoutEditModeNotifier, bool>(
  HomeLayoutEditModeNotifier.new,
);

class HomeLayoutEditModeNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void enter() => state = true;

  void exit() => state = false;

  void toggle() => state = !state;
}
