/// 后台下发的单条单词（音节分割练习表一行）
class SyllableWorksheetWord {
  const SyllableWorksheetWord({
    required this.word,
    required this.phonetic,
    required this.definition,
  });

  final String word;
  final String phonetic;
  final String definition;

  static String _pickStr(Map<String, dynamic> json, List<String> keys) {
    for (final k in keys) {
      final v = json[k];
      if (v == null) continue;
      final s = v is String ? v : v.toString();
      if (s.isNotEmpty) return s;
    }
    return '';
  }

  /// 与 `后台API需求说明.md` 一致：`word` / `phonetic` / `definition`；并兼容 snake_case 与常见别名。
  factory SyllableWorksheetWord.fromJson(Map<String, dynamic> json) {
    return SyllableWorksheetWord(
      word: _pickStr(json, const [
        'word',
        'text',
        'en',
        'english',
        'wordText',
        'word_text',
      ]),
      phonetic: _pickStr(json, const [
        'phonetic',
        'ipa',
        'phonetics',
        'phoneticSymbol',
        'phonetic_symbol',
      ]),
      definition: _pickStr(json, const [
        'definition',
        'meaning',
        'desc',
        'translation',
        'cn',
        'explain',
      ]),
    );
  }

  Map<String, dynamic> toJson() => {
        'word': word,
        'phonetic': phonetic,
        'definition': definition,
      };
}
