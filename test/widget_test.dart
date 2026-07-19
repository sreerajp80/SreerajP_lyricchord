// Basic smoke test for the LyricCord placeholder home screen.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lyriccord/main.dart';
import 'package:lyriccord/providers/theme_mode_provider.dart';

void main() {
  testWidgets('Home screen shows the app name and About action', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const LyricCordApp(),
      ),
    );

    // App name appears (app bar title + body heading).
    expect(find.text('LyricCord'), findsWidgets);
    // About action is present.
    expect(find.byIcon(Icons.info_outline), findsOneWidget);
  });
}
