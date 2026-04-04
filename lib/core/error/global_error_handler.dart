import 'package:flutter/foundation.dart';

/// 全局 Flutter 错误兜底（Sentry 等在后续 Sprint 接入）
void installGlobalErrorHandlers() {
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    if (kDebugMode) {
      debugPrint('FlutterError: ${details.exceptionAsString()}');
    }
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    if (kDebugMode) {
      debugPrint('PlatformDispatcher error: $error\n$stack');
    }
    return true;
  };
}
