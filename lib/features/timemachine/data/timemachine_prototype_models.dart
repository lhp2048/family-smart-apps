/// 时光机：单条成长记录
class TimemachineEntry {
  const TimemachineEntry({
    required this.id,
    required this.bizDate,
    required this.title,
    required this.body,
  });

  final String id;
  final String bizDate;
  final String title;
  final String body;
}

/// 侧边栏：单日筛选项
class TimemachineSidebarDay {
  const TimemachineSidebarDay({
    required this.bizDate,
    required this.label,
    required this.entryCount,
  });

  final String bizDate;
  final String label;
  final int entryCount;
}

/// 第一行：有数据的年月（monthKey 为 yyyy-MM）
class TimemachineMonthChip {
  const TimemachineMonthChip({
    required this.monthKey,
    required this.label,
    required this.entryCount,
  });

  final String monthKey;
  final String label;
  final int entryCount;
}

/// 主区按月份分组后的块
class TimemachineFeedSection {
  const TimemachineFeedSection({
    required this.monthLabel,
    required this.entries,
  });

  final String monthLabel;
  final List<TimemachineEntry> entries;
}
