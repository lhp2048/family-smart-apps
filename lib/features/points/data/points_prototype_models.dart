/// 积分榜原型：单条规则（加分绿勾 / 扣分黄三角）
class PointsRuleLine {
  const PointsRuleLine({
    required this.isPositive,
    required this.description,
    required this.value,
  });

  final bool isPositive;
  final String description;
  /// 展示用绝对值，正负由 [isPositive] 决定
  final int value;
}

/// 单日流水组（含表头当日两人合计变动）
class PointsDayLogGroup {
  const PointsDayLogGroup({
    required this.dayKey,
    required this.weekdayLabel,
    required this.dayDeltaByMemberCode,
    required this.rows,
  });

  final String dayKey;
  final String weekdayLabel;
  final Map<String, int> dayDeltaByMemberCode;
  final List<PointsLogRow> rows;
}

class PointsLogRow {
  const PointsLogRow({
    required this.time,
    required this.person,
    required this.item,
    required this.pointsDelta,
    required this.remark,
  });

  final String time;
  final String person;
  final String item;
  final int pointsDelta;
  final String remark;
}

/// 一个自然周周期（侧边栏 + 主区周汇总 + 日流水）
class PointsWeekCycle {
  const PointsWeekCycle({
    required this.id,
    required this.rangeShort,
    required this.rangeTitleLong,
    required this.isCurrentWeek,
    required this.totalsByMemberCode,
    required this.netGainByMemberCode,
    required this.dailyLogs,
  });

  final String id;
  final String rangeShort;
  final String rangeTitleLong;
  final bool isCurrentWeek;
  final Map<String, int> totalsByMemberCode;
  /// 相对初始分的净增（如 +20）
  final Map<String, int> netGainByMemberCode;
  final List<PointsDayLogGroup> dailyLogs;
}
