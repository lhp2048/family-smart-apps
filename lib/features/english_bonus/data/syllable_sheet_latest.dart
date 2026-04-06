import 'syllable_worksheet_word.dart';

/// `GET /v1/english-bonus/syllable-sheet/latest` 的 `data` 形态（全局最新，不按成员）
class SyllableLatestSheet {
  const SyllableLatestSheet({
    required this.sheetId,
    this.generatedAtIso,
    required this.words,
  });

  final String sheetId;
  final String? generatedAtIso;
  final List<SyllableWorksheetWord> words;
}
