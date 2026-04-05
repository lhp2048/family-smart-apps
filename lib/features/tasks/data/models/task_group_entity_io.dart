import 'package:isar/isar.dart';

part 'task_group_entity_io.g.dart';

@collection
class TaskGroupEntity {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String bizDateGroupKey;

  @Index()
  late String bizDate;

  late String groupCode;

  late String title;

  late double progress;

  @Index()
  late int sort;

  late DateTime updatedAt;
}
