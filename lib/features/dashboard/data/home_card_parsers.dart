import 'package:flutter/material.dart';

import 'dashboard_prototype_models.dart';

/// 当作业摘要接口无 `rows` 时，用成员列表生成行（进度暂为 `-/-`）。
/// 优先展示 `role == child` 的成员；若无孩子则展示全部活跃成员。
List<DashboardHomeworkRow> homeworkRowsFromMembers(
  List<Map<String, dynamic>> members,
) {
  final active = members
      .where((m) => (m['status']?.toString() ?? 'active') != 'inactive')
      .toList();
  final children =
      active.where((m) => m['role']?.toString() == 'child').toList();
  final source = children.isNotEmpty ? children : active;
  final out = <DashboardHomeworkRow>[];
  final seen = <String>{};
  for (final m in source) {
    final code = m['memberCode']?.toString() ?? '';
    if (code.isNotEmpty) {
      if (seen.contains(code)) continue;
      seen.add(code);
    }
    var name = m['name']?.toString() ?? m['displayName']?.toString() ?? '';
    if (name.isEmpty) {
      name = code.isNotEmpty ? code : '成员';
    }
    out.add(DashboardHomeworkRow(name, '-/-'));
  }
  return out;
}

/// 积分卡无 `rows` 时的兜底：成员名 + 0 分（与作业卡成员筛选规则一致）。
List<DashboardPointsRow> pointsRowsFromMembers(
  List<Map<String, dynamic>> members,
) {
  final active = members
      .where((m) => (m['status']?.toString() ?? 'active') != 'inactive')
      .toList();
  final children =
      active.where((m) => m['role']?.toString() == 'child').toList();
  final source = children.isNotEmpty ? children : active;
  final out = <DashboardPointsRow>[];
  final seen = <String>{};
  for (final m in source) {
    final code = m['memberCode']?.toString() ?? '';
    if (code.isNotEmpty) {
      if (seen.contains(code)) continue;
      seen.add(code);
    }
    var name = m['name']?.toString() ?? m['displayName']?.toString() ?? '';
    if (name.isEmpty) {
      name = code.isNotEmpty ? code : '成员';
    }
    out.add(DashboardPointsRow(name, 0));
  }
  return out;
}

Color? parseBadgeColorHex(String? s) {
  if (s == null || s.isEmpty) return null;
  var h = s.trim();
  if (h.startsWith('#')) {
    h = h.substring(1);
  }
  if (h.length == 6) {
    final v = int.tryParse(h, radix: 16);
    if (v != null) {
      return Color(0xFF000000 | v);
    }
  }
  if (h.length == 8) {
    final v = int.tryParse(h, radix: 16);
    if (v != null) {
      return Color(v);
    }
  }
  return null;
}

typedef LifeMenuBadgeSpec = ({String? label, Color? color});

Map<String, LifeMenuBadgeSpec> parseLifeMenuBadgesByRoute(
  Map<String, dynamic> data,
) {
  final raw = data['badges'];
  if (raw is! List) {
    return {};
  }
  final out = <String, LifeMenuBadgeSpec>{};
  for (final e in raw) {
    if (e is! Map) {
      continue;
    }
    final m = Map<String, dynamic>.from(e);
    final route = m['route']?.toString() ?? '';
    if (route.isEmpty) {
      continue;
    }
    final label = m['badgeLabel']?.toString().trim();
    final color = parseBadgeColorHex(m['badgeColor']?.toString());
    out[route] = (
      label: (label == null || label.isEmpty) ? null : label,
      color: color,
    );
  }
  return out;
}

List<DashboardLifeMenuItem> mergeLifeMenuTemplateWithBadges(
  List<DashboardLifeMenuItem> template,
  Map<String, LifeMenuBadgeSpec> byRoute,
) {
  return template
      .map((item) {
        final b = byRoute[item.route];
        final label = b?.label;
        final hasBadge = label != null && label.isNotEmpty;
        if (!hasBadge) {
          return DashboardLifeMenuItem(
            title: item.title,
            subtitle: item.subtitle,
            icon: item.icon,
            iconBackground: item.iconBackground,
            route: item.route,
          );
        }
        return DashboardLifeMenuItem(
          title: item.title,
          subtitle: item.subtitle,
          icon: item.icon,
          iconBackground: item.iconBackground,
          route: item.route,
          badgeLabel: label,
          badgeColor: b?.color ?? const Color(0xFF7C4DFF),
        );
      })
      .toList(growable: false);
}

List<DashboardHomeworkRow> parseHomeworkCardRows(Map<String, dynamic> data) {
  final raw = data['rows'];
  if (raw is! List) return const [];
  final out = <DashboardHomeworkRow>[];
  for (final e in raw) {
    if (e is! Map) continue;
    final m = Map<String, dynamic>.from(e);
    final name =
        m['displayName']?.toString() ?? m['memberCode']?.toString() ?? '?';
    final done = (m['doneCount'] as num?)?.toInt() ?? 0;
    final total = (m['totalCount'] as num?)?.toInt() ?? 0;
    final progressText = total <= 0 ? '-/-' : '$done/$total';
    out.add(DashboardHomeworkRow(name, progressText));
  }
  return out;
}

List<DashboardPointsRow> parsePointsCardRows(Map<String, dynamic> data) {
  final raw = data['rows'];
  if (raw is! List) return const [];
  final out = <DashboardPointsRow>[];
  for (final e in raw) {
    if (e is! Map) continue;
    final m = Map<String, dynamic>.from(e);
    final name =
        m['displayName']?.toString() ?? m['memberCode']?.toString() ?? '?';
    final score = (m['score'] as num?)?.toInt() ?? 0;
    out.add(DashboardPointsRow(name, score));
  }
  return out;
}
