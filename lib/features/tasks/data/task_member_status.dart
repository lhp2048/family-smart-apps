import 'dart:convert';

import '../../../shared/models/member_entity.dart';

/// 将接口里各种「完成」表示统一为 bool（含 1 / "done" / 嵌套对象等）。
bool parseTaskDoneValue(dynamic v) {
  if (v == true) return true;
  if (v == false || v == null) return false;
  if (v is num) return v != 0;
  if (v is String) {
    final s = v.trim().toLowerCase();
    if (s.isEmpty) return false;
    if (s == '1' ||
        s == 'true' ||
        s == 'yes' ||
        s == 'y' ||
        s == 'done' ||
        s == 'completed' ||
        s == 'complete') {
      return true;
    }
    if (s == '0' ||
        s == 'false' ||
        s == 'no' ||
        s == 'n' ||
        s == 'pending' ||
        s == 'incomplete' ||
        s == 'todo') {
      return false;
    }
  }
  return false;
}

bool parseTaskDoneValueDeep(dynamic v) {
  if (v is Map) {
    final m = Map<String, dynamic>.from(v);
    return parseTaskDoneValue(
      m['done'] ??
          m['completed'] ??
          m['status'] ??
          m['value'] ??
          m['finished'] ??
          m['isDone'],
    );
  }
  return parseTaskDoneValue(v);
}

String? _memberKeyFromEntry(Map<String, dynamic> em) {
  const keys = [
    'memberCode',
    'member_code',
    'memberId',
    'member_id',
    'code',
    'userId',
    'user_id',
    'childId',
    'child_id',
  ];
  for (final k in keys) {
    final s = em[k]?.toString().trim();
    if (s != null && s.isNotEmpty) return s;
  }
  return null;
}

/// 将 `statusByMember` 规范为 `{"成员码": true/false}` 的 JSON 字符串后存入实体。
String normalizeStatusByMemberToStoredJson(dynamic v) {
  if (v == null) return '{}';
  if (v is String) {
    final s = v.trim();
    if (s.isEmpty) return '{}';
    try {
      final decoded = jsonDecode(s);
      if (decoded is Map) {
        return _mapToBoolsJson(Map<dynamic, dynamic>.from(decoded));
      }
      if (decoded is List) {
        return _listToBoolsJson(decoded);
      }
    } catch (_) {
      return '{}';
    }
    return '{}';
  }
  if (v is Map) {
    return _mapToBoolsJson(Map<dynamic, dynamic>.from(v));
  }
  if (v is List) {
    return _listToBoolsJson(v);
  }
  return '{}';
}

String _mapToBoolsJson(Map<dynamic, dynamic> map) {
  final out = <String, bool>{};
  for (final e in map.entries) {
    final k = e.key?.toString().trim() ?? '';
    if (k.isEmpty) continue;
    out[k] = parseTaskDoneValueDeep(e.value);
  }
  return jsonEncode(out);
}

String _listToBoolsJson(List<dynamic> list) {
  final out = <String, bool>{};
  for (final e in list) {
    if (e is! Map) continue;
    final em = Map<String, dynamic>.from(e);
    final code = _memberKeyFromEntry(em);
    if (code == null) continue;
    final done = em['done'] ?? em['completed'] ?? em['status'];
    out[code] = parseTaskDoneValueDeep(done);
  }
  return jsonEncode(out);
}

/// 根据 `statusByMemberJson` 解码后的 map 判断某成员是否已完成。
bool memberTaskDoneForCode(Map<String, dynamic> statusMap, String memberCode) {
  if (memberCode.isEmpty) return false;
  if (statusMap.containsKey(memberCode)) {
    return parseTaskDoneValueDeep(statusMap[memberCode]);
  }
  final lower = memberCode.toLowerCase();
  for (final e in statusMap.entries) {
    if (e.key.toString().toLowerCase() == lower) {
      return parseTaskDoneValueDeep(e.value);
    }
  }
  return false;
}

dynamic _mapValueForKeys(Map<String, dynamic> map, String key) {
  if (key.isEmpty) return null;
  if (map.containsKey(key)) return map[key];
  final kl = key.toLowerCase();
  for (final e in map.entries) {
    if (e.key.toString().toLowerCase() == kl) {
      return e.value;
    }
  }
  return null;
}

/// 与 [memberTaskDoneForCode] 相同，但额外用 [MemberEntity.name] 匹配（后台 `groupCode` 与 members 里 `memberCode` 不一致时常用）。
bool memberTaskDoneForMember(MemberEntity member, Map<String, dynamic> statusMap) {
  if (memberTaskDoneForCode(statusMap, member.memberCode)) return true;
  final name = member.name.trim();
  if (name.isEmpty) return false;
  final v = _mapValueForKeys(statusMap, name);
  if (v == null) return false;
  return parseTaskDoneValueDeep(v);
}

/// `completedAtByMemberJson` 解码后的 map：先试 `memberCode`，再试展示名。
String memberTaskTimeDisplayForMember(
  MemberEntity member,
  Map<String, dynamic> atMap,
) {
  for (final k in [member.memberCode.trim(), member.name.trim()]) {
    if (k.isEmpty) continue;
    final v = _mapValueForKeys(atMap, k);
    if (v == null) continue;
    final s = v.toString();
    if (s.isNotEmpty) return s;
  }
  return '';
}
