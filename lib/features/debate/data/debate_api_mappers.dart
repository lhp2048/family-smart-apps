import '../../dashboard/data/family_api_client.dart';
import 'debate_prototype_models.dart';

List<String> parseDebateDaysList(Map<String, dynamic> data) {
  final raw = data['list'];
  if (raw is! List) return const [];
  final out = <String>[];
  for (final e in raw) {
    if (e is String) {
      if (e.isNotEmpty) out.add(e);
    } else if (e is Map && e['bizDate'] != null) {
      final s = e['bizDate'].toString();
      if (s.isNotEmpty) out.add(s);
    }
  }
  out.sort((a, b) => b.compareTo(a));
  return out;
}

List<String> _stringListFrom(dynamic v) {
  if (v is! List) return const [];
  return v.map((e) => e.toString()).toList();
}

DebateTopicItem debateTopicFromApiMap(Map<String, dynamic> m, int orderIndex) {
  final id = m['id']?.toString() ??
      m['topicId']?.toString() ??
      m['topicCode']?.toString() ??
      'topic_$orderIndex';
  final categoryTag = m['categoryTag']?.toString() ??
      m['category']?.toString() ??
      m['tag']?.toString() ??
      '话题';
  final topicIndex = (m['topicIndex'] as num?)?.toInt() ??
      (m['index'] as num?)?.toInt() ??
      (m['roundNo'] as num?)?.toInt() ??
      (m['sort'] as num?)?.toInt() ??
      orderIndex;
  final question = m['question']?.toString() ??
      m['title']?.toString() ??
      m['topic']?.toString() ??
      '';
  final proBody = m['proBody']?.toString() ??
      m['pro']?.toString() ??
      m['proArgument']?.toString() ??
      m['proSummary']?.toString() ??
      m['positive']?.toString() ??
      '';
  final conBody = m['conBody']?.toString() ??
      m['con']?.toString() ??
      m['conArgument']?.toString() ??
      m['conSummary']?.toString() ??
      m['negative']?.toString() ??
      '';
  return DebateTopicItem(
    id: id,
    categoryTag: categoryTag,
    topicIndex: topicIndex,
    question: question,
    proBody: proBody,
    conBody: conBody,
  );
}

/// 将接口 `data` 转为 [DebateDayBundle]（字段与文档 `DebateDayBundle` 对齐，并兼容常见别名）
DebateDayBundle debateDayBundleFromApiMap(
  Map<String, dynamic> data, {
  required String bizDate,
}) {
  final bd = data['bizDate']?.toString();
  final resolvedBizDate =
      (bd != null && bd.isNotEmpty) ? bd : bizDate;
  final mainTitle = data['mainTitle']?.toString() ??
      data['title']?.toString() ??
      data['bundleTitle']?.toString() ??
      '话题辩论';
  final scheduleHint = data['scheduleHint']?.toString() ??
      data['schedule']?.toString() ??
      data['subtitle']?.toString() ??
      '';
  var guideSteps = _stringListFrom(data['guideSteps']);
  if (guideSteps.isEmpty) {
    guideSteps = _stringListFrom(data['guide_steps']);
  }
  if (guideSteps.isEmpty) {
    guideSteps = _stringListFrom(data['steps']);
  }

  var topicMaps = <Map<String, dynamic>>[];
  final topicsRaw = data['topics'];
  if (topicsRaw is List) {
    for (final t in topicsRaw) {
      if (t is Map) topicMaps.add(Map<String, dynamic>.from(t));
    }
  }
  if (topicMaps.isEmpty && data['debateTopics'] is List) {
    for (final t in data['debateTopics'] as List) {
      if (t is Map) topicMaps.add(Map<String, dynamic>.from(t));
    }
  }

  final topics = <DebateTopicItem>[];
  for (var i = 0; i < topicMaps.length; i++) {
    topics.add(debateTopicFromApiMap(topicMaps[i], i + 1));
  }

  return DebateDayBundle(
    bizDate: resolvedBizDate,
    mainTitle: mainTitle,
    scheduleHint: scheduleHint,
    guideSteps: guideSteps,
    topics: topics,
  );
}

Future<List<String>> fetchDebateDaysRemote(FamilyApiClient client) async {
  final data = await client.fetchDebateDays();
  return parseDebateDaysList(data);
}

Future<DebateDayBundle?> fetchDebateBundleForDateRemote(
  FamilyApiClient client,
  String bizDate,
) async {
  final raw = await client.fetchDebateBundleOrNull(bizDate);
  if (raw == null) return null;
  return debateDayBundleFromApiMap(raw, bizDate: bizDate);
}
