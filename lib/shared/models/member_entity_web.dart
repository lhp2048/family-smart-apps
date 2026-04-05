/// Web：无 Isar，字段与 [member_entity_io] 对齐供 Mock / UI 使用
class MemberEntity {
  MemberEntity();

  int id = 0;

  late String memberCode;

  late String name;

  String? avatar;

  late String role;

  late String status;

  late DateTime createdAt;

  late DateTime updatedAt;
}
