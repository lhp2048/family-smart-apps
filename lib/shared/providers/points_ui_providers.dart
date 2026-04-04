import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/mock/mock_data_notifier.dart';
import '../../features/points/data/points_prototype_models.dart';

final pointsRulesProvider = Provider<List<PointsRuleLine>>((ref) {
  return ref.watch(mockDataNotifierProvider).pointsRules;
});

final pointsWeekCyclesProvider = Provider<List<PointsWeekCycle>>((ref) {
  return ref.watch(mockDataNotifierProvider).pointsWeekCycles;
});

/// 当前选中的周周期 id（默认「本周」）
final selectedPointsWeekIdProvider = StateProvider<String>((ref) {
  final cycles = ref.read(mockDataNotifierProvider).pointsWeekCycles;
  for (final c in cycles) {
    if (c.isCurrentWeek) return c.id;
  }
  return cycles.isNotEmpty ? cycles.first.id : '';
});

final selectedPointsWeekProvider = Provider<PointsWeekCycle?>((ref) {
  final id = ref.watch(selectedPointsWeekIdProvider);
  final cycles = ref.watch(pointsWeekCyclesProvider);
  for (final c in cycles) {
    if (c.id == id) return c;
  }
  return cycles.isEmpty ? null : cycles.first;
});
