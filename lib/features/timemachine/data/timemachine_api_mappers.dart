import '../../dashboard/data/family_api_client.dart';
import 'timemachine_prototype_models.dart';

String _fallbackMonthChipLabel(String monthKey) {
  final parts = monthKey.split('-');
  if (parts.length != 2) return monthKey;
  final y = int.tryParse(parts[0]) ?? 0;
  final m = int.tryParse(parts[1]) ?? 0;
  return '${y % 100}年$m月';
}

/// 远程拉取后聚合：条目 + 第一行月份 chips（与接口一致）
class TimemachineRemoteBundle {
  const TimemachineRemoteBundle({
    required this.entries,
    required this.monthChips,
  });

  final List<TimemachineEntry> entries;
  final List<TimemachineMonthChip> monthChips;
}

TimemachineEntry timemachineEntryFromApiMap(Map<String, dynamic> m) {
  final rawId = m['entryId'] ?? m['id'];
  final id = rawId?.toString() ?? '';
  final bizDate = m['bizDate']?.toString() ?? '';
  final title = m['title']?.toString() ?? '';
  final body = m['content']?.toString() ?? m['body']?.toString() ?? '';
  return TimemachineEntry(
    id: id.isNotEmpty ? id : '${bizDate}_${title.hashCode}',
    bizDate: bizDate,
    title: title,
    body: body,
  );
}

List<Map<String, dynamic>> _listFromMap(Map<String, dynamic> data, String key) {
  final raw = data[key];
  if (raw is! List) return const [];
  return raw
      .whereType<Map>()
      .map((e) => Map<String, dynamic>.from(e))
      .toList();
}

TimemachineMonthChip timemachineMonthChipFromApiMap(Map<String, dynamic> m) {
  final mk = m['monthKey']?.toString() ?? '';
  final labelRaw = m['label']?.toString();
  final label = (labelRaw != null && labelRaw.isNotEmpty)
      ? labelRaw
      : _fallbackMonthChipLabel(mk);
  final count = (m['entryCount'] as num?)?.toInt() ?? 0;
  return TimemachineMonthChip(
    monthKey: mk,
    label: label,
    entryCount: count,
  );
}

TimemachineSidebarDay timemachineSidebarDayFromApiMap(Map<String, dynamic> m) {
  final bd = m['bizDate']?.toString() ?? '';
  final labelRaw = m['label']?.toString();
  final label = (labelRaw != null && labelRaw.isNotEmpty)
      ? labelRaw
      : bd;
  final count = (m['entryCount'] as num?)?.toInt() ?? 0;
  return TimemachineSidebarDay(
    bizDate: bd,
    label: label,
    entryCount: count,
  );
}

Future<List<TimemachineMonthChip>> fetchTimelineMonthChipsRemote(
  FamilyApiClient client,
) async {
  final chipsData = await client.fetchTimelineMonthChips();
  final rawChips = _listFromMap(chipsData, 'list');
  final monthChips = rawChips
      .map(timemachineMonthChipFromApiMap)
      .where((c) => c.monthKey.isNotEmpty)
      .toList();
  monthChips.sort((a, b) => b.monthKey.compareTo(a.monthKey));
  return monthChips;
}

Future<List<TimemachineSidebarDay>> fetchTimelineSidebarDaysRemote(
  FamilyApiClient client,
  String monthKey,
) async {
  final data = await client.fetchTimelineSidebarDays(monthKey);
  final raw = _listFromMap(data, 'list');
  final days = raw
      .map(timemachineSidebarDayFromApiMap)
      .where((d) => d.bizDate.isNotEmpty)
      .toList();
  days.sort((a, b) => b.bizDate.compareTo(a.bizDate));
  return days;
}

Future<List<TimemachineEntry>> fetchTimelineEntriesRemote(
  FamilyApiClient client, {
  String? monthKey,
  String? bizDate,
}) async {
  final out = <TimemachineEntry>[];
  const pageSize = 100;
  var page = 1;
  while (true) {
    final data = await client.fetchTimelineEntries(
      monthKey: monthKey,
      bizDate: bizDate,
      page: page,
      pageSize: pageSize,
    );
    final maps = _listFromMap(data, 'list');
    for (final m in maps) {
      out.add(timemachineEntryFromApiMap(m));
    }
    final total = (data['total'] as num?)?.toInt() ?? out.length;
    if (out.length >= total || maps.isEmpty) break;
    page++;
    if (page > 200) break;
  }
  return out;
}

Future<List<TimemachineEntry>> fetchAllTimelineEntriesForMonth(
  FamilyApiClient client,
  String monthKey,
) async {
  final out = <TimemachineEntry>[];
  const pageSize = 100;
  var page = 1;
  while (true) {
    final data = await client.fetchTimelineEntries(
      monthKey: monthKey,
      page: page,
      pageSize: pageSize,
    );
    final maps = _listFromMap(data, 'list');
    for (final m in maps) {
      out.add(timemachineEntryFromApiMap(m));
    }
    final total = (data['total'] as num?)?.toInt() ?? out.length;
    if (out.length >= total || maps.isEmpty) break;
    page++;
    if (page > 200) break;
  }
  return out;
}

@Deprecated('Use fetchTimelineMonthChipsRemote + family providers instead')
Future<TimemachineRemoteBundle> fetchTimemachineBundleRemote(
  FamilyApiClient client,
) async {
  final chipsData = await client.fetchTimelineMonthChips();
  final rawChips = _listFromMap(chipsData, 'list');
  final monthChips = rawChips
      .map(timemachineMonthChipFromApiMap)
      .where((c) => c.monthKey.isNotEmpty)
      .toList();
  monthChips.sort((a, b) => b.monthKey.compareTo(a.monthKey));

  final allEntries = <TimemachineEntry>[];
  for (final c in monthChips) {
    allEntries.addAll(await fetchAllTimelineEntriesForMonth(client, c.monthKey));
  }

  return TimemachineRemoteBundle(
    entries: allEntries,
    monthChips: monthChips,
  );
}
