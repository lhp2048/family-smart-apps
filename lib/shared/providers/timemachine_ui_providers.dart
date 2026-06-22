import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/mock/mock_data_notifier.dart';
import '../../core/utils/biz_date.dart';
import '../../features/dashboard/providers/dashboard_remote_providers.dart';
import '../../features/dashboard/providers/family_api_base_url_provider.dart';
import '../../features/timemachine/data/timemachine_api_mappers.dart';
import '../../features/timemachine/data/timemachine_prototype_models.dart';
import 'task_ui_providers.dart';

final timemachineRemoteRefreshProvider = taskRemoteRefreshProvider;

/// 时光机 entries 查询：选日优先 bizDate；仅选月用 monthKey；均为 null 时不拉取。
@immutable
class TimemachineQuery {
  const TimemachineQuery({this.monthKey, this.bizDate});

  final String? monthKey;
  final String? bizDate;

  bool get hasFilter =>
      (bizDate != null && bizDate!.isNotEmpty) ||
      (monthKey != null && monthKey!.isNotEmpty);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimemachineQuery &&
          runtimeType == other.runtimeType &&
          monthKey == other.monthKey &&
          bizDate == other.bizDate;

  @override
  int get hashCode => Object.hash(monthKey, bizDate);
}

final timemachineMonthChipsAsyncProvider =
    FutureProvider<List<TimemachineMonthChip>>((ref) async {
  ref.watch(timemachineRemoteRefreshProvider);
  if (!ref.watch(familyApiIsConfiguredProvider)) {
    final all = ref.read(mockDataNotifierProvider).timemachineEntries;
    if (all.isEmpty) return const [];
    final monthTotals = <String, int>{};
    for (final e in all) {
      if (e.bizDate.length < 7) continue;
      final mk = e.bizDate.substring(0, 7);
      monthTotals[mk] = (monthTotals[mk] ?? 0) + 1;
    }
    final keys = monthTotals.keys.toList()..sort((a, b) => b.compareTo(a));
    return keys
        .map(
          (k) => TimemachineMonthChip(
            monthKey: k,
            label: timemachineMonthChipLabel(k),
            entryCount: monthTotals[k]!,
          ),
        )
        .toList();
  }
  final client = ref.watch(familyApiClientProvider);
  return fetchTimelineMonthChipsRemote(client);
});

final timemachineSidebarDaysAsyncProvider =
    FutureProvider.family<List<TimemachineSidebarDay>, String>(
        (ref, monthKey) async {
  ref.watch(timemachineRemoteRefreshProvider);
  if (!ref.watch(familyApiIsConfiguredProvider)) {
    final all = ref.read(mockDataNotifierProvider).timemachineEntries;
    final byDay = <String, int>{};
    for (final e in all) {
      if (e.bizDate.length >= 7 && e.bizDate.substring(0, 7) == monthKey) {
        byDay[e.bizDate] = (byDay[e.bizDate] ?? 0) + 1;
      }
    }
    final ordered = byDay.keys.toList()..sort((a, b) => b.compareTo(a));
    return ordered
        .map(
          (bd) => TimemachineSidebarDay(
            bizDate: bd,
            label: timemachineSecondRowDayLabel(bd),
            entryCount: byDay[bd]!,
          ),
        )
        .toList();
  }
  final client = ref.watch(familyApiClientProvider);
  return fetchTimelineSidebarDaysRemote(client, monthKey);
});

final timemachineEntriesAsyncProvider =
    FutureProvider.family<List<TimemachineEntry>, TimemachineQuery>(
        (ref, query) async {
  ref.watch(timemachineRemoteRefreshProvider);
  if (!query.hasFilter) return const [];
  if (!ref.watch(familyApiIsConfiguredProvider)) {
    final all = ref.read(mockDataNotifierProvider).timemachineEntries;
    if (query.bizDate != null && query.bizDate!.isNotEmpty) {
      return all.where((e) => e.bizDate == query.bizDate).toList();
    }
    final mk = query.monthKey;
    if (mk != null && mk.isNotEmpty) {
      return all
          .where(
            (e) => e.bizDate.length >= 7 && e.bizDate.substring(0, 7) == mk,
          )
          .toList();
    }
    return const [];
  }
  final client = ref.watch(familyApiClientProvider);
  return fetchTimelineEntriesRemote(
    client,
    monthKey: query.bizDate == null ? query.monthKey : null,
    bizDate: query.bizDate,
  );
});

@Deprecated('Use timemachineMonthChipsAsyncProvider instead')
final timemachineBundleAsyncProvider =
    FutureProvider<TimemachineRemoteBundle?>((ref) async {
  ref.watch(timemachineRemoteRefreshProvider);
  if (!ref.watch(familyApiIsConfiguredProvider)) {
    return null;
  }
  final client = ref.watch(familyApiClientProvider);
  return fetchTimemachineBundleRemote(client);
});

final timemachineEntriesProvider = Provider<List<TimemachineEntry>>((ref) {
  if (ref.watch(familyApiIsConfiguredProvider)) {
    final query = ref.watch(timemachineActiveQueryProvider);
    if (!query.hasFilter) return const [];
    return ref.watch(timemachineEntriesAsyncProvider(query)).valueOrNull ??
        const [];
  }
  return ref.watch(mockDataNotifierProvider).timemachineEntries;
});

/// `null` 表示未选具体日；与 [timemachineSelectedMonthKeyProvider] 配合筛范围
final timemachineSelectedBizDateProvider = StateProvider<String?>((ref) => null);

/// `null` 表示「全部」；非空为 yyyy-MM，展示该月全部或配合选中日
final timemachineSelectedMonthKeyProvider = StateProvider<String?>((ref) => null);

final timemachineActiveQueryProvider = Provider<TimemachineQuery>((ref) {
  final selDay = ref.watch(timemachineSelectedBizDateProvider);
  final monthKey = ref.watch(timemachineSelectedMonthKeyProvider);
  if (selDay != null && selDay.isNotEmpty) {
    return TimemachineQuery(bizDate: selDay, monthKey: monthKey);
  }
  if (monthKey != null && monthKey.isNotEmpty) {
    return TimemachineQuery(monthKey: monthKey);
  }
  return const TimemachineQuery();
});

String timemachineSidebarDayLabel(String bizDate) {
  final d = DateTime.parse(bizDate);
  final mm = d.month.toString().padLeft(2, '0');
  final dd = d.day.toString().padLeft(2, '0');
  return '$mm-$dd ${weekdayCn(d)}';
}

/// 第一行年月 chip 文案，如 26年3月
String timemachineMonthChipLabel(String monthKey) {
  final parts = monthKey.split('-');
  if (parts.length != 2) return monthKey;
  final y = int.tryParse(parts[0]) ?? 0;
  final m = int.tryParse(parts[1]) ?? 0;
  return '${y % 100}年$m月';
}

/// 第二行：某日（已在某月下）
String timemachineSecondRowDayLabel(String bizDate) {
  final d = DateTime.parse(bizDate);
  return '${d.day}日 ${weekdayCn(d)}';
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

/// 第一行：有数据的月份（新→旧）；远程用接口 chips，Mock 从条目聚合
final timemachineSidebarMonthsProvider =
    Provider<List<TimemachineMonthChip>>((ref) {
  if (ref.watch(familyApiIsConfiguredProvider)) {
    return ref.watch(timemachineMonthChipsAsyncProvider).valueOrNull ??
        const [];
  }

  final all = ref.watch(timemachineEntriesProvider);
  if (all.isEmpty) return [];

  final monthTotals = <String, int>{};
  for (final e in all) {
    if (e.bizDate.length < 7) continue;
    final mk = e.bizDate.substring(0, 7);
    monthTotals[mk] = (monthTotals[mk] ?? 0) + 1;
  }
  final keys = monthTotals.keys.toList()..sort((a, b) => b.compareTo(a));
  return keys
      .map(
        (k) => TimemachineMonthChip(
          monthKey: k,
          label: timemachineMonthChipLabel(k),
          entryCount: monthTotals[k]!,
        ),
      )
      .toList();
});

/// 当前选中月下、有数据的日期（第二行）
final timemachineSecondRowDaysProvider =
    Provider<List<TimemachineSidebarDay>>((ref) {
  final mk = ref.watch(timemachineSelectedMonthKeyProvider);
  if (mk == null) return [];
  if (ref.watch(familyApiIsConfiguredProvider)) {
    return ref.watch(timemachineSidebarDaysAsyncProvider(mk)).valueOrNull ??
        const [];
  }
  final all = ref.watch(timemachineEntriesProvider);
  final byDay = <String, int>{};
  for (final e in all) {
    if (e.bizDate.length >= 7 && e.bizDate.substring(0, 7) == mk) {
      byDay[e.bizDate] = (byDay[e.bizDate] ?? 0) + 1;
    }
  }
  final ordered = byDay.keys.toList()..sort((a, b) => b.compareTo(a));
  return ordered
      .map(
        (bd) => TimemachineSidebarDay(
          bizDate: bd,
          label: timemachineSecondRowDayLabel(bd),
          entryCount: byDay[bd]!,
        ),
      )
      .toList();
});

final filteredTimemachineEntriesProvider =
    Provider<List<TimemachineEntry>>((ref) {
  if (ref.watch(familyApiIsConfiguredProvider)) {
    final query = ref.watch(timemachineActiveQueryProvider);
    if (!query.hasFilter) return const [];
    final async = ref.watch(timemachineEntriesAsyncProvider(query));
    return async.maybeWhen(data: (d) => d, orElse: () => const []);
  }
  final all = ref.watch(timemachineEntriesProvider);
  final selDay = ref.watch(timemachineSelectedBizDateProvider);
  final monthKey = ref.watch(timemachineSelectedMonthKeyProvider);
  if (selDay != null) {
    return all.where((e) => e.bizDate == selDay).toList();
  }
  if (monthKey != null) {
    return all
        .where(
          (e) =>
              e.bizDate.length >= 7 &&
              e.bizDate.substring(0, 7) == monthKey,
        )
        .toList();
  }
  return List.of(all);
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
