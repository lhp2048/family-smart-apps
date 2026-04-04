import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../../features/tasks/data/models/task_date_entity.dart';
import '../../features/tasks/data/models/task_group_entity.dart';
import '../../features/tasks/data/models/task_item_entity.dart';
import '../../shared/models/feature_entry_entity.dart';
import '../../shared/models/home_summary_entity.dart';
import '../../shared/models/member_entity.dart';

final isarProvider = Provider<Isar>((ref) {
  throw UnimplementedError('Isar 未初始化，请在 bootstrap 中 override');
});

Future<Isar> openIsar() async {
  final dir = await getApplicationDocumentsDirectory();
  return Isar.open(
    [
      MemberEntitySchema,
      HomeSummaryEntitySchema,
      FeatureEntryEntitySchema,
      TaskDateEntitySchema,
      TaskGroupEntitySchema,
      TaskItemEntitySchema,
    ],
    directory: dir.path,
    inspector: false,
  );
}
