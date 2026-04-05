import 'package:isar/isar.dart';

part 'member_entity_io.g.dart';

/// 家庭成员（Isar，仅 IO 平台）
@collection
class MemberEntity {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String memberCode;

  late String name;

  String? avatar;

  late String role;

  late String status;

  late DateTime createdAt;

  late DateTime updatedAt;
}
