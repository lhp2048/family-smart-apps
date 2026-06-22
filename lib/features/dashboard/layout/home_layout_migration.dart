import 'home_layout_defaults.dart';
import 'home_layout_models.dart';

/// 将 [kDefaultHomeLayoutConfig] 中新增、但本地持久化布局里还没有的功能卡补入。
///
/// 避免用户升级 App 后仍沿用旧版 SharedPreferences 布局，看不到新模块（如家庭日历）。
HomeLayoutConfig mergeMissingDefaultFeatureCards(HomeLayoutConfig saved) {
  final presentCardIds = <String>{
    for (final e in saved.items)
      if (e is HomeFeatureLayoutItem) e.cardId,
  };

  final missing = kDefaultHomeLayoutConfig.items
      .whereType<HomeFeatureLayoutItem>()
      .where((e) => !presentCardIds.contains(e.cardId))
      .toList();

  if (missing.isEmpty) return saved;

  var items = List<HomeLayoutItem>.from(saved.items);

  for (final feature in missing) {
    final defaultIdx = kDefaultHomeLayoutConfig.items.indexWhere(
      (e) => e is HomeFeatureLayoutItem && e.cardId == feature.cardId,
    );
    var insertAt = items.length;

    for (var i = defaultIdx - 1; i >= 0; i--) {
      final prev = kDefaultHomeLayoutConfig.items[i];
      if (prev is! HomeFeatureLayoutItem) continue;
      final anchorIdx = items.indexWhere(
        (e) => e is HomeFeatureLayoutItem && e.cardId == prev.cardId,
      );
      if (anchorIdx >= 0) {
        insertAt = anchorIdx + 1;
        break;
      }
    }

    if (insertAt >= items.length) {
      final sepIdx = items.indexWhere((e) => e is HomeSeparatorLayoutItem);
      if (sepIdx >= 0) insertAt = sepIdx;
    }

    items.insert(insertAt.clamp(0, items.length), feature);
  }

  return HomeLayoutConfig(items: items);
}

bool homeLayoutItemsEquivalent(
  List<HomeLayoutItem> a,
  List<HomeLayoutItem> b,
) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    final x = a[i];
    final y = b[i];
    if (x.itemId != y.itemId || x.hidden != y.hidden) return false;
    if (x is HomeFeatureLayoutItem && y is HomeFeatureLayoutItem) {
      if (x.cardId != y.cardId || x.size != y.size) return false;
    } else if (x is HomeSeparatorLayoutItem && y is HomeSeparatorLayoutItem) {
      if (x.title != y.title) return false;
    } else {
      return false;
    }
  }
  return true;
}
