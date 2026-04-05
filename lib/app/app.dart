import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/app_theme.dart';
import '../features/voice/presentation/global_mic_overlay_web.dart'
    if (dart.library.io) '../features/voice/presentation/global_mic_overlay.dart';
import 'router.dart';

final goRouterProvider = Provider<GoRouter>((ref) => createAppRouter());

class FamilySmartApp extends ConsumerWidget {
  const FamilySmartApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    return MaterialApp.router(
      title: '家庭智能中心',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
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
              const GlobalMicOverlay(),
            ],
          ),
        );
      },
    );
  }
}
