import 'package:isar/isar.dart';

part 'task_date_entity.g.dart';

@collection
class TaskDateEntity {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String bizDate;

  late String weekday;

  late bool hasReward;

  late DateTime updatedAt;
}
