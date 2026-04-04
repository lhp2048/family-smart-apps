import 'package:isar/isar.dart';

part 'home_summary_entity.g.dart';

/// 首页汇总（按业务日一条）
@collection
class HomeSummaryEntity {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String bizDate;

  late double taskProgress;

  late String memberScoresJson;

  late DateTime updatedAt;
}
