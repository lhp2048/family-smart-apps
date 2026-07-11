import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/biz_date.dart';
import '../../../core/utils/week_range.dart';
import '../../ebook/data/mediacenter_api_client.dart';
import '../../ebook/providers/mediacenter_remote_providers.dart';
import '../data/family_api_client.dart';
import '../data/home_card_preview_models.dart';
import '../data/home_card_remote_catalog.dart';
import '../providers/dashboard_remote_providers.dart';
import '../providers/family_api_base_url_provider.dart';
import '../providers/home_card_catalog_providers.dart';

Future<Map<String, dynamic>> fetchHomeCardPreviewData(
  Ref ref,
  HomeCardPreviewKey key,
) async {
  final catalog = ref.read(remoteHomeCardCatalogProvider).valueOrNull;
  final owner = resolveHomeCardOwner(cardId: key.cardId, catalog: catalog);

  if (owner == 'mediacenter') {
    if (!ref.read(familyMediacenterIsConfiguredProvider)) {
      throw MediacenterApiException('未配置 mediacenter，请在设置中配置门户地址');
    }
    final mc = ref.read(mediacenterApiClientProvider);
    return mc.getHomeCardPreview(
      cardId: key.cardId,
      size: key.size.toJson(),
    );
  }

  if (!ref.read(familyApiIsConfiguredProvider)) {
    throw FamilyApiException('未配置数据中心，请在设置中配置门户地址');
  }
  final client = ref.read(familyApiClientProvider);
  return client.getHomeCardPreview(
    cardId: key.cardId,
    size: key.size.toJson(),
    bizDate: key.bizDate ?? formatBizDate(DateTime.now()),
    periodStart:
        key.periodStart ?? currentWeekPeriodStrings(DateTime.now()).periodStart,
    periodEnd:
        key.periodEnd ?? currentWeekPeriodStrings(DateTime.now()).periodEnd,
  );
}

String homeCardPreviewErrorMessage(Object error) {
  if (error is FamilyApiException) return error.message;
  if (error is MediacenterApiException) return error.message;
  return error.toString();
}
