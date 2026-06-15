import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mock/mock_data_notifier.dart';
import '../../../core/utils/biz_date.dart';
import '../../../core/utils/week_range.dart';
import '../data/dashboard_life_menu_catalog.dart';
import '../data/dashboard_prototype_models.dart';
import '../data/family_api_client.dart';
import '../data/home_card_parsers.dart';
import 'family_api_access_token_provider.dart';
import 'family_api_sync_key_provider.dart';
import 'family_api_base_url_provider.dart';

final familyApiDioProvider = Provider<Dio>((ref) {
  final baseUrl = ref.watch(familyApiV1BaseSyncProvider);
  final token =
      ref.watch(familyApiAccessTokenNotifierProvider).valueOrNull ?? '';
  final dio = FamilyApiClient.createDio(
    baseUrl: baseUrl,
    accessToken: token.isEmpty ? null : token,
  );
  ref.onDispose(dio.close);
  return dio;
});

final familyApiClientProvider = Provider<FamilyApiClient>((ref) {
  final syncKey =
      ref.watch(familyApiSyncKeyNotifierProvider).valueOrNull ?? '';
  return FamilyApiClient(
    ref.watch(familyApiDioProvider),
    syncApiKey: syncKey.isEmpty ? null : syncKey,
  );
});

/// 首页作业卡使用的业务日（当天本地日历）。
final dashboardHomeworkBizDateProvider = Provider<String>((ref) {
  return formatBizDate(DateTime.now());
});

/// 首页积分卡使用的自然周（周一至周日，与文档 `periodStart`/`periodEnd` 一致）。
final dashboardPointsPeriodProvider = Provider<
    ({String periodStart, String periodEnd})>((ref) {
  return currentWeekPeriodStrings(DateTime.now());
});

final dashboardHomeworkRowsProvider =
    FutureProvider<List<DashboardHomeworkRow>>((ref) async {
  if (!ref.watch(familyApiIsConfiguredProvider)) {
    return const [DashboardHomeworkRow('未配置', '—')];
  }
  final client = ref.watch(familyApiClientProvider);
  final bizDate = ref.watch(dashboardHomeworkBizDateProvider);

  Object? homeworkError;
  Map<String, dynamic>? homeworkData;
  try {
    homeworkData = await client.getHomeworkCard(bizDate);
  } catch (e) {
    homeworkError = e;
  }

  try {
    final members = await client.fetchMembers();
    final progressByCode = homeworkData == null
        ? const <String, String>{}
        : homeworkProgressByMemberCode(homeworkData);
    final rows = homeworkRowsForParticipants(members, progressByCode);
    if (rows.isNotEmpty) {
      return rows;
    }
  } catch (membersError) {
    if (homeworkError == null) {
      homeworkError = membersError;
    }
  }

  if (homeworkError != null) {
    throw homeworkError;
  }
  return const [];
});

final dashboardPointsRowsProvider =
    FutureProvider<List<DashboardPointsRow>>((ref) async {
  if (!ref.watch(familyApiIsConfiguredProvider)) {
    return const [DashboardPointsRow('未配置', 0)];
  }
  final client = ref.watch(familyApiClientProvider);
  final p = ref.watch(dashboardPointsPeriodProvider);

  Object? pointsError;
  Map<String, dynamic>? pointsData;
  try {
    pointsData = await client.getPointsCard(
      periodStart: p.periodStart,
      periodEnd: p.periodEnd,
    );
  } catch (e) {
    pointsError = e;
  }

  try {
    final members = await client.fetchMembers();
    final scoreByCode = pointsData == null
        ? const <String, int>{}
        : pointsScoreByMemberCode(pointsData);
    final rows = pointsRowsForParticipants(members, scoreByCode);
    if (rows.isNotEmpty) {
      return rows;
    }
  } catch (membersError) {
    if (pointsError == null) {
      pointsError = membersError;
    }
  }

  if (pointsError != null) {
    throw pointsError;
  }
  return const [];
});

/// P1：`/v1/home/cards/life-menu-badges` 与本地 [kDashboardLifeMenuTemplate] 合并。
final dashboardLifeMenuItemsProvider =
    FutureProvider<List<DashboardLifeMenuItem>>((ref) async {
  if (!ref.watch(familyApiIsConfiguredProvider)) {
    return ref.read(mockDataNotifierProvider).dashboardLifeMenu;
  }
  final client = ref.watch(familyApiClientProvider);
  Map<String, LifeMenuBadgeSpec> byRoute = {};
  try {
    final data = await client.getLifeMenuBadges();
    byRoute = parseLifeMenuBadgesByRoute(data);
  } catch (_) {}
  return mergeLifeMenuTemplateWithBadges(
    kDashboardLifeMenuTemplate,
    byRoute,
  );
});
