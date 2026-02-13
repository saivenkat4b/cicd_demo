import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cicd_demo/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Counter has incremented to 1.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('AI prediction shows learning state before 5 taps', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    // Before any tap, the AI card should show "learning" message.
    expect(find.textContaining('AI is learning'), findsOneWidget);
    expect(find.textContaining('5 more times'), findsOneWidget);

    // After 1 tap, still learning (need 4 more).
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    expect(find.textContaining('4 more time'), findsOneWidget);

    // After 2 taps → 3 more.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    expect(find.textContaining('3 more time'), findsOneWidget);
  });

  testWidgets('AI prediction activates after 5 taps', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    // Tap 5 times to activate prediction.
    for (int i = 0; i < 5; i++) {
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump(const Duration(milliseconds: 500));
    }

    // The AI prediction card should now be active.
    expect(find.textContaining('AI Prediction'), findsOneWidget);

    // Counter should be at 5.
    expect(find.text('5'), findsOneWidget);

    // Tap history chip should show 5 taps.
    expect(find.textContaining('5 taps recorded'), findsOneWidget);
  });
}
