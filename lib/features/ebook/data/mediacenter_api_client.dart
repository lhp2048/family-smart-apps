import 'package:dio/dio.dart';

import 'ebook_api_mappers.dart';
import 'ebook_models.dart';

class MediacenterApiException implements Exception {
  MediacenterApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class MediacenterApiClient {
  MediacenterApiClient(this._dio);

  final Dio _dio;

  static Dio createDio({required String baseUrl}) {
    final resolved = baseUrl.trim();
    final normalized = resolved.isEmpty
        ? 'http://127.0.0.1:18026/api/v1/'
        : (resolved.endsWith('/') ? resolved : '$resolved/');
    return Dio(
      BaseOptions(
        baseUrl: normalized,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 30),
        headers: const {
          'Accept': 'application/json',
        },
      ),
    );
  }

  Future<Map<String, dynamic>> getHomeCardPreview({
    required String cardId,
    required String size,
  }) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        'home/cards/$cardId',
        queryParameters: {'size': size},
      );
      final data = res.data;
      if (data == null) {
        throw MediacenterApiException('首页 preview 返回为空');
      }
      return data;
    } on DioException catch (e) {
      throw MediacenterApiException(_messageForDio(e));
    }
  }

  Future<EbookBrowseResult> browseMaterials({
    String path = '',
    int page = 1,
    int pageSize = 30,
  }) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        'materials',
        queryParameters: {
          'path': path,
          'page': page,
          'page_size': pageSize,
        },
      );
      final data = res.data;
      if (data == null) {
        throw MediacenterApiException('书库返回为空');
      }
      return mapEbookBrowseResult(data);
    } on DioException catch (e) {
      throw MediacenterApiException(_messageForDio(e));
    }
  }

  static String _messageForDio(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      final detail = data['detail']?.toString();
      if (detail != null && detail.isNotEmpty) return detail;
    }
    final code = e.response?.statusCode;
    if (code != null) return 'mediacenter 请求失败 ($code)';
    if (e.type == DioExceptionType.connectionError) {
      return '无法连接 mediacenter，请确认服务已启动';
    }
    return 'mediacenter 请求失败：${e.message ?? e.type.name}';
  }
}
