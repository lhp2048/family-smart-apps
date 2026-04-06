import 'dart:convert';

import '../../../shared/models/member_entity.dart';
import 'models/task_date_entity.dart';
import 'models/task_group_entity.dart';
import 'models/task_item_entity.dart';
import 'homework_items_bundle.dart';
import 'task_keys.dart';
import 'task_member_status.dart';

DateTime? _parseUpdatedAt(dynamic v) {
  if (v == null) return null;
  if (v is DateTime) return v;
  final s = v.toString();
  if (s.isEmpty) return null;
  try {
    return DateTime.parse(s).toLocal();
  } catch (_) {
    return null;
  }
}

String? _firstNonEmptyStr(Map<String, dynamic> m, List<String> keys) {
  for (final k in keys) {
    final v = m[k];
    if (v == null) continue;
    final s = v.toString().trim();
    if (s.isNotEmpty) return s;
  }
  return null;
}

/// 展示名：兼容后端多种字段名及嵌套 `task`。
String _taskItemDisplayName(Map<String, dynamic> m) {
  final direct = _firstNonEmptyStr(m, const [
    'name',
    'taskName',
    'title',
    'taskTitle',
    'label',
    'itemName',
    'content',
    'description',
    'task_name',
    'task_title',
  ]);
  if (direct != null) return direct;
  final nested = m['task'];
  if (nested is Map) {
    final nm = Map<String, dynamic>.from(nested);
    final n = _firstNonEmptyStr(nm, const ['name', 'title', 'taskName']);
    if (n != null) return n;
  }
  final code = _firstNonEmptyStr(m, const [
    'taskCode',
    'code',
    'taskId',
    'task_id',
    'id',
  ]);
  return code ?? '未命名作业';
}

String _taskItemCode(Map<String, dynamic> m) {
  return _firstNonEmptyStr(m, const [
        'taskCode',
        'code',
        'taskId',
        'task_id',
        'id',
      ]) ??
      '';
}

/// 后端「每人一行」：`taskName` + `done` + `groupCode`/`memberCode` 表示孩子，无 `statusByMember`。
bool looksLikeMemberPerTaskRowApiList(List<Map<String, dynamic>> raw) {
  if (raw.isEmpty) return false;
  if (raw.any((m) =>
      m['statusByMember'] != null ||
      m['statusByMemberJson'] != null ||
      m['status_by_member'] != null)) {
    return false;
  }
  for (final m0 in raw) {
    if (_firstNonEmptyStr(m0, const ['taskName', 'task_name', 'name']) == null) {
      continue;
    }
    if (!m0.containsKey('done')) continue;
    if (_memberKeyFromMemberTaskRow(m0) != null) return true;
  }
  return false;
}

String? _memberKeyFromMemberTaskRow(Map<String, dynamic> r) {
  return _firstNonEmptyStr(r, const [
    'memberCode',
    'member_code',
    'groupCode',
    'group_code',
  ]);
}

String _memberRowTaskNameForSort(Map<String, dynamic> r) {
  return _firstNonEmptyStr(r, const ['taskName', 'task_name', 'name']) ?? '';
}

TaskItemEntity _taskItemEntityFromSingleMemberRow(
  Map<String, dynamic> r,
  int sortIndex,
  String fallbackBizDate,
  String memberCode,
) {
  final bizDate =
      _firstNonEmptyStr(r, const ['bizDate', 'biz_date', 'date']) ??
          fallbackBizDate;
  final tnRaw = _memberRowTaskNameForSort(r);
  final tn = tnRaw.isEmpty ? '未命名作业' : tnRaw;
  final d = r['done'];
  final done = d == true ||
      d == 1 ||
      d == '1' ||
      d == 'true' ||
      d == 'done' ||
      d == 'completed';
  final disp = _firstNonEmptyStr(r, const [
    'memberName',
    'member_name',
    'displayName',
    'display_name',
  ]);
  final statusMap = <String, bool>{memberCode: done};
  if (disp != null && disp.isNotEmpty) {
    statusMap[disp] = done;
  }
  final ca = r['completedAt'] ?? r['completed_at'];
  final atMap = <String, dynamic>{};
  if (ca != null && ca.toString().trim().isNotEmpty) {
    final cs = ca.toString();
    atMap[memberCode] = cs;
    if (disp != null && disp.isNotEmpty) {
      atMap[disp] = cs;
    }
  }

  final e = TaskItemEntity();
  e.bizDate = bizDate;
  const aggregateGroupCode = 'homework';
  e.groupCode = aggregateGroupCode;
  final ik = r['itemKey']?.toString().trim();
  e.taskCode =
      (ik != null && ik.isNotEmpty) ? ik : '${memberCode}_t$sortIndex';
  e.bizDateGroupTaskKey =
      taskItemKey(bizDate, aggregateGroupCode, e.taskCode);
  e.name = tn;
  e.score = (r['score'] as num?)?.toInt() ?? 0;
  e.statusByMemberJson = jsonEncode(statusMap);
  e.completedAtByMemberJson = jsonEncode(atMap);
  e.sort = sortIndex;
  e.updatedAt = _parseUpdatedAt(r['updatedAt']) ?? DateTime.now();
  return e;
}

/// 按行上的 `groupCode`/`memberCode` 分成员；组内按 `taskName`（及 `task_name`/`name`）字典序排序。
Map<String, List<TaskItemEntity>> taskMemberGroupedItemsFromMemberPerTaskRows(
  List<Map<String, dynamic>> raw,
  String fallbackBizDate,
) {
  final byMember = <String, List<Map<String, dynamic>>>{};
  for (final r in raw) {
    final gc = _memberKeyFromMemberTaskRow(r);
    if (gc == null || gc.isEmpty) continue;
    byMember.putIfAbsent(gc, () => []).add(r);
  }
  final out = <String, List<TaskItemEntity>>{};
  for (final e in byMember.entries) {
    final rows = [...e.value]..sort(
        (a, b) => _memberRowTaskNameForSort(a).compareTo(
              _memberRowTaskNameForSort(b),
            ),
      );
    out[e.key] = [
      for (var i = 0; i < rows.length; i++)
        _taskItemEntityFromSingleMemberRow(
          rows[i],
          i,
          fallbackBizDate,
          e.key,
        ),
    ];
  }
  return out;
}

HomeworkItemsBundle homeworkItemsBundleFromApiRawList(
  List<Map<String, dynamic>> raw,
  String bizDate,
) {
  if (raw.isEmpty) {
    return HomeworkItemsBundle.flat(const []);
  }
  if (looksLikeMemberPerTaskRowApiList(raw)) {
    return HomeworkItemsBundle.byMember(
      taskMemberGroupedItemsFromMemberPerTaskRows(raw, bizDate),
    );
  }
  return HomeworkItemsBundle.flat(raw.map(taskItemFromApiMap).toList());
}

/// 将 `GET /v1/task-items` 原始 list 转为扁平列表（调试/兼容；作业页请用 [homeworkItemsBundleFromApiRawList]）。
List<TaskItemEntity> taskItemsFromApiRawList(
  List<Map<String, dynamic>> raw,
  String bizDate,
) {
  return homeworkItemsBundleFromApiRawList(raw, bizDate).flattenedMembersSorted();
}

/// `completedAtByMember`：支持 Map、JSON 字符串、或 `[{ memberCode, completedAt }]`。
String _normalizeCompletedAtByMemberJson(dynamic v) {
  if (v == null) return '{}';
  if (v is String) {
    final s = v.trim();
    return s.isEmpty ? '{}' : s;
  }
  if (v is Map) {
    return jsonEncode(v);
  }
  if (v is List) {
    final map = <String, dynamic>{};
    for (final e in v) {
      if (e is! Map) continue;
      final em = Map<String, dynamic>.from(e);
      final code = _firstNonEmptyStr(em, const [
        'memberCode',
        'code',
        'member_id',
        'memberId',
      ]);
      final t = _firstNonEmptyStr(em, const [
        'completedAt',
        'completed_at',
        'time',
        'at',
      ]);
      if (code != null && t != null) {
        map[code] = t;
      }
    }
    return jsonEncode(map);
  }
  return '{}';
}

/// `GET /v1/task-dates` 单条
TaskDateEntity taskDateFromApiMap(Map<String, dynamic> m) {
  final e = TaskDateEntity();
  e.bizDate = m['bizDate']?.toString() ?? '';
  e.weekday = m['weekday']?.toString() ?? '';
  final hr = m['hasReward'];
  e.hasReward = hr == true || hr == 1 || hr == '1' || hr == 'true';
  e.updatedAt = _parseUpdatedAt(m['updatedAt']) ?? DateTime.now();
  return e;
}

/// `GET /v1/task-groups` 单条
TaskGroupEntity taskGroupFromApiMap(Map<String, dynamic> m) {
  final e = TaskGroupEntity();
  final bizDate = m['bizDate']?.toString() ?? '';
  final groupCode = m['groupCode']?.toString() ?? '';
  e.bizDateGroupKey =
      m['bizDateGroupKey']?.toString().isNotEmpty == true
          ? m['bizDateGroupKey'].toString()
          : taskGroupKey(bizDate, groupCode);
  e.bizDate = bizDate;
  e.groupCode = groupCode;
  e.title = m['title']?.toString() ?? groupCode;
  final p = m['progress'];
  e.progress = p is num ? p.toDouble() : double.tryParse('$p') ?? 0;
  e.sort = (m['sort'] as num?)?.toInt() ?? 0;
  e.updatedAt = _parseUpdatedAt(m['updatedAt']) ?? DateTime.now();
  return e;
}

/// `GET /v1/task-items` 单条
TaskItemEntity taskItemFromApiMap(Map<String, dynamic> m) {
  final e = TaskItemEntity();
  final bizDate =
      _firstNonEmptyStr(m, const ['bizDate', 'biz_date', 'date']) ?? '';
  final groupCode =
      _firstNonEmptyStr(m, const ['groupCode', 'group_code']) ?? '';
  var resolvedTaskCode = _taskItemCode(m);
  if (resolvedTaskCode.isEmpty) {
    // 勿把 groupCode 编入 hash：同一任务出现在多个分组时应对齐为同一 taskCode，便于去重。
    resolvedTaskCode =
        's${Object.hash(bizDate, m['sort'], m['name'], m['title'], m['taskName'], m['task_name'])}';
  }
  final sk = m['bizDateGroupTaskKey']?.toString().trim();
  final sk2 = m['biz_date_group_task_key']?.toString().trim();
  e.bizDateGroupTaskKey = (sk != null && sk.isNotEmpty)
      ? sk
      : (sk2 != null && sk2.isNotEmpty)
          ? sk2
          : taskItemKey(bizDate, groupCode, resolvedTaskCode);
  e.bizDate = bizDate;
  e.groupCode = groupCode;
  e.taskCode = resolvedTaskCode;
  e.name = _taskItemDisplayName(m);
  e.score = (m['score'] as num?)?.toInt() ?? 0;
  e.statusByMemberJson = normalizeStatusByMemberToStoredJson(
    m['statusByMember'] ??
        m['statusByMemberJson'] ??
        m['status_by_member'] ??
        m['memberStatus'],
  );
  e.completedAtByMemberJson = _normalizeCompletedAtByMemberJson(
    m['completedAtByMember'] ??
        m['completedAtByMemberJson'] ??
        m['completed_at_by_member'] ??
        m['memberCompletedAt'],
  );
  e.sort = (m['sort'] as num?)?.toInt() ?? 0;
  e.updatedAt = _parseUpdatedAt(m['updatedAt']) ?? DateTime.now();
  return e;
}

MemberEntity memberFromApiMap(Map<String, dynamic> m) {
  final e = MemberEntity();
  e.memberCode = _firstNonEmptyStr(m, const [
        'memberCode',
        'member_code',
        'memberId',
        'member_id',
        'code',
        'userId',
        'user_id',
        'childId',
        'child_id',
        'id',
      ]) ??
      '';
  e.name = m['name']?.toString() ?? m['displayName']?.toString() ?? e.memberCode;
  e.avatar = m['avatar']?.toString();
  e.role = m['role']?.toString() ?? 'child';
  e.status = m['status']?.toString() ?? 'active';
  e.createdAt = _parseUpdatedAt(m['createdAt']) ?? DateTime.now();
  e.updatedAt = _parseUpdatedAt(m['updatedAt']) ?? DateTime.now();
  return e;
}
