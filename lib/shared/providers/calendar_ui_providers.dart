import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/calendar/data/calendar_api_mappers.dart';
import '../../features/calendar/models/calendar_models.dart';
import '../../features/dashboard/providers/dashboard_remote_providers.dart';
import '../../features/dashboard/providers/family_api_base_url_provider.dart';

final calendarSelectedBizDateProvider = StateProvider<String?>((ref) {
  return null;
});

final calendarFocusedMonthKeyProvider = StateProvider<String>((ref) {
  final now = DateTime.now();
  return '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}';
});

final calendarRemoteRefreshProvider = StateProvider<int>((ref) => 0);

final calendarMonthAsyncProvider =
    FutureProvider.family<CalendarMonthBundle, String>((ref, monthKey) async {
  ref.watch(calendarRemoteRefreshProvider);
  if (!ref.watch(familyApiIsConfiguredProvider)) {
    return CalendarMonthBundle(monthKey: monthKey, days: const []);
  }
  final client = ref.watch(familyApiClientProvider);
  final data = await client.getCalendarMonth(monthKey);
  return parseCalendarMonth(data);
});

final calendarDayAsyncProvider =
    FutureProvider.family<CalendarDayBundle, String>((ref, bizDate) async {
  ref.watch(calendarRemoteRefreshProvider);
  if (!ref.watch(familyApiIsConfiguredProvider)) {
    return CalendarDayBundle(bizDate: bizDate, sections: const []);
  }
  final client = ref.watch(familyApiClientProvider);
  final data = await client.getCalendarDay(bizDate);
  return parseCalendarDay(data);
});

final homeCalendarCardAsyncProvider =
    FutureProvider<HomeCalendarCardData>((ref) async {
  ref.watch(calendarRemoteRefreshProvider);
  final bizDate = ref.watch(dashboardHomeworkBizDateProvider);
  if (!ref.watch(familyApiIsConfiguredProvider)) {
    return HomeCalendarCardData(
      bizDate: bizDate,
      highlights: const [],
      indicators: const CalendarDayIndicators(),
    );
  }
  final client = ref.watch(familyApiClientProvider);
  final data = await client.getHomeCalendarCard(bizDate);
  return parseHomeCalendarCard(data);
});

/// 首页日历摘要卡（与 [homeCalendarCardAsyncProvider] 同义，供 dashboard 使用）。
final dashboardCalendarCardProvider = homeCalendarCardAsyncProvider;
