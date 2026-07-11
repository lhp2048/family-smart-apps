import 'package:flutter/material.dart';

/// 首页功能卡元数据（本地 catalog，与 API 摘要解耦）。
class HomeCardCatalogEntry {
  const HomeCardCatalogEntry({
    required this.cardId,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconBackground,
    required this.route,
    this.supportsFatSummary = false,
  });

  final String cardId;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconBackground;
  final String route;

  /// 是否有专用首页摘要 API（作业、积分）。
  final bool supportsFatSummary;
}

const kHomeCardCatalog = <HomeCardCatalogEntry>[
  HomeCardCatalogEntry(
    cardId: 'homework',
    title: '作业进度',
    subtitle: '查看今日任务完成情况',
    icon: Icons.menu_book_rounded,
    iconBackground: Color(0xFF5E35B1),
    route: '/tasks',
    supportsFatSummary: true,
  ),
  HomeCardCatalogEntry(
    cardId: 'points',
    title: '积分榜',
    subtitle: '本周家庭游戏积分',
    icon: Icons.sports_esports_rounded,
    iconBackground: Color(0xFF2E7D32),
    route: '/points',
    supportsFatSummary: true,
  ),
  HomeCardCatalogEntry(
    cardId: 'calendar',
    title: '家庭日历',
    subtitle: '今日',
    icon: Icons.calendar_month_rounded,
    iconBackground: Color(0xFF7986CB),
    route: '/calendar',
    supportsFatSummary: true,
  ),
  HomeCardCatalogEntry(
    cardId: 'wishwall',
    title: '心愿墙',
    subtitle: '许下心愿 · 美好期待',
    icon: Icons.star_rounded,
    iconBackground: Color(0xFFFFCA28),
    route: '/wishwall',
  ),
  HomeCardCatalogEntry(
    cardId: 'timemachine',
    title: '时光机',
    subtitle: '家庭故事 · 成长瞬间',
    icon: Icons.hourglass_empty_rounded,
    iconBackground: Color(0xFF90CAF9),
    route: '/timemachine',
  ),
  HomeCardCatalogEntry(
    cardId: 'debate',
    title: '话题辩论',
    subtitle: '每日话题 · 边吃边聊',
    icon: Icons.restaurant_menu_rounded,
    iconBackground: Color(0xFFFFAB91),
    route: '/debate',
  ),
  HomeCardCatalogEntry(
    cardId: 'english-bonus',
    title: '加分提分',
    subtitle: '练习纸 · 音节训练等',
    icon: Icons.edit_note_rounded,
    iconBackground: Color(0xFF81D4FA),
    route: '/english-bonus',
  ),
  HomeCardCatalogEntry(
    cardId: 'extracurricular',
    title: '精彩课外',
    subtitle: '黄金屋 · 第七艺术 · 动漫 · 更多',
    icon: Icons.auto_stories_rounded,
    iconBackground: Color(0xFFEF9A9A),
    route: '/extra-curricular',
  ),
  HomeCardCatalogEntry(
    cardId: 'ebook',
    title: '电子图书',
    subtitle: '家庭书库 · 在线阅读',
    icon: Icons.menu_book_rounded,
    iconBackground: Color(0xFF80CBC4),
    route: '/ebook',
  ),
  HomeCardCatalogEntry(
    cardId: 'shopping',
    title: '购物清单',
    subtitle: '待买商品 · 价格走势',
    icon: Icons.shopping_bag_outlined,
    iconBackground: Color(0xFFFFAB91),
    route: '/shopping',
  ),
  HomeCardCatalogEntry(
    cardId: 'settings',
    title: '设置',
    subtitle: '应用偏好、通知与关于',
    icon: Icons.settings_rounded,
    iconBackground: Color(0xFF546E7A),
    route: '/settings',
  ),
];

final Map<String, HomeCardCatalogEntry> kHomeCardCatalogById = {
  for (final e in kHomeCardCatalog) e.cardId: e,
};

HomeCardCatalogEntry? homeCardCatalogEntry(String cardId) =>
    kHomeCardCatalogById[cardId];
