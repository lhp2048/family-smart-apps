import 'package:flutter_test/flutter_test.dart';

import 'package:family_smart_center/features/dashboard/layout/home_card_catalog.dart';
import 'package:family_smart_center/features/dashboard/layout/home_layout_defaults.dart';
import 'package:family_smart_center/features/dashboard/layout/home_layout_models.dart';
import 'package:family_smart_center/features/dashboard/layout/home_layout_renderer.dart';

void main() {
  test('默认布局含作业/积分/日历中号卡与两条分隔', () {
    final items = kDefaultHomeLayoutConfig.visibleItems;
    expect(items.length, 12);

    final homework = items[0] as HomeFeatureLayoutItem;
    expect(homework.cardId, 'homework');
    expect(homework.size, HomeCardSize.medium);

    final points = items[1] as HomeFeatureLayoutItem;
    expect(points.cardId, 'points');
    expect(points.size, HomeCardSize.medium);

    final calendar = items[2] as HomeFeatureLayoutItem;
    expect(calendar.cardId, 'calendar');
    expect(calendar.size, HomeCardSize.medium);

    final lifeSep = items[3] as HomeSeparatorLayoutItem;
    expect(lifeSep.title, '学习和生活');

    final settings = items[11] as HomeFeatureLayoutItem;
    expect(settings.cardId, 'settings');
    expect(settings.size, HomeCardSize.small);
  });

  test('布局 JSON 往返', () {
    final encoded = kDefaultHomeLayoutConfig.toJson();
    final decoded = HomeLayoutConfig.fromJson(encoded);
    expect(decoded.items.length, kDefaultHomeLayoutConfig.items.length);

    final first = decoded.items.first as HomeFeatureLayoutItem;
    expect(first.cardId, 'homework');
    expect(first.size, HomeCardSize.medium);
  });

  test('兼容旧版 size 字段', () {
    expect(HomeCardSize.fromJson('fat'), HomeCardSize.medium);
    expect(HomeCardSize.fromJson('thin'), HomeCardSize.small);
    expect(HomeCardSize.fromJson('summary'), HomeCardSize.medium);
    expect(HomeCardSize.fromJson('entry'), HomeCardSize.small);
    expect(HomeCardSize.fromJson('medium'), HomeCardSize.medium);
    expect(HomeCardSize.fromJson('small'), HomeCardSize.small);
    expect(HomeCardSize.fromJson('large'), HomeCardSize.large);
  });

  test('仅中号可与相邻中号并排', () {
    const items = [
      HomeFeatureLayoutItem(
        itemId: 'a',
        cardId: 'homework',
        size: HomeCardSize.medium,
      ),
      HomeFeatureLayoutItem(
        itemId: 'b',
        cardId: 'points',
        size: HomeCardSize.medium,
      ),
      HomeFeatureLayoutItem(
        itemId: 'c',
        cardId: 'settings',
        size: HomeCardSize.large,
      ),
    ];
    expect(nextMediumFeaturePair(items, 0).length, 2);
    expect(nextMediumFeaturePair(items, 2).length, 0);

    const soloMedium = [
      HomeFeatureLayoutItem(
        itemId: 'a',
        cardId: 'homework',
        size: HomeCardSize.medium,
      ),
      HomeFeatureLayoutItem(
        itemId: 'b',
        cardId: 'settings',
        size: HomeCardSize.large,
      ),
    ];
    expect(nextMediumFeaturePair(soloMedium, 0).length, 1);
  });

  test('小号最多四个并排一行', () {
    const items = [
      HomeFeatureLayoutItem(itemId: '1', cardId: 'a', size: HomeCardSize.small),
      HomeFeatureLayoutItem(itemId: '2', cardId: 'b', size: HomeCardSize.small),
      HomeFeatureLayoutItem(itemId: '3', cardId: 'c', size: HomeCardSize.small),
      HomeFeatureLayoutItem(itemId: '4', cardId: 'd', size: HomeCardSize.small),
      HomeFeatureLayoutItem(itemId: '5', cardId: 'e', size: HomeCardSize.small),
    ];
    expect(nextSmallFeatureRun(items, 0).length, 4);
    expect(nextSmallFeatureRun(items, 4).length, 1);
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
