import 'package:isar/isar.dart';

import '../../../core/storage/isar_query_compat.dart';
import '../../../shared/models/home_summary_entity_io.dart';
import '../../tasks/data/models/task_item_entity_io.dart';
import '../../tasks/data/task_progress.dart';

class HomeRepository {
  HomeRepository(this._isar);

  final Isar _isar;

  /// 根据当日任务重算首页「今日任务完成率」，保留原有积分 JSON
  Future<void> recalculateTaskProgress(String bizDate) async {
    final items = await _isar.taskItemEntitys
        .filter()
        .bizDateEqualTo(bizDate)
        .findAllCompat();
    final p = computeDayTaskProgress(items, (e) => e.statusByMemberJson);
    final existing = await _isar.homeSummaryEntitys
        .filter()
        .bizDateEqualTo(bizDate)
        .findFirstCompat();
    final now = DateTime.now();
    await _isar.writeTxn(() async {
      if (existing != null) {
        existing.taskProgress = p;
        existing.updatedAt = now;
        await _isar.homeSummaryEntitys.put(existing);
      } else {
        await _isar.homeSummaryEntitys.put(
          HomeSummaryEntity()
            ..bizDate = bizDate
            ..taskProgress = p
            ..memberScoresJson = '{}'
            ..updatedAt = now,
        );
      }
    });
  }
}
