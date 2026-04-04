import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/isar_provider.dart';
import '../../features/dashboard/data/home_repository.dart';
import '../../features/tasks/data/task_repository.dart';

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepository(ref.watch(isarProvider));
});

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository(
    ref.watch(isarProvider),
    ref.watch(homeRepositoryProvider),
  );
});
