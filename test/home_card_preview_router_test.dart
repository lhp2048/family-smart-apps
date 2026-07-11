import 'package:flutter_test/flutter_test.dart';

import 'package:family_smart_center/features/dashboard/data/home_card_remote_catalog.dart';
import 'package:family_smart_center/features/dashboard/layout/home_layout_defaults.dart';
import 'package:family_smart_center/features/dashboard/layout/home_layout_models.dart';

void main() {
  group('resolveHomeCardOwner', () {
    test('uses catalog owner when present', () {
      const catalog = RemoteHomeCardCatalog(
        items: [
          RemoteHomeCardCatalogItem(
            cardId: 'ebook',
            title: '电子图书',
            subtitle: '',
            sortOrder: 9,
            ownerService: 'mediacenter',
          ),
        ],
      );
      expect(
        resolveHomeCardOwner(cardId: 'ebook', catalog: catalog),
        'mediacenter',
      );
      expect(
        resolveHomeCardOwner(cardId: 'homework', catalog: catalog),
        'datacenter',
      );
    });

    test('falls back to legacy map when catalog missing entry', () {
      expect(
        resolveHomeCardOwner(cardId: 'ebook', catalog: null),
        'mediacenter',
      );
    });
  });

  group('filterLayoutByEnabledCatalog', () {
    test('hides disabled cards in browse layout', () {
      final items = kDefaultHomeLayoutConfig.visibleItems;
      final filtered = filterLayoutByEnabledCatalog(
        items,
        {'homework', 'calendar'},
      );
      final cardIds = filtered
          .whereType<HomeFeatureLayoutItem>()
          .map((e) => e.cardId)
          .toList();
      expect(cardIds, contains('homework'));
      expect(cardIds, contains('calendar'));
      expect(cardIds, isNot(contains('ebook')));
    });

    test('returns all items when enabled set is null', () {
      final items = kDefaultHomeLayoutConfig.visibleItems;
      expect(
        filterLayoutByEnabledCatalog(items, null).length,
        items.length,
      );
    });
  });

  group('parseRemoteHomeCardCatalog', () {
    test('parses list and sort order', () {
      final catalog = parseRemoteHomeCardCatalog({
        'list': [
          {
            'cardId': 'ebook',
            'title': '书库',
            'ownerService': 'mediacenter',
            'sortOrder': 9,
          },
          {
            'cardId': 'homework',
            'title': '作业',
            'ownerService': 'datacenter',
            'sortOrder': 1,
          },
        ],
      });
      expect(catalog.items.length, 2);
      expect(catalog.items.first.cardId, 'homework');
      expect(catalog.ownerFor('ebook'), 'mediacenter');
    });
  });
}
