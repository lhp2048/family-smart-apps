import 'package:flutter/material.dart';

import 'dashboard_prototype_models.dart';

/// 本地固定的「学习和生活」文案与路由；角标由 `GET /v1/home/cards/life-menu-badges` 按 `route` 合并。
const List<DashboardLifeMenuItem> kDashboardLifeMenuTemplate = [
  DashboardLifeMenuItem(
    title: '心愿墙',
    subtitle: '许下心愿 · 美好期待',
    icon: Icons.star_rounded,
    iconBackground: Color(0xFFFFCA28),
    route: '/wishwall',
  ),
  DashboardLifeMenuItem(
    title: '时光机',
    subtitle: '家庭故事 · 成长瞬间',
    icon: Icons.hourglass_empty_rounded,
    iconBackground: Color(0xFF90CAF9),
    route: '/timemachine',
  ),
  DashboardLifeMenuItem(
    title: '话题辩论',
    subtitle: '每日话题 · 边吃边聊',
    icon: Icons.restaurant_menu_rounded,
    iconBackground: Color(0xFFFFAB91),
    route: '/debate',
  ),
  DashboardLifeMenuItem(
    title: '加分提分',
    subtitle: '练习纸 · 音节训练等',
    icon: Icons.edit_note_rounded,
    iconBackground: Color(0xFF81D4FA),
    route: '/english-bonus',
  ),
  DashboardLifeMenuItem(
    title: '精彩课外',
    subtitle: '黄金屋 · 第七艺术 · 动漫 · 更多',
    icon: Icons.auto_stories_rounded,
    iconBackground: Color(0xFFEF9A9A),
    route: '/extra-curricular',
  ),
];
