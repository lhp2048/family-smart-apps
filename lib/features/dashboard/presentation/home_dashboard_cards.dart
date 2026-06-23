import 'package:flutter/material.dart';

import '../data/dashboard_prototype_models.dart';
import '../data/home_card_preview_models.dart';
import '../../calendar/models/calendar_models.dart';
import '../layout/home_card_catalog.dart';
import '../layout/home_layout_models.dart';

const Color kHomeworkTitleColor = Color(0xFFC4A7FF);
const Color kPointsTitleColor = Color(0xFFFF8BC4);
const Color kScoreGreen = Color(0xFF69F0AE);

const EdgeInsets kHomeSummaryCardPadding = EdgeInsets.fromLTRB(10, 10, 10, 8);
const double kHomeSummaryCardPaddingTop = 10;
const double kHomeSummaryCardPaddingBottom = 8;
const double kHomeSummaryCardRadius = 18;
/// 摘要卡单行数据区高度（与作业/积分列表行一致，含行间距）。
const double kHomeSummaryDataRowHeight = 23;
/// 摘要卡默认数据行数（与作业/积分首页展示对齐）。
const int kHomeSummaryDefaultDataRows = 3;
/// 摘要卡标题行以下内容区最小高度。
const double kHomeSummaryBodyMinHeight =
    kHomeSummaryDataRowHeight * kHomeSummaryDefaultDataRows;
/// 单张摘要卡统一最小高度（含内边距与标题行）。
const double kHomeSummaryCardMinHeight = kHomeSummaryCardPaddingTop +
    22 +
    8 +
    kHomeSummaryBodyMinHeight +
    kHomeSummaryCardPaddingBottom;
/// 大号摘要卡最小高度（中号的 2 倍）。
const double kHomeLargeSummaryCardMinHeight = kHomeSummaryCardMinHeight * 2;

/// 小号卡片一行最多数量。
const int kHomeSmallCardsMaxPerRow = 4;

/// 小号卡片横向间距。
const double kHomeSmallCardGap = 8;

/// 小卡 hint 行占位高度（含与标题间距 2px），无 preview 时也保留以保持同行等高。
const double kHomeSmallCardHintBlockHeight = 13;

double homeSummaryShellMinHeight(HomeCardSize size) =>
    size.isLarge ? kHomeLargeSummaryCardMinHeight : kHomeSummaryCardMinHeight;

double homeSummaryBodyMinHeight(HomeCardSize size) =>
    size.isLarge ? kHomeSummaryBodyMinHeight * 2 : kHomeSummaryBodyMinHeight;

/// 摘要卡统一外壳：渐变底 + 圆角。
class HomeSummaryCardShell extends StatelessWidget {
  const HomeSummaryCardShell({
    super.key,
    required this.gradientColors,
    required this.onTap,
    required this.child,
    this.onLongPress,
    this.cardSize = HomeCardSize.medium,
  });

  final List<Color> gradientColors;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final Widget child;
  final HomeCardSize cardSize;

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
            constraints: BoxConstraints(
              minHeight: homeSummaryShellMinHeight(cardSize),
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
    case 'calendar':
      return (
        gradient: [
          const Color(0xFF2A3350).withValues(alpha: 0.95),
          const Color(0xFF1E2438).withValues(alpha: 0.98),
        ],
        titleColor: const Color(0xFF9FA8DA),
        iconColor: const Color(0xFF7986CB),
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
    this.cardSize = HomeCardSize.medium,
  });

  final List<DashboardHomeworkRow> rows;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final HomeCardSize cardSize;

  @override
  Widget build(BuildContext context) {
    final style = homeSummaryCardStyle(
      homeCardCatalogEntry('homework')!,
    );
    return HomeSummaryCardShell(
      gradientColors: style.gradient,
      onTap: onTap,
      onLongPress: onLongPress,
      cardSize: cardSize,
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
            constraints: BoxConstraints(
              minHeight: homeSummaryBodyMinHeight(cardSize),
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
    this.cardSize = HomeCardSize.medium,
  });

  final List<DashboardPointsRow> rows;
  final VoidCallback onTap;
  final String? subtitle;
  final VoidCallback? onLongPress;
  final HomeCardSize cardSize;

  @override
  Widget build(BuildContext context) {
    final style = homeSummaryCardStyle(
      homeCardCatalogEntry('points')!,
    );
    return HomeSummaryCardShell(
      gradientColors: style.gradient,
      onTap: onTap,
      onLongPress: onLongPress,
      cardSize: cardSize,
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
            constraints: BoxConstraints(
              minHeight: homeSummaryBodyMinHeight(cardSize),
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

class HomeCalendarSummaryCard extends StatelessWidget {
  const HomeCalendarSummaryCard({
    super.key,
    required this.highlights,
    required this.onTap,
    this.onLongPress,
    this.cardSize = HomeCardSize.medium,
  });

  final List<CalendarHighlight> highlights;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final HomeCardSize cardSize;

  @override
  Widget build(BuildContext context) {
    final style = homeSummaryCardStyle(
      homeCardCatalogEntry('calendar')!,
    );
    return HomeSummaryCardShell(
      gradientColors: style.gradient,
      onTap: onTap,
      onLongPress: onLongPress,
      cardSize: cardSize,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HomeSummaryCardHeader(
            icon: Icons.calendar_month_rounded,
            iconColor: style.iconColor,
            title: '家庭日历',
            titleColor: style.titleColor,
          ),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: homeSummaryBodyMinHeight(cardSize),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (highlights.isEmpty)
                  Text(
                    '今日暂无日程记录',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.45),
                      fontSize: 13,
                    ),
                  )
                else
                  ...highlights.take(cardSize.isLarge ? 8 : 3).map(
                        (h) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  h.label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              if (h.detail.isNotEmpty)
                                Text(
                                  h.detail,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.4),
                                    fontSize: 11,
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

/// 按 API preview presentation 渲染摘要正文。
class HomeCardPreviewBody extends StatelessWidget {
  const HomeCardPreviewBody({
    super.key,
    required this.presentation,
    required this.cardSize,
    this.fallbackSubtitle,
  });

  final HomeCardPresentation presentation;
  final HomeCardSize cardSize;
  final String? fallbackSubtitle;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: homeSummaryBodyMinHeight(cardSize),
      ),
      child: switch (presentation) {
        HomeCardPresentationLoading() => Text(
            '加载中…',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.45),
              fontSize: 13,
            ),
          ),
        HomeCardPresentationRows(:final rows, :final footer) =>
          _RowsBody(rows: rows, footer: footer, cardSize: cardSize),
        HomeCardPresentationHighlights(:final highlights) =>
          _HighlightsBody(highlights: highlights, cardSize: cardSize),
        HomeCardPresentationEmpty(:final message) => _EmptyBody(
            message: message,
            fallbackSubtitle: fallbackSubtitle,
          ),
        HomeCardPresentationCompact(:final hint) => _EmptyBody(
            message: hint ?? '',
            fallbackSubtitle: fallbackSubtitle,
          ),
      },
    );
  }
}

class _RowsBody extends StatelessWidget {
  const _RowsBody({
    required this.rows,
    required this.footer,
    required this.cardSize,
  });

  final List<HomeCardPreviewRow> rows;
  final String? footer;
  final HomeCardSize cardSize;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return Text(
        '暂无数据',
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.45),
          fontSize: 13,
        ),
      );
    }
    return Column(
      mainAxisAlignment: cardSize.isLarge
          ? MainAxisAlignment.spaceBetween
          : MainAxisAlignment.start,
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
                    r.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 13,
                    ),
                  ),
                ),
                if (r.value.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  Expanded(
                    flex: 2,
                    child: Text(
                      r.value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: r.value.startsWith('-')
                            ? Colors.white.withValues(alpha: 0.45)
                            : kScoreGreen,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (footer != null && footer!.isNotEmpty)
          Text(
            footer!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.35),
              fontSize: 11,
            ),
          ),
      ],
    );
  }
}

class _HighlightsBody extends StatelessWidget {
  const _HighlightsBody({
    required this.highlights,
    required this.cardSize,
  });

  final List<HomeCardPreviewHighlight> highlights;
  final HomeCardSize cardSize;

  @override
  Widget build(BuildContext context) {
    if (highlights.isEmpty) {
      return Text(
        '今日暂无日程记录',
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.45),
          fontSize: 13,
        ),
      );
    }
    final limit = cardSize.isLarge ? 8 : 3;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: highlights.take(limit).map(
        (h) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    h.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 13,
                    ),
                  ),
                ),
                if (h.detail.isNotEmpty)
                  Text(
                    h.detail,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          );
        },
      ).toList(),
    );
  }
}

class _EmptyBody extends StatelessWidget {
  const _EmptyBody({
    required this.message,
    this.fallbackSubtitle,
  });

  final String message;
  final String? fallbackSubtitle;

  @override
  Widget build(BuildContext context) {
    final subtitle = fallbackSubtitle ?? '';
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          subtitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 13,
            height: 1.25,
          ),
        ),
        Text(
          message.isNotEmpty ? message : '点击查看详情',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.35),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

/// 通用首页摘要卡：catalog 外观 + API preview 正文。
class HomeCardPreviewSummaryCard extends StatelessWidget {
  const HomeCardPreviewSummaryCard({
    super.key,
    required this.entry,
    required this.preview,
    required this.onTap,
    this.onLongPress,
  });

  final HomeCardCatalogEntry entry;
  final HomeCardPreview preview;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final style = homeSummaryCardStyle(entry);
    final title = homeCardDisplayTitle(preview: preview, entry: entry);
    final subtitle = homeCardDisplaySubtitle(preview: preview, entry: entry);
    return HomeSummaryCardShell(
      gradientColors: style.gradient,
      onTap: onTap,
      onLongPress: onLongPress,
      cardSize: preview.size,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HomeSummaryCardHeader(
            icon: entry.icon,
            iconColor: style.iconColor,
            title: title,
            titleColor: style.titleColor,
          ),
          const SizedBox(height: 8),
          HomeCardPreviewBody(
            presentation: preview.presentation,
            cardSize: preview.size,
            fallbackSubtitle: subtitle,
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
    this.cardSize = HomeCardSize.medium,
  });

  final HomeCardCatalogEntry entry;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final HomeCardSize cardSize;

  @override
  Widget build(BuildContext context) {
    final style = homeSummaryCardStyle(entry);

    return HomeSummaryCardShell(
      gradientColors: style.gradient,
      onTap: onTap,
      onLongPress: onLongPress,
      cardSize: cardSize,
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
            constraints: BoxConstraints(
              minHeight: homeSummaryBodyMinHeight(cardSize),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
    this.title,
    this.badge,
    this.hint,
  });

  final DashboardLifeMenuItem item;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  /// 覆盖 [item.title]；通常来自 preview API。
  final String? title;
  final String? badge;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: item.iconBackground,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(item.icon, color: Colors.white, size: 20),
                    ),
                    if (badge != null && badge!.isNotEmpty)
                      Positioned(
                        top: -4,
                        right: -4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF7C4DFF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            badge!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  title ?? item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                ),
                SizedBox(
                  height: kHomeSmallCardHintBlockHeight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Text(
                        hint ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(
                            alpha: (hint != null && hint!.isNotEmpty) ? 0.45 : 0,
                          ),
                          fontSize: 10,
                          height: 1.1,
                        ),
                      ),
                    ),
                  ),
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
