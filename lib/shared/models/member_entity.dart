import 'package:isar/isar.dart';

part 'member_entity.g.dart';

/// 家庭成员（Isar 首表，用于 Sprint 0 验证本地库）
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
