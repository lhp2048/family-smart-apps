import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/dashboard/data/dashboard_prototype_models.dart';
import '../../features/debate/data/debate_prototype_models.dart';
import '../../features/extracurricular/data/extracurricular_models.dart';
import '../../features/points/data/points_prototype_models.dart';
import '../../features/timemachine/data/timemachine_prototype_models.dart';
import '../../features/wishwall/data/wishwall_prototype_models.dart';
import '../../features/tasks/data/models/task_date_entity.dart';
import '../../features/tasks/data/models/task_group_entity.dart';
import '../../features/tasks/data/models/task_item_entity.dart';
import '../../features/tasks/data/task_keys.dart';
import '../../features/tasks/data/task_progress.dart';
import '../../shared/models/feature_entry_entity.dart';
import '../../shared/models/home_summary_entity.dart';
import '../../shared/models/member_entity.dart';
import '../utils/biz_date.dart';

/// 临时假数据（内存），不连 Isar，便于先把 App 跑通
class MockAppState {
  const MockAppState({
    required this.homeSummaries,
    required this.featureEntries,
    required this.members,
    required this.taskDates,
    required this.taskGroups,
    required this.taskItems,
    required this.dashboardHomeworkRows,
    required this.dashboardPointsRows,
    required this.dashboardLifeMenu,
    required this.dashboardSystemMenu,
    required this.pointsRules,
    required this.pointsWeekCycles,
    required this.wishwallItems,
    required this.timemachineEntries,
    required this.debateDayBundles,
    required this.extracurricularItems,
  });

  final Map<String, HomeSummaryEntity> homeSummaries;
  final List<FeatureEntryEntity> featureEntries;
  final List<MemberEntity> members;
  final List<TaskDateEntity> taskDates;
  final List<TaskGroupEntity> taskGroups;
  final List<TaskItemEntity> taskItems;

  /// 首页原型：作业完成卡片
  final List<DashboardHomeworkRow> dashboardHomeworkRows;
  final List<DashboardPointsRow> dashboardPointsRows;
  final List<DashboardLifeMenuItem> dashboardLifeMenu;

  /// 首页：「系统和配置」入口
  final List<DashboardLifeMenuItem> dashboardSystemMenu;

  /// 积分榜：规则与按周流水（原型假数据）
  final List<PointsRuleLine> pointsRules;
  final List<PointsWeekCycle> pointsWeekCycles;

  final List<WishwallItem> wishwallItems;

  final List<TimemachineEntry> timemachineEntries;

  final List<DebateDayBundle> debateDayBundles;

  final List<ExtracurricularItem> extracurricularItems;

  MockAppState copyWith({
    Map<String, HomeSummaryEntity>? homeSummaries,
    List<FeatureEntryEntity>? featureEntries,
    List<MemberEntity>? members,
    List<TaskDateEntity>? taskDates,
    List<TaskGroupEntity>? taskGroups,
    List<TaskItemEntity>? taskItems,
    List<DashboardHomeworkRow>? dashboardHomeworkRows,
    List<DashboardPointsRow>? dashboardPointsRows,
    List<DashboardLifeMenuItem>? dashboardLifeMenu,
    List<DashboardLifeMenuItem>? dashboardSystemMenu,
    List<PointsRuleLine>? pointsRules,
    List<PointsWeekCycle>? pointsWeekCycles,
    List<WishwallItem>? wishwallItems,
    List<TimemachineEntry>? timemachineEntries,
    List<DebateDayBundle>? debateDayBundles,
    List<ExtracurricularItem>? extracurricularItems,
  }) {
    return MockAppState(
      homeSummaries: homeSummaries ?? this.homeSummaries,
      featureEntries: featureEntries ?? this.featureEntries,
      members: members ?? this.members,
      taskDates: taskDates ?? this.taskDates,
      taskGroups: taskGroups ?? this.taskGroups,
      taskItems: taskItems ?? this.taskItems,
      dashboardHomeworkRows:
          dashboardHomeworkRows ?? this.dashboardHomeworkRows,
      dashboardPointsRows: dashboardPointsRows ?? this.dashboardPointsRows,
      dashboardLifeMenu: dashboardLifeMenu ?? this.dashboardLifeMenu,
      dashboardSystemMenu:
          dashboardSystemMenu ?? this.dashboardSystemMenu,
      pointsRules: pointsRules ?? this.pointsRules,
      pointsWeekCycles: pointsWeekCycles ?? this.pointsWeekCycles,
      wishwallItems: wishwallItems ?? this.wishwallItems,
      timemachineEntries: timemachineEntries ?? this.timemachineEntries,
      debateDayBundles: debateDayBundles ?? this.debateDayBundles,
      extracurricularItems: extracurricularItems ?? this.extracurricularItems,
    );
  }

  /// 作业页假数据：按历史日索引与任务索引生成完成状态
  static bool _homeworkSeedDone(int dayIndex, int taskIndex) {
    if (dayIndex == 1) return taskIndex < 2;
    if (dayIndex == 2) return true;
    if (dayIndex == 0) return taskIndex < 3;
    return taskIndex == 0;
  }

  static String _homeworkSeedTime(int taskIndex) {
    const times = <String>[
      '22:38',
      '21:05',
      '20:12',
      '19:40',
      '18:30',
      '17:15',
      '16:00',
    ];
    final i = taskIndex.clamp(0, times.length - 1);
    return times[i];
  }

  static MockAppState initial() {
    final now = DateTime.now();

    final members = <MemberEntity>[
      MemberEntity()
        ..memberCode = 'parent1'
        ..name = '家长'
        ..role = 'parent'
        ..status = 'active'
        ..createdAt = now
        ..updatedAt = now,
      MemberEntity()
        ..memberCode = 'xixi'
        ..name = '曦曦'
        ..avatar = '👧'
        ..role = 'child'
        ..status = 'active'
        ..createdAt = now
        ..updatedAt = now,
      MemberEntity()
        ..memberCode = 'chuan'
        ..name = '川川'
        ..avatar = '👦'
        ..role = 'child'
        ..status = 'active'
        ..createdAt = now
        ..updatedAt = now,
      MemberEntity()
        ..memberCode = 'mx'
        ..name = 'mx'
        ..avatar = '👦'
        ..role = 'parent'
        ..status = 'active'
        ..createdAt = now
        ..updatedAt = now,
    ];

    final features = <FeatureEntryEntity>[
      FeatureEntryEntity()
        ..entryKey = 'tasks'
        ..title = '作业完成情况'
        ..icon = 'fact_check_outlined'
        ..sort = 10
        ..enabled = true
        ..updatedAt = now,
      FeatureEntryEntity()
        ..entryKey = 'points'
        ..title = '积分榜'
        ..icon = 'emoji_events_outlined'
        ..sort = 20
        ..enabled = true
        ..updatedAt = now,
      FeatureEntryEntity()
        ..entryKey = 'wishwall'
        ..title = '心愿墙'
        ..icon = 'favorite_border'
        ..sort = 30
        ..enabled = true
        ..updatedAt = now,
      FeatureEntryEntity()
        ..entryKey = 'timemachine'
        ..title = '时光机'
        ..icon = 'history_edu_outlined'
        ..sort = 40
        ..enabled = true
        ..updatedAt = now,
      FeatureEntryEntity()
        ..entryKey = 'debate'
        ..title = '话题辩论'
        ..icon = 'forum_outlined'
        ..sort = 50
        ..enabled = true
        ..updatedAt = now,
    ];

    final dates = <TaskDateEntity>[];
    for (var i = 0; i < 7; i++) {
      final d = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: i));
      final bd = formatBizDate(d);
      dates.add(
        TaskDateEntity()
          ..bizDate = bd
          ..weekday = weekdayCn(d)
          ..hasReward = false
          ..updatedAt = now,
      );
    }

    const homeworkTaskDefs = <(String, String)>[
      ('t1', '学校作业'),
      ('t2', '学习机同步练习'),
      ('t3', '英语音标练习'),
      ('t4', '数学思维训练'),
      ('t5', '语文阅读打卡'),
      ('t6', '科学小实验'),
      ('t7', '课外阅读 30 分钟'),
    ];

    var allGroups = <TaskGroupEntity>[];
    var allItems = <TaskItemEntity>[];

    for (var dayIndex = 0; dayIndex < dates.length; dayIndex++) {
      final bd = dates[dayIndex].bizDate;
      allGroups.add(
        TaskGroupEntity()
          ..bizDateGroupKey = taskGroupKey(bd, 'homework')
          ..bizDate = bd
          ..groupCode = 'homework'
          ..title = '作业'
          ..progress = 0
          ..sort = 1
          ..updatedAt = now,
      );

      for (var ti = 0; ti < homeworkTaskDefs.length; ti++) {
        final pair = homeworkTaskDefs[ti];
        final code = pair.$1;
        final name = pair.$2;
        final xixiDone = _homeworkSeedDone(dayIndex, ti);
        final chuanDone = _homeworkSeedDone(dayIndex, ti);
        final at = <String, String>{};
        if (xixiDone) {
          at['xixi'] = _homeworkSeedTime(ti);
        }
        if (chuanDone) {
          at['chuan'] = _homeworkSeedTime((ti + 2) % homeworkTaskDefs.length);
        }
        allItems.add(
          TaskItemEntity()
            ..bizDateGroupTaskKey = taskItemKey(bd, 'homework', code)
            ..bizDate = bd
            ..groupCode = 'homework'
            ..taskCode = code
            ..name = name
            ..score = 1
            ..statusByMemberJson = jsonEncode(<String, bool>{
              'xixi': xixiDone,
              'chuan': chuanDone,
            })
            ..completedAtByMemberJson = jsonEncode(at)
            ..sort = ti + 1
            ..updatedAt = now,
        );
      }

      allGroups = _withGroupProgress(allGroups, allItems, bd, 'homework');
    }

    for (var i = 0; i < dates.length; i++) {
      final bd = dates[i].bizDate;
      final dayItems = allItems.where((e) => e.bizDate == bd).toList();
      var fully = false;
      if (dayItems.isNotEmpty) {
        fully = dayItems.every((e) {
          final st = jsonDecode(e.statusByMemberJson) as Map<String, dynamic>;
          return st['xixi'] == true && st['chuan'] == true;
        });
      }
      dates[i].hasReward = fully;
    }

    final summaries = <String, HomeSummaryEntity>{};
    for (final dt in dates) {
      final bd = dt.bizDate;
      final dayItems = allItems.where((e) => e.bizDate == bd).toList();
      summaries[bd] = HomeSummaryEntity()
        ..bizDate = bd
        ..taskProgress = computeDayTaskProgress(dayItems)
        ..memberScoresJson = jsonEncode(<String, int>{'xixi': 65, 'chuan': 80})
        ..updatedAt = now;
    }

    const homeworkRows = [
      DashboardHomeworkRow('曦曦', '-/-'),
      DashboardHomeworkRow('川川', '-/-'),
    ];
    const pointsRows = [
      DashboardPointsRow('曦曦', 65),
      DashboardPointsRow('川川', 80),
    ];
    final lifeMenu = <DashboardLifeMenuItem>[
      const DashboardLifeMenuItem(
        title: '心愿墙',
        subtitle: '许下心愿 · 记录美好期待',
        icon: Icons.star_rounded,
        iconBackground: Color(0xFFFFCA28),
        badgeLabel: '2 待实现',
        badgeColor: Color(0xFF7C4DFF),
        route: '/wishwall',
      ),
      const DashboardLifeMenuItem(
        title: '时光机',
        subtitle: '家庭故事 · 成长瞬间',
        icon: Icons.hourglass_empty_rounded,
        iconBackground: Color(0xFF90CAF9),
        badgeLabel: '回忆',
        badgeColor: Color(0xFFFFD54F),
        route: '/timemachine',
      ),
      const DashboardLifeMenuItem(
        title: '话题辩论',
        subtitle: '每日话题 · 边吃边聊',
        icon: Icons.restaurant_menu_rounded,
        iconBackground: Color(0xFFFFAB91),
        badgeLabel: '辩论',
        badgeColor: Color(0xFFFF9800),
        route: '/debate',
      ),
      const DashboardLifeMenuItem(
        title: '加分提升',
        subtitle: '训练试卷 · 在线答题',
        icon: Icons.edit_note_rounded,
        iconBackground: Color(0xFF81D4FA),
        badgeLabel: '练习',
        badgeColor: Color(0xFF42A5F5),
        route: '/english-bonus',
      ),
      const DashboardLifeMenuItem(
        title: '精彩课外',
        subtitle: '黄金屋 · 第七艺术 · 动漫 · 更多',
        icon: Icons.auto_stories_rounded,
        iconBackground: Color(0xFFEF9A9A),
        badgeLabel: '推荐',
        badgeColor: Color(0xFFFF5252),
        route: '/extra-curricular',
      ),
    ];

    const systemMenu = <DashboardLifeMenuItem>[
      DashboardLifeMenuItem(
        title: '设置',
        subtitle: '应用偏好、通知与关于',
        icon: Icons.settings_rounded,
        iconBackground: Color(0xFF546E7A),
        route: '/settings',
      ),
    ];

    const pointsRules = <PointsRuleLine>[
      PointsRuleLine(isPositive: true, description: '7:10 前起床', value: 5),
      PointsRuleLine(isPositive: true, description: '19:30 前完成作业', value: 15),
      PointsRuleLine(isPositive: true, description: '20:00 前完成作业', value: 10),
      PointsRuleLine(isPositive: true, description: '20:30 前完成作业', value: 5),
      PointsRuleLine(isPositive: true, description: '老师表扬 / 获奖', value: 15),
      PointsRuleLine(isPositive: true, description: '竞赛活动', value: 5),
      PointsRuleLine(isPositive: false, description: '21:30 作业未完成', value: 5),
      PointsRuleLine(isPositive: false, description: '22:00 未入睡', value: 5),
      PointsRuleLine(isPositive: false, description: '被老师点名 / 争吵', value: 10),
    ];

    final pointsWeekCycles = <PointsWeekCycle>[
      const PointsWeekCycle(
        id: 'w2026_0330_0405',
        rangeShort: '03.30—04.05',
        rangeTitleLong: '2026年03月30日 — 04月05日',
        isCurrentWeek: true,
        totalsByMemberCode: {'xixi': 65, 'chuan': 80},
        netGainByMemberCode: {'xixi': 20, 'chuan': 35},
        dailyLogs: [
          PointsDayLogGroup(
            dayKey: '03-30',
            weekdayLabel: '周一',
            dayDeltaByMemberCode: {'xixi': 0, 'chuan': 5},
            rows: [
              PointsLogRow(
                time: '20:20',
                person: '川川',
                item: '完成作业',
                pointsDelta: 5,
                remark: '20:30 前完成 6/7 项作业',
              ),
            ],
          ),
          PointsDayLogGroup(
            dayKey: '03-31',
            weekdayLabel: '周二',
            dayDeltaByMemberCode: {'xixi': 5, 'chuan': 20},
            rows: [
              PointsLogRow(
                time: '19:22',
                person: '川川',
                item: '完成作业',
                pointsDelta: 15,
                remark: '19:30 前完成全部 7/7 作业',
              ),
              PointsLogRow(
                time: '07:14',
                person: '曦曦/川川',
                item: '早起',
                pointsDelta: 5,
                remark: '7:30 前起床',
              ),
            ],
          ),
        ],
      ),
      const PointsWeekCycle(
        id: 'w2026_0323_0329',
        rangeShort: '03.23—03.29',
        rangeTitleLong: '2026年03月23日 — 03月29日',
        isCurrentWeek: false,
        totalsByMemberCode: {'xixi': 45, 'chuan': 30},
        netGainByMemberCode: {'xixi': 0, 'chuan': -15},
        dailyLogs: [],
      ),
      const PointsWeekCycle(
        id: 'w2026_0316_0322',
        rangeShort: '03.16—03.22',
        rangeTitleLong: '2026年03月16日 — 03月22日',
        isCurrentWeek: false,
        totalsByMemberCode: {'xixi': 45, 'chuan': 45},
        netGainByMemberCode: {'xixi': 0, 'chuan': 0},
        dailyLogs: [],
      ),
    ];

    const wishwallItems = <WishwallItem>[
      WishwallItem(
        id: 'w1',
        memberCode: 'chuan',
        content: '如果能减肥10斤，妈妈说给一笔零花钱💰',
        cardEmoji: '💪',
        fulfilled: false,
        createdAtLabel: '2026-03-31 23:22',
      ),
      WishwallItem(
        id: 'w2',
        memberCode: 'chuan',
        content: '每周末陪爸爸去遛弯，坚持一个月，就能得到一辆自行车🚲',
        cardEmoji: '🚲',
        fulfilled: false,
        createdAtLabel: '2026-03-31 23:22',
      ),
    ];

    const timemachineEntries = <TimemachineEntry>[
      TimemachineEntry(
        id: 'tm1',
        bizDate: '2026-04-01',
        title: '4月1日 🏀 篮球场上的小明星',
        body:
            '今天下午带曦曦去社区篮球场，她一进门眼睛就亮了。练习赛里，她第一次成功断到了球，朝我大喊：「爸爸！我会抢球啦！」✨\n\n'
            '回家路上她还在比划运球动作。看着她从不爱到敢上场，我们觉得，自信和敢于尝试，比进球数珍贵得多。🏆',
      ),
      TimemachineEntry(
        id: 'tm2',
        bizDate: '2026-04-01',
        title: '4月1日 🌸 晚饭桌旁的笑声',
        body: '晚上一家人围坐吃饭，曦曦主动讲了学校里的趣事，川川则科普起了篮球规则。妈妈说：「今天家里气氛💯。」',
      ),
      TimemachineEntry(
        id: 'tm3',
        bizDate: '2026-03-30',
        title: '新的一周，双双在线 🌟',
        body:
            '这一周开局不错：川川和曦曦都能在晚上八点前把作业收尾。英语听读两人都打卡了，数学订正也及时完成。\n\n'
            '反思：把时间切成小块、先难后易，效率明显提高。希望把这种节奏坚持成习惯。💪',
      ),
      TimemachineEntry(
        id: 'tm4',
        bizDate: '2026-03-28',
        title: '3月28日 📚 图书馆半日',
        body: '周末上午泡图书馆，各自挑了感兴趣的书。川川迷上了科普，曦曦读完了半本桥梁书。',
      ),
      TimemachineEntry(
        id: 'tm5',
        bizDate: '2026-03-28',
        title: '3月28日 🎨 随手画的小创作',
        body: '下午自由画画时间，曦曦画了一幅「全家去野餐」，配色大胆，被贴在了冰箱上。',
      ),
      TimemachineEntry(
        id: 'tm6',
        bizDate: '2026-03-25',
        title: '3月25日 🎹 练琴小进步',
        body: '曦曦曲子终于连贯了一遍，虽然还有错音，但态度很认真，自己要求再练两遍。',
      ),
      TimemachineEntry(
        id: 'tm7',
        bizDate: '2026-03-22',
        title: '3月22日 🏃 黄昏跑步',
        body: '全家下楼慢跑两圈，川川配速最稳，曦曦最后一公里坚持没停。',
      ),
      TimemachineEntry(
        id: 'tm8',
        bizDate: '2026-03-22',
        title: '3月22日 🥣 厨房小帮手',
        body: '川川帮忙洗菜、摆盘，说「下次想学煎蛋」。',
      ),
      TimemachineEntry(
        id: 'tm9',
        bizDate: '2026-03-18',
        title: '3月18日 ✅ 单科小测反馈',
        body: '数学老师留言表扬计算准确率提高，回家一起复盘了错题本。',
      ),
      TimemachineEntry(
        id: 'tm10',
        bizDate: '2026-03-15',
        title: '3月15日 🌙 睡前聊天',
        body: '聊了「最想去的三个地方」，两人答案截然不同，笑作一团。',
      ),
    ];

    const debateGuideSteps = <String>['主持人读题目', '选择立场', '陈述理由', '换边辩论', '总结'];

    const debateDayBundles = <DebateDayBundle>[
      DebateDayBundle(
        bizDate: '2026-03-26',
        mainTitle: '饭桌话题辩论',
        scheduleHint: '2026年03月26日 · 每天17:00更新',
        guideSteps: debateGuideSteps,
        topics: [
          DebateTopicItem(
            id: 'd1',
            categoryTag: '哲思与价值观',
            topicIndex: 1,
            question: '成功是靠努力还是运气？',
            proBody: '努力决定下限、运气决定上限、持续努力创造机会。',
            conBody: '机遇很重要、环境因素大、有时努力未必有结果。',
          ),
          DebateTopicItem(
            id: 'd2',
            categoryTag: '生活与健康',
            topicIndex: 2,
            question: '小学生该不该自己管零花钱？',
            proBody: '从小学习规划与责任，适度试错更懂金钱价值。',
            conBody: '自控力尚不成熟，家长引导更稳妥，避免攀比。',
          ),
        ],
      ),
      DebateDayBundle(
        bizDate: '2026-03-25',
        mainTitle: '饭桌话题辩论',
        scheduleHint: '2026年03月25日 · 每天17:00更新',
        guideSteps: debateGuideSteps,
        topics: [
          DebateTopicItem(
            id: 'd3',
            categoryTag: '学习与成长',
            topicIndex: 1,
            question: '周末应该先玩还是先写作业？',
            proBody: '先完成作业心里踏实，玩得更尽兴。',
            conBody: '适度放松后效率更高，要尊重孩子的节奏。',
          ),
        ],
      ),
      DebateDayBundle(
        bizDate: '2026-03-24',
        mainTitle: '饭桌话题辩论',
        scheduleHint: '2026年03月24日 · 每天17:00更新',
        guideSteps: debateGuideSteps,
        topics: [
          DebateTopicItem(
            id: 'd4',
            categoryTag: '家庭与社会',
            topicIndex: 1,
            question: '做家务算不算孩子的义务？',
            proBody: '家是共同的，分担家务培养责任感。',
            conBody: '学业压力大时，应以学习为主、家务量力而行。',
          ),
        ],
      ),
    ];

    const extracurricularItems = <ExtracurricularItem>[
      ExtracurricularItem(
        id: 'ec1',
        title: '家有儿女',
        filterId: ExtracurricularFilterIds.tv,
        mediumKind: ExtracurricularMediumKind.tvSeries,
        mediumLabel: '电视剧',
        year: 2005,
        genre: '家庭/喜剧',
        ratingStars: 5,
        description: '重组家庭的日常爆笑与温情，适合全家一起看，轻松讨论亲子关系与成长话题。',
        emoji: '🏠',
        watched: false,
      ),
      ExtracurricularItem(
        id: 'ec2',
        title: '奔跑吧',
        filterId: ExtracurricularFilterIds.doc,
        mediumKind: ExtracurricularMediumKind.documentary,
        mediumLabel: '纪录片/其他',
        year: 2014,
        genre: '真人秀/竞技',
        ratingStars: 4,
        description: '户外竞技与团队协作，可看团队合作与坚持，家长可引导孩子聊「规则与公平」。',
        emoji: '🏃',
        watched: false,
      ),
      ExtracurricularItem(
        id: 'ec3',
        title: '主持人大赛',
        filterId: ExtracurricularFilterIds.doc,
        mediumKind: ExtracurricularMediumKind.documentary,
        mediumLabel: '纪录片/其他',
        year: 2019,
        genre: '竞技/演讲',
        ratingStars: 5,
        description: '专业主持与即兴表达的高水平对决，适合启发孩子的语言组织与临场反应。',
        emoji: '🎤',
        watched: false,
      ),
      ExtracurricularItem(
        id: 'ec4',
        title: '十三邀',
        filterId: ExtracurricularFilterIds.doc,
        mediumKind: ExtracurricularMediumKind.documentary,
        mediumLabel: '纪录片/其他',
        year: 2016,
        genre: '访谈/人文',
        ratingStars: 5,
        description: '深度对话不同领域人物，拓展视野，适合高年级亲子共赏后讨论价值观。',
        emoji: '🎙️',
        watched: false,
      ),
      ExtracurricularItem(
        id: 'ec5',
        title: '开讲啦',
        filterId: ExtracurricularFilterIds.doc,
        mediumKind: ExtracurricularMediumKind.documentary,
        mediumLabel: '纪录片/其他',
        year: 2012,
        genre: '演讲/青年',
        ratingStars: 4,
        description: '青年公开课形式，嘉宾分享人生选择与坚持，可联系孩子的目标与兴趣。',
        emoji: '📣',
        watched: false,
      ),
      ExtracurricularItem(
        id: 'ec6',
        title: '新国辩',
        filterId: ExtracurricularFilterIds.doc,
        mediumKind: ExtracurricularMediumKind.documentary,
        mediumLabel: '纪录片/其他',
        year: 2013,
        genre: '辩论/思辨',
        ratingStars: 5,
        description: '华语辩论赛事精选，逻辑与表达并重，可与家庭「话题辩论」联动观看。',
        emoji: '⚖️',
        watched: false,
      ),
      ExtracurricularItem(
        id: 'ec7',
        title: '我的团长我的团',
        filterId: ExtracurricularFilterIds.tv,
        mediumKind: ExtracurricularMediumKind.tvSeries,
        mediumLabel: '电视剧',
        year: 2009,
        genre: '战争/人性',
        ratingStars: 5,
        description: '群像刻画深刻，适合家长遴选片段与孩子讨论勇气、责任与历史感受。',
        emoji: '📦',
        watched: false,
      ),
      ExtracurricularItem(
        id: 'ec8',
        title: '指环王：护戒使者',
        filterId: ExtracurricularFilterIds.seventh,
        mediumKind: ExtracurricularMediumKind.movie,
        mediumLabel: '电影',
        year: 2001,
        genre: '奇幻/史诗',
        ratingStars: 5,
        description: '经典奇幻三部曲开篇，友情与使命主题突出，可按年龄段分次观看。',
        emoji: '💍',
        watched: false,
      ),
      ExtracurricularItem(
        id: 'ec9',
        title: '指环王：双塔奇兵',
        filterId: ExtracurricularFilterIds.seventh,
        mediumKind: ExtracurricularMediumKind.movie,
        mediumLabel: '电影',
        year: 2002,
        genre: '奇幻/史诗',
        ratingStars: 5,
        description: '中段战役与角色成长高潮迭起，建议与第一部连贯观看体验更佳。',
        emoji: '🗼',
        watched: false,
      ),
      ExtracurricularItem(
        id: 'ec10',
        title: '哈利·波特与魔法石',
        filterId: ExtracurricularFilterIds.golden,
        mediumKind: ExtracurricularMediumKind.book,
        mediumLabel: '图书',
        year: 2000,
        genre: '奇幻/成长',
        ratingStars: 5,
        description: '魔法世界入门篇，可亲子共读或先看片再读书，激发阅读兴趣。',
        emoji: '📖',
        watched: true,
      ),
      ExtracurricularItem(
        id: 'ec11',
        title: '罗小黑战记',
        filterId: ExtracurricularFilterIds.anime,
        mediumKind: ExtracurricularMediumKind.anime,
        mediumLabel: '动漫',
        year: 2019,
        genre: '动画/冒险',
        ratingStars: 5,
        description: '国漫治愈系代表作之一，画风清新，适合全家轻松观看。',
        emoji: '🐱',
        watched: false,
      ),
    ];

    return MockAppState(
      homeSummaries: summaries,
      featureEntries: features,
      members: members,
      taskDates: dates,
      taskGroups: allGroups,
      taskItems: allItems,
      dashboardHomeworkRows: homeworkRows,
      dashboardPointsRows: pointsRows,
      dashboardLifeMenu: lifeMenu,
      dashboardSystemMenu: systemMenu,
      pointsRules: pointsRules,
      pointsWeekCycles: pointsWeekCycles,
      wishwallItems: wishwallItems,
      timemachineEntries: timemachineEntries,
      debateDayBundles: debateDayBundles,
      extracurricularItems: extracurricularItems,
    );
  }

  List<TaskGroupEntity> taskGroupsFor(String bizDate) {
    final list = taskGroups.where((g) => g.bizDate == bizDate).toList();
    list.sort((a, b) => a.sort.compareTo(b.sort));
    return list;
  }

  List<TaskItemEntity> taskItemsFor(String bizDate, String groupCode) {
    final list = taskItems
        .where((e) => e.bizDate == bizDate && e.groupCode == groupCode)
        .toList();
    list.sort((a, b) => a.sort.compareTo(b.sort));
    return list;
  }

  static List<TaskGroupEntity> _withGroupProgress(
    List<TaskGroupEntity> groups,
    List<TaskItemEntity> items,
    String bizDate,
    String groupCode,
  ) {
    final list =
        items
            .where((e) => e.bizDate == bizDate && e.groupCode == groupCode)
            .toList()
          ..sort((a, b) => a.sort.compareTo(b.sort));
    final p = computeTaskGroupProgress(list);
    return groups.map((g) {
      if (g.bizDate == bizDate && g.groupCode == groupCode) {
        g.progress = p;
        return g;
      }
      return g;
    }).toList();
  }
}

class MockDataNotifier extends Notifier<MockAppState> {
  @override
  MockAppState build() => MockAppState.initial();

  void toggleMemberStatus({
    required String bizDate,
    required String groupCode,
    required String taskCode,
    required String memberCode,
  }) {
    final key = taskItemKey(bizDate, groupCode, taskCode);
    final items = state.taskItems.map((e) {
      if (e.bizDateGroupTaskKey != key) return e;
      final map = Map<String, dynamic>.from(
        jsonDecode(e.statusByMemberJson) as Map<dynamic, dynamic>,
      );
      final cur = map[memberCode] == true;
      final newDone = !cur;
      map[memberCode] = newDone;
      Map<String, dynamic> atMap = {};
      try {
        atMap = Map<String, dynamic>.from(
          jsonDecode(e.completedAtByMemberJson) as Map<dynamic, dynamic>,
        );
      } catch (_) {}
      if (newDone) {
        final t = DateTime.now();
        atMap[memberCode] =
            '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
      } else {
        atMap.remove(memberCode);
      }
      final copy = TaskItemEntity()
        ..bizDateGroupTaskKey = e.bizDateGroupTaskKey
        ..bizDate = e.bizDate
        ..groupCode = e.groupCode
        ..taskCode = e.taskCode
        ..name = e.name
        ..score = e.score
        ..statusByMemberJson = jsonEncode(map)
        ..completedAtByMemberJson = jsonEncode(atMap)
        ..sort = e.sort
        ..updatedAt = DateTime.now();
      return copy;
    }).toList();

    var groups = List<TaskGroupEntity>.from(state.taskGroups);
    groups = MockAppState._withGroupProgress(groups, items, bizDate, groupCode);

    final dayItems = items.where((e) => e.bizDate == bizDate).toList();
    final dayP = computeDayTaskProgress(dayItems);
    final summaries = Map<String, HomeSummaryEntity>.from(state.homeSummaries);
    final prev = summaries[bizDate];
    if (prev != null) {
      summaries[bizDate] = HomeSummaryEntity()
        ..bizDate = prev.bizDate
        ..taskProgress = dayP
        ..memberScoresJson = prev.memberScoresJson
        ..updatedAt = DateTime.now();
    } else {
      summaries[bizDate] = HomeSummaryEntity()
        ..bizDate = bizDate
        ..taskProgress = dayP
        ..memberScoresJson = '{}'
        ..updatedAt = DateTime.now();
    }

    state = state.copyWith(
      taskItems: items,
      taskGroups: groups,
      homeSummaries: summaries,
    );
  }
}

final mockDataNotifierProvider =
    NotifierProvider<MockDataNotifier, MockAppState>(MockDataNotifier.new);
