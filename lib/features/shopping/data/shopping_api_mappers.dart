import '../../dashboard/data/family_api_client.dart';
import 'shopping_models.dart';

ShoppingLink shoppingLinkFromMap(Map<String, dynamic> m) {
  return ShoppingLink(
    url: m['url']?.toString() ?? '',
    label: m['label']?.toString(),
    platform: m['platform']?.toString(),
    isPrimary: m['isPrimary'] == true || m['isPrimary'] == 1,
  );
}

ShoppingItem shoppingItemFromMap(Map<String, dynamic> m) {
  final linksRaw = m['links'];
  final links = <ShoppingLink>[];
  if (linksRaw is List) {
    for (final e in linksRaw) {
      if (e is Map) {
        links.add(shoppingLinkFromMap(Map<String, dynamic>.from(e)));
      }
    }
  }
  final priceRaw = m['currentPrice'];
  double? price;
  if (priceRaw is num) {
    price = priceRaw.toDouble();
  }
  return ShoppingItem(
    itemId: m['itemId']?.toString() ?? '',
    title: m['title']?.toString() ?? '',
    specText: m['specText']?.toString(),
    platform: m['platform']?.toString(),
    currentPrice: price,
    currency: m['currency']?.toString() ?? 'CNY',
    quantity: (m['quantity'] as num?)?.toInt() ?? 1,
    memberCode: m['memberCode']?.toString(),
    purchased: m['purchased'] == true || m['purchased'] == 1,
    addedAt: m['addedAt']?.toString(),
    purchasedAt: m['purchasedAt']?.toString(),
    coverUrl: m['coverUrl']?.toString(),
    notes: m['notes']?.toString(),
    links: links,
  );
}

ShoppingPriceRecord shoppingPriceRecordFromMap(Map<String, dynamic> m) {
  return ShoppingPriceRecord(
    recordId: m['recordId']?.toString() ?? '',
    price: (m['price'] as num?)?.toDouble() ?? 0,
    currency: m['currency']?.toString() ?? 'CNY',
    recordedAt: m['recordedAt']?.toString() ?? '',
    recordKind: m['recordKind']?.toString() ?? 'quote',
    correctsRecordId: m['correctsRecordId']?.toString(),
    voided: m['voided'] == true || m['voided'] == 1,
    note: m['note']?.toString(),
  );
}

List<Map<String, dynamic>> shoppingListMapsFromData(Map<String, dynamic> data) {
  final raw = data['list'];
  if (raw is! List) return const [];
  return raw
      .whereType<Map>()
      .map((e) => Map<String, dynamic>.from(e))
      .toList();
}

Future<List<ShoppingItem>> fetchAllShoppingItemsRemote(
  FamilyApiClient client, {
  String? purchased,
}) async {
  final out = <ShoppingItem>[];
  const pageSize = 100;
  var page = 1;
  while (true) {
    final data = await client.fetchShoppingItems(
      page: page,
      pageSize: pageSize,
      purchased: purchased,
    );
    final maps = shoppingListMapsFromData(data);
    for (final m in maps) {
      out.add(shoppingItemFromMap(m));
    }
    final total = (data['total'] as num?)?.toInt() ?? out.length;
    if (out.length >= total || maps.isEmpty) break;
    page++;
    if (page > 50) break;
  }
  return out;
}

List<ShoppingPriceRecord> priceRecordsFromHistoryData(
  Map<String, dynamic> data,
) {
  final raw = data['records'];
  if (raw is! List) return const [];
  return raw
      .whereType<Map>()
      .map((e) => shoppingPriceRecordFromMap(Map<String, dynamic>.from(e)))
      .toList();
}

List<ShoppingPriceSeries> priceSeriesFromTrendsData(Map<String, dynamic> data) {
  final raw = data['series'];
  if (raw is! List) return const [];
  return raw.map((e) {
    final m = Map<String, dynamic>.from(e as Map);
    final ptsRaw = m['points'];
    final points = <ShoppingPriceTrendPoint>[];
    if (ptsRaw is List) {
      for (final p in ptsRaw) {
        if (p is Map) {
          final pm = Map<String, dynamic>.from(p);
          points.add(
            ShoppingPriceTrendPoint(
              recordedAt: pm['recordedAt']?.toString() ?? '',
              price: (pm['price'] as num?)?.toDouble() ?? 0,
            ),
          );
        }
      }
    }
    return ShoppingPriceSeries(
      itemId: m['itemId']?.toString() ?? '',
      title: m['title']?.toString() ?? '',
      currency: m['currency']?.toString() ?? 'CNY',
      currentPrice: (m['currentPrice'] as num?)?.toDouble(),
      points: points,
    );
  }).toList();
}
