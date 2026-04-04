import 'dart:convert';

import 'package:isar/isar.dart';

import '../../../core/storage/isar_query_compat.dart';
import '../../dashboard/data/home_repository.dart';
import 'models/task_date_entity.dart';
import 'models/task_group_entity.dart';
import 'models/task_item_entity.dart';
import 'task_keys.dart';
import 'task_progress.dart';

class TaskRepository {
  TaskRepository(this._isar, this._homeRepository);

  final Isar _isar;
  final HomeRepository _homeRepository;

  Stream<List<TaskDateEntity>> watchTaskDates() {
    return _isar.taskDateEntitys.watchLazy(fireImmediately: true).asyncMap(
          (_) => _isar.taskDateEntitys
              .where()
              .anyId()
              .sortByBizDateDesc()
              .findAllCompat(),
        );
  }

  Stream<List<TaskGroupEntity>> watchGroupsForBizDate(String bizDate) {
    return _isar.taskGroupEntitys.watchLazy(fireImmediately: true).asyncMap(
          (_) => _isar.taskGroupEntitys
              .filter()
              .bizDateEqualTo(bizDate)
              .sortBySort()
              .findAllCompat(),
        );
  }

  Stream<List<TaskItemEntity>> watchItemsForGroup(
    String bizDate,
    String groupCode,
  ) {
    return _isar.taskItemEntitys.watchLazy(fireImmediately: true).asyncMap(
          (_) => _isar.taskItemEntitys
              .filter()
              .bizDateEqualTo(bizDate)
              .groupCodeEqualTo(groupCode)
              .sortBySort()
              .findAllCompat(),
        );
  }

  Future<void> toggleMemberStatus({
    required String bizDate,
    required String groupCode,
    required String taskCode,
    required String memberCode,
  }) async {
    final key = taskItemKey(bizDate, groupCode, taskCode);
    await _isar.writeTxn(() async {
      final item = await _isar.taskItemEntitys
          .filter()
          .bizDateGroupTaskKeyEqualTo(key)
          .findFirstCompat();
      if (item == null) return;
      final map = Map<String, dynamic>.from(
        jsonDecode(item.statusByMemberJson) as Map<dynamic, dynamic>,
      );
      final cur = map[memberCode] == true;
      final newDone = !cur;
      map[memberCode] = newDone;
      item.statusByMemberJson = jsonEncode(map);
      Map<String, dynamic> atMap = {};
      try {
        atMap = Map<String, dynamic>.from(
          jsonDecode(item.completedAtByMemberJson) as Map<dynamic, dynamic>,
        );
      } catch (_) {}
      if (newDone) {
        final t = DateTime.now();
        atMap[memberCode] =
            '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
      } else {
        atMap.remove(memberCode);
      }
      item.completedAtByMemberJson = jsonEncode(atMap);
      item.updatedAt = DateTime.now();
      await _isar.taskItemEntitys.put(item);

      await _updateGroupProgressInTxn(bizDate, groupCode);
    });
    await _homeRepository.recalculateTaskProgress(bizDate);
  }

  Future<void> _updateGroupProgressInTxn(
    String bizDate,
    String groupCode,
  ) async {
    final items = await _isar.taskItemEntitys
        .filter()
        .bizDateEqualTo(bizDate)
        .groupCodeEqualTo(groupCode)
        .sortBySort()
        .findAllCompat();
    final p = computeTaskGroupProgress(items);
    final gk = taskGroupKey(bizDate, groupCode);
    final g = await _isar.taskGroupEntitys
        .filter()
        .bizDateGroupKeyEqualTo(gk)
        .findFirstCompat();
    if (g != null) {
      g.progress = p;
      g.updatedAt = DateTime.now();
      await _isar.taskGroupEntitys.put(g);
    }
  }
}
