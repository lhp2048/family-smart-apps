import '../../../core/utils/biz_date.dart';
import '../../../core/utils/week_range.dart';
import '../../../shared/models/member_entity.dart';
import '../../dashboard/data/family_api_client.dart';
import '../../tasks/data/task_api_mappers.dart';
import 'points_prototype_models.dart';

/// 积分榜参与人：active 的 child 与 parent。
bool isActivePointsParticipant(MemberEntity m) =>
    m.status == 'active' && (m.role == 'child' || m.role == 'parent');

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
    String ymd(DateTime d) => '${d.year}年${d.month}月${d.day}日';
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

/// 成员展示名：优先 API `displayName`，其次 `name`。
String memberDisplayNameFromApiMap(Map<String, dynamic> m) {
  final dn = m['displayName']?.toString().trim();
  if (dn != null && dn.isNotEmpty) return dn;
  final name = m['name']?.toString().trim();
  if (name != null && name.isNotEmpty) return name;
  return m['memberCode']?.toString().trim() ?? '';
}

/// 积分明细「人员」列：优先 displayName（流水 → 成员表），person 仅历史兜底。
String resolvePointsRecordPerson(
  Map<String, dynamic> m,
  Map<String, String> displayNameByMemberCode,
) {
  final mc = m['memberCode']?.toString() ?? '';

  final apiDisplay = m['displayName']?.toString().trim();
  if (apiDisplay != null && apiDisplay.isNotEmpty) return apiDisplay;

  final memberDisplay = displayNameByMemberCode[mc]?.trim();
  if (memberDisplay != null && memberDisplay.isNotEmpty) return memberDisplay;

  final apiPerson = m['person']?.toString().trim();
  if (apiPerson != null && apiPerson.isNotEmpty) return apiPerson;

  return mc.isNotEmpty ? mc : '—';
}

PointsLogRow pointsLogRowFromApi(
  Map<String, dynamic> m,
  Map<String, String> displayNameByMemberCode,
) {
  final delta = (m['delta'] as num?)?.toInt() ?? 0;
  final person = resolvePointsRecordPerson(m, displayNameByMemberCode);

  final note = m['note']?.toString() ?? '';
  final remark = m['remark']?.toString() ?? '';
  final extra = note.isNotEmpty ? note : remark;

  final apiItem = m['item']?.toString().trim();
  final ruleCode = m['ruleCode']?.toString() ?? '';
  final item = (apiItem != null && apiItem.isNotEmpty)
      ? apiItem
      : (extra.isNotEmpty ? extra : (ruleCode.isNotEmpty ? ruleCode : '积分变动'));

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

  final remarkCol = extra.isNotEmpty && extra != item ? extra : '';

  return PointsLogRow(
    time: time,
    person: person,
    item: item,
    pointsDelta: delta,
    remark: remarkCol,
  );
}

int _comparePointsRecordsSameDay(
  Map<String, dynamic> a,
  Map<String, dynamic> b,
) {
  final ca = a['createdAt']?.toString() ?? '';
  final cb = b['createdAt']?.toString() ?? '';
  if (ca.isNotEmpty || cb.isNotEmpty) {
    return ca.compareTo(cb);
  }
  final ta = a['time']?.toString() ?? '';
  final tb = b['time']?.toString() ?? '';
  final t = ta.compareTo(tb);
  if (t != 0) return t;
  return (a['memberCode']?.toString() ?? '').compareTo(
    b['memberCode']?.toString() ?? '',
  );
}

/// 将周期内流水按业务日分组（日内排序：优先 `createdAt`，否则 `time`）
List<PointsDayLogGroup> groupPointsRecordsByBizDate(
  List<Map<String, dynamic>> records,
  Set<String> participantMemberCodes,
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
      for (final c in participantMemberCodes) c: 0,
    };
    for (final r in dayRows) {
      final mc = r['memberCode']?.toString() ?? '';
      if (!participantMemberCodes.contains(mc)) continue;
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

/// 解析流水 item 的 (类别头, 备注尾)，兼容「早起」+note 与「早起 —— xxx」。
(String, String) _pointsRecordItemParts(Map<String, dynamic> r) {
  final item = r['item']?.toString().trim() ?? '';
  final note = r['note']?.toString().trim() ?? '';
  final desc = r['description']?.toString().trim() ?? '';
  for (final sep in ['——', '—', ' - ', '－']) {
    if (item.contains(sep)) {
      final parts = item.split(sep);
      return (parts.first.trim(), parts.sublist(1).join(sep).trim());
    }
  }
  if (note.isNotEmpty) return (item, note);
  if (desc.isNotEmpty) {
    for (final sep in ['——', '—', ' - ', '－']) {
      if (desc.contains(sep)) {
        final parts = desc.split(sep);
        return (parts.first.trim(), parts.sublist(1).join(sep).trim());
      }
    }
    return (item, desc);
  }
  return (item, '');
}

/// 合并重复流水（含同日同人重复的「初始积分」只保留一条）
List<Map<String, dynamic>> dedupePointsRecords(
  List<Map<String, dynamic>> records,
) {
  final seen = <String>{};
  final out = <Map<String, dynamic>>[];
  for (final r in records) {
    final bd = pointsRecordBizDate(r);
    final mc = r['memberCode']?.toString() ?? '';
    final ruleCode = r['ruleCode']?.toString() ?? '';
    final ruleType = r['ruleType']?.toString() ?? '';
    final item = r['item']?.toString().trim() ?? '';
    final isBase =
        ruleCode == 'base_weekly' || ruleType == 'base' || item == '初始积分';
    final String key;
    if (isBase) {
      key = '$bd|$mc|base';
    } else {
      final delta = (r['delta'] as num?)?.toInt() ?? 0;
      final parts = _pointsRecordItemParts(r);
      key = '$bd|$mc|$delta|${parts.$1}|${parts.$2}';
    }
    if (seen.add(key)) out.add(r);
  }
  return out;
}

/// 由周期内积分明细按 [memberCode] 汇总（与「积分明细」展示同源，保证汇总=明细聚合）。
({
  Map<String, int> totalsByMemberCode,
  Map<String, int> netGainByMemberCode,
  Map<String, String> displayNameByMemberCode,
})
computePointsSummaryFromRecords(
  List<Map<String, dynamic>> records,
  Set<String> memberCodes,
  Map<String, String> seedDisplayNames,
) {
  final totals = <String, int>{for (final code in memberCodes) code: 0};
  final nets = <String, int>{for (final code in memberCodes) code: 0};
  final names = Map<String, String>.from(seedDisplayNames);

  bool isBaseRecord(Map<String, dynamic> r) {
    final ruleCode = r['ruleCode']?.toString() ?? '';
    final ruleType = r['ruleType']?.toString() ?? '';
    final item = r['item']?.toString() ?? '';
    return ruleCode == 'base_weekly' || ruleType == 'base' || item == '初始积分';
  }

  for (final r in records) {
    final mc = r['memberCode']?.toString() ?? '';
    if (mc.isEmpty) continue;
    if (memberCodes.isNotEmpty && !memberCodes.contains(mc)) continue;

    totals.putIfAbsent(mc, () => 0);
    nets.putIfAbsent(mc, () => 0);

    final delta = (r['delta'] as num?)?.toInt() ?? 0;
    totals[mc] = (totals[mc] ?? 0) + delta;
    if (!isBaseRecord(r)) {
      nets[mc] = (nets[mc] ?? 0) + delta;
    }

    final dn = r['displayName']?.toString().trim();
    final person = r['person']?.toString().trim();
    if (dn != null && dn.isNotEmpty) {
      names.putIfAbsent(mc, () => dn);
    } else if (person != null && person.isNotEmpty) {
      names.putIfAbsent(mc, () => person);
    }
  }

  return (
    totalsByMemberCode: totals,
    netGainByMemberCode: nets,
    displayNameByMemberCode: names,
  );
}

/// 积分榜参与成员 code + 展示名（active 的 child / parent）
Future<({Set<String> codes, Map<String, String> displayNames})>
fetchPointsMemberCodes(FamilyApiClient client) async {
  final codes = <String>{};
  final names = <String, String>{};
  try {
    final rawMembers = await client.fetchMembers();
    for (final m in rawMembers) {
      final entity = memberFromApiMap(m);
      if (!isActivePointsParticipant(entity)) continue;
      final code = entity.memberCode;
      if (code.isEmpty) continue;
      codes.add(code);
      final label = memberDisplayNameFromApiMap(m);
      if (label.isNotEmpty) {
        names[code] = label;
      }
    }
  } catch (_) {}
  return (codes: codes, displayNames: names);
}

/// 由 summary.list 构建总分、净增（相对 baseScore）
({
  Map<String, int> totalsByMemberCode,
  Map<String, int> netGainByMemberCode,
  Map<String, String> displayNameByMemberCode,
  int? commonBaseScore,
})
parsePointsSummaryMembers(List<Map<String, dynamic>> list) {
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

List<Map<String, dynamic>> pointsSummaryListFromData(
  Map<String, dynamic> data,
) {
  final raw = data['list'];
  if (raw is! List) return const [];
  return raw.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
}

List<Map<String, dynamic>> pointsRulesListFromData(Map<String, dynamic> data) {
  final raw = data['list'];
  if (raw is! List) return const [];
  return raw.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
}

List<Map<String, dynamic>> pointsWeeksListFromData(Map<String, dynamic> data) {
  final raw = data['list'];
  if (raw is! List) return const [];
  return raw.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
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
      final list =
          (data['list'] as List?)?.whereType<Map>().map(
            (e) => Map<String, dynamic>.from(e),
          ) ??
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
        final k =
            '${pointsRecordBizDate(r)}|${r['memberCode']}|'
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

/// 远程积分榜：周列表 + 并行 summary（侧栏用，不拉 records）
Future<List<PointsWeekShell>> fetchPointsWeekShellsRemote(
  FamilyApiClient client, {
  DateTime? now,
}) async {
  final anchor = now ?? DateTime.now();
  final current = currentWeekPeriodStrings(anchor);
  final weeksData = await client.fetchPointsWeeks();
  final rawWeeks = pointsWeeksListFromData(weeksData);
  final merged = mergePointsWeeksFromApi(rawWeeks, current);

  final shells = await Future.wait(
    merged.map((meta) async {
      final summaryData = await client.fetchPointsSummary(
        periodStart: meta.periodStart,
        periodEnd: meta.periodEnd,
      );
      final parsed = parsePointsSummaryMembers(
        pointsSummaryListFromData(summaryData),
      );
      final isCur =
          meta.periodStart == current.periodStart &&
          meta.periodEnd == current.periodEnd;
      return PointsWeekShell(
        id: pointsWeekCycleId(meta.periodStart, meta.periodEnd),
        periodStart: meta.periodStart,
        periodEnd: meta.periodEnd,
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
        displayNameByMemberCode: parsed.displayNameByMemberCode,
      );
    }),
  );
  return shells;
}

/// 单周积分明细（选中周 / PageView 可见周时拉取）
Future<PointsWeekDetail> fetchPointsWeekDetailRemote(
  FamilyApiClient client,
  PointsWeekShell shell,
) async {
  final childSeed = await fetchPointsMemberCodes(client);
  var participantCodes = Set<String>.from(childSeed.codes);
  final displayNames = Map<String, String>.from(childSeed.displayNames);
  displayNames.addAll(shell.displayNameByMemberCode);

  var allRecords = await fetchPointsRecordsForPeriod(
    client,
    shell.periodStart,
    shell.periodEnd,
    participantCodes,
  );
  allRecords = dedupePointsRecords(allRecords);
  for (final r in allRecords) {
    final mc = r['memberCode']?.toString() ?? '';
    if (mc.isNotEmpty) participantCodes.add(mc);
  }

  final computed = computePointsSummaryFromRecords(
    allRecords,
    participantCodes,
    displayNames,
  );
  final daily = groupPointsRecordsByBizDate(
    allRecords,
    participantCodes,
    computed.displayNameByMemberCode,
  );
  return PointsWeekDetail(
    dailyLogs: daily,
    displayNameByMemberCode: computed.displayNameByMemberCode,
  );
}

PointsWeekShell pointsWeekShellFromCycle(PointsWeekCycle cycle) {
  return PointsWeekShell(
    id: cycle.id,
    periodStart: cycle.periodStart,
    periodEnd: cycle.periodEnd,
    rangeShort: cycle.rangeShort,
    rangeTitleLong: cycle.rangeTitleLong,
    isCurrentWeek: cycle.isCurrentWeek,
    totalsByMemberCode: cycle.totalsByMemberCode,
    netGainByMemberCode: cycle.netGainByMemberCode,
    displayNameByMemberCode: cycle.displayNameByMemberCode,
  );
}

PointsWeekDetail pointsWeekDetailFromCycle(PointsWeekCycle cycle) {
  return PointsWeekDetail(
    dailyLogs: cycle.dailyLogs,
    displayNameByMemberCode: cycle.displayNameByMemberCode,
  );
}

/// @deprecated 全量拉取所有周明细；请用 [fetchPointsWeekShellsRemote] + [fetchPointsWeekDetailRemote]
Future<List<PointsWeekCycle>> fetchPointsWeekCyclesRemote(
  FamilyApiClient client, {
  DateTime? now,
}) async {
  final anchor = now ?? DateTime.now();
  final current = currentWeekPeriodStrings(anchor);
  final weeksData = await client.fetchPointsWeeks();
  final rawWeeks = pointsWeeksListFromData(weeksData);
  final merged = mergePointsWeeksFromApi(rawWeeks, current);
  final childSeed = await fetchPointsMemberCodes(client);
  final cycles = <PointsWeekCycle>[];
  for (final meta in merged) {
    var participantCodes = Set<String>.from(childSeed.codes);
    final displayNames = Map<String, String>.from(childSeed.displayNames);

    var allRecords = await fetchPointsRecordsForPeriod(
      client,
      meta.periodStart,
      meta.periodEnd,
      participantCodes,
    );
    allRecords = dedupePointsRecords(allRecords);
    for (final r in allRecords) {
      final mc = r['memberCode']?.toString() ?? '';
      if (mc.isNotEmpty) participantCodes.add(mc);
    }

    final computed = computePointsSummaryFromRecords(
      allRecords,
      participantCodes,
      displayNames,
    );
    final daily = groupPointsRecordsByBizDate(
      allRecords,
      participantCodes,
      computed.displayNameByMemberCode,
    );
    final isCur =
        meta.periodStart == current.periodStart &&
        meta.periodEnd == current.periodEnd;
    cycles.add(
      PointsWeekCycle(
        id: pointsWeekCycleId(meta.periodStart, meta.periodEnd),
        periodStart: meta.periodStart,
        periodEnd: meta.periodEnd,
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
        totalsByMemberCode: computed.totalsByMemberCode,
        netGainByMemberCode: computed.netGainByMemberCode,
        dailyLogs: daily,
        displayNameByMemberCode: computed.displayNameByMemberCode,
      ),
    );
  }
  return cycles;
}

Future<List<PointsRuleLine>> fetchPointsRulesRemote(
  FamilyApiClient client,
) async {
  final data = await client.fetchPointsRules();
  final raw = pointsRulesListFromData(data);
  return raw.map(pointsRuleLineFromApiMap).toList();
}
