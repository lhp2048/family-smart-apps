import 'package:isar/isar.dart';

part 'task_item_entity_io.g.dart';

@collection
class TaskItemEntity {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String bizDateGroupTaskKey;

  @Index()
  late String bizDate;

  @Index()
  late String groupCode;

  late String taskCode;

  late String name;

  late int score;

  late String statusByMemberJson;

  late String completedAtByMemberJson;

  @Index()
  late int sort;

  late DateTime updatedAt;
}
