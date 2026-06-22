class CalendarDayIndicators {
  const CalendarDayIndicators({
    this.homeworkHasData = false,
    this.homeworkProgress = 0,
    this.pointsHasData = false,
    this.pointsTotalDelta = 0,
    this.timemachineCount = 0,
    this.debateHasData = false,
    this.debateTopicCount = 0,
    this.wishesCount = 0,
    this.itineraryCount = 0,
    this.planCount = 0,
    this.reminderCount = 0,
  });

  final bool homeworkHasData;
  final double homeworkProgress;
  final bool pointsHasData;
  final int pointsTotalDelta;
  final int timemachineCount;
  final bool debateHasData;
  final int debateTopicCount;
  final int wishesCount;
  final int itineraryCount;
  final int planCount;
  final int reminderCount;

  bool get hasAnyData =>
      homeworkHasData ||
      pointsHasData ||
      timemachineCount > 0 ||
      debateHasData ||
      wishesCount > 0 ||
      itineraryCount > 0 ||
      planCount > 0 ||
      reminderCount > 0;

  List<String> get activeTypes {
    final out = <String>[];
    if (homeworkHasData) out.add('homework');
    if (pointsHasData) out.add('points');
    if (timemachineCount > 0) out.add('timemachine');
    if (debateHasData) out.add('debate');
    if (wishesCount > 0) out.add('wishes');
    if (itineraryCount > 0) out.add('itinerary');
    if (planCount > 0) out.add('plan');
    if (reminderCount > 0) out.add('reminder');
    return out;
  }
}

class CalendarMonthDay {
  const CalendarMonthDay({
    required this.bizDate,
    required this.indicators,
  });

  final String bizDate;
  final CalendarDayIndicators indicators;
}

class CalendarMonthBundle {
  const CalendarMonthBundle({
    required this.monthKey,
    required this.days,
  });

  final String monthKey;
  final List<CalendarMonthDay> days;

  CalendarDayIndicators? indicatorsFor(String bizDate) {
    for (final d in days) {
      if (d.bizDate == bizDate) return d.indicators;
    }
    return null;
  }
}

class CalendarDaySection {
  const CalendarDaySection({
    required this.type,
    this.summary,
    this.items,
    this.bundle,
  });

  final String type;
  final Map<String, dynamic>? summary;
  final List<Map<String, dynamic>>? items;
  final Map<String, dynamic>? bundle;
}

class CalendarDayBundle {
  const CalendarDayBundle({
    required this.bizDate,
    required this.sections,
  });

  final String bizDate;
  final List<CalendarDaySection> sections;
}

class CalendarHighlight {
  const CalendarHighlight({
    required this.type,
    required this.label,
    this.detail = '',
  });

  final String type;
  final String label;
  final String detail;
}

class HomeCalendarCardData {
  const HomeCalendarCardData({
    required this.bizDate,
    required this.highlights,
    required this.indicators,
    this.sectionCount = 0,
  });

  final String bizDate;
  final List<CalendarHighlight> highlights;
  final CalendarDayIndicators indicators;
  final int sectionCount;
}

class FamilyEventItem {
  const FamilyEventItem({
    required this.eventId,
    required this.eventType,
    required this.bizDate,
    required this.title,
    this.content = '',
    this.memberCode,
    this.status = 'pending',
    this.startAt,
    this.endAt,
    this.remindAt,
  });

  final String eventId;
  final String eventType;
  final String bizDate;
  final String title;
  final String content;
  final String? memberCode;
  final String status;
  final String? startAt;
  final String? endAt;
  final String? remindAt;

  bool get isDone => status == 'done';

  Map<String, dynamic> toSyncPayload() => {
        'eventId': eventId,
        'eventType': eventType,
        'bizDate': bizDate,
        'title': title,
        'content': content,
        if (memberCode != null && memberCode!.isNotEmpty)
          'memberCode': memberCode,
        'status': status,
        if (startAt != null) 'startAt': startAt,
        if (endAt != null) 'endAt': endAt,
        if (remindAt != null) 'remindAt': remindAt,
      };
}
