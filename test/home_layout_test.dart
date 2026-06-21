import 'package:flutter_test/flutter_test.dart';

import 'package:family_smart_center/features/dashboard/layout/home_card_catalog.dart';
import 'package:family_smart_center/features/dashboard/layout/home_layout_defaults.dart';
import 'package:family_smart_center/features/dashboard/layout/home_layout_models.dart';

void main() {
  test('默认布局含作业/积分摘要卡与两条分隔', () {
    final items = kDefaultHomeLayoutConfig.visibleItems;
    expect(items.length, 10);

    final homework = items[0] as HomeFeatureLayoutItem;
    expect(homework.cardId, 'homework');
    expect(homework.size, HomeCardSize.summary);

    final points = items[1] as HomeFeatureLayoutItem;
    expect(points.cardId, 'points');
    expect(points.size, HomeCardSize.summary);

    final lifeSep = items[2] as HomeSeparatorLayoutItem;
    expect(lifeSep.title, '学习和生活');

    final settings = items[9] as HomeFeatureLayoutItem;
    expect(settings.cardId, 'settings');
    expect(settings.size, HomeCardSize.entry);
  });

  test('布局 JSON 往返', () {
    final encoded = kDefaultHomeLayoutConfig.toJson();
    final decoded = HomeLayoutConfig.fromJson(encoded);
    expect(decoded.items.length, kDefaultHomeLayoutConfig.items.length);

    final first = decoded.items.first as HomeFeatureLayoutItem;
    expect(first.cardId, 'homework');
    expect(first.size, HomeCardSize.summary);
  });

  test('兼容旧版 fat/thin 字段', () {
    expect(HomeCardSize.fromJson('fat'), HomeCardSize.summary);
    expect(HomeCardSize.fromJson('thin'), HomeCardSize.entry);
    expect(HomeCardSize.fromJson('summary'), HomeCardSize.summary);
    expect(HomeCardSize.fromJson('entry'), HomeCardSize.entry);
  });

  test('catalog 覆盖全部默认功能卡', () {
    for (final item in kDefaultHomeLayoutConfig.items) {
      if (item is! HomeFeatureLayoutItem) continue;
      expect(
        homeCardCatalogEntry(item.cardId),
        isNotNull,
        reason: item.cardId,
      );
    }
  });
}
