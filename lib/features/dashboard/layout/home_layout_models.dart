/// 首页功能卡展示形态：摘要（数据预览）或入口（简洁跳转）。
enum HomeCardSize {
  summary,
  entry;

  String toJson() => name;

  String get label => switch (this) {
        HomeCardSize.summary => '摘要卡',
        HomeCardSize.entry => '入口卡',
      };

  static HomeCardSize fromJson(String? raw) {
    switch (raw) {
      case 'entry':
      case 'thin':
        return HomeCardSize.entry;
      case 'summary':
      case 'fat':
      default:
        return HomeCardSize.summary;
    }
  }
}

enum HomeLayoutItemKind {
  feature,
  separator;

  String toJson() => name;

  static HomeLayoutItemKind fromJson(String? raw) {
    return raw == 'separator'
        ? HomeLayoutItemKind.separator
        : HomeLayoutItemKind.feature;
  }
}

sealed class HomeLayoutItem {
  const HomeLayoutItem({
    required this.itemId,
    required this.hidden,
  });

  final String itemId;
  final bool hidden;

  HomeLayoutItemKind get kind;

  HomeLayoutItem copyWithHidden(bool hidden);

  Map<String, dynamic> toJson();
}

class HomeFeatureLayoutItem extends HomeLayoutItem {
  const HomeFeatureLayoutItem({
    required super.itemId,
    required this.cardId,
    required this.size,
    super.hidden = false,
  });

  final String cardId;
  final HomeCardSize size;

  @override
  HomeLayoutItemKind get kind => HomeLayoutItemKind.feature;

  @override
  HomeFeatureLayoutItem copyWithHidden(bool hidden) {
    return HomeFeatureLayoutItem(
      itemId: itemId,
      cardId: cardId,
      size: size,
      hidden: hidden,
    );
  }

  HomeFeatureLayoutItem copyWithSize(HomeCardSize size) {
    return HomeFeatureLayoutItem(
      itemId: itemId,
      cardId: cardId,
      size: size,
      hidden: hidden,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'itemId': itemId,
        'kind': kind.toJson(),
        'cardId': cardId,
        'size': size.toJson(),
        'hidden': hidden,
      };

  static HomeFeatureLayoutItem fromJson(Map<String, dynamic> m) {
    return HomeFeatureLayoutItem(
      itemId: m['itemId']?.toString() ?? '',
      cardId: m['cardId']?.toString() ?? '',
      size: HomeCardSize.fromJson(m['size']?.toString()),
      hidden: m['hidden'] == true,
    );
  }
}

class HomeSeparatorLayoutItem extends HomeLayoutItem {
  const HomeSeparatorLayoutItem({
    required super.itemId,
    required this.title,
    super.hidden = false,
  });

  final String title;

  @override
  HomeLayoutItemKind get kind => HomeLayoutItemKind.separator;

  @override
  HomeSeparatorLayoutItem copyWithHidden(bool hidden) {
    return HomeSeparatorLayoutItem(
      itemId: itemId,
      title: title,
      hidden: hidden,
    );
  }

  HomeSeparatorLayoutItem copyWithTitle(String title) {
    return HomeSeparatorLayoutItem(
      itemId: itemId,
      title: title,
      hidden: hidden,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'itemId': itemId,
        'kind': kind.toJson(),
        'title': title,
        'hidden': hidden,
      };

  static HomeSeparatorLayoutItem fromJson(Map<String, dynamic> m) {
    return HomeSeparatorLayoutItem(
      itemId: m['itemId']?.toString() ?? '',
      title: m['title']?.toString() ?? '',
      hidden: m['hidden'] == true,
    );
  }
}

HomeLayoutItem homeLayoutItemFromJson(Map<String, dynamic> m) {
  final kind = HomeLayoutItemKind.fromJson(m['kind']?.toString());
  if (kind == HomeLayoutItemKind.separator) {
    return HomeSeparatorLayoutItem.fromJson(m);
  }
  return HomeFeatureLayoutItem.fromJson(m);
}

class HomeLayoutConfig {
  const HomeLayoutConfig({required this.items});

  final List<HomeLayoutItem> items;

  List<HomeLayoutItem> get visibleItems =>
      items.where((e) => !e.hidden).toList(growable: false);

  List<HomeLayoutItem> get hiddenItems =>
      items.where((e) => e.hidden).toList(growable: false);

  Map<String, dynamic> toJson() => {
        'schemaVersion': 1,
        'items': items.map((e) => e.toJson()).toList(),
      };

  static HomeLayoutConfig fromJson(Map<String, dynamic> m) {
    final raw = m['items'];
    if (raw is! List) {
      return const HomeLayoutConfig(items: []);
    }
    final items = <HomeLayoutItem>[];
    for (final e in raw) {
      if (e is! Map) continue;
      final item = homeLayoutItemFromJson(Map<String, dynamic>.from(e));
      if (item.itemId.isEmpty) continue;
      items.add(item);
    }
    if (items.isEmpty) {
      return const HomeLayoutConfig(items: []);
    }
    return HomeLayoutConfig(items: items);
  }
}
