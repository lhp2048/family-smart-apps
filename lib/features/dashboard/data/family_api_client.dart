import 'package:dio/dio.dart';

import '../../../core/utils/api_base_url.dart';

class FamilyApiException implements Exception {
  FamilyApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// P0 只读：首页卡片等（`后台API需求说明.md`）。
class FamilyApiClient {
  FamilyApiClient(this._dio);

  final Dio _dio;

  static Dio createDio({String? baseUrl}) {
    final resolved = (baseUrl == null || baseUrl.isEmpty)
        ? kFamilyApiUnsetV1Placeholder
        : baseUrl;
    final dio = Dio(
      BaseOptions(
        baseUrl: resolved,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 20),
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
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

  /// 设置页保存前校验：请求 `GET {origin}/api/v1/members`，且成员列表非空。
  static Future<void> validateServerBaseUrl(String rawInput) async {
    final String origin;
    try {
      origin = normalizeFamilyApiOrigin(rawInput);
    } on FormatException catch (e) {
      final m = e.message;
      throw FamilyApiException(m.isNotEmpty ? m : '地址无效');
    }
    final v1Base = familyOriginToApiV1Base(origin);
    final dio = createDio(baseUrl: v1Base);
    try {
      final res = await dio.get<Map<String, dynamic>>('members');
      final list = _parseMembersListFromResponse(res.data);
      if (list.isEmpty) {
        throw FamilyApiException('接口无成员数据，请确认服务与家庭');
      }
    } on DioException catch (e) {
      throw FamilyApiException(_messageForValidateDio(e));
    } finally {
      dio.close();
    }
  }

  static String _messageForValidateDio(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      final m = data['message']?.toString();
      if (m != null && m.isNotEmpty) return m;
    }
    final code = e.response?.statusCode;
    switch (code) {
      case 404:
        return '未找到接口(404)。请确认端口正确（如 :18024），且服务提供 GET /api/v1/members';
      case 401:
      case 403:
        return '无权限访问($code)，请检查鉴权';
      case 500:
      case 502:
      case 503:
        return '服务异常($code)，请稍后重试';
    }
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return '连接超时，请检查 IP、端口与网络';
      case DioExceptionType.connectionError:
        return '无法连接服务器，请检查 IP、端口、防火墙与网络';
      default:
        break;
    }
    return '请求失败${code != null ? '（HTTP $code）' : ''}';
  }

  static List<dynamic> _parseMembersListFromResponse(dynamic body) {
    if (body == null) return [];
    if (body is List) return body;
    if (body is! Map) return [];
    final m = Map<String, dynamic>.from(body);
    dynamic payload;
    if (m.containsKey('code')) {
      final code = m['code'];
      final ok = code == 0 || code == '0';
      if (!ok) {
        throw FamilyApiException(m['message']?.toString() ?? '接口返回错误');
      }
      payload = m['data'];
    } else {
      payload = m['data'] ?? m['list'] ?? m;
    }
    if (payload is List) return payload;
    if (payload is Map && payload['list'] is List) {
      return payload['list'] as List;
    }
    return [];
  }

  /// `GET /v1/members`：用于作业卡等在 `home/cards/homework` 无行数据时的展示兜底。
  Future<List<Map<String, dynamic>>> fetchMembers() async {
    final res = await _dio.get<Map<String, dynamic>>('members');
    final raw = _parseMembersListFromResponse(res.data);
    final out = <Map<String, dynamic>>[];
    for (final e in raw) {
      if (e is Map) {
        out.add(Map<String, dynamic>.from(e));
      }
    }
    return out;
  }

  /// `GET /v1/home/cards/homework?bizDate=`
  Future<Map<String, dynamic>> getHomeworkCard(String bizDate) async {
    final res = await _dio.get<Map<String, dynamic>>(
      'home/cards/homework',
      queryParameters: {'bizDate': bizDate},
    );
    return _unwrapData(res.data);
  }

  /// `GET /v1/home/cards/points?periodStart=&periodEnd=`
  Future<Map<String, dynamic>> getPointsCard({
    required String periodStart,
    required String periodEnd,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      'home/cards/points',
      queryParameters: {
        'periodStart': periodStart,
        'periodEnd': periodEnd,
      },
    );
    return _unwrapData(res.data);
  }

  Map<String, dynamic> _unwrapData(Map<String, dynamic>? body) {
    if (body == null) {
      throw FamilyApiException('响应为空');
    }
    if (body.containsKey('code')) {
      final code = body['code'];
      final ok = code == 0 || code == '0';
      if (!ok) {
        final msg = body['message']?.toString() ?? '业务错误';
        throw FamilyApiException(msg);
      }
      final data = body['data'];
      if (data is Map<String, dynamic>) return data;
      if (data is Map) return Map<String, dynamic>.from(data);
      if (data is List) {
        return <String, dynamic>{'list': data};
      }
      return {};
    }
    return body;
  }

  /// `GET /v1/home/cards/life-menu-badges`
  Future<Map<String, dynamic>> getLifeMenuBadges() async {
    final res =
        await _dio.get<Map<String, dynamic>>('home/cards/life-menu-badges');
    return _unwrapData(res.data);
  }

  static List<dynamic> _listFromUnwrappedMap(Map<String, dynamic> data) {
    final a = data['list'] ?? data['rows'] ?? data['items'] ?? data['dates'];
    if (a is List) {
      return a;
    }
    return const [];
  }

  /// `GET /v1/task-dates`
  Future<List<Map<String, dynamic>>> fetchTaskDates() async {
    final res = await _dio.get<Map<String, dynamic>>('task-dates');
    final data = _unwrapData(res.data);
    final raw = _listFromUnwrappedMap(data);
    return raw
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  /// `GET /v1/task-groups?bizDate=`
  Future<List<Map<String, dynamic>>> fetchTaskGroups(String bizDate) async {
    final res = await _dio.get<Map<String, dynamic>>(
      'task-groups',
      queryParameters: {'bizDate': bizDate},
    );
    final data = _unwrapData(res.data);
    final raw = _listFromUnwrappedMap(data);
    return raw
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  /// `GET /v1/points/rules`
  Future<Map<String, dynamic>> fetchPointsRules() async {
    final res = await _dio.get<Map<String, dynamic>>('points/rules');
    return _unwrapData(res.data);
  }

  /// `GET /v1/points/weeks`
  Future<Map<String, dynamic>> fetchPointsWeeks() async {
    final res = await _dio.get<Map<String, dynamic>>('points/weeks');
    return _unwrapData(res.data);
  }

  /// `GET /v1/points/summary?periodStart=&periodEnd=`
  Future<Map<String, dynamic>> fetchPointsSummary({
    required String periodStart,
    required String periodEnd,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      'points/summary',
      queryParameters: {
        'periodStart': periodStart,
        'periodEnd': periodEnd,
      },
    );
    return _unwrapData(res.data);
  }

  /// `GET /v1/points/records`（支持业务日或周区间 + 可选成员 + 分页）
  Future<Map<String, dynamic>> fetchPointsRecords({
    String? bizDate,
    String? periodStart,
    String? periodEnd,
    String? memberCode,
    int page = 1,
    int pageSize = 100,
  }) async {
    final q = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
    };
    if (bizDate != null && bizDate.isNotEmpty) {
      q['bizDate'] = bizDate;
    }
    if (periodStart != null && periodStart.isNotEmpty) {
      q['periodStart'] = periodStart;
    }
    if (periodEnd != null && periodEnd.isNotEmpty) {
      q['periodEnd'] = periodEnd;
    }
    if (memberCode != null && memberCode.isNotEmpty) {
      q['memberCode'] = memberCode;
    }
    final res = await _dio.get<Map<String, dynamic>>(
      'points/records',
      queryParameters: q,
    );
    return _unwrapData(res.data);
  }

  /// `GET /v1/wishes?page=&pageSize=&status=&memberCode=`
  Future<Map<String, dynamic>> fetchWishes({
    int page = 1,
    int pageSize = 50,
    String? status,
    String? memberCode,
  }) async {
    final q = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
    };
    if (status != null && status.isNotEmpty) {
      q['status'] = status;
    }
    if (memberCode != null && memberCode.isNotEmpty) {
      q['memberCode'] = memberCode;
    }
    final res = await _dio.get<Map<String, dynamic>>(
      'wishes',
      queryParameters: q,
    );
    return _unwrapData(res.data);
  }

  /// `GET /v1/wish-tags`
  Future<Map<String, dynamic>> fetchWishTags() async {
    final res = await _dio.get<Map<String, dynamic>>('wish-tags');
    return _unwrapData(res.data);
  }

  /// `GET /v1/debate/days`
  Future<Map<String, dynamic>> fetchDebateDays() async {
    final res = await _dio.get<Map<String, dynamic>>('debate/days');
    return _unwrapData(res.data);
  }

  /// `GET /v1/debate/bundles/{bizDate}`  
  /// `code≠0` 或 `data==null` 时返回 `null`（如该日无辩题），不抛 [FamilyApiException]。
  Future<Map<String, dynamic>?> fetchDebateBundleOrNull(String bizDate) async {
    try {
      final res =
          await _dio.get<Map<String, dynamic>>('debate/bundles/$bizDate');
      final body = res.data;
      if (body == null) return null;
      if (body.containsKey('code')) {
        final code = body['code'];
        final ok = code == 0 || code == '0';
        if (!ok) return null;
        final data = body['data'];
        if (data == null) return null;
        if (data is Map<String, dynamic>) return data;
        if (data is Map) return Map<String, dynamic>.from(data);
        return null;
      }
      final data = body['data'] ?? body;
      if (data is Map<String, dynamic>) return data;
      if (data is Map) return Map<String, dynamic>.from(data);
      return null;
    } on DioException catch (e) {
      final sc = e.response?.statusCode;
      if (sc == 404) return null;
      throw FamilyApiException(_messageForValidateDio(e));
    }
  }

  /// `GET /v1/timeline/month-chips`
  Future<Map<String, dynamic>> fetchTimelineMonthChips() async {
    final res =
        await _dio.get<Map<String, dynamic>>('timeline/month-chips');
    return _unwrapData(res.data);
  }

  /// `GET /v1/timeline/sidebar-days?monthKey=`
  Future<Map<String, dynamic>> fetchTimelineSidebarDays(
    String monthKey,
  ) async {
    final res = await _dio.get<Map<String, dynamic>>(
      'timeline/sidebar-days',
      queryParameters: {'monthKey': monthKey},
    );
    return _unwrapData(res.data);
  }

  /// `GET /v1/timeline/entries?monthKey=&bizDate=&page=&pageSize=`
  Future<Map<String, dynamic>> fetchTimelineEntries({
    String? monthKey,
    String? bizDate,
    int page = 1,
    int pageSize = 50,
  }) async {
    final q = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
    };
    if (monthKey != null && monthKey.isNotEmpty) {
      q['monthKey'] = monthKey;
    }
    if (bizDate != null && bizDate.isNotEmpty) {
      q['bizDate'] = bizDate;
    }
    final res = await _dio.get<Map<String, dynamic>>(
      'timeline/entries',
      queryParameters: q,
    );
    return _unwrapData(res.data);
  }

  /// `GET /v1/extracurricular/filters`
  Future<Map<String, dynamic>> fetchExtracurricularFilters() async {
    final res =
        await _dio.get<Map<String, dynamic>>('extracurricular/filters');
    return _unwrapData(res.data);
  }

  /// `GET /v1/extracurricular/items?filterId=&page=&pageSize=`
  Future<Map<String, dynamic>> fetchExtracurricularItems({
    required String filterId,
    int page = 1,
    int pageSize = 50,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      'extracurricular/items',
      queryParameters: {
        'filterId': filterId,
        'page': page,
        'pageSize': pageSize,
      },
    );
    return _unwrapData(res.data);
  }

  /// `GET /v1/english-bonus/syllable-sheet/latest`（全局最新一张练习纸，无 Query）
  Future<Map<String, dynamic>> fetchSyllableSheetLatest() async {
    final res = await _dio.get<Map<String, dynamic>>(
      'english-bonus/syllable-sheet/latest',
    );
    return _unwrapData(res.data);
  }

  /// `GET /v1/task-items?bizDate=&groupCode=`
  Future<List<Map<String, dynamic>>> fetchTaskItems(
    String bizDate, {
    String? groupCode,
  }) async {
    final q = <String, dynamic>{'bizDate': bizDate};
    if (groupCode != null && groupCode.isNotEmpty) {
      q['groupCode'] = groupCode;
    }
    final res = await _dio.get<Map<String, dynamic>>(
      'task-items',
      queryParameters: q,
    );
    final data = _unwrapData(res.data);
    final raw = _listFromUnwrappedMap(data);
    return raw
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }
}
