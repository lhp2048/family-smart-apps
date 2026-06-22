import 'package:flutter_test/flutter_test.dart';

import 'package:family_smart_center/features/points/data/points_api_mappers.dart';

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
}
