import 'package:flutter/material.dart';

import '../data/dashboard_prototype_models.dart';
import '../layout/home_card_catalog.dart';

const Color kHomeworkTitleColor = Color(0xFFC4A7FF);
const Color kPointsTitleColor = Color(0xFFFF8BC4);
const Color kScoreGreen = Color(0xFF69F0AE);

const EdgeInsets kHomeSummaryCardPadding = EdgeInsets.fromLTRB(10, 10, 10, 8);
const double kHomeSummaryCardRadius = 18;
/// 摘要卡标题行以下内容区最小高度（副标题两行 + 底部提示）。
const double kHomeSummaryBodyMinHeight = 50;
/// 单张摘要卡统一最小高度（含内边距与标题行）。
const double kHomeSummaryCardMinHeight = 98;

/// 摘要卡统一外壳：渐变底 + 圆角。
class HomeSummaryCardShell extends StatelessWidget {
  const HomeSummaryCardShell({
    super.key,
    required this.gradientColors,
    required this.onTap,
    required this.child,
    this.onLongPress,
  });

  final List<Color> gradientColors;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(kHomeSummaryCardRadius),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(kHomeSummaryCardRadius),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradientColors,
            ),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: kHomeSummaryCardMinHeight,
            ),
            child: Padding(
              padding: kHomeSummaryCardPadding,
              child: SizedBox(
                width: double.infinity,
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 摘要卡标题行：图标 + 强调色标题。
class HomeSummaryCardHeader extends StatelessWidget {
  const HomeSummaryCardHeader({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.titleColor,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final Color titleColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 22),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: titleColor,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

/// 各模块摘要卡渐变色与标题/图标强调色。
({List<Color> gradient, Color titleColor, Color iconColor}) homeSummaryCardStyle(
  HomeCardCatalogEntry entry,
) {
  switch (entry.cardId) {
    case 'homework':
      return (
        gradient: [
          const Color(0xFF3D3566).withValues(alpha: 0.95),
          const Color(0xFF252240).withValues(alpha: 0.98),
        ],
        titleColor: kHomeworkTitleColor,
        iconColor: Colors.orange.shade200,
      );
    case 'points':
      return (
        gradient: [
          const Color(0xFF2D4A3E).withValues(alpha: 0.9),
          const Color(0xFF1E2835).withValues(alpha: 0.95),
        ],
        titleColor: kPointsTitleColor,
        iconColor: Colors.greenAccent.shade200,
      );
    default:
      final tint = entry.iconBackground;
      return (
        gradient: [
          Color.alphaBlend(tint.withValues(alpha: 0.38), const Color(0xFF2E2A40)),
          const Color(0xFF252240).withValues(alpha: 0.98),
        ],
        titleColor: Color.lerp(tint, Colors.white, 0.45)!,
        iconColor: Color.lerp(tint, Colors.white, 0.25)!,
      );
  }
}

class HomeHomeworkSummaryCard extends StatelessWidget {
  const HomeHomeworkSummaryCard({
    super.key,
    required this.rows,
    required this.onTap,
    this.onLongPress,
  });

  final List<DashboardHomeworkRow> rows;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final style = homeSummaryCardStyle(
      homeCardCatalogEntry('homework')!,
    );
    return HomeSummaryCardShell(
      gradientColors: style.gradient,
      onTap: onTap,
      onLongPress: onLongPress,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HomeSummaryCardHeader(
            icon: Icons.menu_book_rounded,
            iconColor: style.iconColor,
            title: '作业进度',
            titleColor: style.titleColor,
          ),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: kHomeSummaryBodyMinHeight,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...rows.map(
                  (r) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            r.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          flex: 2,
                          child: Text(
                            r.progressText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.45),
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HomePointsSummaryCard extends StatelessWidget {
  const HomePointsSummaryCard({
    super.key,
    required this.rows,
    required this.onTap,
    this.subtitle,
    this.onLongPress,
  });

  final List<DashboardPointsRow> rows;
  final VoidCallback onTap;
  final String? subtitle;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final style = homeSummaryCardStyle(
      homeCardCatalogEntry('points')!,
    );
    return HomeSummaryCardShell(
      gradientColors: style.gradient,
      onTap: onTap,
      onLongPress: onLongPress,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HomeSummaryCardHeader(
            icon: Icons.sports_esports_rounded,
            iconColor: style.iconColor,
            title: '积分榜',
            titleColor: style.titleColor,
          ),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: kHomeSummaryBodyMinHeight,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  Text(
                    subtitle!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.redAccent.withValues(alpha: 0.9),
                      fontSize: 11,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
                ...rows.map(
                  (r) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            r.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${r.score} 分',
                          style: const TextStyle(
                            color: kScoreGreen,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 无专用摘要 API 的模块：摘要卡降级为说明 + 占位提示。
class HomeGenericSummaryCard extends StatelessWidget {
  const HomeGenericSummaryCard({
    super.key,
    required this.entry,
    required this.onTap,
    this.onLongPress,
  });

  final HomeCardCatalogEntry entry;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final style = homeSummaryCardStyle(entry);

    return HomeSummaryCardShell(
      gradientColors: style.gradient,
      onTap: onTap,
      onLongPress: onLongPress,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HomeSummaryCardHeader(
            icon: entry.icon,
            iconColor: style.iconColor,
            title: entry.title,
            titleColor: style.titleColor,
          ),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: kHomeSummaryBodyMinHeight,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 13,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '点击查看详情',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.35),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HomeThinFeatureCard extends StatelessWidget {
  const HomeThinFeatureCard({
    super.key,
    required this.item,
    required this.onTap,
    this.onLongPress,
  });

  final DashboardLifeMenuItem item;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: item.iconBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(item.icon, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.subtitle,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 12,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right,
                  color: Colors.white.withValues(alpha: 0.28),
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HomeSeparatorTitle extends StatelessWidget {
  const HomeSeparatorTitle({
    super.key,
    required this.title,
    this.topPadding = 12,
  });

  final String title;
  final double topPadding;

  @override
  Widget build(BuildContext context) {
    final label = title.trim().isEmpty ? '未命名' : title.trim();
    return Padding(
      padding: EdgeInsets.only(top: topPadding, bottom: 10),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.85),
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
