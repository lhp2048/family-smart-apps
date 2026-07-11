import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/api_config.dart';
import '../../../core/utils/api_base_url.dart';
import '../data/portal_discovery_client.dart';

const _kPrefsFamilyPortalOrigin = 'family_portal_origin';
const _kPrefsFamilyDatacenterV1Base = 'family_datacenter_v1_base';
const _kPrefsFamilyMediacenterV1Base = 'family_mediacenter_v1_base';
const _kPrefsFamilyMediacenterOrigin = 'family_mediacenter_origin';

/// 持久化的**门户根**（仅 `http://host:port`，不含路径）；空表示未配置。
final familyPortalOriginNotifierProvider =
    AsyncNotifierProvider<FamilyPortalOriginNotifier, String>(
  FamilyPortalOriginNotifier.new,
);

class FamilyPortalOriginNotifier extends AsyncNotifier<String> {
  @override
  Future<String> build() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_kPrefsFamilyPortalOrigin);
    if (saved != null) {
      return saved;
    }
    return kFamilyPortalDefaultOrigin;
  }

  Future<void> persistValidatedOrigin(String rawInput) async {
    final origin = normalizeFamilyApiOrigin(rawInput);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPrefsFamilyPortalOrigin, origin);
    state = AsyncData(origin);
  }

  Future<void> clearOrigin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kPrefsFamilyPortalOrigin);
    state = const AsyncData(kFamilyPortalDefaultOrigin);
  }
}

/// 发现并缓存的数据中心 `/api/v1/` 基址（末尾 `/`）。
final familyDatacenterV1BaseNotifierProvider =
    AsyncNotifierProvider<FamilyDatacenterV1BaseNotifier, String>(
  FamilyDatacenterV1BaseNotifier.new,
);

class FamilyDatacenterV1BaseNotifier extends AsyncNotifier<String> {
  @override
  Future<String> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kPrefsFamilyDatacenterV1Base) ?? '';
  }

  Future<void> persistValidatedV1Base(String v1Base) async {
    final normalized = v1Base.trim();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPrefsFamilyDatacenterV1Base, normalized);
    state = AsyncData(normalized);
  }

  Future<void> updateFromDiscovery(String v1Base) async {
    await persistValidatedV1Base(v1Base);
  }

  Future<void> clearV1Base() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kPrefsFamilyDatacenterV1Base);
    state = const AsyncData('');
  }
}

/// 发现并缓存的 mediacenter `/api/v1/` 基址（末尾 `/`）。
final familyMediacenterV1BaseNotifierProvider =
    AsyncNotifierProvider<FamilyMediacenterV1BaseNotifier, String>(
  FamilyMediacenterV1BaseNotifier.new,
);

class FamilyMediacenterV1BaseNotifier extends AsyncNotifier<String> {
  @override
  Future<String> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kPrefsFamilyMediacenterV1Base) ?? '';
  }

  Future<void> persistValidatedV1Base(String v1Base) async {
    final normalized = v1Base.trim();
    final prefs = await SharedPreferences.getInstance();
    if (normalized.isEmpty) {
      await prefs.remove(_kPrefsFamilyMediacenterV1Base);
    } else {
      await prefs.setString(_kPrefsFamilyMediacenterV1Base, normalized);
    }
    state = AsyncData(normalized);
  }

  Future<void> clearV1Base() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kPrefsFamilyMediacenterV1Base);
    state = const AsyncData('');
  }
}

/// mediacenter 服务根（`http://host:port`，无尾斜杠）。
final familyMediacenterOriginNotifierProvider =
    AsyncNotifierProvider<FamilyMediacenterOriginNotifier, String>(
  FamilyMediacenterOriginNotifier.new,
);

class FamilyMediacenterOriginNotifier extends AsyncNotifier<String> {
  @override
  Future<String> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kPrefsFamilyMediacenterOrigin) ?? '';
  }

  Future<void> persistOrigin(String origin) async {
    final normalized = origin.trim();
    final prefs = await SharedPreferences.getInstance();
    if (normalized.isEmpty) {
      await prefs.remove(_kPrefsFamilyMediacenterOrigin);
    } else {
      await prefs.setString(_kPrefsFamilyMediacenterOrigin, normalized);
    }
    state = AsyncData(normalized);
  }

  Future<void> clearOrigin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kPrefsFamilyMediacenterOrigin);
    state = const AsyncData('');
  }
}

/// 启动时若已保存门户地址，尝试重新发现数据中心与 mediacenter（失败则保留缓存）。
final familyPortalDiscoveryBootstrapProvider = FutureProvider<void>((ref) async {
  final portal = ref.watch(familyPortalOriginNotifierProvider).valueOrNull ?? '';
  if (portal.isEmpty) return;
  try {
    final discovery = await PortalDiscoveryClient.discoverAll(portal);
    await ref
        .read(familyDatacenterV1BaseNotifierProvider.notifier)
        .updateFromDiscovery(discovery.datacenterV1Base);
    final mc = discovery.mediacenter;
    if (mc != null) {
      await ref
          .read(familyMediacenterV1BaseNotifierProvider.notifier)
          .persistValidatedV1Base(mc.apiBaseUrl);
      await ref
          .read(familyMediacenterOriginNotifierProvider.notifier)
          .persistOrigin(mc.origin);
    }
  } catch (_) {
    // 保留上次校验成功的基址
  }
});

/// 兼容旧引用：等同 [familyPortalOriginNotifierProvider]。
@Deprecated('Use familyPortalOriginNotifierProvider')
final familyApiOriginNotifierProvider = familyPortalOriginNotifierProvider;

/// 是否已完成门户发现且数据中心可用。
final familyApiIsConfiguredProvider = Provider<bool>((ref) {
  ref.watch(familyPortalDiscoveryBootstrapProvider);
  final portal =
      ref.watch(familyPortalOriginNotifierProvider).valueOrNull?.trim() ?? '';
  final v1 =
      ref.watch(familyDatacenterV1BaseNotifierProvider).valueOrNull?.trim() ??
          '';
  return portal.isNotEmpty && v1.isNotEmpty;
});

/// mediacenter 是否已通过门户发现并缓存。
final familyMediacenterIsConfiguredProvider = Provider<bool>((ref) {
  ref.watch(familyPortalDiscoveryBootstrapProvider);
  final v1 =
      ref.watch(familyMediacenterV1BaseNotifierProvider).valueOrNull?.trim() ??
          '';
  final origin =
      ref.watch(familyMediacenterOriginNotifierProvider).valueOrNull?.trim() ??
          '';
  return v1.isNotEmpty && origin.isNotEmpty;
});

/// 供 mediacenter client：`…/api/v1/` 基址。
final familyMediacenterV1BaseSyncProvider = Provider<String>((ref) {
  ref.watch(familyPortalDiscoveryBootstrapProvider);
  final async = ref.watch(familyMediacenterV1BaseNotifierProvider);
  return async.when(
    data: (v1) {
      final trimmed = v1.trim();
      if (trimmed.isEmpty) return '';
      return trimmed.endsWith('/') ? trimmed : '$trimmed/';
    },
    loading: () => '',
    error: (_, _) => '',
  );
});

/// mediacenter 服务根（无尾斜杠）。
final familyMediacenterOriginSyncProvider = Provider<String>((ref) {
  ref.watch(familyPortalDiscoveryBootstrapProvider);
  final async = ref.watch(familyMediacenterOriginNotifierProvider);
  return async.when(
    data: (origin) {
      final trimmed = origin.trim();
      if (trimmed.isEmpty) return '';
      return trimmed.endsWith('/')
          ? trimmed.substring(0, trimmed.length - 1)
          : trimmed;
    },
    loading: () => '',
    error: (_, _) => '',
  );
});

/// 供 [familyApiDioProvider]：`…/api/v1/` 基址；未配置时用占位。
final familyApiV1BaseSyncProvider = Provider<String>((ref) {
  ref.watch(familyPortalDiscoveryBootstrapProvider);
  final async = ref.watch(familyDatacenterV1BaseNotifierProvider);
  return async.when(
    data: (v1) {
      final trimmed = v1.trim();
      if (trimmed.isEmpty) return kFamilyApiUnsetV1Placeholder;
      return trimmed.endsWith('/') ? trimmed : '$trimmed/';
    },
    loading: () => kFamilyApiUnsetV1Placeholder,
    error: (_, _) => kFamilyApiUnsetV1Placeholder,
  );
});
