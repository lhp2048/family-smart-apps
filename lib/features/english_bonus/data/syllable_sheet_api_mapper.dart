import 'syllable_sheet_latest.dart';
import 'syllable_worksheet_word.dart';

/// 将 [raw] 规范为形态 H 的 Map（兼容 snake_case、外层 `sheet` 包裹、误用 `list` 单条等）。
Map<String, dynamic> _normalizeSyllableSheetDataMap(Map<String, dynamic> raw) {
  Map<String, dynamic> m = Map<String, dynamic>.from(raw);

  final sheet = m['sheet'];
  if (sheet is Map && m['words'] == null && m['word_list'] == null) {
    m = Map<String, dynamic>.from(sheet);
  } else {
    final payload = m['payload'];
    if (payload is Map && m['words'] == null && m['word_list'] == null) {
      m = Map<String, dynamic>.from(payload);
    }
  }

  if (m['words'] == null && m['wordList'] == null && m['word_list'] == null) {
    final list = m['list'];
    if (list is List &&
        list.isNotEmpty &&
        list.first is Map &&
        (list.first as Map)['word'] != null) {
      return {
        ...m,
        'words': list,
      };
    }
    if (list is List && list.length == 1 && list.first is Map) {
      final only = Map<String, dynamic>.from(list.first as Map);
      if (only.containsKey('words') ||
          only.containsKey('word_list') ||
          only.containsKey('sheetId') ||
          only.containsKey('sheet_id')) {
        return _normalizeSyllableSheetDataMap(only);
      }
    }
  }

  return m;
}

List<dynamic>? _wordsArrayFrom(Map<String, dynamic> m) {
  final w = m['words'];
  if (w is List) return w;
  final wl = m['wordList'];
  if (wl is List) return wl;
  final wu = m['word_list'];
  if (wu is List) return wu;
  final items = m['items'];
  if (items is List) return items;
  return null;
}

SyllableLatestSheet syllableLatestSheetFromApiMap(Map<String, dynamic> raw) {
  final m = _normalizeSyllableSheetDataMap(raw);
  final sheetId =
      m['sheetId']?.toString() ?? m['sheet_id']?.toString() ?? '';
  final gen = m['generatedAt'] ?? m['generated_at'];
  final genStr = gen?.toString();
  final rawList = _wordsArrayFrom(m);
  final words = <SyllableWorksheetWord>[];
  if (rawList != null) {
    for (final e in rawList) {
      if (e is Map) {
        words.add(
          SyllableWorksheetWord.fromJson(Map<String, dynamic>.from(e)),
        );
      }
    }
  }
  return SyllableLatestSheet(
    sheetId: sheetId,
    generatedAtIso: genStr,
    words: words,
  );
}

const SyllableWorksheetWord _kBlankWord = SyllableWorksheetWord(
  word: '',
  phonetic: '',
  definition: '',
);

/// 练习纸固定 15 行：取非空单词至多 15 条，不足补空白行。
List<SyllableWorksheetWord> padSyllableWordsForWorksheet(
  List<SyllableWorksheetWord> src,
) {
  final filtered = src
      .where((w) => w.word.trim().isNotEmpty)
      .take(15)
      .toList(growable: true);
  while (filtered.length < 15) {
    filtered.add(_kBlankWord);
  }
  return filtered;
}

int syllableFilledWordCount(List<SyllableWorksheetWord> src) {
  return src.where((w) => w.word.trim().isNotEmpty).length;
}
