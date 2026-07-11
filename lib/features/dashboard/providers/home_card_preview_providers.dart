import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/family_api_client.dart';
import '../data/home_card_preview_models.dart';
import '../data/home_card_preview_parsers.dart';
import '../data/home_card_preview_router.dart';
import '../data/home_card_remote_catalog.dart';
import 'family_api_base_url_provider.dart';
import 'home_card_catalog_providers.dart';
import 'home_card_refresh_provider.dart';

final homeCardPreviewProvider =
    FutureProvider.family<HomeCardPreview, HomeCardPreviewKey>((ref, key) async {
  ref.watch(homeCardPreviewRefreshProvider);
  ref.watch(remoteHomeCardCatalogProvider);

  final catalog = ref.read(remoteHomeCardCatalogProvider).valueOrNull;
  final owner = resolveHomeCardOwner(cardId: key.cardId, catalog: catalog);

  if (owner == 'mediacenter') {
    if (!ref.watch(familyMediacenterIsConfiguredProvider)) {
      return HomeCardPreview.unconfigured(key.cardId, key.size);
    }
  } else if (!ref.watch(familyApiIsConfiguredProvider)) {
    return HomeCardPreview.unconfigured(key.cardId, key.size);
  }

  try {
    final data = await fetchHomeCardPreviewData(ref, key);
    return parseHomeCardPreview(data);
  } on FamilyApiException catch (e) {
    return HomeCardPreview.error(key.cardId, key.size, e.message);
  } on DioException catch (e) {
    return HomeCardPreview.error(
      key.cardId,
      key.size,
      FamilyApiClient.messageForDio(e),
    );
  } catch (e) {
    return HomeCardPreview.error(
      key.cardId,
      key.size,
      homeCardPreviewErrorMessage(e),
    );
  }
});
