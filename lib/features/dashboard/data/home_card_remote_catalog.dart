import 'package:flutter/material.dart';

import '../layout/home_card_catalog.dart';
import '../layout/home_layout_models.dart';

/// Datacenter `GET /home/cards/catalog` 单项（仅 enabled 卡片）。
class RemoteHomeCardCatalogItem {
  const RemoteHomeCardCatalogItem({
    required this.cardId,
    required this.title,
    required this.subtitle,
    required this.sortOrder,
    required this.ownerService,
    this.discoveryKey,
    this.previewPath,
    this.detailRoute,
  });

  final String cardId;
  final String title;
  final String subtitle;
  final int sortOrder;
  final String ownerService;
  final String? discoveryKey;
  final String? previewPath;
  final String? detailRoute;

  factory RemoteHomeCardCatalogItem.fromJson(Map<String, dynamic> json) {
    return RemoteHomeCardCatalogItem(
      cardId: (json['cardId'] ?? '').toString().trim().toLowerCase(),
      title: (json['title'] ?? '').toString().trim(),
      subtitle: (json['subtitle'] ?? '').toString().trim(),
      sortOrder: _parseInt(json['sortOrder']),
      ownerService: (json['ownerService'] ?? 'datacenter')
          .toString()
          .trim()
          .toLowerCase(),
      discoveryKey: _optionalString(json['discoveryKey']),
      previewPath: _optionalString(json['previewPath']),
      detailRoute: _optionalString(json['detailRoute']),
    );
  }
}

class RemoteHomeCardCatalog {
  const RemoteHomeCardCatalog({required this.items});

  final List<RemoteHomeCardCatalogItem> items;

  Map<String, RemoteHomeCardCatalogItem> get itemsById => {
        for (final item in items) item.cardId: item,
      };

  Set<String> get enabledCardIds =>
      items.map((e) => e.cardId).where((id) => id.isNotEmpty).toSet();

  String? ownerFor(String cardId) {
    final cid = cardId.trim().toLowerCase();
    return itemsById[cid]?.ownerService;
  }
}

/// catalog 未加载或失败时的 owner 兜底（兼容旧部署）。
const kLegacyExternalHomeCardOwners = <String, String>{
  'ebook': 'mediacenter',
};

RemoteHomeCardCatalog parseRemoteHomeCardCatalog(Map<String, dynamic> body) {
  final listRaw = body['list'];
  if (listRaw is! List) {
    return const RemoteHomeCardCatalog(items: []);
  }
  final items = <RemoteHomeCardCatalogItem>[];
  for (final raw in listRaw) {
    if (raw is! Map) continue;
    final item = RemoteHomeCardCatalogItem.fromJson(
      Map<String, dynamic>.from(raw),
    );
    if (item.cardId.isEmpty) continue;
    items.add(item);
  }
  items.sort((a, b) {
    final bySort = a.sortOrder.compareTo(b.sortOrder);
    if (bySort != 0) return bySort;
    return a.cardId.compareTo(b.cardId);
  });
  return RemoteHomeCardCatalog(items: items);
}

String resolveHomeCardOwner({
  required String cardId,
  RemoteHomeCardCatalog? catalog,
}) {
  final cid = cardId.trim().toLowerCase();
  final fromCatalog = catalog?.ownerFor(cid);
  if (fromCatalog != null && fromCatalog.isNotEmpty) {
    return fromCatalog;
  }
  return kLegacyExternalHomeCardOwners[cid] ?? 'datacenter';
}

HomeCardCatalogEntry? mergeHomeCardCatalogEntry({
  required String cardId,
  RemoteHomeCardCatalogItem? remote,
}) {
  final local = homeCardCatalogEntry(cardId);
  if (local == null) {
    if (remote == null || remote.title.isEmpty) return null;
    return HomeCardCatalogEntry(
      cardId: remote.cardId,
      title: remote.title,
      subtitle: remote.subtitle.isNotEmpty ? remote.subtitle : remote.title,
      icon: Icons.menu_book_rounded,
      iconBackground: const Color(0xFF546E7A),
      route: remote.detailRoute?.isNotEmpty == true
          ? remote.detailRoute!
          : '/${remote.cardId}',
    );
  }
  final remoteTitle = remote?.title.trim();
  final remoteSubtitle = remote?.subtitle.trim();
  final remoteRoute = remote?.detailRoute?.trim();
  return HomeCardCatalogEntry(
    cardId: local.cardId,
    title: remoteTitle != null && remoteTitle.isNotEmpty
        ? remoteTitle
        : local.title,
    subtitle: remoteSubtitle != null && remoteSubtitle.isNotEmpty
        ? remoteSubtitle
        : local.subtitle,
    icon: local.icon,
    iconBackground: local.iconBackground,
    route: remoteRoute != null && remoteRoute.isNotEmpty
        ? remoteRoute
        : local.route,
    supportsFatSummary: local.supportsFatSummary,
  );
}

List<HomeLayoutItem> filterLayoutByEnabledCatalog(
  List<HomeLayoutItem> items,
  Set<String>? enabledCardIds,
) {
  if (enabledCardIds == null) return items;
  return items.where((item) {
    if (item is HomeSeparatorLayoutItem) return true;
    if (item is HomeFeatureLayoutItem) {
      return enabledCardIds.contains(item.cardId);
    }
    return true;
  }).toList(growable: false);
}

int _parseInt(Object? raw) {
  if (raw is int) return raw;
  if (raw is num) return raw.toInt();
  return int.tryParse(raw?.toString() ?? '') ?? 0;
}

String? _optionalString(Object? raw) {
  final v = raw?.toString().trim();
  if (v == null || v.isEmpty) return null;
  return v;
}
