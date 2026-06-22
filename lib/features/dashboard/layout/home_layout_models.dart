/// 首页功能卡展示形态：小（入口条）、中（摘要，可并排）、大（摘要，通栏双倍高）。
enum HomeCardSize {
  small,
  medium,
  large;

  String toJson() => name;

  String get label => switch (this) {
        HomeCardSize.small => '小',
        HomeCardSize.medium => '中',
        HomeCardSize.large => '大',
      };

  bool get isSmall => this == HomeCardSize.small;

  bool get isMedium => this == HomeCardSize.medium;

  bool get isLarge => this == HomeCardSize.large;

  /// 中 / 大使用摘要内容；小使用入口条。
  bool get usesSummaryContent => isMedium || isLarge;

  /// 仅中号可与相邻中号并排（一行 2 个）。
  bool get canPairHorizontally => isMedium;

  /// 小号可与相邻小号并排（一行最多 [kHomeSmallCardsMaxPerRow] 个）。
  bool get canGroupInSmallRow => isSmall;

  static HomeCardSize fromJson(String? raw) {
    switch (raw) {
      case 'small':
      case 'entry':
      case 'thin':
        return HomeCardSize.small;
      case 'large':
        return HomeCardSize.large;
      case 'medium':
      case 'summary':
      case 'fat':
        return HomeCardSize.medium;
      default:
        return HomeCardSize.medium;
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
