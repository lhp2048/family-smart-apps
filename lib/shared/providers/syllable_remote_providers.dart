import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/dashboard/providers/dashboard_remote_providers.dart';
import '../../features/dashboard/providers/family_api_base_url_provider.dart';
import '../../features/english_bonus/data/syllable_sheet_api_mapper.dart';
import '../../features/english_bonus/data/syllable_sheet_latest.dart';
import 'task_ui_providers.dart';

/// 与作业等共用刷新信号，便于设置页「刷新」一并重拉。
final syllableRemoteRefreshProvider = taskRemoteRefreshProvider;

/// 已配置家庭 API 时拉取最新音节练习词表（未配置请勿 watch）。
final syllableLatestSheetAsyncProvider =
    FutureProvider<SyllableLatestSheet>((ref) async {
  ref.watch(syllableRemoteRefreshProvider);
  if (!ref.watch(familyApiIsConfiguredProvider)) {
    return const SyllableLatestSheet(sheetId: '', words: []);
  }
  final client = ref.watch(familyApiClientProvider);
  final data = await client.fetchSyllableSheetLatest();
  return syllableLatestSheetFromApiMap(data);
});

/// 最近一次成功拉取的音节练习表（仅内存，不触发图片渲染）。
/// 点击词表行生成 PNG 时应从此读取，与网络请求状态解耦。
final syllableLatestSheetMemoryCacheProvider =
    StateProvider<SyllableLatestSheet?>((ref) => null);
