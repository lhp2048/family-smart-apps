import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/mock/mock_data_notifier.dart';
import '../../features/extracurricular/data/extracurricular_models.dart';

final extracurricularItemsProvider = Provider<List<ExtracurricularItem>>((ref) {
  return ref.watch(mockDataNotifierProvider).extracurricularItems;
});

final extracurricularFilterIdProvider =
    StateProvider<String>((ref) => ExtracurricularFilterIds.all);

final extracurricularUnwatchedOnlyProvider = StateProvider<bool>((ref) => false);

final filteredExtracurricularItemsProvider =
    Provider<List<ExtracurricularItem>>((ref) {
  final items = ref.watch(extracurricularItemsProvider);
  final filter = ref.watch(extracurricularFilterIdProvider);
  final onlyUnwatched = ref.watch(extracurricularUnwatchedOnlyProvider);

  return items.where((e) {
    if (filter != ExtracurricularFilterIds.all && e.filterId != filter) {
      return false;
    }
    if (onlyUnwatched && e.watched) return false;
    return true;
  }).toList();
});
