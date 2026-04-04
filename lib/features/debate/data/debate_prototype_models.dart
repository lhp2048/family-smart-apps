/// 单日下的一个辩题卡片
class DebateTopicItem {
  const DebateTopicItem({
    required this.id,
    required this.categoryTag,
    required this.topicIndex,
    required this.question,
    required this.proBody,
    required this.conBody,
  });

  final String id;
  final String categoryTag;
  final int topicIndex;
  final String question;
  final String proBody;
  final String conBody;
}

/// 某业务日的一整套辩论内容（侧边栏选中日）
class DebateDayBundle {
  const DebateDayBundle({
    required this.bizDate,
    required this.mainTitle,
    required this.scheduleHint,
    required this.guideSteps,
    required this.topics,
  });

  final String bizDate;
  final String mainTitle;
  /// 如：2026年03月26日 · 每天17:00更新
  final String scheduleHint;
  final List<String> guideSteps;
  final List<DebateTopicItem> topics;
}
