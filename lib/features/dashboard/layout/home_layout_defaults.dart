import 'home_layout_models.dart';

HomeLayoutConfig get kDefaultHomeLayoutConfig => const HomeLayoutConfig(
      items: [
        HomeFeatureLayoutItem(
          itemId: 'feat-homework',
          cardId: 'homework',
          size: HomeCardSize.summary,
        ),
        HomeFeatureLayoutItem(
          itemId: 'feat-points',
          cardId: 'points',
          size: HomeCardSize.summary,
        ),
        HomeSeparatorLayoutItem(
          itemId: 'sep-life',
          title: '学习和生活',
        ),
        HomeFeatureLayoutItem(
          itemId: 'feat-wishwall',
          cardId: 'wishwall',
          size: HomeCardSize.entry,
        ),
        HomeFeatureLayoutItem(
          itemId: 'feat-timemachine',
          cardId: 'timemachine',
          size: HomeCardSize.entry,
        ),
        HomeFeatureLayoutItem(
          itemId: 'feat-debate',
          cardId: 'debate',
          size: HomeCardSize.entry,
        ),
        HomeFeatureLayoutItem(
          itemId: 'feat-english-bonus',
          cardId: 'english-bonus',
          size: HomeCardSize.entry,
        ),
        HomeFeatureLayoutItem(
          itemId: 'feat-extracurricular',
          cardId: 'extracurricular',
          size: HomeCardSize.entry,
        ),
        HomeSeparatorLayoutItem(
          itemId: 'sep-system',
          title: '系统和配置',
        ),
        HomeFeatureLayoutItem(
          itemId: 'feat-settings',
          cardId: 'settings',
          size: HomeCardSize.entry,
        ),
      ],
    );
