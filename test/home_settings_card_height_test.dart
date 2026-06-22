import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:family_smart_center/features/dashboard/data/dashboard_prototype_models.dart';
import 'package:family_smart_center/features/dashboard/layout/home_card_catalog.dart';
import 'package:family_smart_center/features/dashboard/layout/home_layout_models.dart';
import 'package:family_smart_center/features/dashboard/presentation/home_dashboard_cards.dart';
import 'package:family_smart_center/features/dashboard/presentation/home_layout_editable_tile.dart';

void main() {
  final settingsEntry = homeCardCatalogEntry('settings')!;
  const settingsMenu = DashboardLifeMenuItem(
    title: '设置',
    subtitle: '应用偏好、通知与关于',
    icon: Icons.settings_rounded,
    iconBackground: Color(0xFF546E7A),
    route: '/settings',
  );

  Future<double> measureHeight(
    WidgetTester tester,
    Widget child, {
    required double width,
  }) async {
    final key = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(useMaterial3: true),
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: width,
              child: KeyedSubtree(key: key, child: child),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final box = key.currentContext!.findRenderObject()! as RenderBox;
    return box.size.height;
  }

  group('设置卡片高度', () {
    testWidgets('摘要模式：全宽高度 >= kHomeSummaryCardMinHeight', (tester) async {
      final h = await measureHeight(
        tester,
        HomeGenericSummaryCard(
          entry: settingsEntry,
          onTap: () {},
        ),
        width: 320,
      );
      expect(h, greaterThanOrEqualTo(kHomeSummaryCardMinHeight));
    });

    testWidgets('摘要模式：半宽（并排）高度 >= kHomeSummaryCardMinHeight', (tester) async {
      final h = await measureHeight(
        tester,
        HomeGenericSummaryCard(
          entry: settingsEntry,
          onTap: () {},
        ),
        width: 160,
      );
      expect(h, greaterThanOrEqualTo(kHomeSummaryCardMinHeight));
    });

    testWidgets('小号模式：全宽高度稳定', (tester) async {
      final h = await measureHeight(
        tester,
        HomeThinFeatureCard(
          item: settingsMenu,
          onTap: () {},
        ),
        width: 320,
      );
      expect(h, inInclusiveRange(88, 94));
    });

    testWidgets('小号模式：四分之一宽高度稳定', (tester) async {
      final h = await measureHeight(
        tester,
        HomeThinFeatureCard(
          item: settingsMenu,
          onTap: () {},
        ),
        width: 80,
      );
      expect(h, inInclusiveRange(88, 94));
    });

    testWidgets('小号模式：有/无 hint 高度一致', (tester) async {
      final withoutHint = await measureHeight(
        tester,
        HomeThinFeatureCard(
          item: settingsMenu,
          onTap: () {},
        ),
        width: 80,
      );
      final withHint = await measureHeight(
        tester,
        HomeThinFeatureCard(
          item: settingsMenu,
          onTap: () {},
          hint: '待实现',
        ),
        width: 80,
      );
      expect(withoutHint, withHint);
    });

    testWidgets('摘要与入口在首页典型宽度下高度关系正确', (tester) async {
      const width = 334.0;
      final summaryH = await measureHeight(
        tester,
        HomeGenericSummaryCard(entry: settingsEntry, onTap: () {}),
        width: width,
      );
      final entryH = await measureHeight(
        tester,
        HomeThinFeatureCard(item: settingsMenu, onTap: () {}),
        width: width,
      );
      expect(summaryH, kHomeSummaryCardMinHeight);
      expect(entryH, lessThan(summaryH));
      expect(entryH, inInclusiveRange(88, 94));
    });

    testWidgets('与同类型其它模块高度一致', (tester) async {
      const width = 334.0;
      final timemachineEntry = homeCardCatalogEntry('timemachine')!;
      final settingsSummaryH = await measureHeight(
        tester,
        HomeGenericSummaryCard(entry: settingsEntry, onTap: () {}),
        width: width,
      );
      final timemachineSummaryH = await measureHeight(
        tester,
        HomeGenericSummaryCard(entry: timemachineEntry, onTap: () {}),
        width: width,
      );
      expect(settingsSummaryH, timemachineSummaryH);
    });

    testWidgets('编辑态 overlay 不增加卡片内容高度', (tester) async {
      const width = 320.0;
      final cardKey = GlobalKey();
      final tileKey = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(useMaterial3: true),
          home: Scaffold(
            body: Column(
              children: [
                SizedBox(
                  width: width,
                  child: KeyedSubtree(
                    key: cardKey,
                    child: HomeThinFeatureCard(
                      item: settingsMenu,
                      onTap: () {},
                    ),
                  ),
                ),
                SizedBox(
                  width: width,
                  child: KeyedSubtree(
                    key: tileKey,
                    child: HomeLayoutEditableTile(
                      listIndex: 0,
                      borderRadius: 20,
                      outerPadding: false,
                      featureToolbarBuilder: (tileWidth) =>
                          HomeFeatureEditToolbar(
                        size: HomeCardSize.small,
                        availableWidth: tileWidth,
                        onSelectSize: (_) {},
                        onHide: () {},
                      ),
                      child: HomeThinFeatureCard(
                        item: settingsMenu,
                        onTap: () {},
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final cardH =
          (cardKey.currentContext!.findRenderObject()! as RenderBox).size.height;
      final tileH =
          (tileKey.currentContext!.findRenderObject()! as RenderBox).size.height;
      expect(tileH, cardH);
    });
  });
}
