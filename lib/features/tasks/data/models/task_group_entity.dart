import 'package:isar/isar.dart';

part 'task_group_entity.g.dart';

@collection
class TaskGroupEntity {
  Id id = Isar.autoIncrement;

  /// `bizDate|groupCode`，唯一
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
