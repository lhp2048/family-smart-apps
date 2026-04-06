import 'biz_date.dart';

/// 以 [anchor] 所在周为范围：周一 00:00 所在日 ～ 周日，返回 `YYYY-MM-DD`。
({String periodStart, String periodEnd}) currentWeekPeriodStrings(
  DateTime anchor,
) {
  final local = DateTime(anchor.year, anchor.month, anchor.day);
  final monday = local.subtract(Duration(days: local.weekday - 1));
  final sunday = monday.add(const Duration(days: 6));
  return (
    periodStart: formatBizDate(monday),
    periodEnd: formatBizDate(sunday),
  );
}
