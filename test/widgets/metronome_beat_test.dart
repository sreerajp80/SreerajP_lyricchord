import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lyricchord/providers/theme_mode_provider.dart';
import 'package:lyricchord/widgets/metronome_beat.dart';

void main() {
  Future<void> pumpButton(
    WidgetTester tester, {
    required int bpm,
    bool active = true,
    Map<String, Object> prefs = const {'metronome_enabled': true},
  }) async {
    SharedPreferences.setMockInitialValues(prefs);
    final sp = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(sp)],
        child: MaterialApp(
          home: Scaffold(
            body: MetronomeBeat(bpm: bpm, active: active),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('starts stopped, showing the timer icon', (tester) async {
    await pumpButton(tester, bpm: 120);

    expect(find.byIcon(Icons.av_timer), findsOneWidget);
    expect(find.byIcon(Icons.stop), findsNothing);
  });

  testWidgets('tapping starts the beat and shows the stop icon', (
    tester,
  ) async {
    await pumpButton(tester, bpm: 120);

    await tester.tap(find.byType(MetronomeBeat));
    await tester.pump();

    expect(find.byIcon(Icons.stop), findsOneWidget);

    // Tapping again stops it. Stop the ticker before the test ends so no timer
    // is left running.
    await tester.tap(find.byType(MetronomeBeat));
    await tester.pump();
    expect(find.byIcon(Icons.av_timer), findsOneWidget);
  });

  testWidgets('a zero tempo cannot start', (tester) async {
    await pumpButton(tester, bpm: 0);

    await tester.tap(find.byType(MetronomeBeat));
    await tester.pump();

    // Still stopped — the button is disabled with no valid tempo.
    expect(find.byIcon(Icons.av_timer), findsOneWidget);
    expect(find.byIcon(Icons.stop), findsNothing);
  });
}
