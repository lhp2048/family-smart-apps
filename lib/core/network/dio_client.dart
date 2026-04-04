import 'package:dio/dio.dart';

/// 语音链路专用 Dio（ASR / AI），业务数据不走网络
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
