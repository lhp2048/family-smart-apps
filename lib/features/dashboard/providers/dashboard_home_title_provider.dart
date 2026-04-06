import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kPrefsDashboardHomeTitle = 'dashboard_home_title_v1';

/// 主页顶部大标题（默认「我家」），持久化在本地。
final dashboardHomeTitleProvider =
    AsyncNotifierProvider<DashboardHomeTitleNotifier, String>(
  DashboardHomeTitleNotifier.new,
);

class DashboardHomeTitleNotifier extends AsyncNotifier<String> {
  static const kDefaultTitle = '我家';

  @override
  Future<String> build() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(_kPrefsDashboardHomeTitle);
    if (s != null && s.trim().isNotEmpty) {
      return s.trim();
    }
    return kDefaultTitle;
  }

  /// 保存；空或仅空白则回退为 [kDefaultTitle]。
  Future<void> persistTitle(String raw) async {
    final t = raw.trim().isEmpty ? kDefaultTitle : raw.trim();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPrefsDashboardHomeTitle, t);
    state = AsyncData(t);
  }
}
