import 'package:isar/isar.dart';

part 'feature_entry_entity.g.dart';

/// 首页功能入口配置
@collection
class FeatureEntryEntity {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String entryKey;

  late String title;

  /// Material Icons 名称片段，如 `fact_check_outlined`
  late String icon;

  @Index()
  late int sort;

  late bool enabled;

  late DateTime updatedAt;
}
