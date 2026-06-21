import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home_layout_defaults.dart';
import 'home_layout_models.dart';

const _kPrefsHomeLayout = 'home_layout_config_v1';
const _kPrefsHomeLayoutEditHintShown = 'home_layout_edit_hint_shown_v1';

final homeLayoutConfigProvider =
    AsyncNotifierProvider<HomeLayoutNotifier, HomeLayoutConfig>(
  HomeLayoutNotifier.new,
);

final homeLayoutEditHintShownProvider =
    FutureProvider<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(_kPrefsHomeLayoutEditHintShown) ?? false;
});

class HomeLayoutNotifier extends AsyncNotifier<HomeLayoutConfig> {
  @override
  Future<HomeLayoutConfig> build() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kPrefsHomeLayout);
    if (raw == null || raw.trim().isEmpty) {
      return kDefaultHomeLayoutConfig;
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        final config = HomeLayoutConfig.fromJson(decoded);
        if (config.items.isNotEmpty) return config;
      }
    } catch (_) {}
    return kDefaultHomeLayoutConfig;
  }

  Future<void> _persist(HomeLayoutConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPrefsHomeLayout, jsonEncode(config.toJson()));
    state = AsyncData(config);
  }

  Future<void> replaceItems(List<HomeLayoutItem> items) async {
    await _persist(HomeLayoutConfig(items: List.unmodifiable(items)));
  }

  Future<void> reorderVisible(List<HomeLayoutItem> newVisibleOrder) async {
    final hidden = state.valueOrNull?.hiddenItems ?? const [];
    await replaceItems([...newVisibleOrder, ...hidden]);
  }

  Future<void> toggleFeatureSize(String itemId, HomeCardSize size) async {
    final current = state.valueOrNull ?? kDefaultHomeLayoutConfig;
    final next = current.items.map((e) {
      if (e is HomeFeatureLayoutItem && e.itemId == itemId) {
        return e.copyWithSize(size);
      }
      return e;
    }).toList();
    await replaceItems(next);
  }

  Future<void> setFeatureHidden(String itemId, bool hidden) async {
    final current = state.valueOrNull ?? kDefaultHomeLayoutConfig;
    final next = current.items.map((e) {
      if (e.itemId == itemId) {
        return e.copyWithHidden(hidden);
      }
      return e;
    }).toList();
    await replaceItems(next);
  }

  Future<void> updateSeparatorTitle(String itemId, String title) async {
    final trimmed = title.trim();
    if (trimmed.isEmpty) return;
    final current = state.valueOrNull ?? kDefaultHomeLayoutConfig;
    final next = current.items.map((e) {
      if (e is HomeSeparatorLayoutItem && e.itemId == itemId) {
        return e.copyWithTitle(trimmed);
      }
      return e;
    }).toList();
    await replaceItems(next);
  }

  Future<void> addSeparator({String title = '新分组'}) async {
    final current = state.valueOrNull ?? kDefaultHomeLayoutConfig;
    final id = 'sep-${DateTime.now().millisecondsSinceEpoch}';
    await replaceItems([
      ...current.items,
      HomeSeparatorLayoutItem(itemId: id, title: title),
    ]);
  }

  Future<void> deleteSeparator(String itemId) async {
    final current = state.valueOrNull ?? kDefaultHomeLayoutConfig;
    await replaceItems(
      current.items.where((e) => e.itemId != itemId).toList(),
    );
  }

  Future<void> restoreDefault() async {
    await _persist(kDefaultHomeLayoutConfig);
  }
}

Future<void> markHomeLayoutEditHintShown() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_kPrefsHomeLayoutEditHintShown, true);
}
