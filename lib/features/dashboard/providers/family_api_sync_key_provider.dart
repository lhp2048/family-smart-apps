import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/utils/bearer_token.dart';

const _kPrefsFamilyApiSyncKey = 'family_api_sync_key_v1';

/// 持久化的 Sync API KEY（写操作请求头 `X-Sync-Key`）；未设置则为空（回退 `X-API-Key`）。
final familyApiSyncKeyNotifierProvider =
    AsyncNotifierProvider<FamilyApiSyncKeyNotifier, String>(
  FamilyApiSyncKeyNotifier.new,
);

class FamilyApiSyncKeyNotifier extends AsyncNotifier<String> {
  @override
  Future<String> build() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_kPrefsFamilyApiSyncKey);
    return normalizeBearerSecret(saved ?? '');
  }

  Future<void> persistSyncKey(String raw) async {
    final t = normalizeBearerSecret(raw);
    final prefs = await SharedPreferences.getInstance();
    if (t.isEmpty) {
      await prefs.remove(_kPrefsFamilyApiSyncKey);
      state = const AsyncData('');
    } else {
      await prefs.setString(_kPrefsFamilyApiSyncKey, t);
      state = AsyncData(t);
    }
  }
}
