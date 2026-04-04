/// 业务日 `YYYY-MM-DD`
String formatBizDate(DateTime d) {
  final y = d.year.toString().padLeft(4, '0');
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '$y-$m-$day';
}

const _weekdaysCn = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];

String weekdayCn(DateTime d) => _weekdaysCn[d.weekday - 1];
