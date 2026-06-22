import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/biz_date.dart';
import '../../../core/utils/week_range.dart';
import '../data/family_api_client.dart';
import '../data/home_card_preview_models.dart';
import '../data/home_card_preview_parsers.dart';
import 'dashboard_remote_providers.dart';
import 'family_api_base_url_provider.dart';

/// 递增后使全部首页卡片 preview 缓存失效。
final homeCardPreviewRefreshProvider = StateProvider<int>((ref) => 0);

final homeCardPreviewProvider =
    FutureProvider.family<HomeCardPreview, HomeCardPreviewKey>((ref, key) async {
  ref.watch(homeCardPreviewRefreshProvider);
  if (!ref.watch(familyApiIsConfiguredProvider)) {
    return HomeCardPreview.unconfigured(key.cardId, key.size);
  }
  final client = ref.watch(familyApiClientProvider);
  try {
    final data = await client.getHomeCardPreview(
      cardId: key.cardId,
      size: key.size.toJson(),
      bizDate: key.bizDate ?? formatBizDate(DateTime.now()),
      periodStart: key.periodStart ??
          currentWeekPeriodStrings(DateTime.now()).periodStart,
      periodEnd:
          key.periodEnd ?? currentWeekPeriodStrings(DateTime.now()).periodEnd,
    );
    return parseHomeCardPreview(data);
  } on FamilyApiException catch (e) {
    return HomeCardPreview.error(key.cardId, key.size, e.message);
  }
});
