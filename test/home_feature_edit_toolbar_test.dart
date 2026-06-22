import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:family_smart_center/features/dashboard/layout/home_layout_models.dart';
import 'package:family_smart_center/features/dashboard/presentation/home_layout_editable_tile.dart';

void main() {
  group('HomeFeatureEditToolbar', () {
    testWidgets('宽度足够时平铺四个按钮', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: HomeFeatureEditToolbar(
                size: HomeCardSize.medium,
                availableWidth: 200,
                onSelectSize: (_) {},
                onHide: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.view_headline_rounded), findsOneWidget);
      expect(find.byIcon(Icons.view_agenda_outlined), findsOneWidget);
      expect(find.byIcon(Icons.view_day_outlined), findsOneWidget);
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
      expect(find.byType(PopupMenuButton<dynamic>), findsNothing);
    });

    testWidgets('宽度不足时收成单按钮菜单', (tester) async {
      HomeCardSize? selected;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 80,
                child: HomeFeatureEditToolbar(
                  size: HomeCardSize.small,
                  availableWidth: 80,
                  onSelectSize: (s) => selected = s,
                  onHide: () {},
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.view_headline_rounded), findsOneWidget);
      expect(find.byIcon(Icons.view_agenda_outlined), findsNothing);
      expect(find.byIcon(Icons.visibility_off_outlined), findsNothing);

      await tester.tap(find.byIcon(Icons.view_headline_rounded));
      await tester.pumpAndSettle();

      expect(find.text('中'), findsOneWidget);
      expect(find.text('大'), findsOneWidget);
      expect(find.text('隐藏'), findsOneWidget);

      await tester.tap(find.text('大'));
      await tester.pumpAndSettle();

      expect(selected, HomeCardSize.large);
    });
  });
}
