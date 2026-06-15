import 'dart:convert';

import '../../../shared/models/member_entity.dart';
import '../../dashboard/data/family_api_client.dart';
import '../data/models/task_item_entity.dart';
import 'task_member_status.dart';

/// 将某成员当日作业列表转为 `POST /api/v1/sync/homework` 请求体中的 `items`。
///
/// [toggleTaskCode] 非空时翻转该任务对该成员的完成状态（用于 App 勾选）。
List<Map<String, dynamic>> buildHomeworkSyncItems({
  required MemberEntity member,
  required List<TaskItemEntity> items,
  String? toggleTaskCode,
  String? toggleGroupCode,
}) {
  final now = DateTime.now();
  final timeLabel =
      '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  final out = <Map<String, dynamic>>[];

  for (final item in items) {
    Map<String, dynamic> st = {};
    Map<String, dynamic> at = {};
    try {
      st = Map<String, dynamic>.from(
        jsonDecode(item.statusByMemberJson) as Map<dynamic, dynamic>,
      );
    } catch (_) {}
    try {
      at = Map<String, dynamic>.from(
        jsonDecode(item.completedAtByMemberJson) as Map<dynamic, dynamic>,
      );
    } catch (_) {}

    var done = memberTaskDoneForMember(member, st);
    final isToggleTarget = toggleTaskCode != null &&
        item.taskCode == toggleTaskCode &&
        (toggleGroupCode == null || item.groupCode == toggleGroupCode);
    if (isToggleTarget) {
      done = !done;
    }

    String? completedAt;
    if (done) {
      if (isToggleTarget) {
        completedAt = timeLabel;
      } else {
        final existing = memberTaskTimeDisplayForMember(member, at);
        completedAt = existing.isNotEmpty ? existing : timeLabel;
      }
    }

    final row = <String, dynamic>{
      'name': item.name,
      'done': done,
    };
    if (completedAt != null && completedAt.isNotEmpty) {
      row['completedAt'] = completedAt;
    }
    out.add(row);
  }
  return out;
}

/// 勾选/取消某成员的一条作业后，全量同步该成员当日作业到数据中心。
Future<void> syncHomeworkMemberDay({
  required FamilyApiClient client,
  required String bizDate,
  required MemberEntity member,
  required List<TaskItemEntity> items,
  required String toggleTaskCode,
  String? toggleGroupCode,
}) async {
  final syncItems = buildHomeworkSyncItems(
    member: member,
    items: items,
    toggleTaskCode: toggleTaskCode,
    toggleGroupCode: toggleGroupCode,
  );
  await client.syncHomework(
    bizDate: bizDate,
    memberCode: member.memberCode,
    displayName: member.name,
    items: syncItems,
  );
}
