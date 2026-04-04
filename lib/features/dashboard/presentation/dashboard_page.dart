import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/mock/mock_data_notifier.dart';
import '../data/dashboard_prototype_models.dart';

/// 原型主色：深紫灰背景
const Color _kDashboardBg = Color(0xFF1A1A2E);

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

String _formatTime(DateTime d) {
  final h = d.hour.toString().padLeft(2, '0');
  final m = d.minute.toString().padLeft(2, '0');
  return '$h:$m';
}

Color _onBadge(Color bg) =>
    bg.computeLuminance() > 0.55 ? Colors.black87 : Colors.white;

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final mock = ref.watch(mockDataNotifierProvider);

    return Scaffold(
      backgroundColor: _kDashboardBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _DashboardHeader(now: now),
              const SizedBox(height: 22),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _HomeworkSummaryCard(
                        rows: mock.dashboardHomeworkRows,
                        footer: mock.dashboardHomeworkFooter,
                        onTap: () => context.push('/tasks'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _PointsSummaryCard(
                        rows: mock.dashboardPointsRows,
                        footer: mock.dashboardPointsFooter,
                        onTap: () => context.push('/points'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Text(
                '学习和生活',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 14),
              ...mock.dashboardLifeMenu.map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
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
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({required this.now});

  final DateTime now;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _greetingLine(now),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.55),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                '智能中心',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatTime(now),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _formatZhDate(now),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 12,
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
  const _HomeworkSummaryCard({
    required this.rows,
    required this.footer,
    required this.onTap,
  });

  final List<DashboardHomeworkRow> rows;
  final String footer;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
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
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.menu_book_rounded,
                        color: Colors.orange.shade200, size: 22),
                    const SizedBox(width: 4),
                    Icon(Icons.menu_book_rounded,
                        color: Colors.lightGreenAccent.shade100, size: 22),
                    const SizedBox(width: 4),
                    Icon(Icons.menu_book_rounded,
                        color: Colors.lightBlue.shade200, size: 22),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  '作业完成',
                  style: TextStyle(
                    color: _kHomeworkTitle,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                ...rows.map(
                  (r) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Text(
                          r.name,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 14,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          r.progressText,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.45),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                const Divider(height: 20, color: Color(0x33FFFFFF)),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        footer,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: Colors.white.withValues(alpha: 0.35),
                    ),
                  ],
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
    required this.footer,
    required this.onTap,
  });

  final List<DashboardPointsRow> rows;
  final String footer;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
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
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.sports_esports_rounded,
                  color: Colors.greenAccent.shade200,
                  size: 28,
                ),
                const SizedBox(height: 8),
                Text(
                  '积分榜',
                  style: TextStyle(
                    color: _kPointsTitle,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                ...rows.map(
                  (r) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Text(
                          r.name,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 14,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${r.score} 分',
                          style: const TextStyle(
                            color: _kScoreGreen,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                const Divider(height: 20, color: Color(0x33FFFFFF)),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        footer,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: Colors.white.withValues(alpha: 0.35),
                    ),
                  ],
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
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.06),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: item.iconBackground,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    item.icon,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.subtitle,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 13,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: item.badgeColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    item.badgeLabel,
                    style: TextStyle(
                      color: _onBadge(item.badgeColor),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
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
