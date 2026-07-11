import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../dashboard/providers/family_api_base_url_provider.dart';
import '../data/mediacenter_api_client.dart';

final mediacenterDioProvider = Provider.autoDispose<Dio>((ref) {
  final base = ref.watch(familyMediacenterV1BaseSyncProvider);
  return MediacenterApiClient.createDio(baseUrl: base);
});

final mediacenterApiClientProvider =
    Provider.autoDispose<MediacenterApiClient>((ref) {
  final dio = ref.watch(mediacenterDioProvider);
  return MediacenterApiClient(dio);
});
