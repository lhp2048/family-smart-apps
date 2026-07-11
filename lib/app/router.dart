import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/calendar/presentation/calendar_page.dart';
import '../features/dashboard/presentation/dashboard_page.dart';
import '../features/english_bonus/presentation/english_bonus_page.dart';
import '../features/english_bonus/presentation/syllable_practice_page.dart';
import '../features/english_bonus/data/syllable_sheet_preview_args.dart';
import '../features/english_bonus/presentation/syllable_sheet_preview_page.dart';
import '../features/dashboard/presentation/settings_page.dart';
import '../features/debate/presentation/debate_page.dart';
import '../features/extracurricular/presentation/extracurricular_page.dart';
import '../features/ebook/presentation/ebook_library_page.dart';
import '../features/ebook/data/ebook_api_mappers.dart';
import '../features/ebook/presentation/ebook_reader_page.dart';
import '../features/voice/presentation/voice_history_chat_page.dart';
import '../features/points/presentation/points_page.dart';
import '../features/shopping/presentation/shopping_item_detail_page.dart';
import '../features/shopping/presentation/shopping_list_page.dart';
import '../features/shopping/presentation/shopping_price_compare_page.dart';
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
        path: '/calendar',
        name: 'calendar',
        builder: (context, state) => const CalendarPage(),
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
        builder: (context, state) => const EnglishBonusPage(),
      ),
      GoRoute(
        path: '/english-bonus/syllable-practice',
        name: 'englishBonusSyllable',
        builder: (context, state) => const SyllablePracticePage(),
      ),
      GoRoute(
        path: '/english-bonus/sheet-preview',
        name: 'englishBonusSheetPreview',
        builder: (context, state) {
          final extra = state.extra;
          if (extra is SyllableSheetPreviewArgs) {
            return SyllableSheetPreviewPage.fromArgs(extra);
          }
          return const Scaffold(
            body: Center(
              child: Text('无效的预览参数'),
            ),
          );
        },
      ),
      GoRoute(
        path: '/extra-curricular',
        name: 'extraCurricular',
        builder: (context, state) => const ExtracurricularPage(),
      ),
      GoRoute(
        path: '/ebook',
        name: 'ebook',
        builder: (context, state) => const EbookLibraryPage(),
      ),
      GoRoute(
        path: '/ebook/read',
        name: 'ebookRead',
        builder: (context, state) {
          final subPath = state.uri.queryParameters['path'] ?? '';
          final title = state.uri.queryParameters['title'] ?? '';
          final fileUrl = state.uri.queryParameters['url'] ?? '';
          final kind = ebookKindFromRoute(state.uri.queryParameters['kind']);
          return EbookReaderPage(
            subPath: subPath,
            title: title,
            fileUrl: fileUrl,
            kind: kind,
          );
        },
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
      GoRoute(
        path: '/shopping',
        name: 'shopping',
        builder: (context, state) => const ShoppingListPage(),
      ),
      GoRoute(
        path: '/shopping/item/:itemId',
        name: 'shoppingItem',
        builder: (context, state) {
          final id = state.pathParameters['itemId'] ?? '';
          return ShoppingItemDetailPage(itemId: id);
        },
      ),
      GoRoute(
        path: '/shopping/compare',
        name: 'shoppingCompare',
        builder: (context, state) => const ShoppingPriceComparePage(),
      ),
    ],
  );
}
