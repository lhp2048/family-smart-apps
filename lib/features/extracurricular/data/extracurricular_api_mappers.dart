import 'package:flutter/material.dart';

import '../../dashboard/data/family_api_client.dart';
import 'extracurricular_models.dart';

List<Map<String, dynamic>> _listFromData(Map<String, dynamic> data) {
  final raw =
      data['list'] ?? data['rows'] ?? data['items'] ?? data['records'];
  if (raw is! List) return const [];
  return raw
      .whereType<Map>()
      .map((e) => Map<String, dynamic>.from(e))
      .toList();
}

ExtracurricularMediumKind mediumKindFromFilterId(String filterId) {
  switch (filterId) {
    case 'book':
    case ExtracurricularFilterIds.golden:
      return ExtracurricularMediumKind.book;
    case 'movie':
    case ExtracurricularFilterIds.seventh:
      return ExtracurricularMediumKind.movie;
    case 'tv':
      return ExtracurricularMediumKind.tvSeries;
    case 'anime':
      return ExtracurricularMediumKind.anime;
    case 'music':
    case 'game':
    case ExtracurricularFilterIds.doc:
    default:
      return ExtracurricularMediumKind.documentary;
  }
}

String _defaultEmojiForKind(ExtracurricularMediumKind k) {
  switch (k) {
    case ExtracurricularMediumKind.book:
      return '📚';
    case ExtracurricularMediumKind.movie:
      return '🎬';
    case ExtracurricularMediumKind.tvSeries:
      return '📺';
    case ExtracurricularMediumKind.anime:
      return '🎮';
    case ExtracurricularMediumKind.documentary:
      return '🎥';
  }
}

String _mediumLabelForKind(ExtracurricularMediumKind k, String typeFallback) {
  if (typeFallback.isNotEmpty) return typeFallback;
  switch (k) {
    case ExtracurricularMediumKind.book:
      return '图书';
    case ExtracurricularMediumKind.movie:
      return '电影';
    case ExtracurricularMediumKind.tvSeries:
      return '电视剧';
    case ExtracurricularMediumKind.anime:
      return '动漫';
    case ExtracurricularMediumKind.documentary:
      return '纪录片/其他';
  }
}

int _intFromDynamic(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString().trim()) ?? 0;
}

/// 接口可能返回数字 1–5，也可能返回星级字符串如 `★★★★★`。
int _ratingStarsFromApi(dynamic raw) {
  if (raw == null) return 0;
  if (raw is num) {
    return raw.round().clamp(0, 5);
  }
  final s = raw.toString().trim();
  if (s.isEmpty) return 0;
  final asInt = int.tryParse(s);
  if (asInt != null) {
    return asInt.clamp(0, 5);
  }
  final asDouble = double.tryParse(s);
  if (asDouble != null) {
    return asDouble.round().clamp(0, 5);
  }
  var n = '★'.allMatches(s).length;
  if (n == 0) {
    n = '⭐'.allMatches(s).length;
  }
  if (n == 0) {
    n = '☆'.allMatches(s).length;
  }
  if (n > 0) {
    return n.clamp(1, 5);
  }
  return 0;
}

ExtracurricularItem extracurricularItemFromApiMap(Map<String, dynamic> m) {
  final id = m['id']?.toString() ?? '';
  final filterId = m['filterId']?.toString() ?? ExtracurricularFilterIds.all;
  final kind = mediumKindFromFilterId(filterId);
  final typeStr = m['type']?.toString() ?? '';
  final genre = m['genre']?.toString() ?? typeStr;
  final stars = _ratingStarsFromApi(m['rating']);
  final watchedRaw = m['watched'];
  final watched = watchedRaw == true ||
      watchedRaw == 1 ||
      watchedRaw == '1' ||
      watchedRaw == 'true';
  final emojiRaw =
      m['cover_emoji']?.toString() ?? m['emoji']?.toString();
  final emoji = (emojiRaw != null && emojiRaw.isNotEmpty)
      ? emojiRaw
      : _defaultEmojiForKind(kind);

  return ExtracurricularItem(
    id: id.isNotEmpty ? id : '${m['title']}'.hashCode.toString(),
    title: m['title']?.toString() ?? '',
    filterId: filterId,
    mediumKind: kind,
    mediumLabel: _mediumLabelForKind(kind, typeStr),
    year: _intFromDynamic(m['year']),
    genre: genre,
    ratingStars: stars,
    description: m['summary']?.toString() ??
        m['description']?.toString() ??
        m['desc']?.toString() ??
        '',
    emoji: emoji,
    watched: watched,
  );
}

ExtracurricularSidebarEntry extracurricularSidebarFromApiMap(
  Map<String, dynamic> m,
) {
  final filterId = m['filterId']?.toString() ?? '';
  final label = m['label']?.toString() ?? filterId;
  final iconStr = m['icon']?.toString().trim();
  String? emoji;
  if (iconStr != null &&
      iconStr.isNotEmpty &&
      !iconStr.startsWith('http') &&
      !iconStr.contains('/')) {
    emoji = iconStr;
  }
  return ExtracurricularSidebarEntry(
    filterId: filterId,
    label: label,
    icon: emoji == null ? Icons.apps_rounded : null,
    iconEmoji: emoji,
  );
}

Future<List<ExtracurricularSidebarEntry>> fetchExtracurricularFiltersRemote(
  FamilyApiClient client,
) async {
  final data = await client.fetchExtracurricularFilters();
  final maps = _listFromData(data);
  final out = maps.map(extracurricularSidebarFromApiMap).toList();
  if (out.isEmpty) {
    return const [
      ExtracurricularSidebarEntry(
        filterId: ExtracurricularFilterIds.all,
        label: '全部',
        icon: Icons.apps_rounded,
      ),
    ];
  }
  return out;
}

Future<List<ExtracurricularItem>> fetchAllExtracurricularItemsRemote(
  FamilyApiClient client,
  String filterId,
) async {
  final out = <ExtracurricularItem>[];
  const pageSize = 100;
  var page = 1;
  while (true) {
    final data = await client.fetchExtracurricularItems(
      filterId: filterId,
      page: page,
      pageSize: pageSize,
    );
    final maps = _listFromData(data);
    for (final m in maps) {
      out.add(extracurricularItemFromApiMap(m));
    }
    final totalRaw = _intFromDynamic(data['total']);
    final total = totalRaw > 0 ? totalRaw : out.length;
    if (out.length >= total || maps.isEmpty) break;
    page++;
    if (page > 200) break;
  }
  return out;
}
