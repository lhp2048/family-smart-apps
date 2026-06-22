import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/calendar_ui_providers.dart';
import '../../../shared/providers/debate_ui_providers.dart';
import '../../../shared/providers/extracurricular_ui_providers.dart';
import '../../../shared/providers/points_ui_providers.dart';
import '../../../shared/providers/syllable_remote_providers.dart';
import '../../../shared/providers/home_ui_providers.dart';
import '../../../shared/providers/task_ui_providers.dart';
import '../../../shared/providers/timemachine_ui_providers.dart';
import '../../../shared/providers/shopping_ui_providers.dart';
import '../../../shared/providers/wishwall_ui_providers.dart';
import '../../extracurricular/data/extracurricular_models.dart';
import 'dashboard_remote_providers.dart';
import 'home_card_preview_providers.dart';

/// 清空站点或切换站点后调用：失效远程 [FutureProvider] 缓存、重置依赖远程数据的 UI 状态、递增作业/积分等刷新计数。
void invalidateFamilyApiCaches(WidgetRef ref) {
  ref.read(homeCardPreviewRefreshProvider.notifier).state++;
  ref.invalidate(familyApiDioProvider);
  ref.invalidate(familyApiClientProvider);

  ref.invalidate(taskDatesAsyncProvider);
  ref.invalidate(homeworkChildrenAsyncProvider);
  ref.invalidate(homeworkItemsBundleForDateAsyncProvider);
  ref.invalidate(familyMembersAllAsyncProvider);

  ref.invalidate(pointsMembersAsyncProvider);
  ref.invalidate(pointsRulesAsyncProvider);
  ref.invalidate(pointsWeekShellsAsyncProvider);
  ref.invalidate(pointsWeekCyclesAsyncProvider);

  ref.invalidate(wishwallItemsAsyncProvider);
  ref.invalidate(shoppingItemsAsyncProvider);
  ref.invalidate(timemachineMonthChipsAsyncProvider);
  ref.invalidate(timemachineBundleAsyncProvider);

  ref.invalidate(debateRemoteDaysAsyncProvider);
  ref.invalidate(debateSelectedBundleAsyncProvider);

  ref.invalidate(extracurricularRemoteFiltersAsyncProvider);
  ref.invalidate(extracurricularRemoteItemsAsyncProvider);

  ref.invalidate(syllableLatestSheetAsyncProvider);
  ref.invalidate(featureEntriesAsyncProvider);

  ref.read(taskRemoteRefreshProvider.notifier).state++;

  ref.read(calendarRemoteRefreshProvider.notifier).state++;
  ref.read(calendarSelectedBizDateProvider.notifier).state = null;
  ref.read(calendarFocusedMonthKeyProvider.notifier).state =
      '${DateTime.now().year.toString().padLeft(4, '0')}-${DateTime.now().month.toString().padLeft(2, '0')}';

  ref.read(selectedPointsWeekIdProvider.notifier).state = '';
  ref.read(selectedDebateBizDateProvider.notifier).state = '';
  ref.read(timemachineSelectedBizDateProvider.notifier).state = null;
  ref.read(timemachineSelectedMonthKeyProvider.notifier).state = null;
  ref.read(wishwallFilterIdProvider.notifier).state = 'all';
  ref.read(extracurricularFilterIdProvider.notifier).state =
      ExtracurricularFilterIds.all;
  ref.read(syllableLatestSheetMemoryCacheProvider.notifier).state = null;
}
