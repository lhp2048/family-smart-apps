import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/dashboard/presentation/coming_soon_page.dart';
import '../features/dashboard/presentation/dashboard_page.dart';
import '../features/dashboard/presentation/settings_page.dart';
import '../features/debate/presentation/debate_page.dart';
import '../features/extracurricular/presentation/extracurricular_page.dart';
import '../features/voice/presentation/voice_history_chat_page.dart';
import '../features/points/presentation/points_page.dart';
import '../features/tasks/presentation/tasks_page.dart';
import '../features/timemachine/presentation/timemachine_page.dart';
import '../features/wishwall/presentation/wishwall_page.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createAppRouter() {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'dashboard',
        builder: (context, state) => DashboardPage(),
      ),
      GoRoute(
        path: '/tasks',
        name: 'tasks',
        builder: (context, state) => const TasksPage(),
      ),
      GoRoute(
        path: '/points',
        name: 'points',
        builder: (context, state) => const PointsPage(),
      ),
      GoRoute(
        path: '/wishwall',
        name: 'wishwall',
        builder: (context, state) => const WishwallPage(),
      ),
      GoRoute(
        path: '/timemachine',
        name: 'timemachine',
        builder: (context, state) => const TimemachinePage(),
      ),
      GoRoute(
        path: '/debate',
        name: 'debate',
        builder: (context, state) => const DebatePage(),
      ),
      GoRoute(
        path: '/english-bonus',
        name: 'englishBonus',
        builder: (context, state) =>
            const ComingSoonPage(title: '英语加分区'),
      ),
      GoRoute(
        path: '/extra-curricular',
        name: 'extraCurricular',
        builder: (context, state) => const ExtracurricularPage(),
      ),
      GoRoute(
        path: '/voice-history',
        name: 'voiceHistory',
        builder: (context, state) => const VoiceHistoryChatPage(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsPage(),
      ),
    ],
  );
}
