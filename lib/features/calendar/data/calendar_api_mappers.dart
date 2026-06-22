import 'package:flutter/material.dart';

import '../models/calendar_models.dart';

CalendarDayIndicators parseCalendarIndicators(Map<String, dynamic>? raw) {
  if (raw == null || raw.isEmpty) {
    return const CalendarDayIndicators();
  }
  final hw = raw['homework'];
  final pt = raw['points'];
  final tm = raw['timemachine'];
  final db = raw['debate'];
  final ws = raw['wishes'];
  final it = raw['itinerary'];
  final pl = raw['plan'];
  final rm = raw['reminder'];
  return CalendarDayIndicators(
    homeworkHasData: hw is Map && (hw['hasData'] == true),
    homeworkProgress: hw is Map ? _toDouble(hw['progress']) : 0,
    pointsHasData: pt is Map && (pt['hasData'] == true),
    pointsTotalDelta: pt is Map ? _toInt(pt['totalDelta']) : 0,
    timemachineCount: tm is Map ? _toInt(tm['count']) : 0,
    debateHasData: db is Map && (db['hasData'] == true),
    debateTopicCount: db is Map ? _toInt(db['topicCount']) : 0,
    wishesCount: ws is Map ? _toInt(ws['count']) : 0,
    itineraryCount: it is Map ? _toInt(it['count']) : 0,
    planCount: pl is Map ? _toInt(pl['count']) : 0,
    reminderCount: rm is Map ? _toInt(rm['count']) : 0,
  );
}

CalendarMonthBundle parseCalendarMonth(Map<String, dynamic> data) {
  final monthKey = data['monthKey']?.toString() ?? '';
  final daysRaw = data['days'];
  final days = <CalendarMonthDay>[];
  if (daysRaw is List) {
    for (final e in daysRaw) {
      if (e is! Map) continue;
      final m = Map<String, dynamic>.from(e);
      days.add(
        CalendarMonthDay(
          bizDate: m['bizDate']?.toString() ?? '',
          indicators: parseCalendarIndicators(
            m['indicators'] is Map
                ? Map<String, dynamic>.from(m['indicators'] as Map)
                : null,
          ),
        ),
      );
    }
  }
  return CalendarMonthBundle(monthKey: monthKey, days: days);
}

CalendarDayBundle parseCalendarDay(Map<String, dynamic> data) {
  final bizDate = data['bizDate']?.toString() ?? '';
  final sectionsRaw = data['sections'];
  final sections = <CalendarDaySection>[];
  if (sectionsRaw is List) {
    for (final e in sectionsRaw) {
      if (e is! Map) continue;
      final m = Map<String, dynamic>.from(e);
      sections.add(
        CalendarDaySection(
          type: m['type']?.toString() ?? '',
          summary: m['summary'] is Map
              ? Map<String, dynamic>.from(m['summary'] as Map)
              : null,
          items: _mapList(m['items']),
          bundle: m['bundle'] is Map
              ? Map<String, dynamic>.from(m['bundle'] as Map)
              : null,
        ),
      );
    }
  }
  return CalendarDayBundle(bizDate: bizDate, sections: sections);
}

HomeCalendarCardData parseHomeCalendarCard(Map<String, dynamic> data) {
  final highlightsRaw = data['highlights'];
  final highlights = <CalendarHighlight>[];
  if (highlightsRaw is List) {
    for (final e in highlightsRaw) {
      if (e is! Map) continue;
      final m = Map<String, dynamic>.from(e);
      highlights.add(
        CalendarHighlight(
          type: m['type']?.toString() ?? '',
          label: m['label']?.toString() ?? '',
          detail: m['detail']?.toString() ?? '',
        ),
      );
    }
  }
  return HomeCalendarCardData(
    bizDate: data['bizDate']?.toString() ?? '',
    highlights: highlights,
    indicators: parseCalendarIndicators(
      data['indicators'] is Map
          ? Map<String, dynamic>.from(data['indicators'] as Map)
          : null,
    ),
    sectionCount: _toInt(data['sectionCount']),
  );
}

FamilyEventItem parseFamilyEventItem(Map<String, dynamic> m) {
  return FamilyEventItem(
    eventId: m['eventId']?.toString() ?? '',
    eventType: m['eventType']?.toString() ?? 'plan',
    bizDate: m['bizDate']?.toString() ?? '',
    title: m['title']?.toString() ?? '',
    content: m['content']?.toString() ?? '',
    memberCode: m['memberCode']?.toString(),
    status: m['status']?.toString() ?? 'pending',
    startAt: m['startAt']?.toString(),
    endAt: m['endAt']?.toString(),
    remindAt: m['remindAt']?.toString(),
  );
}

List<Map<String, dynamic>>? _mapList(dynamic raw) {
  if (raw is! List) return null;
  return raw
      .whereType<Map>()
      .map((e) => Map<String, dynamic>.from(e))
      .toList();
}

int _toInt(dynamic v) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v?.toString() ?? '') ?? 0;
}

double _toDouble(dynamic v) {
  if (v is double) return v;
  if (v is num) return v.toDouble();
  return double.tryParse(v?.toString() ?? '') ?? 0;
}

String calendarSectionTitle(String type) {
  switch (type) {
    case 'homework':
      return '作业';
    case 'points':
      return '积分';
    case 'timemachine':
      return '时光机';
    case 'debate':
      return '话题辩论';
    case 'wishes':
      return '心愿';
    case 'itinerary':
      return '行程';
    case 'plan':
      return '计划';
    case 'reminder':
      return '提醒';
    default:
      return type;
  }
}

String calendarSectionRoute(String type, String bizDate) {
  switch (type) {
    case 'homework':
      return '/tasks';
    case 'points':
      return '/points';
    case 'timemachine':
      return '/timemachine';
    case 'debate':
      return '/debate';
    case 'wishes':
      return '/wishwall';
    default:
      return '/calendar';
  }
}

Color calendarIndicatorColor(String type) {
  switch (type) {
    case 'homework':
      return const Color(0xFFC4A7FF);
    case 'points':
      return const Color(0xFF69F0AE);
    case 'timemachine':
      return const Color(0xFF90CAF9);
    case 'debate':
      return const Color(0xFFFFAB91);
    case 'wishes':
      return const Color(0xFFFFCA28);
    case 'itinerary':
      return const Color(0xFF80DEEA);
    case 'plan':
      return const Color(0xFFCE93D8);
    case 'reminder':
      return const Color(0xFFFF8A80);
    default:
      return const Color(0xFFB0BEC5);
  }
}
