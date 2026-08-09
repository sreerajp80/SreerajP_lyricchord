import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lyricchord/providers/theme_mode_provider.dart';
import 'package:lyricchord/widgets/performance_controls.dart';

/// The status line above the chord sheet.
///
/// The rule under test: a song written in swaras shows **no key**. A Western
/// note letter has no place on an Indian sheet, and a swara is already named
/// relative to Sa, so a key would add nothing.
void main() {
  Future<void> pumpControls(
    WidgetTester tester, {
    String currentKey = 'G',
    String? raga,
    String? tala,
  }) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(500, 1000);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: MaterialApp(
          home: Scaffold(
            body: PerformanceControls(
              currentKey: currentKey,
              bpm: 120,
              active: true,
              raga: raga,
              tala: tala,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('a Western song shows its key', (tester) async {
    await pumpControls(tester);

    expect(find.textContaining('Key G'), findsOneWidget);
    expect(find.textContaining('120 BPM'), findsOneWidget);
  });

  testWidgets('a raga song shows no key', (tester) async {
    await pumpControls(tester, raga: 'Mishra Gara', tala: 'Keherwa');

    expect(find.textContaining('Key'), findsNothing);
    expect(find.textContaining('Sa ='), findsNothing);
    expect(find.textContaining('120 BPM'), findsOneWidget);
  });

  testWidgets('a raga song still shows its raga and tala', (tester) async {
    await pumpControls(tester, raga: 'Mishra Gara', tala: 'Keherwa');

    expect(find.textContaining('Raga Mishra Gara'), findsOneWidget);
    expect(find.textContaining('Tala Keherwa'), findsOneWidget);
  });

  testWidgets('an empty raga counts as a Western song', (tester) async {
    await pumpControls(tester, raga: '');

    expect(find.textContaining('Key G'), findsOneWidget);
  });
}
