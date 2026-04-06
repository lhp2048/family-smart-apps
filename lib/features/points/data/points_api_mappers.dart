import '../../../core/utils/biz_date.dart';
import '../../../core/utils/week_range.dart';
import '../../dashboard/data/family_api_client.dart';
import 'points_prototype_models.dart';

/// 单条积分规则 API → UI 行
PointsRuleLine pointsRuleLineFromApiMap(Map<String, dynamic> m) {
  final delta = (m['delta'] as num?)?.toInt() ?? 0;
  final category = m['category']?.toString().trim() ?? '';
  final desc = m['description']?.toString().trim() ?? '';
  final unit = m['unit']?.toString().trim() ?? '';
  final text = [
    if (category.isNotEmpty) '【$category】',
    desc,
    if (unit.isNotEmpty) '（$unit）',
  ].join();
  return PointsRuleLine(
    isPositive: delta >= 0,
    description: text.isNotEmpty ? text : (m['ruleCode']?.toString() ?? '规则'),
    value: delta.abs(),
  );
}

String pointsWeekCycleId(String periodStart, String periodEnd) {
  final a = periodStart.replaceAll('-', '');
  final b = periodEnd.replaceAll('-', '');
  return 'w${a}_$b';
}

/// `YYYY-MM-DD` → 侧栏短标签用 `MM-dd`
String pointsDayKeyShort(String bizDateYmd) {
  try {
    final d = DateTime.parse(bizDateYmd);
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$m-$day';
  } catch (_) {
    return bizDateYmd;
  }
}

/// 自然周展示：短标题（如 `03.30—04.05`）
String pointsRangeShortFromPeriod(String periodStart, String periodEnd) {
  try {
    final s = DateTime.parse(periodStart);
    final e = DateTime.parse(periodEnd);
    String p(DateTime d) =>
        '${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}';
    return '${p(s)}—${p(e)}';
  } catch (_) {
    return '$periodStart ~ $periodEnd';
  }
}

/// 主区长标题
String pointsRangeTitleLongFromPeriod(String periodStart, String periodEnd) {
  try {
    final s = DateTime.parse(periodStart);
    final e = DateTime.parse(periodEnd);
    String ymd(DateTime d) =>
        '${d.year}年${d.month}月${d.day}日';
    return '${ymd(s)} — ${ymd(e)}';
  } catch (_) {
    return '$periodStart — $periodEnd';
  }
}

/// API `label` 可优先使用（如 `03/30~04/05`）
String pointsRangeShortPreferLabel(
  String? label,
  String periodStart,
  String periodEnd,
) {
  if (label != null && label.trim().isNotEmpty) {
    return label.trim().replaceAll('/', '.').replaceAll('~', '—');
  }
  return pointsRangeShortFromPeriod(periodStart, periodEnd);
}

class PointsWeekPeriodMeta {
  const PointsWeekPeriodMeta({
    required this.periodStart,
    required this.periodEnd,
    this.label,
  });

  final String periodStart;
  final String periodEnd;
  final String? label;
}

/// 合并接口返回的周与「当前自然周」，按 periodStart 降序（新周在前）
List<PointsWeekPeriodMeta> mergePointsWeeksFromApi(
  List<Map<String, dynamic>> apiWeeks,
  ({String periodStart, String periodEnd}) current,
) {
  final byKey = <String, PointsWeekPeriodMeta>{};
  void put(String ps, String pe, String? label) {
    if (ps.isEmpty || pe.isEmpty) return;
    final key = '$ps|$pe';
    byKey[key] = PointsWeekPeriodMeta(
      periodStart: ps,
      periodEnd: pe,
      label: label,
    );
  }

  for (final m in apiWeeks) {
    if (m['periodStart'] == null || m['periodEnd'] == null) continue;
    put(
      m['periodStart'].toString(),
      m['periodEnd'].toString(),
      m['label']?.toString(),
    );
  }
  put(current.periodStart, current.periodEnd, null);

  final list = byKey.values.toList()
    ..sort((a, b) => b.periodStart.compareTo(a.periodStart));
  return list;
}

/// 流水业务日：文档为 `bizDate`，部分后台实现为 `date`
String pointsRecordBizDate(Map<String, dynamic> m) {
  final b = m['bizDate']?.toString().trim();
  if (b != null && b.isNotEmpty) return b;
  final d = m['date']?.toString().trim();
  if (d != null && d.isNotEmpty) return d;
  return '';
}

PointsLogRow pointsLogRowFromApi(
  Map<String, dynamic> m,
  Map<String, String> displayNameByMemberCode,
) {
  final delta = (m['delta'] as num?)?.toInt() ?? 0;
  final mc = m['memberCode']?.toString() ?? '';

  final apiPerson = m['person']?.toString().trim();
  final apiDisplay = m['displayName']?.toString().trim();
  String person;
  if (apiPerson != null && apiPerson.isNotEmpty) {
    person = apiPerson;
  } else if (apiDisplay != null && apiDisplay.isNotEmpty) {
    person = apiDisplay;
  } else if (displayNameByMemberCode[mc]?.trim().isNotEmpty == true) {
    person = displayNameByMemberCode[mc]!.trim();
  } else {
    person = mc.isNotEmpty ? mc : '—';
  }

  final note = m['note']?.toString() ?? '';
  final remark = m['remark']?.toString() ?? '';
  final extra = note.isNotEmpty ? note : remark;

  final apiItem = m['item']?.toString().trim();
  final ruleCode = m['ruleCode']?.toString() ?? '';
  final item = (apiItem != null && apiItem.isNotEmpty)
      ? apiItem
      : (extra.isNotEmpty
          ? extra
          : (ruleCode.isNotEmpty ? ruleCode : '积分变动'));

  var time = m['time']?.toString().trim() ?? '';
  if (time.isEmpty) {
    final created = m['createdAt']?.toString();
    if (created != null && created.isNotEmpty) {
      try {
        final dt = DateTime.tryParse(created);
        if (dt != null) {
          final l = dt.toLocal();
          time =
              '${l.hour.toString().padLeft(2, '0')}:${l.minute.toString().padLeft(2, '0')}';
        }
      } catch (_) {}
    }
  }
  if (time.isEmpty) time = '—';

  final remarkCol =
      extra.isNotEmpty && extra != item ? extra : '';

  return PointsLogRow(
    time: time,
    person: person,
    item: item,
    pointsDelta: delta,
    remark: remarkCol,
  );
}

int _comparePointsRecordsSameDay(Map<String, dynamic> a, Map<String, dynamic> b) {
  final ca = a['createdAt']?.toString() ?? '';
  final cb = b['createdAt']?.toString() ?? '';
  if (ca.isNotEmpty || cb.isNotEmpty) {
    return ca.compareTo(cb);
  }
  final ta = a['time']?.toString() ?? '';
  final tb = b['time']?.toString() ?? '';
  final t = ta.compareTo(tb);
  if (t != 0) return t;
  return (a['memberCode']?.toString() ?? '')
      .compareTo(b['memberCode']?.toString() ?? '');
}

/// 将周期内流水按业务日分组（日内排序：优先 `createdAt`，否则 `time`）
List<PointsDayLogGroup> groupPointsRecordsByBizDate(
  List<Map<String, dynamic>> records,
  Set<String> childMemberCodes,
  Map<String, String> displayNameByMemberCode,
) {
  final byDate = <String, List<Map<String, dynamic>>>{};
  for (final r in records) {
    final bd = pointsRecordBizDate(r);
    if (bd.isEmpty) continue;
    byDate.putIfAbsent(bd, () => []).add(r);
  }
  final dates = byDate.keys.toList()..sort();
  final out = <PointsDayLogGroup>[];
  for (final bd in dates) {
    final dayRows = byDate[bd]!;
    dayRows.sort(_comparePointsRecordsSameDay);
    final dayDelta = <String, int>{
      for (final c in childMemberCodes) c: 0,
    };
    for (final r in dayRows) {
      final mc = r['memberCode']?.toString() ?? '';
      if (!childMemberCodes.contains(mc)) continue;
      final d = (r['delta'] as num?)?.toInt() ?? 0;
      dayDelta[mc] = (dayDelta[mc] ?? 0) + d;
    }
    final logRows = dayRows
        .map((m) => pointsLogRowFromApi(m, displayNameByMemberCode))
        .toList();
    DateTime? parsed;
    try {
      parsed = DateTime.parse(bd);
    } catch (_) {}
    out.add(
      PointsDayLogGroup(
        dayKey: pointsDayKeyShort(bd),
        weekdayLabel: parsed != null ? weekdayCn(parsed) : '',
        dayDeltaByMemberCode: dayDelta,
        rows: logRows,
      ),
    );
  }
  return out;
}

/// 由 summary.list 构建总分、净增（相对 baseScore）
({
  Map<String, int> totalsByMemberCode,
  Map<String, int> netGainByMemberCode,
  Map<String, String> displayNameByMemberCode,
  int? commonBaseScore,
}) parsePointsSummaryMembers(List<Map<String, dynamic>> list) {
  final totals = <String, int>{};
  final nets = <String, int>{};
  final names = <String, String>{};
  int? baseHint;
  for (final m in list) {
    final code = m['memberCode']?.toString() ?? '';
    if (code.isEmpty) continue;
    final total = (m['totalScore'] as num?)?.toInt() ?? 0;
    final delta = (m['deltaScore'] as num?)?.toInt() ?? 0;
    final base = (m['baseScore'] as num?)?.toInt();
    totals[code] = total;
    nets[code] = delta;
    final dn = m['displayName']?.toString();
    if (dn != null && dn.isNotEmpty) names[code] = dn;
    baseHint ??= base;
  }
  return (
    totalsByMemberCode: totals,
    netGainByMemberCode: nets,
    displayNameByMemberCode: names,
    commonBaseScore: baseHint,
  );
}

List<Map<String, dynamic>> pointsSummaryListFromData(Map<String, dynamic> data) {
  final raw = data['list'];
  if (raw is! List) return const [];
  return raw
      .whereType<Map>()
      .map((e) => Map<String, dynamic>.from(e))
      .toList();
}

List<Map<String, dynamic>> pointsRulesListFromData(Map<String, dynamic> data) {
  final raw = data['list'];
  if (raw is! List) return const [];
  return raw
      .whereType<Map>()
      .map((e) => Map<String, dynamic>.from(e))
      .toList();
}

List<Map<String, dynamic>> pointsWeeksListFromData(Map<String, dynamic> data) {
  final raw = data['list'];
  if (raw is! List) return const [];
  return raw
      .whereType<Map>()
      .map((e) => Map<String, dynamic>.from(e))
      .toList();
}

Future<List<Map<String, dynamic>>> fetchPointsRecordsForPeriod(
  FamilyApiClient client,
  String periodStart,
  String periodEnd,
  Set<String> memberCodes,
) async {
  Future<List<Map<String, dynamic>>> pull({String? memberCode}) async {
    final all = <Map<String, dynamic>>[];
    var page = 1;
    const pageSize = 200;
    while (true) {
      final data = await client.fetchPointsRecords(
        periodStart: periodStart,
        periodEnd: periodEnd,
        memberCode: memberCode,
        page: page,
        pageSize: pageSize,
      );
      final list = (data['list'] as List?)
              ?.whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e)) ??
          <Map<String, dynamic>>[];
      all.addAll(list);
      final total = (data['total'] as num?)?.toInt() ?? 0;
      if (all.length >= total || list.isEmpty) break;
      page++;
      if (page > 50) break;
    }
    return all;
  }

  try {
    final broad = await pull();
    if (broad.isNotEmpty || memberCodes.isEmpty) {
      return broad;
    }
  } catch (_) {}

  final merged = <Map<String, dynamic>>[];
  final seen = <String>{};
  for (final mc in memberCodes) {
    try {
      final part = await pull(memberCode: mc);
      for (final r in part) {
        final k = '${pointsRecordBizDate(r)}|${r['memberCode']}|'
            '${r['createdAt']}|${r['time']}|${r['item']}|${r['delta']}|'
            '${r['ruleCode']}|${r['note']}';
        if (seen.add(k)) merged.add(r);
      }
    } catch (_) {}
  }
  merged.sort((a, b) {
    final da =
        '${pointsRecordBizDate(a)}|${a['createdAt']}|${a['time']}|${a['memberCode']}';
    final db =
        '${pointsRecordBizDate(b)}|${b['createdAt']}|${b['time']}|${b['memberCode']}';
    return da.compareTo(db);
  });
  return merged;
}

/// 远程积分榜：周列表 + 每周汇总与流水（与 `后台API需求说明.md` §3.4 一致）
Future<List<PointsWeekCycle>> fetchPointsWeekCyclesRemote(
  FamilyApiClient client, {
  DateTime? now,
}) async {
  final anchor = now ?? DateTime.now();
  final current = currentWeekPeriodStrings(anchor);
  final weeksData = await client.fetchPointsWeeks();
  final rawWeeks = pointsWeeksListFromData(weeksData);
  final merged = mergePointsWeeksFromApi(rawWeeks, current);
  final cycles = <PointsWeekCycle>[];
  for (final meta in merged) {
    final summaryData = await client.fetchPointsSummary(
      periodStart: meta.periodStart,
      periodEnd: meta.periodEnd,
    );
    final summaryList = pointsSummaryListFromData(summaryData);
    final parsed = parsePointsSummaryMembers(summaryList);
    var childCodes = parsed.totalsByMemberCode.keys.toSet();
    if (childCodes.isEmpty) {
      childCodes = parsed.displayNameByMemberCode.keys.toSet();
    }
    var allRecords = await fetchPointsRecordsForPeriod(
      client,
      meta.periodStart,
      meta.periodEnd,
      childCodes,
    );
    if (childCodes.isEmpty && allRecords.isNotEmpty) {
      childCodes = allRecords
          .map((r) => r['memberCode']?.toString() ?? '')
          .where((s) => s.isNotEmpty)
          .toSet();
    }
    final displayNames = Map<String, String>.from(parsed.displayNameByMemberCode);
    final daily = groupPointsRecordsByBizDate(
      allRecords,
      childCodes,
      displayNames,
    );
    final isCur = meta.periodStart == current.periodStart &&
        meta.periodEnd == current.periodEnd;
    cycles.add(
      PointsWeekCycle(
        id: pointsWeekCycleId(meta.periodStart, meta.periodEnd),
        rangeShort: pointsRangeShortPreferLabel(
          meta.label,
          meta.periodStart,
          meta.periodEnd,
        ),
        rangeTitleLong: pointsRangeTitleLongFromPeriod(
          meta.periodStart,
          meta.periodEnd,
        ),
        isCurrentWeek: isCur,
        totalsByMemberCode: parsed.totalsByMemberCode,
        netGainByMemberCode: parsed.netGainByMemberCode,
        dailyLogs: daily,
        displayNameByMemberCode: displayNames,
      ),
    );
  }
  return cycles;
}

Future<List<PointsRuleLine>> fetchPointsRulesRemote(FamilyApiClient client) async {
  final data = await client.fetchPointsRules();
  final raw = pointsRulesListFromData(data);
  return raw.map(pointsRuleLineFromApiMap).toList();
}
