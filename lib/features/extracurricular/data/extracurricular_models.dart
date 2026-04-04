import 'package:flutter/material.dart';

/// 与左侧「类型筛选」对应（`all` 为全部）
abstract final class ExtracurricularFilterIds {
  static const all = 'all';
  static const golden = 'golden';
  static const seventh = 'seventh';
  static const tv = 'tv';
  static const anime = 'anime';
  static const doc = 'doc';
}

/// 卡片上彩色标签对应的介质类型（决定颜色与文案）
enum ExtracurricularMediumKind {
  tvSeries,
  documentary,
  movie,
  book,
  anime,
}

/// 精彩课外单条内容
class ExtracurricularItem {
  const ExtracurricularItem({
    required this.id,
    required this.title,
    required this.filterId,
    required this.mediumKind,
    required this.mediumLabel,
    required this.year,
    required this.genre,
    required this.ratingStars,
    required this.description,
    required this.emoji,
    required this.watched,
  });

  final String id;
  final String title;
  /// 归属哪一类筛选（黄金屋/第七艺术/电视剧等）
  final String filterId;
  final ExtracurricularMediumKind mediumKind;
  /// 标签展示文案：电视剧 / 纪录片/其他 / 电影
  final String mediumLabel;
  final int year;
  final String genre;
  final int ratingStars;
  final String description;
  final String emoji;
  final bool watched;
}

class ExtracurricularSidebarEntry {
  const ExtracurricularSidebarEntry({
    required this.filterId,
    required this.label,
    required this.icon,
  });

  final String filterId;
  final String label;
  final IconData icon;
}
