import 'package:flutter/material.dart';

/// 首页原型：作业卡片行
class DashboardHomeworkRow {
  const DashboardHomeworkRow(this.name, this.progressText);

  final String name;
  final String progressText;
}

/// 首页原型：积分榜行
class DashboardPointsRow {
  const DashboardPointsRow(this.name, this.score);

  final String name;
  final int score;
}

/// 首页原型：「学习和生活」菜单项
class DashboardLifeMenuItem {
  const DashboardLifeMenuItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconBackground,
    required this.route,
    this.badgeLabel,
    this.badgeColor,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconBackground;
  /// 为 null 或空字符串时不展示角标（如「设置」）
  final String? badgeLabel;
  final Color? badgeColor;
  final String route;
}
