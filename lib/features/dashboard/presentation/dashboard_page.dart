import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/mock/mock_data_notifier.dart';
import '../../../shared/providers/task_ui_providers.dart';
import '../data/dashboard_life_menu_catalog.dart';
import '../data/dashboard_prototype_models.dart';
import '../data/family_api_client.dart';
import '../providers/dashboard_home_title_provider.dart';
import '../providers/dashboard_remote_providers.dart';
import '../providers/family_api_base_url_provider.dart';

/// 主页主内容区左右边距
/// 使用非 const 的 [EdgeInsets]，避免仅改数字时 Hot Reload 不刷新布局。
const double _kDashboardHorizontalPadding = 28;

const Color _kHomeworkTitle = Color(0xFFC4A7FF);
const Color _kPointsTitle = Color(0xFFFF8BC4);
const Color _kScoreGreen = Color(0xFF69F0AE);

String _greetingLine(DateTime now) {
  final h = now.hour;
  if (h < 12) return '早上好 ☀️';
  if (h < 18) return '下午好';
  return '晚上好';
}

String _formatZhDate(DateTime d) {
  const weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
  final y = d.year;
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '$y/$m/$day ${weekdays[d.weekday - 1]}';
}

String _formatHms(DateTime d) {
  final h = d.hour.toString().padLeft(2, '0');
  final m = d.minute.toString().padLeft(2, '0');
  final s = d.second.toString().padLeft(2, '0');
  return '$h:$m:$s';
}

Color _onBadge(Color bg) =>
    bg.computeLuminance() > 0.55 ? Colors.black87 : Colors.white;

String _shortDashboardError(Object e) {
  if (e is FamilyApiException) return e.message;
  if (e is DioException) {
    return e.message ?? '网络请求失败';
  }
  return '请检查网络与服务地址';
}

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mock = ref.watch(mockDataNotifierProvider);
    final configured = ref.watch(familyApiIsConfiguredProvider);
    final homeworkAsync = ref.watch(dashboardHomeworkRowsProvider);
    final pointsAsync = ref.watch(dashboardPointsRowsProvider);
    final lifeMenuAsync = ref.watch(dashboardLifeMenuItemsProvider);
    final homeTitle = ref.watch(dashboardHomeTitleProvider).valueOrNull ??
        DashboardHomeTitleNotifier.kDefaultTitle;

    final lifeMenuItems = lifeMenuAsync.when(
      data: (v) => v,
      loading: () =>
          configured ? kDashboardLifeMenuTemplate : mock.dashboardLifeMenu,
      error: (_, _) =>
          configured ? kDashboardLifeMenuTemplate : mock.dashboardLifeMenu,
    );

    Future<void> onPullRefresh() async {
      ref.invalidate(dashboardHomeworkRowsProvider);
      ref.invalidate(dashboardPointsRowsProvider);
      ref.invalidate(dashboardLifeMenuItemsProvider);
      ref.read(taskRemoteRefreshProvider.notifier).state++;
      await Future.wait([
        ref.read(dashboardHomeworkRowsProvider.future),
        ref.read(dashboardPointsRowsProvider.future),
        ref.read(dashboardLifeMenuItemsProvider.future),
      ]);
    }

    final homeworkRows = homeworkAsync.when(
      data: (rows) =>
          rows.isEmpty ? const [DashboardHomeworkRow('暂无数据', '-/-')] : rows,
      loading: () => const [DashboardHomeworkRow('加载中', '…')],
      error: (e, _) => [DashboardHomeworkRow('作业卡片', _shortDashboardError(e))],
    );
    final pointsRows = pointsAsync.when(
      data: (rows) =>
          rows.isEmpty ? const [DashboardPointsRow('暂无数据', 0)] : rows,
      loading: () => const [DashboardPointsRow('加载中', 0)],
      error: (e, _) => const [DashboardPointsRow('—', 0)],
    );

    final hPad = _kDashboardHorizontalPadding;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: onPullRefresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(hPad, 6, hPad, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _DashboardHeader(title: homeTitle),
                      const SizedBox(height: 12),
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: _HomeworkSummaryCard(
                                rows: homeworkRows,
                                onTap: () => context.push('/tasks'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _PointsSummaryCard(
                                rows: pointsRows,
                                subtitle:
                                    pointsAsync.hasError &&
                                        pointsAsync.error != null
                                    ? _shortDashboardError(
                                        pointsAsync.error!,
                                      )
                                    : null,
                                onTap: () => context.push('/points'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        '学习和生活',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...lifeMenuItems.map(
                        (e) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _LifeMenuCard(
                            item: e,
                            onTap: () => context.push(e.route),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        '系统和配置',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...mock.dashboardSystemMenu.map(
                        (e) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _LifeMenuCard(
                            item: e,
                            onTap: () => context.push(e.route),
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
                _greetingLine(now),
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
                _formatZhDate(now),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.55),
                  fontSize: 10,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatHms(now),
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

class _HomeworkSummaryCard extends StatelessWidget {
  const _HomeworkSummaryCard({required this.rows, required this.onTap});

  final List<DashboardHomeworkRow> rows;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF3D3566).withValues(alpha: 0.95),
                const Color(0xFF252240).withValues(alpha: 0.98),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.menu_book_rounded,
                      color: Colors.orange.shade200,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '作业进度',
                      style: TextStyle(
                        color: _kHomeworkTitle,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
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
        ),
      ),
    );
  }
}

class _PointsSummaryCard extends StatelessWidget {
  const _PointsSummaryCard({
    required this.rows,
    required this.onTap,
    this.subtitle,
  });

  final List<DashboardPointsRow> rows;
  final VoidCallback onTap;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF2D4A3E).withValues(alpha: 0.9),
                const Color(0xFF1E2835).withValues(alpha: 0.95),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.sports_esports_rounded,
                      color: Colors.greenAccent.shade200,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '积分榜',
                      style: TextStyle(
                        color: _kPointsTitle,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
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
                            color: _kScoreGreen,
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
        ),
      ),
    );
  }
}

class _LifeMenuCard extends StatelessWidget {
  const _LifeMenuCard({required this.item, required this.onTap});

  final DashboardLifeMenuItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
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
                if (item.badgeLabel != null &&
                    item.badgeLabel!.isNotEmpty &&
                    item.badgeColor != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: item.badgeColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      item.badgeLabel!,
                      style: TextStyle(
                        color: _onBadge(item.badgeColor!),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ] else
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
