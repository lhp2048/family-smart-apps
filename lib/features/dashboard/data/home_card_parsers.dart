import 'package:flutter/material.dart';

import '../../tasks/data/task_api_mappers.dart';
import '../../../shared/models/member_entity.dart';
import 'dashboard_prototype_models.dart';

int _dashboardCardParticipantRoleRank(String role) {
  return role == 'child' ? 0 : 1;
}

void _sortDashboardCardParticipants(List<MemberEntity> members) {
  members.sort((a, b) {
    final byRole = _dashboardCardParticipantRoleRank(a.role)
        .compareTo(_dashboardCardParticipantRoleRank(b.role));
    if (byRole != 0) return byRole;
    return a.memberCode.compareTo(b.memberCode);
  });
}

/// 首页作业/积分卡参与人：全部 active 成员；先 child，再其他角色。
List<MemberEntity> activeDashboardCardParticipants(
  List<Map<String, dynamic>> members,
) {
  final out = members
      .map(memberFromApiMap)
      .where((m) => m.status == 'active')
      .toList();
  _sortDashboardCardParticipants(out);
  return out;
}

/// 从作业卡 API `rows` 解析各成员进度（key 为 memberCode）。
Map<String, String> homeworkProgressByMemberCode(Map<String, dynamic> data) {
  final raw = data['rows'];
  if (raw is! List) return {};
  final out = <String, String>{};
  for (final e in raw) {
    if (e is! Map) continue;
    final m = Map<String, dynamic>.from(e);
    final code = m['memberCode']?.toString() ?? '';
    if (code.isEmpty) continue;
    final done = (m['doneCount'] as num?)?.toInt() ?? 0;
    final total = (m['totalCount'] as num?)?.toInt() ?? 0;
    out[code] = total <= 0 ? '-/-' : '$done/$total';
  }
  return out;
}

/// 按全部 active 成员列举作业进度；排序：先 child，再其他角色，同组按 memberCode。
List<DashboardHomeworkRow> homeworkRowsForParticipants(
  List<Map<String, dynamic>> members,
  Map<String, String> progressByCode,
) {
  final participants = activeDashboardCardParticipants(members);
  if (participants.isEmpty) {
    return const [];
  }

  return participants
      .map((m) {
        final name = m.name.isNotEmpty ? m.name : m.memberCode;
        final progress = progressByCode[m.memberCode] ?? '-/-';
        return DashboardHomeworkRow(name, progress);
      })
      .toList(growable: false);
}

/// 当作业摘要接口无 `rows` 时，用成员列表生成行（进度为 `-/-`）。
List<DashboardHomeworkRow> homeworkRowsFromMembers(
  List<Map<String, dynamic>> members,
) {
  return homeworkRowsForParticipants(members, const {});
}

/// 从积分卡 API `rows` 解析各成员总分（key 为 memberCode）。
Map<String, int> pointsScoreByMemberCode(Map<String, dynamic> data) {
  final raw = data['rows'];
  if (raw is! List) return {};
  final out = <String, int>{};
  for (final e in raw) {
    if (e is! Map) continue;
    final m = Map<String, dynamic>.from(e);
    final code = m['memberCode']?.toString() ?? '';
    if (code.isEmpty) continue;
    out[code] = (m['score'] as num?)?.toInt() ?? 0;
  }
  return out;
}

/// 按全部 active 成员列举积分榜；排序与作业卡一致。
List<DashboardPointsRow> pointsRowsForParticipants(
  List<Map<String, dynamic>> members,
  Map<String, int> scoreByCode,
) {
  final participants = activeDashboardCardParticipants(members);
  if (participants.isEmpty) {
    return const [];
  }

  return participants
      .map((m) {
        final name = m.name.isNotEmpty ? m.name : m.memberCode;
        final score = scoreByCode[m.memberCode] ?? 0;
        return DashboardPointsRow(name, score);
      })
      .toList(growable: false);
}

/// 积分卡无 `rows` 时的兜底：全部 active 成员，0 分；排序与作业卡一致。
List<DashboardPointsRow> pointsRowsFromMembers(
  List<Map<String, dynamic>> members,
) {
  return pointsRowsForParticipants(members, const {});
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
