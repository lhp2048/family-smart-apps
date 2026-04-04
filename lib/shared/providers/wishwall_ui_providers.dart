import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/mock/mock_data_notifier.dart';
import '../../features/wishwall/data/wishwall_prototype_models.dart';

final wishwallItemsProvider = Provider<List<WishwallItem>>((ref) {
  return ref.watch(mockDataNotifierProvider).wishwallItems;
});

/// 筛选：`all` | `xixi` | `chuan` | `mx` | `unrealized` | `realized`
final wishwallFilterIdProvider = StateProvider<String>((ref) => 'all');

final filteredWishwallItemsProvider = Provider<List<WishwallItem>>((ref) {
  final items = ref.watch(wishwallItemsProvider);
  final filter = ref.watch(wishwallFilterIdProvider);
  return items.where((w) {
    switch (filter) {
      case 'xixi':
        return w.memberCode == 'xixi';
      case 'chuan':
        return w.memberCode == 'chuan';
      case 'mx':
        return w.memberCode == 'mx';
      case 'unrealized':
        return !w.fulfilled;
      case 'realized':
        return w.fulfilled;
      case 'all':
      default:
        return true;
    }
  }).toList();
});

String wishwallFilterSubtitleLabel(String filterId) {
  switch (filterId) {
    case 'xixi':
      return '曦曦的心愿';
    case 'chuan':
      return '川川的心愿';
    case 'mx':
      return 'mx 的心愿';
    case 'unrealized':
      return '未实现心愿';
    case 'realized':
      return '已实现心愿';
    case 'all':
    default:
      return '全部心愿';
  }
}
