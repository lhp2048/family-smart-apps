import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/dashboard_prototype_models.dart';
import '../layout/home_card_catalog.dart';
import '../layout/home_layout_models.dart';
import '../presentation/home_dashboard_cards.dart';

/// 首页布局流渲染：分隔标题 + 功能卡（摘要/入口）。
class HomeLayoutRenderData {
  const HomeLayoutRenderData({
    required this.homeworkRows,
    required this.pointsRows,
    this.pointsErrorSubtitle,
    required this.menuByRoute,
    this.onEnterEditMode,
  });

  final List<DashboardHomeworkRow> homeworkRows;
  final List<DashboardPointsRow> pointsRows;
  final String? pointsErrorSubtitle;
  final Map<String, DashboardLifeMenuItem> menuByRoute;
  final VoidCallback? onEnterEditMode;
}

DashboardLifeMenuItem menuItemForCatalog(
  HomeCardCatalogEntry entry,
  Map<String, DashboardLifeMenuItem> menuByRoute,
) {
  return menuByRoute[entry.route] ??
      DashboardLifeMenuItem(
        title: entry.title,
        subtitle: entry.subtitle,
        icon: entry.icon,
        iconBackground: entry.iconBackground,
        route: entry.route,
      );
}

List<Widget> buildHomeLayoutColumn({
  required BuildContext context,
  required List<HomeLayoutItem> visibleItems,
  required HomeLayoutRenderData data,
}) {
  final out = <Widget>[];
  var separatorCount = 0;
  var i = 0;
  while (i < visibleItems.length) {
    final item = visibleItems[i];
    if (item is HomeSeparatorLayoutItem) {
      out.add(
        buildSingleLayoutItem(
          context: context,
          item: item,
          data: data,
          separatorIndexBefore: separatorCount,
        ),
      );
      separatorCount++;
      i++;
      continue;
    }
    if (item is! HomeFeatureLayoutItem) {
      i++;
      continue;
    }
    if (item.size == HomeCardSize.entry) {
      out.add(
        buildSingleLayoutItem(
          context: context,
          item: item,
          data: data,
          separatorIndexBefore: separatorCount,
        ),
      );
      i++;
      continue;
    }

    final pair = nextSummaryFeaturePair(visibleItems, i);
    if (pair.length == 2) {
      out.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: buildSingleLayoutItem(
                  context: context,
                  item: pair[0],
                  data: data,
                  separatorIndexBefore: separatorCount,
                  omitBottomPadding: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: buildSingleLayoutItem(
                  context: context,
                  item: pair[1],
                  data: data,
                  separatorIndexBefore: separatorCount,
                  omitBottomPadding: true,
                ),
              ),
            ],
          ),
        ),
      );
      i += 2;
    } else {
      out.add(
        buildSingleLayoutItem(
          context: context,
          item: item,
          data: data,
          separatorIndexBefore: separatorCount,
        ),
      );
      i++;
    }
  }
  return out;
}

Widget buildSingleLayoutItem({
  required BuildContext context,
  required HomeLayoutItem item,
  required HomeLayoutRenderData data,
  required int separatorIndexBefore,
  bool isEditPreview = false,
  bool omitBottomPadding = false,
}) {
  if (item is HomeSeparatorLayoutItem) {
    return HomeSeparatorTitle(
      title: item.title,
      topPadding: separatorIndexBefore == 0 ? 12 : 28,
    );
  }
  if (item is! HomeFeatureLayoutItem) {
    return const SizedBox.shrink();
  }

  final child = item.size == HomeCardSize.entry
      ? _buildEntryFeature(context, item, data)
      : _buildSummaryFeature(context, item, data);

  if (omitBottomPadding) return child;
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: child,
  );
}

List<HomeFeatureLayoutItem> nextSummaryFeaturePair(
  List<HomeLayoutItem> items,
  int start,
) {
  return _nextSummaryFeaturePair(items, start);
}

List<HomeFeatureLayoutItem> _nextSummaryFeaturePair(
  List<HomeLayoutItem> items,
  int start,
) {
  final first = items[start];
  if (first is! HomeFeatureLayoutItem || first.size != HomeCardSize.summary) {
    return const [];
  }
  for (var j = start + 1; j < items.length; j++) {
    final next = items[j];
    if (next is HomeSeparatorLayoutItem) break;
    if (next is HomeFeatureLayoutItem) {
      if (next.size == HomeCardSize.summary) {
        return [first, next];
      }
      break;
    }
  }
  return [first];
}

Widget _buildEntryFeature(
  BuildContext context,
  HomeFeatureLayoutItem item,
  HomeLayoutRenderData data,
) {
  final entry = homeCardCatalogEntry(item.cardId);
  if (entry == null) return const SizedBox.shrink();
  final menu = menuItemForCatalog(entry, data.menuByRoute);
  return HomeThinFeatureCard(
    item: menu,
    onTap: () => context.push(entry.route),
    onLongPress: data.onEnterEditMode,
  );
}

Widget _buildSummaryFeature(
  BuildContext context,
  HomeFeatureLayoutItem item,
  HomeLayoutRenderData data,
) {
  final entry = homeCardCatalogEntry(item.cardId);
  if (entry == null) return const SizedBox.shrink();

  final onEdit = data.onEnterEditMode;

  switch (item.cardId) {
    case 'homework':
      return HomeHomeworkSummaryCard(
        rows: data.homeworkRows,
        onTap: () => context.push(entry.route),
        onLongPress: onEdit,
      );
    case 'points':
      return HomePointsSummaryCard(
        rows: data.pointsRows,
        subtitle: data.pointsErrorSubtitle,
        onTap: () => context.push(entry.route),
        onLongPress: onEdit,
      );
    default:
      return HomeGenericSummaryCard(
        entry: entry,
        onTap: () => context.push(entry.route),
        onLongPress: onEdit,
      );
  }
}
