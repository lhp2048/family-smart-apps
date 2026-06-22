import 'package:flutter/material.dart';

import '../../points/data/points_api_mappers.dart';
import '../data/calendar_api_mappers.dart';
import '../models/calendar_models.dart';
class CalendarDayDetail extends StatelessWidget {
  const CalendarDayDetail({
    super.key,
    required this.bundle,
    this.onSectionTap,
    this.onEventTap,
    this.onEventToggle,
    this.onEventDelete,
    this.readOnly = false,
  });

  final CalendarDayBundle bundle;
  final void Function(String sectionType)? onSectionTap;
  final void Function(FamilyEventItem event)? onEventTap;
  final void Function(FamilyEventItem event)? onEventToggle;
  final void Function(FamilyEventItem event)? onEventDelete;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    if (bundle.sections.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            '这一天暂无记录',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.45),
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: bundle.sections.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final section = bundle.sections[index];
        return _CalendarSectionCard(
          section: section,
          readOnly: readOnly,
          onHeaderTap: onSectionTap == null
              ? null
              : () => onSectionTap!(section.type),
          onEventTap: onEventTap,
          onEventToggle: onEventToggle,
          onEventDelete: onEventDelete,
        );
      },
    );
  }
}

class _CalendarSectionCard extends StatelessWidget {
  const _CalendarSectionCard({
    required this.section,
    required this.readOnly,
    this.onHeaderTap,
    this.onEventTap,
    this.onEventToggle,
    this.onEventDelete,
  });

  final CalendarDaySection section;
  final bool readOnly;
  final VoidCallback? onHeaderTap;
  final void Function(FamilyEventItem event)? onEventTap;
  final void Function(FamilyEventItem event)? onEventToggle;
  final void Function(FamilyEventItem event)? onEventDelete;

  @override
  Widget build(BuildContext context) {
    final color = calendarIndicatorColor(section.type);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: onHeaderTap,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      calendarSectionTitle(section.type),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (onHeaderTap != null)
                    Icon(
                      Icons.chevron_right,
                      color: Colors.white.withValues(alpha: 0.28),
                      size: 20,
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
            child: _SectionBody(
              section: section,
              readOnly: readOnly,
              onEventTap: onEventTap,
              onEventToggle: onEventToggle,
              onEventDelete: onEventDelete,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionBody extends StatelessWidget {
  const _SectionBody({
    required this.section,
    required this.readOnly,
    this.onEventTap,
    this.onEventToggle,
    this.onEventDelete,
  });

  final CalendarDaySection section;
  final bool readOnly;
  final void Function(FamilyEventItem event)? onEventTap;
  final void Function(FamilyEventItem event)? onEventToggle;
  final void Function(FamilyEventItem event)? onEventDelete;

  @override
  Widget build(BuildContext context) {
    switch (section.type) {
      case 'homework':
        return _HomeworkBody(summary: section.summary);
      case 'points':
        return _PointsBody(summary: section.summary);
      case 'debate':
        return _DebateBody(bundle: section.bundle);
      case 'timemachine':
      case 'wishes':
      case 'itinerary':
      case 'plan':
      case 'reminder':
        return _ItemsBody(
          items: section.items ?? const [],
          eventTypes: section.type,
          readOnly: readOnly,
          onEventTap: onEventTap,
          onEventToggle: onEventToggle,
          onEventDelete: onEventDelete,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

class _HomeworkBody extends StatelessWidget {
  const _HomeworkBody({this.summary});

  final Map<String, dynamic>? summary;

  @override
  Widget build(BuildContext context) {
    final rows = summary?['rows'];
    if (rows is! List || rows.isEmpty) {
      return _muted('暂无作业数据');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final r in rows)
          if (r is Map)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '${r['displayName'] ?? ''}：${r['doneCount'] ?? 0}/${r['totalCount'] ?? 0}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.78),
                  fontSize: 13,
                ),
              ),
            ),
      ],
    );
  }
}

class _PointsBody extends StatelessWidget {
  const _PointsBody({this.summary});

  final Map<String, dynamic>? summary;

  @override
  Widget build(BuildContext context) {
    if (summary == null) return _muted('暂无积分流水');
    final delta = summary!['totalDelta'] ?? 0;
    final records = summary!['records'];
    final lines = <Widget>[
      Text(
        '当日净变化：$delta 分',
        style: TextStyle(
          color: Colors.greenAccent.withValues(alpha: 0.9),
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    ];
    if (records is List) {
      for (final r in records.take(8)) {
        if (r is! Map) continue;
        final map = Map<String, dynamic>.from(r);
        final person = resolvePointsRecordPerson(map, const {});
        final item = map['item']?.toString() ??
            map['description']?.toString() ??
            '积分变动';
        final delta = (map['delta'] as num?)?.toInt() ?? 0;
        final deltaStr = delta >= 0 ? '+$delta' : '$delta';
        lines.add(
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '$person：$item $deltaStr',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.72),
                fontSize: 12,
              ),
            ),
          ),
        );
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines,
    );
  }
}

class _DebateBody extends StatelessWidget {
  const _DebateBody({this.bundle});

  final Map<String, dynamic>? bundle;

  @override
  Widget build(BuildContext context) {
    if (bundle == null) return _muted('暂无辩题');
    final count = bundle!['topicCount'] ?? (bundle!['topics'] as List?)?.length ?? 0;
    return Text(
      '共 $count 个话题',
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.78),
        fontSize: 13,
      ),
    );
  }
}

class _ItemsBody extends StatelessWidget {
  const _ItemsBody({
    required this.items,
    required this.eventTypes,
    required this.readOnly,
    this.onEventTap,
    this.onEventToggle,
    this.onEventDelete,
  });

  final List<Map<String, dynamic>> items;
  final String eventTypes;
  final bool readOnly;
  final void Function(FamilyEventItem event)? onEventTap;
  final void Function(FamilyEventItem event)? onEventToggle;
  final void Function(FamilyEventItem event)? onEventDelete;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return _muted('暂无条目');
    final isEvent = eventTypes == 'itinerary' ||
        eventTypes == 'plan' ||
        eventTypes == 'reminder';
    return Column(
      children: [
        for (final raw in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: isEvent
                ? _EventRow(
                    event: parseFamilyEventItem(raw),
                    readOnly: readOnly,
                    onTap: onEventTap,
                    onToggle: onEventToggle,
                    onDelete: onEventDelete,
                  )
                : _SimpleRow(item: raw),
          ),
      ],
    );
  }
}

class _SimpleRow extends StatelessWidget {
  const _SimpleRow({required this.item});

  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) {
    final title = item['title'] ?? item['content'] ?? item['entryId'] ?? '';
    return Text(
      title.toString(),
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.78),
        fontSize: 13,
      ),
    );
  }
}

class _EventRow extends StatelessWidget {
  const _EventRow({
    required this.event,
    required this.readOnly,
    this.onTap,
    this.onToggle,
    this.onDelete,
  });

  final FamilyEventItem event;
  final bool readOnly;
  final void Function(FamilyEventItem event)? onTap;
  final void Function(FamilyEventItem event)? onToggle;
  final void Function(FamilyEventItem event)? onDelete;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap == null ? null : () => onTap!(event),
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            if (!readOnly && onToggle != null)
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                onPressed: () => onToggle!(event),
                icon: Icon(
                  event.isDone
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked,
                  color: event.isDone
                      ? Colors.greenAccent
                      : Colors.white.withValues(alpha: 0.35),
                  size: 20,
                ),
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: TextStyle(
                      color: Colors.white.withValues(
                        alpha: event.isDone ? 0.45 : 0.88,
                      ),
                      fontSize: 13,
                      decoration:
                          event.isDone ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  if ((event.remindAt ?? event.startAt ?? '').isNotEmpty)
                    Text(
                      event.remindAt ?? event.startAt ?? '',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 11,
                      ),
                    ),
                ],
              ),
            ),
            if (!readOnly && onDelete != null)
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                onPressed: () => onDelete!(event),
                icon: Icon(
                  Icons.close_rounded,
                  color: Colors.white.withValues(alpha: 0.28),
                  size: 18,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

Widget _muted(String text) {
  return Text(
    text,
    style: TextStyle(
      color: Colors.white.withValues(alpha: 0.45),
      fontSize: 13,
    ),
  );
}
