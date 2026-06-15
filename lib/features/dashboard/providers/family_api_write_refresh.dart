import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'family_api_cache_invalidation.dart';

/// 写操作成功后递增远程刷新计数并失效首页等缓存。
void refreshAfterFamilyApiWrite(WidgetRef ref) {
  invalidateFamilyApiCaches(ref);
}
