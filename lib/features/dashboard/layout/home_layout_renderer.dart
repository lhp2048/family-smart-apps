import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';



import '../data/family_api_client.dart';

import '../data/dashboard_prototype_models.dart';

import '../data/home_card_preview_models.dart';

import '../layout/home_card_catalog.dart';

import '../layout/home_layout_models.dart';

import '../presentation/home_dashboard_cards.dart';



/// 首页布局流渲染：分隔标题 + 功能卡（小 / 中 / 大）。

class HomeLayoutRenderData {

  const HomeLayoutRenderData({

    required this.previewAsyncByKey,

    required this.menuByRoute,

    this.onEnterEditMode,

    this.catalogEntryFor,

  });



  final Map<String, AsyncValue<HomeCardPreview>> previewAsyncByKey;

  final Map<String, DashboardLifeMenuItem> menuByRoute;

  final VoidCallback? onEnterEditMode;

  /// 合并远程 catalog 后的卡片元数据；为空时回退本地 catalog。
  final HomeCardCatalogEntry? Function(String cardId)? catalogEntryFor;



  HomeCardPreview previewFor(HomeFeatureLayoutItem item) {

    final async =

        previewAsyncByKey[homeCardPreviewLookupKey(item.cardId, item.size)];

    if (async == null) {

      return HomeCardPreview.unconfigured(item.cardId, item.size);

    }

    return async.when(

      data: (preview) => preview,

      loading: () => HomeCardPreview.loading(item.cardId, item.size),

      error: (e, _) => HomeCardPreview.error(
        item.cardId,
        item.size,
        e is DioException
            ? FamilyApiClient.messageForDio(e)
            : (e is FamilyApiException ? e.message : e.toString()),
      ),

    );

  }

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



    if (item.size.isLarge) {

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



    if (item.size.isSmall) {

      final run = nextSmallFeatureRun(visibleItems, i);

      out.add(

        buildSmallCardsRow(

          context: context,

          run: run,

          data: data,

          separatorIndexBefore: separatorCount,

        ),

      );

      i += run.length;

      continue;

    }



    final pair = nextMediumFeaturePair(visibleItems, i);

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



  final child = item.size.isSmall

      ? _buildSmallFeature(context, item, data)

      : _buildSummaryFeature(context, item, data);



  if (omitBottomPadding) return child;

  return Padding(

    padding: const EdgeInsets.only(bottom: 8),

    child: child,

  );

}



List<HomeFeatureLayoutItem> nextMediumFeaturePair(

  List<HomeLayoutItem> items,

  int start,

) {

  return _nextMediumFeaturePair(items, start);

}



/// 连续小号卡片（一行最多 [kHomeSmallCardsMaxPerRow] 个）。

List<HomeFeatureLayoutItem> nextSmallFeatureRun(

  List<HomeLayoutItem> items,

  int start, {

  int maxCount = kHomeSmallCardsMaxPerRow,

}) {

  final first = items[start];

  if (first is! HomeFeatureLayoutItem || !first.size.canGroupInSmallRow) {

    return const [];

  }

  final run = <HomeFeatureLayoutItem>[first];

  for (var j = start + 1; j < items.length && run.length < maxCount; j++) {

    final next = items[j];

    if (next is HomeSeparatorLayoutItem) break;

    if (next is HomeFeatureLayoutItem) {

      if (next.size.canGroupInSmallRow) {

        run.add(next);

      } else {

        break;

      }

    }

  }

  return run;

}



/// 小号卡片等宽并排（1~4 个自动平分一行宽度）。

Widget buildSmallCardsRow({

  required BuildContext context,

  required List<HomeFeatureLayoutItem> run,

  required HomeLayoutRenderData data,

  required int separatorIndexBefore,

  int startListIndex = 0,

  Widget Function(int listIndex, Widget child)? wrapChild,

}) {

  final cells = <Widget>[];

  for (var k = 0; k < run.length; k++) {

    if (k > 0) {

      cells.add(const SizedBox(width: kHomeSmallCardGap));

    }

    var cell = buildSingleLayoutItem(

      context: context,

      item: run[k],

      data: data,

      separatorIndexBefore: separatorIndexBefore,

      omitBottomPadding: true,

    );

    if (wrapChild != null) {

      cell = wrapChild(startListIndex + k, cell);

    }

    cells.add(Expanded(child: cell));

  }

  return Padding(

    padding: const EdgeInsets.only(bottom: 8),

    child: Row(

      crossAxisAlignment: CrossAxisAlignment.start,

      children: cells,

    ),

  );

}



List<HomeFeatureLayoutItem> _nextMediumFeaturePair(

  List<HomeLayoutItem> items,

  int start,

) {

  final first = items[start];

  if (first is! HomeFeatureLayoutItem || !first.size.canPairHorizontally) {

    return const [];

  }

  for (var j = start + 1; j < items.length; j++) {

    final next = items[j];

    if (next is HomeSeparatorLayoutItem) break;

    if (next is HomeFeatureLayoutItem) {

      if (next.size.canPairHorizontally) {

        return [first, next];

      }

      break;

    }

  }

  return [first];

}



(String? badge, String? hint) _compactPreviewFields(HomeCardPreview preview) {

  final p = preview.presentation;

  if (p is HomeCardPresentationCompact) {

    return (p.badge, p.hint);

  }

  return (null, null);

}



Widget _buildSmallFeature(

  BuildContext context,

  HomeFeatureLayoutItem item,

  HomeLayoutRenderData data,

) {

  final entry = _catalogEntryFor(item.cardId, data);

  if (entry == null) return const SizedBox.shrink();

  final menu = menuItemForCatalog(entry, data.menuByRoute);

  final preview = data.previewFor(item);

  final (badge, hint) = _compactPreviewFields(preview);

  return HomeThinFeatureCard(
    item: menu,
    title: homeCardDisplayTitle(preview: preview, entry: entry),
    badge: badge,
    hint: hint,
    onTap: () => context.push(entry.route),
    onLongPress: data.onEnterEditMode,
  );
}



Widget _buildSummaryFeature(
  BuildContext context,
  HomeFeatureLayoutItem item,
  HomeLayoutRenderData data,
) {
  final entry = _catalogEntryFor(item.cardId, data);
  if (entry == null) return const SizedBox.shrink();

  final onEdit = data.onEnterEditMode;
  final preview = data.previewFor(item);

  return HomeCardPreviewSummaryCard(
    entry: entry,
    preview: preview,
    onTap: () => context.push(entry.route),
    onLongPress: onEdit,
  );
}

HomeCardCatalogEntry? _catalogEntryFor(
  String cardId,
  HomeLayoutRenderData data,
) {
  return data.catalogEntryFor?.call(cardId) ?? homeCardCatalogEntry(cardId);
}


