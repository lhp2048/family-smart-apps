import 'package:flutter_test/flutter_test.dart';

import 'package:family_smart_center/features/points/data/points_api_mappers.dart';
import 'package:family_smart_center/features/points/data/points_prototype_models.dart';

void main() {
  test('memberDisplayNameFromApiMap 优先 displayName', () {
    expect(
      memberDisplayNameFromApiMap({
        'memberCode': 'chuan',
        'name': 'chuan',
        'displayName': '川川',
      }),
      '川川',
    );
  });

  test('resolvePointsRecordPerson 优先流水 displayName', () {
    expect(
      resolvePointsRecordPerson(
        {
          'memberCode': 'chuan',
          'displayName': '川川',
          'person': 'chuan',
        },
        const {'chuan': '曦曦-wrong'},
      ),
      '川川',
    );
  });

  test('流水无 displayName 时回退成员 displayName', () {
    expect(
      resolvePointsRecordPerson(
        {
          'memberCode': 'chuan',
          'displayName': '',
          'person': 'chuan',
        },
        const {'chuan': '川川'},
      ),
      '川川',
    );
  });

  test('pointsLogRowFromApi 明细与 displayName 策略一致', () {
    final row = pointsLogRowFromApi(
      {
        'memberCode': 'chuan',
        'person': 'chuan',
        'displayName': '',
        'item': '补周日积分',
        'delta': 5,
      },
      const {'chuan': '川川'},
    );
    expect(row.person, '川川');
  });

  test('pointsWeekShellFromCycle 保留 summary 字段不含 dailyLogs', () {
    const cycle = PointsWeekCycle(
      id: 'w1',
      periodStart: '2026-03-10',
      periodEnd: '2026-03-16',
      rangeShort: '3.10-3.16',
      rangeTitleLong: '2026年3月10日 - 3月16日',
      isCurrentWeek: true,
      totalsByMemberCode: {'xixi': 50, 'chuan': 60},
      netGainByMemberCode: {'xixi': 5, 'chuan': 10},
      dailyLogs: [
        PointsDayLogGroup(
          dayKey: '2026-03-10',
          weekdayLabel: '周二',
          dayDeltaByMemberCode: {'xixi': 1},
          rows: const [],
        ),
      ],
      displayNameByMemberCode: {'chuan': '川川'},
    );
    final shell = pointsWeekShellFromCycle(cycle);
    expect(shell.id, 'w1');
    expect(shell.totalsByMemberCode['chuan'], 60);
    expect(shell.displayNameByMemberCode['chuan'], '川川');
    expect(shell.periodStart, '2026-03-10');
  });

  test('pointsWeekDetailFromCycle 仅含明细', () {
    const cycle = PointsWeekCycle(
      id: 'w1',
      periodStart: '2026-03-10',
      periodEnd: '2026-03-16',
      rangeShort: '3.10-3.16',
      rangeTitleLong: '2026年3月10日 - 3月16日',
      isCurrentWeek: false,
      totalsByMemberCode: const {},
      netGainByMemberCode: const {},
      dailyLogs: [
        PointsDayLogGroup(
          dayKey: '2026-03-10',
          weekdayLabel: '周二',
          dayDeltaByMemberCode: {'xixi': 1},
          rows: const [],
        ),
      ],
      displayNameByMemberCode: {'xixi': '曦曦'},
    );
    final detail = pointsWeekDetailFromCycle(cycle);
    expect(detail.dailyLogs, hasLength(1));
    expect(detail.dailyLogs.first.dayKey, '2026-03-10');
    expect(detail.displayNameByMemberCode['xixi'], '曦曦');
  });
}
