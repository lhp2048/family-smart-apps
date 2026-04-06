import 'package:shared_preferences/shared_preferences.dart';

const _kPrefsTaskSelectedBizDate = 'tasks_selected_biz_date_v1';

/// 作业页上次选中的业务日 `YYYY-MM-DD`（与 [taskDatesAsyncProvider] 列表项一致）。
final class TaskSelectedBizDatePrefs {
  TaskSelectedBizDatePrefs._();

  static Future<String?> read() async {
    final p = await SharedPreferences.getInstance();
    final s = p.getString(_kPrefsTaskSelectedBizDate);
    if (s == null || s.trim().isEmpty) return null;
    return s.trim();
  }

  static Future<void> write(String bizDate) async {
    if (bizDate.isEmpty) return;
    final p = await SharedPreferences.getInstance();
    await p.setString(_kPrefsTaskSelectedBizDate, bizDate);
  }
}
