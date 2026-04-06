import '../../dashboard/data/family_api_client.dart';
import 'wishwall_prototype_models.dart';

WishwallItem wishwallItemFromApiMap(Map<String, dynamic> m) {
  final rawId = m['id'];
  final id = rawId == null ? '' : rawId.toString();
  final memberCode = m['memberCode']?.toString() ?? '';
  final content = m['content']?.toString() ?? '';
  final emoji = m['emoji']?.toString();
  final cardEmoji =
      (emoji != null && emoji.isNotEmpty) ? emoji : '✨';
  final fulfilledRaw = m['fulfilled'];
  final status = m['status']?.toString().toLowerCase() ?? '';
  final fulfilled = fulfilledRaw == true ||
      fulfilledRaw == 1 ||
      fulfilledRaw == '1' ||
      fulfilledRaw == 'true' ||
      status == 'done' ||
      status == 'fulfilled';
  final createdAtLabel = m['createdAt']?.toString() ?? '';
  final dn = m['displayName']?.toString();
  return WishwallItem(
    id: id.isNotEmpty ? id : '${memberCode}_${content.hashCode}',
    memberCode: memberCode,
    content: content,
    cardEmoji: cardEmoji,
    fulfilled: fulfilled,
    createdAtLabel: createdAtLabel,
    displayName: (dn != null && dn.isNotEmpty) ? dn : null,
  );
}

List<Map<String, dynamic>> wishesListFromData(Map<String, dynamic> data) {
  final raw = data['list'];
  if (raw is! List) return const [];
  return raw
      .whereType<Map>()
      .map((e) => Map<String, dynamic>.from(e))
      .toList();
}

/// 分页拉全量心愿（单页上限由服务端与 [pageSize] 决定）
Future<List<WishwallItem>> fetchAllWishesRemote(FamilyApiClient client) async {
  final out = <WishwallItem>[];
  const pageSize = 100;
  var page = 1;
  while (true) {
    final data = await client.fetchWishes(page: page, pageSize: pageSize);
    final maps = wishesListFromData(data);
    for (final m in maps) {
      out.add(wishwallItemFromApiMap(m));
    }
    final total = (data['total'] as num?)?.toInt() ?? out.length;
    if (out.length >= total || maps.isEmpty) break;
    page++;
    if (page > 200) break;
  }
  return out;
}
