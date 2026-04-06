import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/api_config.dart';
import '../../../core/utils/api_base_url.dart';

const _kPrefsFamilyApiOrigin = 'family_api_origin';

/// 持久化的**站点根**（仅 `http://host:port`，不含路径）；空表示未配置。
final familyApiOriginNotifierProvider =
    AsyncNotifierProvider<FamilyApiOriginNotifier, String>(
  FamilyApiOriginNotifier.new,
);

class FamilyApiOriginNotifier extends AsyncNotifier<String> {
  @override
  Future<String> build() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_kPrefsFamilyApiOrigin);
    if (saved != null) {
      return saved;
    }
    return kFamilyApiDefaultOrigin;
  }

  /// 已通过 [FamilyApiClient.validateServerBaseUrl] 校验后调用；写入的为规范化后的站点根。
  Future<void> persistValidatedOrigin(String rawInput) async {
    final origin = normalizeFamilyApiOrigin(rawInput);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPrefsFamilyApiOrigin, origin);
    state = AsyncData(origin);
  }
}

/// 是否已在设置中保存非空站点根。
final familyApiIsConfiguredProvider = Provider<bool>((ref) {
  final o = ref.watch(familyApiOriginNotifierProvider).valueOrNull;
  return o != null && o.trim().isNotEmpty;
});

/// 供 [familyApiDioProvider]：`…/api/v1/` 基址（末尾 `/` 供 Dio 正确拼接相对路径）；未配置时用占位。
final familyApiV1BaseSyncProvider = Provider<String>((ref) {
  final async = ref.watch(familyApiOriginNotifierProvider);
  final v1 = async.when(
    data: (origin) => effectiveFamilyApiV1Base(origin),
    loading: () => null,
    error: (_, _) => null,
  );
  return v1 ?? kFamilyApiUnsetV1Placeholder;
});
