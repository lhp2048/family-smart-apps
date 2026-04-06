/// 英语音节 A4 练习卷（[title] 一般为试卷生成日期文案，[subtitle] 为补充说明）
class SyllableSheetItem {
  const SyllableSheetItem({
    required this.id,
    required this.title,
    required this.subtitle,
  });

  final String id;
  /// 列表主标题，如 `2026年4月5日`
  final String title;
  final String subtitle;
}
