import 'package:isar/isar.dart';

part 'feature_entry_entity_io.g.dart';

/// 首页功能入口配置（Isar，仅 IO）
@collection
class FeatureEntryEntity {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String entryKey;

  late String title;

  late String icon;

  @Index()
  late int sort;

  late bool enabled;

  late DateTime updatedAt;
}
