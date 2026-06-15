import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/error/global_error_handler.dart';
import 'app.dart';
import 'web_plugin_registrant_stub.dart'
    if (dart.library.html) 'web_plugin_registrant_web.dart' as app_web_plugins;

/// 全部使用内存假数据（见 [MockAppState]），不初始化 Isar，便于先跑通 App。
void bootstrap() {
  WidgetsFlutterBinding.ensureInitialized();
  app_web_plugins.registerAppWebPlugins();
  installGlobalErrorHandlers();
  runApp(
    const ProviderScope(
      child: FamilySmartApp(),
    ),
  );
}
