import 'package:flutter_test/flutter_test.dart';

import 'package:family_smart_center/features/dashboard/data/home_card_preview_models.dart';
import 'package:family_smart_center/features/dashboard/data/home_card_preview_parsers.dart';
import 'package:family_smart_center/features/dashboard/layout/home_card_catalog.dart';
import 'package:family_smart_center/features/dashboard/layout/home_layout_models.dart';

void main() {
  test('parse compact presentation', () {
    final preview = parseHomeCardPreview({
      'cardId': 'homework',
      'size': 'small',
      'title': '今日作业',
      'presentation': {'type': 'compact', 'badge': '60%', 'hint': '川川'},
    });
    expect(preview.cardId, 'homework');
    expect(preview.size, HomeCardSize.small);
    expect(preview.title, '今日作业');
    final p = preview.presentation;
    expect(p, isA<HomeCardPresentationCompact>());
    expect((p as HomeCardPresentationCompact).badge, '60%');
    expect(p.hint, '川川');
  });

  test('homeCardDisplayTitle falls back to catalog', () {
    final entry = homeCardCatalogEntry('wishwall')!;
    final preview = parseHomeCardPreview({
      'cardId': 'wishwall',
      'size': 'medium',
      'presentation': {'type': 'empty'},
    });
    expect(
      homeCardDisplayTitle(preview: preview, entry: entry),
      entry.title,
    );
  });

  test('homeCardDisplayTitle prefers API title', () {
    final entry = homeCardCatalogEntry('wishwall')!;
    final preview = parseHomeCardPreview({
      'cardId': 'wishwall',
      'size': 'medium',
      'title': '未来心愿',
      'presentation': {'type': 'empty'},
    });
    expect(
      homeCardDisplayTitle(preview: preview, entry: entry),
      '未来心愿',
    );
  });

  test('parse rows presentation with footer', () {
    final preview = parseHomeCardPreview({
      'cardId': 'points',
      'size': 'medium',
      'presentation': {
        'type': 'rows',
        'rows': [
          {'label': '川川', 'value': '12'},
        ],
        'footer': '领先 川川 12 分',
      },
    });
    final p = preview.presentation as HomeCardPresentationRows;
    expect(p.rows.length, 1);
    expect(p.rows.first.label, '川川');
    expect(p.footer, '领先 川川 12 分');
  });

  test('parse highlights presentation', () {
    final preview = parseHomeCardPreview({
      'cardId': 'calendar',
      'size': 'large',
      'presentation': {
        'type': 'highlights',
        'highlights': [
          {'type': 'reminder', 'label': '交作业', 'detail': '20:00'},
        ],
      },
    });
    final p = preview.presentation as HomeCardPresentationHighlights;
    expect(p.highlights.first.label, '交作业');
  });
}
