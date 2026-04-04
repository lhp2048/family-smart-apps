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

/// 侧边栏：月份下的日期行
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

class TimemachineSidebarSection {
  const TimemachineSidebarSection({
    required this.monthLabel,
    required this.days,
  });

  final String monthLabel;
  final List<TimemachineSidebarDay> days;
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
