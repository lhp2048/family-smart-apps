import 'package:isar/isar.dart';

part 'task_item_entity.g.dart';

@collection
class TaskItemEntity {
  Id id = Isar.autoIncrement;

  /// `bizDate|groupCode|taskCode`，唯一
  @Index(unique: true, replace: true)
  late String bizDateGroupTaskKey;

  @Index()
  late String bizDate;

  @Index()
  late String groupCode;

  late String taskCode;

  late String name;

  late int score;

  /// `{"memberCode": true/false}` JSON
  late String statusByMemberJson;

  /// `{"memberCode":"HH:mm"}` JSON，仅已完成成员有键
  late String completedAtByMemberJson;

  @Index()
  late int sort;

  late DateTime updatedAt;
}
