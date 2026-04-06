import 'models/task_item_entity.dart';

/// 某日作业数据：要么全员共用一份扁平列表（Mock / 经典 API），要么按成员 `memberCode` 分块（每人一行接口）。
final class HomeworkItemsBundle {
  HomeworkItemsBundle._(this._flat, this._byMember);

  factory HomeworkItemsBundle.flat(List<TaskItemEntity> items) =>
      HomeworkItemsBundle._(items, null);

  factory HomeworkItemsBundle.byMember(Map<String, List<TaskItemEntity>> by) =>
      HomeworkItemsBundle._(null, Map<String, List<TaskItemEntity>>.from(by));

  final List<TaskItemEntity>? _flat;
  final Map<String, List<TaskItemEntity>>? _byMember;

  bool get isPerMember => _byMember != null;

  bool get hasAnyItems {
    final f = _flat;
    if (f != null) return f.isNotEmpty;
    final m = _byMember;
    return m != null && m.values.any((l) => l.isNotEmpty);
  }

  /// 某孩子卡片使用的作业行；扁平模式下与所有人相同。
  List<TaskItemEntity> itemsForMemberCode(String memberCode) {
    final f = _flat;
    if (f != null) return f;
    final m = _byMember;
    if (m == null) return const [];
    return m[memberCode] ?? const [];
  }

  /// 按成员码排序后拼接（仅用于调试/烟测等需「所有行」的场景）。
  List<TaskItemEntity> flattenedMembersSorted() {
    final f = _flat;
    if (f != null) return List<TaskItemEntity>.from(f);
    final m = _byMember;
    if (m == null) return const [];
    final keys = m.keys.toList()..sort();
    final out = <TaskItemEntity>[];
    for (final k in keys) {
      out.addAll(m[k] ?? const []);
    }
    return out;
  }

  /// 扁平模式为单段 `*`；按成员分块时为各 `memberCode`（已排序）。
  void forEachMemberSection(
    void Function(String sectionLabel, List<TaskItemEntity> items) fn,
  ) {
    final f = _flat;
    if (f != null) {
      fn('*', f);
      return;
    }
    final m = _byMember;
    if (m == null) return;
    final keys = m.keys.toList()..sort();
    for (final k in keys) {
      fn(k, m[k] ?? const []);
    }
  }

  /// 合并多次 `fetchTaskItems(..., groupCode:)` 的结果。
  static HomeworkItemsBundle mergeGroupFetches(
    List<HomeworkItemsBundle> parts,
    List<TaskItemEntity> Function(List<TaskItemEntity>) dedupeFlat,
  ) {
    if (parts.isEmpty) {
      return HomeworkItemsBundle.flat(const []);
    }
    final mergedByMember = <String, List<TaskItemEntity>>{};
    final flatChunks = <List<TaskItemEntity>>[];
    for (final p in parts) {
      final bm = p._byMember;
      if (bm != null) {
        for (final e in bm.entries) {
          mergedByMember.putIfAbsent(e.key, () => []).addAll(e.value);
        }
      } else {
        final fl = p._flat;
        if (fl != null && fl.isNotEmpty) {
          flatChunks.add(fl);
        }
      }
    }
    if (mergedByMember.isNotEmpty) {
      for (final list in mergedByMember.values) {
        list.sort((a, b) => a.sort.compareTo(b.sort));
      }
      return HomeworkItemsBundle.byMember(mergedByMember);
    }
    final combined = <TaskItemEntity>[];
    for (final c in flatChunks) {
      combined.addAll(c);
    }
    combined.sort((a, b) => a.sort.compareTo(b.sort));
    return HomeworkItemsBundle.flat(dedupeFlat(combined));
  }
}
