import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/utils/bearer_token.dart';

const _kPrefsFamilyApiAccessToken = 'family_api_access_token_v1';

/// 持久化的访问 API KEY（请求头 `X-API-Key`）；未设置则为空字符串。
final familyApiAccessTokenNotifierProvider =
    AsyncNotifierProvider<FamilyApiAccessTokenNotifier, String>(
  FamilyApiAccessTokenNotifier.new,
);

class FamilyApiAccessTokenNotifier extends AsyncNotifier<String> {
  @override
  Future<String> build() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_kPrefsFamilyApiAccessToken);
    return normalizeBearerSecret(saved ?? '');
  }

  Future<void> persistToken(String raw) async {
    final t = normalizeBearerSecret(raw);
    final prefs = await SharedPreferences.getInstance();
    if (t.isEmpty) {
      await prefs.remove(_kPrefsFamilyApiAccessToken);
      state = const AsyncData('');
    } else {
      await prefs.setString(_kPrefsFamilyApiAccessToken, t);
      state = AsyncData(t);
    }
  }
}
