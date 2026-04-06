/// 本地记录的「已生成」音节练习卷（按自然日一条；与后台生成结果对应后可扩展字段）
class SyllableGeneratedSheetRecord {
  const SyllableGeneratedSheetRecord({
    required this.sheetDateId,
    required this.generatedAt,
  });

  /// yyyyMMdd
  final String sheetDateId;
  final DateTime generatedAt;
}
