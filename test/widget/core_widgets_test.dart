import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../lib/core/widgets/pill_badge.dart';
import '../../lib/core/widgets/progress_bar.dart';

void main() {
  group('Core Widgets Widget Tests', () {
    testWidgets('PillBadge displays correct text and renders properly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PillBadge(
              label: 'High Priority',
              textColor: Colors.red,
            ),
          ),
        ),
      );

      expect(find.text('High Priority'), findsOneWidget);
    });

    testWidgets('ProgressBar displays percentage text and updates properly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProgressBar(
              progress: 75,
              height: 10,
              showLabel: true,
            ),
          ),
        ),
      );

      expect(find.text('75%'), findsOneWidget);
      expect(find.text('Completion Progress'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('ProgressEditor preset buttons trigger value callbacks',
        (WidgetTester tester) async {
      int updatedProgress = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ProgressEditor(
                initialProgress: 20,
                onChanged: (val) {
                  updatedProgress = val;
                },
              ),
            ),
          ),
        ),
      );

      // Verify preset buttons exist
      expect(find.text('25%'), findsOneWidget);
      expect(find.text('50%'), findsOneWidget);
      expect(find.text('75%'), findsOneWidget);
      expect(find.text('100%'), findsOneWidget);

      // Tap 100%
      await tester.tap(find.text('100%'));
      await tester.pumpAndSettle();

      expect(updatedProgress, 100);

      // Tap 50%
      await tester.tap(find.text('50%'));
      await tester.pumpAndSettle();

      expect(updatedProgress, 50);
    });
  });
}
