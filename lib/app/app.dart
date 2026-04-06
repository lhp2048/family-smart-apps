import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_product_flags.dart';
import '../core/theme/app_theme.dart';
import '../features/voice/presentation/global_mic_overlay_web.dart'
    if (dart.library.io) '../features/voice/presentation/global_mic_overlay.dart';
import 'router.dart';

final goRouterProvider = Provider<GoRouter>((ref) => createAppRouter());

/// 用于在任意子页面显示 SnackBar，避免嵌套路由下 `ScaffoldMessenger.of(context)` 指向错误实例。
final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

class FamilySmartApp extends ConsumerWidget {
  const FamilySmartApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    return MaterialApp.router(
      title: 'FamilyAI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      routerConfig: router,
      builder: (context, child) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarColor: AppTheme.shellBackground,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
            systemNavigationBarColor: AppTheme.shellBackground,
            systemNavigationBarIconBrightness: Brightness.light,
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              child ?? const SizedBox.shrink(),
              if (!kAppReadOnlyDataMode) const GlobalMicOverlay(),
            ],
          ),
        );
      },
    );
  }
}
