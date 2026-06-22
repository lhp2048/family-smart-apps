import '../layout/home_card_catalog.dart';
import '../layout/home_layout_models.dart';

/// Unified home card preview envelope from `GET /home/cards/{cardId}?size=`.
class HomeCardPreview {
  const HomeCardPreview({
    required this.cardId,
    required this.size,
    required this.presentation,
    this.title,
    this.subtitle,
    this.updatedAt,
  });

  final String cardId;
  final HomeCardSize size;
  final HomeCardPresentation presentation;

  /// 服务端可选标题；为空时客户端使用 catalog 硬编码。
  final String? title;

  /// 服务端可选副标题；为空时客户端使用 catalog 硬编码。
  final String? subtitle;
  final String? updatedAt;

  factory HomeCardPreview.loading(String cardId, HomeCardSize size) {
    return HomeCardPreview(
      cardId: cardId,
      size: size,
      presentation: const HomeCardPresentationLoading(),
    );
  }

  factory HomeCardPreview.error(String cardId, HomeCardSize size, String message) {
    return HomeCardPreview(
      cardId: cardId,
      size: size,
      presentation: HomeCardPresentationEmpty(message: message),
    );
  }

  factory HomeCardPreview.unconfigured(String cardId, HomeCardSize size) {
    return HomeCardPreview(
      cardId: cardId,
      size: size,
      presentation: const HomeCardPresentationEmpty(message: '未配置'),
    );
  }
}

sealed class HomeCardPresentation {
  const HomeCardPresentation();
}

class HomeCardPresentationCompact extends HomeCardPresentation {
  const HomeCardPresentationCompact({this.badge, this.hint});

  final String? badge;
  final String? hint;
}

class HomeCardPreviewRow {
  const HomeCardPreviewRow({
    required this.label,
    required this.value,
    this.secondary,
  });

  final String label;
  final String value;
  final String? secondary;
}

class HomeCardPresentationRows extends HomeCardPresentation {
  const HomeCardPresentationRows({required this.rows, this.footer});

  final List<HomeCardPreviewRow> rows;
  final String? footer;
}

class HomeCardPreviewHighlight {
  const HomeCardPreviewHighlight({
    required this.type,
    required this.label,
    required this.detail,
  });

  final String type;
  final String label;
  final String detail;
}

class HomeCardPresentationHighlights extends HomeCardPresentation {
  const HomeCardPresentationHighlights({required this.highlights});

  final List<HomeCardPreviewHighlight> highlights;
}

class HomeCardPresentationEmpty extends HomeCardPresentation {
  const HomeCardPresentationEmpty({this.message = ''});

  final String message;
}

class HomeCardPresentationLoading extends HomeCardPresentation {
  const HomeCardPresentationLoading();
}

/// Riverpod family key for home card preview requests.
class HomeCardPreviewKey {
  const HomeCardPreviewKey({
    required this.cardId,
    required this.size,
    this.bizDate,
    this.periodStart,
    this.periodEnd,
  });

  final String cardId;
  final HomeCardSize size;
  final String? bizDate;
  final String? periodStart;
  final String? periodEnd;

  String get cacheKey => '$cardId:${size.toJson()}';

  @override
  bool operator ==(Object other) {
    return other is HomeCardPreviewKey &&
        other.cardId == cardId &&
        other.size == size &&
        other.bizDate == bizDate &&
        other.periodStart == periodStart &&
        other.periodEnd == periodEnd;
  }

  @override
  int get hashCode => Object.hash(cardId, size, bizDate, periodStart, periodEnd);
}

String homeCardPreviewLookupKey(String cardId, HomeCardSize size) =>
    '$cardId:${size.toJson()}';

/// API 标题优先，否则使用本地 catalog。
String homeCardDisplayTitle({
  required HomeCardPreview preview,
  required HomeCardCatalogEntry entry,
}) {
  final apiTitle = preview.title?.trim();
  if (apiTitle != null && apiTitle.isNotEmpty) {
    return apiTitle;
  }
  return entry.title;
}

String homeCardDisplaySubtitle({
  required HomeCardPreview preview,
  required HomeCardCatalogEntry entry,
}) {
  final apiSubtitle = preview.subtitle?.trim();
  if (apiSubtitle != null && apiSubtitle.isNotEmpty) {
    return apiSubtitle;
  }
  return entry.subtitle;
}

List<HomeFeatureLayoutItem> visibleFeatureLayoutItems(
  List<HomeLayoutItem> items,
) {
  return items.whereType<HomeFeatureLayoutItem>().toList(growable: false);
}

Set<HomeCardPreviewKey> previewKeysForVisibleFeatures(
  List<HomeLayoutItem> visibleItems, {
  required String bizDate,
  required String periodStart,
  required String periodEnd,
}) {
  final keys = <HomeCardPreviewKey>{};
  for (final item in visibleFeatureLayoutItems(visibleItems)) {
    keys.add(
      HomeCardPreviewKey(
        cardId: item.cardId,
        size: item.size,
        bizDate: bizDate,
        periodStart: periodStart,
        periodEnd: periodEnd,
      ),
    );
  }
  return keys;
}
