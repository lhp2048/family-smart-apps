import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 递增后使首页 catalog / preview 缓存失效。
final homeCardPreviewRefreshProvider = StateProvider<int>((ref) => 0);
