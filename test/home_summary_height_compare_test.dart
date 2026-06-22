import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:family_smart_center/features/dashboard/data/dashboard_prototype_models.dart';
import 'package:family_smart_center/features/dashboard/layout/home_card_catalog.dart';
import 'package:family_smart_center/features/dashboard/presentation/home_dashboard_cards.dart';

void main() {
  Future<double> measureHeight(
    WidgetTester tester,
    Widget child, {
    required double width,
    TextScaler textScaler = TextScaler.noScaling,
  }) async {
    final key = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(useMaterial3: true),
        home: MediaQuery(
          data: MediaQueryData(textScaler: textScaler),
          child: Scaffold(
            body: Center(
              child: SizedBox(
                width: width,
                child: KeyedSubtree(key: key, child: child),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return (key.currentContext!.findRenderObject()! as RenderBox).size.height;
  }

  testWidgets('作业3行 vs 设置摘要高度对比', (tester) async {
    const width = 161.0;
    const homeworkRows = [
      DashboardHomeworkRow('川川', '2/3'),
      DashboardHomeworkRow('曦曦', '1/3'),
      DashboardHomeworkRow('mx', '0/3'),
    ];
    final settingsEntry = homeCardCatalogEntry('settings')!;

    final homeworkH = await measureHeight(
      tester,
      HomeHomeworkSummaryCard(rows: homeworkRows, onTap: () {}),
      width: width,
    );
    final settingsH = await measureHeight(
      tester,
      HomeGenericSummaryCard(entry: settingsEntry, onTap: () {}),
      width: width,
    );

    // ignore: avoid_print
    print('homework=$homeworkH settings=$settingsH diff=${homeworkH - settingsH}');
    expect((homeworkH - settingsH).abs(), lessThan(4));
  });

  testWidgets('iOS 常见 textScale 下仍偏矮', (tester) async {
    const width = 161.0;
    const homeworkRows = [
      DashboardHomeworkRow('川川', '2/3'),
      DashboardHomeworkRow('曦曦', '1/3'),
      DashboardHomeworkRow('mx', '0/3'),
    ];
    final settingsEntry = homeCardCatalogEntry('settings')!;

    final homeworkH = await measureHeight(
      tester,
      HomeHomeworkSummaryCard(rows: homeworkRows, onTap: () {}),
      width: width,
      textScaler: const TextScaler.linear(1.1),
    );
    final settingsH = await measureHeight(
      tester,
      HomeGenericSummaryCard(entry: settingsEntry, onTap: () {}),
      width: width,
      textScaler: const TextScaler.linear(1.1),
    );

    // ignore: avoid_print
    print('scaled homework=$homeworkH settings=$settingsH diff=${homeworkH - settingsH}');
    expect((homeworkH - settingsH).abs(), lessThan(6));
  });
}
