import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lyriccord/providers/theme_mode_provider.dart';
import 'package:lyriccord/screens/metronome_settings_screen.dart';

void main() {
  Future<void> pumpScreen(
    WidgetTester tester,
    Map<String, Object> initialPrefs,
  ) async {
    SharedPreferences.setMockInitialValues(initialPrefs);
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const MaterialApp(home: MetronomeSettingsScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  SwitchListTile tileFor(WidgetTester tester, String title) {
    return tester.widget<SwitchListTile>(
      find.ancestor(
        of: find.text(title),
        matching: find.byType(SwitchListTile),
      ),
    );
  }

  testWidgets('shows three switches', (tester) async {
    await pumpScreen(tester, {});

    expect(find.text('Enable metronome'), findsOneWidget);
    expect(find.text('Flash'), findsOneWidget);
    expect(find.text('Click'), findsOneWidget);
  });

  testWidgets('Flash and Click are disabled while Enable is off', (
    tester,
  ) async {
    await pumpScreen(tester, {});

    expect(tileFor(tester, 'Enable metronome').value, isFalse);
    expect(tileFor(tester, 'Flash').onChanged, isNull);
    expect(tileFor(tester, 'Click').onChanged, isNull);
  });

  testWidgets('Flash and Click become usable once Enable is on', (
    tester,
  ) async {
    await pumpScreen(tester, {'metronome_enabled': true});

    expect(tileFor(tester, 'Flash').onChanged, isNotNull);
    expect(tileFor(tester, 'Click').onChanged, isNotNull);
  });

  testWidgets('turning Enable on saves it', (tester) async {
    await pumpScreen(tester, {});

    await tester.tap(find.text('Enable metronome'));
    await tester.pumpAndSettle();

    expect(tileFor(tester, 'Enable metronome').value, isTrue);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('metronome_enabled'), isTrue);
  });

  testWidgets('turning Click off saves it', (tester) async {
    await pumpScreen(tester, {'metronome_enabled': true});

    await tester.tap(find.text('Click'));
    await tester.pumpAndSettle();

    expect(tileFor(tester, 'Click').value, isFalse);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('metronome_click'), isFalse);
  });
}
