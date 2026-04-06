import 'package:dio/dio.dart';

/// 语音链路专用 Dio（ASR / AI）。
/// 家庭业务读接口见 `features/dashboard/data/family_api_client.dart` 与 `api_config.dart`。
Dio createVoiceDio({String? baseUrl}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl ?? '',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 25),
      headers: const {'Content-Type': 'application/json'},
    ),
  );
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        options.headers['X-Request-Id'] =
            DateTime.now().microsecondsSinceEpoch.toString();
        handler.next(options);
      },
    ),
  );
  return dio;
}
