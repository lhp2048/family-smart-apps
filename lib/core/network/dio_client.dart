import 'package:dio/dio.dart';

import '../utils/bearer_token.dart';

/// 语音链路专用 Dio（ASR / AI）。
/// 家庭业务读接口见 `features/dashboard/data/family_api_client.dart`。
/// [accessToken] 与设置中「访问API KEY」一致，写入 `X-API-Key`；未设置则不携带该头。
Dio createVoiceDio({String? baseUrl, String? accessToken}) {
  final raw = accessToken?.trim();
  final key = raw == null || raw.isEmpty ? '' : normalizeBearerSecret(raw);
  final baseHeaders = <String, dynamic>{
    'Content-Type': 'application/json',
  };
  if (key.isNotEmpty) {
    baseHeaders['X-API-Key'] = key;
  }
  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl ?? '',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 25),
      preserveHeaderCase: true,
      headers: baseHeaders,
    ),
  );
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        options.headers['X-Request-Id'] =
            DateTime.now().microsecondsSinceEpoch.toString();
        if (key.isNotEmpty) {
          options.headers['X-API-Key'] = key;
        } else {
          options.headers.remove('X-API-Key');
        }
        handler.next(options);
      },
    ),
  );
  return dio;
}
