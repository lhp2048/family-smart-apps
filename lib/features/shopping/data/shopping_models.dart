class ShoppingLink {
  const ShoppingLink({
    required this.url,
    this.label,
    this.platform,
    this.isPrimary = false,
  });

  final String url;
  final String? label;
  final String? platform;
  final bool isPrimary;
}

class ShoppingItem {
  const ShoppingItem({
    required this.itemId,
    required this.title,
    this.specText,
    this.platform,
    this.currentPrice,
    this.currency = 'CNY',
    this.quantity = 1,
    this.memberCode,
    this.purchased = false,
    this.addedAt,
    this.purchasedAt,
    this.coverUrl,
    this.notes,
    this.links = const [],
  });

  final String itemId;
  final String title;
  final String? specText;
  final String? platform;
  final double? currentPrice;
  final String currency;
  final int quantity;
  final String? memberCode;
  final bool purchased;
  final String? addedAt;
  final String? purchasedAt;
  final String? coverUrl;
  final String? notes;
  final List<ShoppingLink> links;

  bool get hasLinks => links.any((l) => l.url.isNotEmpty);

  String get copyText {
    final spec = specText?.trim();
    if (spec != null && spec.isNotEmpty) {
      return '$title $spec';
    }
    return title;
  }

  ShoppingLink? get primaryLink {
    for (final l in links) {
      if (l.isPrimary && l.url.isNotEmpty) return l;
    }
    for (final l in links) {
      if (l.url.isNotEmpty) return l;
    }
    return null;
  }
}

class ShoppingPriceRecord {
  const ShoppingPriceRecord({
    required this.recordId,
    required this.price,
    required this.currency,
    required this.recordedAt,
    required this.recordKind,
    this.correctsRecordId,
    this.voided = false,
    this.note,
  });

  final String recordId;
  final double price;
  final String currency;
  final String recordedAt;
  final String recordKind;
  final String? correctsRecordId;
  final bool voided;
  final String? note;
}

class ShoppingPriceTrendPoint {
  const ShoppingPriceTrendPoint({
    required this.recordedAt,
    required this.price,
  });

  final String recordedAt;
  final double price;
}

class ShoppingPriceSeries {
  const ShoppingPriceSeries({
    required this.itemId,
    required this.title,
    required this.currency,
    this.currentPrice,
    this.points = const [],
  });

  final String itemId;
  final String title;
  final String currency;
  final double? currentPrice;
  final List<ShoppingPriceTrendPoint> points;
}
