import 'home_layout_models.dart';

HomeLayoutConfig get kDefaultHomeLayoutConfig => const HomeLayoutConfig(
      items: [
        HomeFeatureLayoutItem(
          itemId: 'feat-homework',
          cardId: 'homework',
          size: HomeCardSize.medium,
        ),
        HomeFeatureLayoutItem(
          itemId: 'feat-points',
          cardId: 'points',
          size: HomeCardSize.medium,
        ),
        HomeFeatureLayoutItem(
          itemId: 'feat-calendar',
          cardId: 'calendar',
          size: HomeCardSize.medium,
        ),
        HomeSeparatorLayoutItem(
          itemId: 'sep-life',
          title: '学习和生活',
        ),
        HomeFeatureLayoutItem(
          itemId: 'feat-wishwall',
          cardId: 'wishwall',
          size: HomeCardSize.small,
        ),
        HomeFeatureLayoutItem(
          itemId: 'feat-timemachine',
          cardId: 'timemachine',
          size: HomeCardSize.small,
        ),
        HomeFeatureLayoutItem(
          itemId: 'feat-debate',
          cardId: 'debate',
          size: HomeCardSize.small,
        ),
        HomeFeatureLayoutItem(
          itemId: 'feat-english-bonus',
          cardId: 'english-bonus',
          size: HomeCardSize.small,
        ),
        HomeFeatureLayoutItem(
          itemId: 'feat-extracurricular',
          cardId: 'extracurricular',
          size: HomeCardSize.small,
        ),
        HomeFeatureLayoutItem(
          itemId: 'feat-shopping',
          cardId: 'shopping',
          size: HomeCardSize.small,
        ),
        HomeSeparatorLayoutItem(
          itemId: 'sep-system',
          title: '系统和配置',
        ),
        HomeFeatureLayoutItem(
          itemId: 'feat-settings',
          cardId: 'settings',
          size: HomeCardSize.small,
        ),
      ],
    );
