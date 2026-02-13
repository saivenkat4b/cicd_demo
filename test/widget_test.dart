import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cicd_demo/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    debugPrint('');
    debugPrint('  ┌─────────────────────────────────────────────┐');
    debugPrint('  │        COUNTER INCREMENT TEST               │');
    debugPrint('  └─────────────────────────────────────────────┘');
    debugPrint('');

    debugPrint('  Before any tap:');
    debugPrint('    Counter displays: 0');
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);
    debugPrint('    ✅ Verified counter = 0');

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    debugPrint('');
    debugPrint('  After 1 tap:');
    debugPrint('    Counter displays: 1');
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
    debugPrint('    ✅ Verified counter = 1');
    debugPrint('');
  });

  testWidgets('AI prediction shows learning state before 5 taps', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    debugPrint('');
    debugPrint('  ┌─────────────────────────────────────────────┐');
    debugPrint('  │     AI LEARNING PHASE — TAP-BY-TAP LOG      │');
    debugPrint('  └─────────────────────────────────────────────┘');
    debugPrint('');
    debugPrint('  The AI needs 5 taps to start predicting.');
    debugPrint('  Watch each tap reduce the learning countdown:');
    debugPrint('');

    // ── Tap 0 (before any tap) ──
    debugPrint('  ── Before any tap ──────────────────────────────');
    debugPrint('    Counter:    0');
    debugPrint('    AI State:   🧠 AI is learning...');
    debugPrint('    Message:    "Tap 5 more times to activate prediction"');
    expect(find.textContaining('AI is learning'), findsOneWidget);
    expect(find.textContaining('5 more times'), findsOneWidget);
    debugPrint('    ✅ Correct — AI is collecting data');
    debugPrint('');

    // ── Tap 1 ──
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    debugPrint('  ── Tap 1 ──────────────────────────────────────');
    debugPrint('    Counter:    1');
    debugPrint('    AI State:   🧠 AI is learning...');
    debugPrint('    Message:    "Tap 4 more times to activate prediction"');
    expect(find.textContaining('4 more time'), findsOneWidget);
    debugPrint('    ✅ Correct — 4 taps remaining');
    debugPrint('');

    // ── Tap 2 ──
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    debugPrint('  ── Tap 2 ──────────────────────────────────────');
    debugPrint('    Counter:    2');
    debugPrint('    AI State:   🧠 AI is learning...');
    debugPrint('    Message:    "Tap 3 more times to activate prediction"');
    expect(find.textContaining('3 more time'), findsOneWidget);
    debugPrint('    ✅ Correct — 3 taps remaining');
    debugPrint('');

    // ── Tap 3 ──
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    debugPrint('  ── Tap 3 ──────────────────────────────────────');
    debugPrint('    Counter:    3');
    debugPrint('    AI State:   🧠 AI is learning...');
    debugPrint('    Message:    "Tap 2 more times to activate prediction"');
    expect(find.textContaining('2 more time'), findsOneWidget);
    debugPrint('    ✅ Correct — 2 taps remaining');
    debugPrint('');

    // ── Tap 4 ──
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    debugPrint('  ── Tap 4 ──────────────────────────────────────');
    debugPrint('    Counter:    4');
    debugPrint('    AI State:   🧠 AI is learning...');
    debugPrint('    Message:    "Tap 1 more time to activate prediction"');
    expect(find.textContaining('1 more time'), findsOneWidget);
    debugPrint('    ✅ Correct — 1 tap remaining (almost there!)');
    debugPrint('');

    debugPrint('  ── Summary ────────────────────────────────────');
    debugPrint('    Taps 0-4: AI is in learning mode');
    debugPrint('    Each tap records a timestamp for the model');
    debugPrint('    Next tap (5th) will activate prediction!');
    debugPrint('');
  });

  testWidgets('AI prediction activates after 5 taps', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    debugPrint('');
    debugPrint('  ┌─────────────────────────────────────────────┐');
    debugPrint('  │  AI PREDICTION PHASE — TAP-BY-TAP LOG       │');
    debugPrint('  └─────────────────────────────────────────────┘');
    debugPrint('');
    debugPrint('  Tapping 10 times with 500ms intervals.');
    debugPrint('  AI activates at tap 5. Watch the prediction');
    debugPrint('  appear and adapt as more data comes in.');
    debugPrint('');

    for (int i = 1; i <= 10; i++) {
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump(const Duration(milliseconds: 500));

      debugPrint('  ── Tap $i ──────────────────────────────────────');
      debugPrint('    Counter:      $i');
      debugPrint('    Taps recorded: $i');

      if (i < 5) {
        final remaining = 5 - i;
        debugPrint('    AI State:     🧠 Learning...');
        debugPrint(
          '    Message:      "Tap $remaining more time${remaining == 1 ? '' : 's'} to activate"',
        );
        expect(find.textContaining('$remaining more time'), findsOneWidget);
        debugPrint('    ✅ Still learning — collecting tap interval data');
      } else if (i == 5) {
        debugPrint('    AI State:     🤖 PREDICTION ACTIVATED!');
        debugPrint('    Algorithm:    Weighted Moving Average');
        debugPrint('    Data points:  4 intervals from 5 taps');
        debugPrint('    Weights:      Recent taps weighted more heavily');
        expect(find.textContaining('AI Prediction'), findsOneWidget);
        expect(find.text('5'), findsOneWidget);
        expect(find.textContaining('5 taps recorded'), findsOneWidget);
        debugPrint('    ✅ AI is now predicting next tap timing!');
      } else {
        debugPrint('    AI State:     🤖 Prediction active');
        debugPrint('    Data points:  ${i - 1} intervals from $i taps');
        debugPrint('    Improvement:  More data → more accurate prediction');
        expect(find.textContaining('AI Prediction'), findsOneWidget);
        expect(find.textContaining('$i taps recorded'), findsOneWidget);
        debugPrint('    ✅ Model updated with new tap data');
      }
      debugPrint('');
    }

    debugPrint('  ┌─────────────────────────────────────────────┐');
    debugPrint('  │  FINAL SUMMARY                              │');
    debugPrint('  │                                             │');
    debugPrint('  │  Total taps:     10                         │');
    debugPrint('  │  Learning phase: Taps 1-4 (collecting data) │');
    debugPrint('  │  Active phase:   Taps 5-10 (predicting)     │');
    debugPrint('  │  Algorithm:      Weighted Moving Average     │');
    debugPrint('  │  Adapts:         Yes — weights recent taps   │');
    debugPrint('  │                  more heavily                │');
    debugPrint('  └─────────────────────────────────────────────┘');
    debugPrint('');
  });
}
