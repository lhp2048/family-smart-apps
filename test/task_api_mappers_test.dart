import 'package:flutter_test/flutter_test.dart';

import 'package:family_smart_center/features/tasks/data/task_api_mappers.dart';

void main() {
  test('taskDateFromApiMap 解析 allDone', () {
    final e = taskDateFromApiMap({
      'bizDate': '2026-03-10',
      'weekday': '周二',
      'hasReward': true,
      'allDone': true,
    });
    expect(e.bizDate, '2026-03-10');
    expect(e.allDone, isTrue);
  });

  test('taskDateFromApiMap allDone 缺省为 false', () {
    final e = taskDateFromApiMap({
      'bizDate': '2026-03-10',
      'weekday': '周二',
    });
    expect(e.allDone, isFalse);
  });
}
