import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/mock/mock_data_notifier.dart';
import '../../core/utils/biz_date.dart';
import '../../features/timemachine/data/timemachine_prototype_models.dart';

final timemachineEntriesProvider = Provider<List<TimemachineEntry>>((ref) {
  return ref.watch(mockDataNotifierProvider).timemachineEntries;
});

/// `null` 表示「全部」
final timemachineSelectedBizDateProvider = StateProvider<String?>((ref) => null);

String timemachineSidebarDayLabel(String bizDate) {
  final d = DateTime.parse(bizDate);
  final mm = d.month.toString().padLeft(2, '0');
  final dd = d.day.toString().padLeft(2, '0');
  return '$mm-$dd ${weekdayCn(d)}';
}

String timemachineMonthSectionLabel(String bizDate) {
  final d = DateTime.parse(bizDate);
  return '${d.year}年${d.month}月';
}

String timemachineCardPillLabel(String bizDate) {
  final d = DateTime.parse(bizDate);
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '$m月$day日';
}

final timemachineSidebarSectionsProvider =
    Provider<List<TimemachineSidebarSection>>((ref) {
  final all = ref.watch(timemachineEntriesProvider);
  if (all.isEmpty) return [];

  final byDay = <String, int>{};
  for (final e in all) {
    byDay[e.bizDate] = (byDay[e.bizDate] ?? 0) + 1;
  }
  final days = byDay.keys.toList()..sort((a, b) => b.compareTo(a));

  final monthToDays = <String, List<String>>{};
  for (final bd in days) {
    final mk = timemachineMonthSectionLabel(bd);
    monthToDays.putIfAbsent(mk, () => []).add(bd);
  }

  final monthKeys = monthToDays.keys.toList();
  monthKeys.sort((a, b) {
    final da = monthToDays[a]!.first;
    final db = monthToDays[b]!.first;
    return db.compareTo(da);
  });

  return monthKeys
      .map(
        (mk) => TimemachineSidebarSection(
          monthLabel: mk,
          days: monthToDays[mk]!
              .map(
                (bd) => TimemachineSidebarDay(
                  bizDate: bd,
                  label: timemachineSidebarDayLabel(bd),
                  entryCount: byDay[bd]!,
                ),
              )
              .toList(),
        ),
      )
      .toList();
});

final filteredTimemachineEntriesProvider =
    Provider<List<TimemachineEntry>>((ref) {
  final all = ref.watch(timemachineEntriesProvider);
  final sel = ref.watch(timemachineSelectedBizDateProvider);
  if (sel == null) return List.of(all);
  return all.where((e) => e.bizDate == sel).toList();
});

/// 主区按月份分组的顺序（月份新到旧）
final timemachineFeedSectionsProvider =
    Provider<List<TimemachineFeedSection>>((ref) {
  final filtered = ref.watch(filteredTimemachineEntriesProvider);
  if (filtered.isEmpty) return [];

  final sorted = List<TimemachineEntry>.of(filtered)
    ..sort((a, b) {
      final c = b.bizDate.compareTo(a.bizDate);
      if (c != 0) return c;
      return b.id.compareTo(a.id);
    });

  final map = <String, List<TimemachineEntry>>{};
  for (final e in sorted) {
    final mk = timemachineMonthSectionLabel(e.bizDate);
    map.putIfAbsent(mk, () => []).add(e);
  }

  final keys = map.keys.toList();
  keys.sort((a, b) {
    final da = map[a]!.first.bizDate;
    final db = map[b]!.first.bizDate;
    return db.compareTo(da);
  });

  return keys
      .map((k) => TimemachineFeedSection(monthLabel: k, entries: map[k]!))
      .toList();
});
