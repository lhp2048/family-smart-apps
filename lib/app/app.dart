import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_product_flags.dart';
import '../core/theme/app_theme.dart';
import '../features/dashboard/providers/family_api_base_url_provider.dart';
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
    final apiConfigured = ref.watch(familyApiIsConfiguredProvider);
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!apiConfigured)
                Material(
                  color: const Color(0xFF3D3510),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    child: Text(
                      '【测试】未连接服务器，以下为本地原型数据',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.amber.shade200,
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ),
                ),
              Expanded(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    child ?? const SizedBox.shrink(),
                    if (!kAppReadOnlyDataMode) const GlobalMicOverlay(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
