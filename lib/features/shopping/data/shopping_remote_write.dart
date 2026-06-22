import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../dashboard/providers/dashboard_remote_providers.dart';
import '../../dashboard/providers/family_api_write_refresh.dart';

Future<void> toggleShoppingPurchasedRemote(
  WidgetRef ref,
  String itemId,
) async {
  final client = ref.read(familyApiClientProvider);
  await client.toggleShoppingPurchased(itemId);
  refreshAfterFamilyApiWrite(ref);
}
