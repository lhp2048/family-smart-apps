import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../dashboard/data/family_api_client.dart';
import '../../dashboard/providers/dashboard_remote_providers.dart';
import '../../dashboard/providers/family_api_write_refresh.dart';
import 'syllable_sheet_latest.dart';
import 'syllable_worksheet_word.dart';

Map<String, dynamic> syllableSheetToSyncPayload(SyllableLatestSheet sheet) {
  final now = DateTime.now().toIso8601String();
  final words = sheet.words
      .where((w) => w.word.trim().isNotEmpty)
      .take(15)
      .map(
        (w) => {
          'word': w.word,
          'phonetic': w.phonetic,
          'definition': w.definition,
        },
      )
      .toList();
  var sheetId = sheet.sheetId.trim();
  if (sheetId.isEmpty) {
    final d = DateTime.now();
    sheetId =
        '${d.year}${d.month.toString().padLeft(2, '0')}${d.day.toString().padLeft(2, '0')}';
  }
  return {
    'sheetId': sheetId,
    'generatedAt': sheet.generatedAtIso ?? now,
    'words': words,
  };
}

/// 将词表同步为数据中心最新练习纸。
Future<void> syncSyllableSheetRemote(
  WidgetRef ref,
  SyllableLatestSheet sheet,
) async {
  final payload = syllableSheetToSyncPayload(sheet);
  if ((payload['words'] as List).isEmpty) {
    throw FamilyApiException('没有可同步的单词');
  }
  final client = ref.read(familyApiClientProvider);
  await client.syncSyllableSheet(payload);
  refreshAfterFamilyApiWrite(ref);
}

/// 用演示词表生成并同步（API 模式下词表为空时）。
SyllableLatestSheet demoSyllableSheetForSync() {
  const demo = [
    SyllableWorksheetWord(
      word: 'apple',
      phonetic: '/ˈæp.əl/',
      definition: '苹果',
    ),
    SyllableWorksheetWord(
      word: 'table',
      phonetic: '/ˈteɪ.bəl/',
      definition: '桌子',
    ),
    SyllableWorksheetWord(
      word: 'happy',
      phonetic: '/ˈhæp.i/',
      definition: '快乐的',
    ),
  ];
  final d = DateTime.now();
  final sheetId =
      '${d.year}${d.month.toString().padLeft(2, '0')}${d.day.toString().padLeft(2, '0')}';
  return SyllableLatestSheet(
    sheetId: sheetId,
    generatedAtIso: d.toIso8601String(),
    words: demo,
  );
}
