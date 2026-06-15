import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../dashboard/data/family_api_client.dart';
import '../../dashboard/providers/dashboard_remote_providers.dart';
import '../../dashboard/providers/family_api_write_refresh.dart';
import 'extracurricular_models.dart';

Future<void> toggleExtracurricularWatchedRemote(
  WidgetRef ref,
  ExtracurricularItem item,
) async {
  final client = ref.read(familyApiClientProvider);
  await client.syncMediaItem({
    'id': item.id,
    'filterId': item.filterId,
    'title': item.title,
    'type': item.mediumLabel,
    'genre': item.genre,
    'year': item.year,
    'rating': item.ratingStars,
    'desc': item.description,
    'cover_emoji': item.emoji,
    'watched': !item.watched,
  });
  refreshAfterFamilyApiWrite(ref);
}
