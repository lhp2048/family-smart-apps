import 'package:isar/isar.dart';

/// Isar 3 的 `QueryBuilder` 泛型在 `findFirst` / `findAll` 上静态类型过窄，
/// 通过运行时转发与扩展方法保持一致。
extension IsarQueryCompat<O, R, S> on QueryBuilder<O, R, S> {
  Future<R?> findFirstCompat() =>
      (this as dynamic).findFirst() as Future<R?>;

  Future<List<R>> findAllCompat() =>
      (this as dynamic).findAll() as Future<List<R>>;
}
