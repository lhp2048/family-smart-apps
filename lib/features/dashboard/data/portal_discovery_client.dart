import 'package:dio/dio.dart';

class PortalDiscoveryException implements Exception {
  PortalDiscoveryException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// 通过门户 `GET /api/v1/portal/services` 发现内网服务地址。
class MediacenterDiscovery {
  const MediacenterDiscovery({
    required this.apiBaseUrl,
    required this.origin,
    required this.running,
    required this.title,
    required this.productId,
  });

  final String apiBaseUrl;
  final String origin;
  final bool running;
  final String title;
  final String productId;
}

class PortalDiscoveryResult {
  const PortalDiscoveryResult({
    required this.datacenterV1Base,
    this.mediacenter,
  });

  final String datacenterV1Base;
  final MediacenterDiscovery? mediacenter;
}

class PortalDiscoveryClient {
  static Future<Map<String, dynamic>> fetchServices(String portalOrigin) async {
    final dio = Dio(
      BaseOptions(
        baseUrl: portalOrigin,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 20),
        headers: const {
          'Accept': 'application/json',
        },
      ),
    );
    try {
      final res = await dio.get<Map<String, dynamic>>('/api/v1/portal/services');
      final body = res.data;
      if (body == null || body['ok'] != true) {
        final err = body?['error']?.toString();
        throw PortalDiscoveryException(
          err != null && err.isNotEmpty ? err : '门户发现失败',
        );
      }
      final data = body['data'];
      if (data is! Map) {
        throw PortalDiscoveryException('门户返回格式异常');
      }
      return Map<String, dynamic>.from(data);
    } on DioException catch (e) {
      throw PortalDiscoveryException(_messageForPortalDio(e));
    } finally {
      dio.close();
    }
  }

  static Future<String> discoverDatacenterV1Base(String portalOrigin) async {
    final payload = await fetchServices(portalOrigin);
    final services = payload['services'];
    if (services is! Map) {
      throw PortalDiscoveryException('门户未返回 services');
    }
    final datacenter = services['datacenter'];
    if (datacenter is! Map) {
      throw PortalDiscoveryException('门户未注册数据中心（datacenter）');
    }
    final apiBaseUrl = datacenter['apiBaseUrl']?.toString().trim() ?? '';
    if (apiBaseUrl.isEmpty) {
      throw PortalDiscoveryException('数据中心 apiBaseUrl 为空');
    }
    return apiBaseUrl.endsWith('/') ? apiBaseUrl : '$apiBaseUrl/';
  }

  static Future<MediacenterDiscovery?> discoverMediacenter(String portalOrigin) async {
    final payload = await fetchServices(portalOrigin);
    final services = payload['services'];
    if (services is! Map) {
      return null;
    }
    final mediacenter = services['mediacenter'];
    if (mediacenter is! Map) {
      return null;
    }
    final apiBaseUrl = mediacenter['apiBaseUrl']?.toString().trim() ?? '';
    final origin = mediacenter['origin']?.toString().trim() ?? '';
    if (apiBaseUrl.isEmpty || origin.isEmpty) {
      return null;
    }
    return MediacenterDiscovery(
      apiBaseUrl: apiBaseUrl.endsWith('/') ? apiBaseUrl : '$apiBaseUrl/',
      origin: origin.endsWith('/') ? origin.substring(0, origin.length - 1) : origin,
      running: mediacenter['running'] == true,
      title: mediacenter['title']?.toString() ?? 'Media Center',
      productId: mediacenter['productId']?.toString() ?? 'family_mediacenter',
    );
  }

  static Future<PortalDiscoveryResult> discoverAll(String portalOrigin) async {
    final datacenterV1Base = await discoverDatacenterV1Base(portalOrigin);
    MediacenterDiscovery? mediacenter;
    try {
      mediacenter = await discoverMediacenter(portalOrigin);
    } on PortalDiscoveryException {
      mediacenter = null;
    }
    return PortalDiscoveryResult(
      datacenterV1Base: datacenterV1Base,
      mediacenter: mediacenter,
    );
  }

  static String _messageForPortalDio(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      final m = data['error']?.toString() ?? data['message']?.toString();
      if (m != null && m.isNotEmpty) return m;
    }
    final code = e.response?.statusCode;
    switch (code) {
      case 404:
        return '未找到门户发现接口(404)。请确认端口正确（如 :18024）';
      case 401:
      case 403:
        return '无权限访问门户($code)';
      case 500:
      case 502:
      case 503:
        return '门户服务异常($code)，请稍后重试';
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return '连接门户超时，请检查网络与地址';
    }
    if (e.type == DioExceptionType.connectionError) {
      return '无法连接门户，请确认地址与端口（如 :18024）';
    }
    return '门户发现失败：${e.message ?? e.type.name}';
  }
}
