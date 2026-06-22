import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/family_api_client.dart';
import '../data/dashboard_life_menu_catalog.dart';
import '../data/dashboard_prototype_models.dart';
import '../data/home_card_preview_models.dart';
import '../layout/home_layout_defaults.dart';
import '../layout/home_layout_edit_mode_provider.dart';
import '../layout/home_layout_models.dart';
import '../layout/home_layout_provider.dart';
import '../layout/home_layout_renderer.dart';
import '../providers/dashboard_home_title_provider.dart';
import '../providers/dashboard_remote_providers.dart';
import '../providers/family_api_base_url_provider.dart';
import '../providers/home_card_preview_providers.dart';
import '../../../core/mock/mock_data_notifier.dart';
import '../../../shared/providers/task_ui_providers.dart';
import 'home_layout_edit_chrome.dart';
import 'home_layout_edit_list.dart';

const double kDashboardHorizontalPadding = 28;

String greetingLine(DateTime now) {
  final h = now.hour;
  if (h < 12) return '早上好 ☀️';
  if (h < 18) return '下午好';
  return '晚上好';
}

String formatZhDate(DateTime d) {
  const weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
  final y = d.year;
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '$y/$m/$day ${weekdays[d.weekday - 1]}';
}

String formatHms(DateTime d) {
  final h = d.hour.toString().padLeft(2, '0');
  final m = d.minute.toString().padLeft(2, '0');
  final s = d.second.toString().padLeft(2, '0');
  return '$h:$m:$s';
}

String shortDashboardError(Object e) {
  if (e is FamilyApiException) return e.message;
  if (e is DioException) {
    return e.message ?? '网络请求失败';
  }
  return '请检查网络与服务地址';
}

Map<String, DashboardLifeMenuItem> buildMenuByRoute({
  required List<DashboardLifeMenuItem> lifeMenuItems,
  required List<DashboardLifeMenuItem> systemMenuItems,
}) {
  final out = <String, DashboardLifeMenuItem>{};
  for (final e in lifeMenuItems) {
    out[e.route] = e;
  }
  for (final e in systemMenuItems) {
    out[e.route] = e;
  }
  return out;
}

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  bool _layoutDragActive = false;

  Future<void> _enterLayoutEditMode() async {
    ref.read(homeLayoutEditModeProvider.notifier).enter();

    final hintShown = await ref.read(homeLayoutEditHintShownProvider.future);
    if (!hintShown && mounted) {
      await markHomeLayoutEditHintShown();
      ref.invalidate(homeLayoutEditHintShownProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('可在此调整卡片顺序、展示样式与显示'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _exitLayoutEditMode() {
    _layoutDragActive = false;
    ref.read(homeLayoutEditModeProvider.notifier).exit();
  }

  Future<void> _restoreDefaultLayout() async {
    final ok = await confirmRestoreDefaultLayout(context);
    if (ok == true && mounted) {
      await ref.read(homeLayoutConfigProvider.notifier).restoreDefault();
    }
  }

  Future<void> _editSeparatorTitle(HomeSeparatorLayoutItem item) async {
    final title = await promptSeparatorTitleEdit(
      context,
      initial: item.title,
    );
    if (title == null || !mounted) return;
    await ref
        .read(homeLayoutConfigProvider.notifier)
        .updateSeparatorTitle(item.itemId, title);
  }

  Future<void> _deleteSeparator(HomeSeparatorLayoutItem item) async {
    final ok = await confirmDeleteSeparator(context);
    if (ok == true && mounted) {
      await ref
          .read(homeLayoutConfigProvider.notifier)
          .deleteSeparator(item.itemId);
    }
  }

  void _showHiddenSheet(List<HomeLayoutItem> hiddenItems) {
    showHomeLayoutHiddenSheet(
      context,
      hiddenItems: hiddenItems,
      onRestore: (id) =>
          ref.read(homeLayoutConfigProvider.notifier).setFeatureHidden(id, false),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mock = ref.watch(mockDataNotifierProvider);
    final configured = ref.watch(familyApiIsConfiguredProvider);
    final layoutAsync = ref.watch(homeLayoutConfigProvider);
    final isEditing = ref.watch(homeLayoutEditModeProvider);
    final homeTitle = ref.watch(dashboardHomeTitleProvider).valueOrNull ??
        DashboardHomeTitleNotifier.kDefaultTitle;

    final layoutConfig =
        layoutAsync.valueOrNull ?? kDefaultHomeLayoutConfig;
    final visibleItems = layoutConfig.visibleItems;
    final hiddenItems = layoutConfig.hiddenItems;

    final bizDate = ref.watch(dashboardHomeworkBizDateProvider);
    final period = ref.watch(dashboardPointsPeriodProvider);
    final previewKeys = previewKeysForVisibleFeatures(
      visibleItems,
      bizDate: bizDate,
      periodStart: period.periodStart,
      periodEnd: period.periodEnd,
    );

    final previewAsyncByKey = <String, AsyncValue<HomeCardPreview>>{};
    for (final key in previewKeys) {
      previewAsyncByKey[key.cacheKey] = ref.watch(homeCardPreviewProvider(key));
    }

    Future<void> onPullRefresh() async {
      ref.read(homeCardPreviewRefreshProvider.notifier).state++;
      ref.read(taskRemoteRefreshProvider.notifier).state++;
      await Future.wait(
        previewKeys.map((k) => ref.read(homeCardPreviewProvider(k).future)),
      );
    }

    final renderData = HomeLayoutRenderData(
      previewAsyncByKey: previewAsyncByKey,
      menuByRoute: buildMenuByRoute(
        lifeMenuItems:
            configured ? kDashboardLifeMenuTemplate : mock.dashboardLifeMenu,
        systemMenuItems: mock.dashboardSystemMenu,
      ),
      onEnterEditMode: _enterLayoutEditMode,
    );

    final hPad = kDashboardHorizontalPadding;

    final scrollBody = CustomScrollView(
      physics: _layoutDragActive
          ? const NeverScrollableScrollPhysics()
          : const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(hPad, 6, hPad, 8),
            child: isEditing
                ? HomeLayoutEditBar(
                    onAddSeparator: () => ref
                        .read(homeLayoutConfigProvider.notifier)
                        .addSeparator(),
                    onRestoreDefault: _restoreDefaultLayout,
                    onDone: _exitLayoutEditMode,
                  )
                : GestureDetector(
                    onLongPress: _enterLayoutEditMode,
                    behavior: HitTestBehavior.translucent,
                    child: _DashboardHeader(title: homeTitle),
                  ),
          ),
        ),
        SliverToBoxAdapter(
          child: GestureDetector(
            onLongPress: isEditing ? null : _enterLayoutEditMode,
            behavior: HitTestBehavior.translucent,
            child: Padding(
              padding: EdgeInsets.fromLTRB(hPad, 4, hPad, 28),
              child: isEditing
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        HomeLayoutEditList(
                          data: renderData,
                          onEditSeparatorTitle: _editSeparatorTitle,
                          onDeleteSeparator: _deleteSeparator,
                          onDragActiveChanged: (active) {
                            if (_layoutDragActive != active) {
                              setState(() => _layoutDragActive = active);
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        HomeLayoutHiddenBanner(
                          hiddenCount: hiddenItems.length,
                          onTap: () => _showHiddenSheet(hiddenItems),
                        ),
                      ],
                    )
                  : _buildBrowseLayout(context, visibleItems, renderData),
            ),
          ),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: isEditing
            ? scrollBody
            : RefreshIndicator(
                onRefresh: onPullRefresh,
                child: scrollBody,
              ),
      ),
    );
  }

  Widget _buildBrowseLayout(
    BuildContext context,
    List<HomeLayoutItem> visibleItems,
    HomeLayoutRenderData renderData,
  ) {
    if (visibleItems.isEmpty) {
      return _EmptyHomeLayoutHint(onEdit: _enterLayoutEditMode);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: buildHomeLayoutColumn(
        context: context,
        visibleItems: visibleItems,
        data: renderData,
      ),
    );
  }
}

class _EmptyHomeLayoutHint extends StatelessWidget {
  const _EmptyHomeLayoutHint({required this.onEdit});

  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Text(
            '首页卡片已全部隐藏',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: onEdit,
            child: const Text('管理首页布局'),
          ),
        ],
      ),
    );
  }
}

class _DashboardHeader extends StatefulWidget {
  const _DashboardHeader({required this.title});

  final String title;

  @override
  State<_DashboardHeader> createState() => _DashboardHeaderState();
}

class _DashboardHeaderState extends State<_DashboardHeader> {
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  height: 1.12,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                greetingLine(now),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 12,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                formatZhDate(now),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.55),
                  fontSize: 10,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                formatHms(now),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
