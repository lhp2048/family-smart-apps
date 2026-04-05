import 'package:flutter_test/flutter_test.dart';

import 'package:family_smart_center/core/utils/biz_date.dart';
import 'package:family_smart_center/features/tasks/data/task_keys.dart';
import 'package:family_smart_center/features/tasks/data/task_progress.dart';
import 'package:family_smart_center/features/tasks/data/models/task_item_entity.dart';

void main() {
  test('formatBizDate 输出 YYYY-MM-DD', () {
    expect(formatBizDate(DateTime(2026, 4, 2)), '2026-04-02');
  });

  test('taskGroupKey / taskItemKey', () {
    expect(taskGroupKey('2026-04-02', 'g1'), '2026-04-02|g1');
    expect(taskItemKey('2026-04-02', 'g1', 't1'), '2026-04-02|g1|t1');
  });

  test('computeTaskGroupProgress', () {
    final a = TaskItemEntity()
      ..bizDateGroupTaskKey = 'x'
      ..bizDate = '2026-04-02'
      ..groupCode = 'g'
      ..taskCode = '1'
      ..name = 'n'
      ..score = 1
      ..statusByMemberJson = '{"a":true,"b":false}'
      ..completedAtByMemberJson = '{}'
      ..sort = 1
      ..updatedAt = DateTime.now();
    expect(computeTaskGroupProgress([a], (e) => e.statusByMemberJson), 0.5);
  });
}
