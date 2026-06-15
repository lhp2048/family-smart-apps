import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../dashboard/data/family_api_client.dart';
import '../../dashboard/providers/dashboard_remote_providers.dart';
import '../../dashboard/providers/family_api_write_refresh.dart';
import 'wishwall_prototype_models.dart';

Future<void> deleteWishRemote(WidgetRef ref, WishwallItem item) async {
  final wishId = int.tryParse(item.id);
  if (wishId == null) {
    throw FamilyApiException('心愿 ID 无效');
  }
  final client = ref.read(familyApiClientProvider);
  await client.deleteWish(wishId);
  refreshAfterFamilyApiWrite(ref);
}

Future<void> syncWishRemote(
  WidgetRef ref, {
  required String content,
  required String memberCode,
  String? displayName,
  String emoji = '✨',
}) async {
  final trimmed = content.trim();
  if (trimmed.isEmpty) {
    throw FamilyApiException('心愿内容不能为空');
  }
  if (memberCode.trim().isEmpty) {
    throw FamilyApiException('请选择成员');
  }
  final client = ref.read(familyApiClientProvider);
  await client.syncWish({
    'content': trimmed,
    'memberCode': memberCode,
    if (displayName != null && displayName.isNotEmpty)
      'displayName': displayName,
    'emoji': emoji,
    'status': 'pending',
    'fulfilled': false,
    'createdAt': DateTime.now().toIso8601String(),
    'tags': <String>[],
  });
  refreshAfterFamilyApiWrite(ref);
}
