import 'package:flutter/material.dart';

/// 与 [FeatureEntryEntity.icon] 字符串对应
IconData featureEntryIcon(String key) {
  switch (key) {
    case 'fact_check_outlined':
      return Icons.fact_check_outlined;
    case 'emoji_events_outlined':
      return Icons.emoji_events_outlined;
    case 'favorite_border':
      return Icons.favorite_border;
    case 'history_edu_outlined':
      return Icons.history_edu_outlined;
    case 'forum_outlined':
      return Icons.forum_outlined;
    case 'edit_note_outlined':
      return Icons.edit_note_rounded;
    case 'auto_stories_outlined':
      return Icons.auto_stories_outlined;
    default:
      return Icons.widgets_outlined;
  }
}

String routeForEntryKey(String entryKey) {
  switch (entryKey) {
    case 'tasks':
      return '/tasks';
    case 'points':
      return '/points';
    case 'wishwall':
      return '/wishwall';
    case 'timemachine':
      return '/timemachine';
    case 'debate':
      return '/debate';
    case 'english-bonus':
    case 'english_bonus':
      return '/english-bonus';
    case 'extra-curricular':
    case 'extracurricular':
    case 'extra_curricular':
      return '/extra-curricular';
    default:
      return '/';
  }
}
