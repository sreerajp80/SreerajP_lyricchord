// Basic smoke test for the LyricCord placeholder home screen.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lyriccord/main.dart';

void main() {
  testWidgets('Home screen shows the app name and About action', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: LyricCordApp()));

    // App name appears (app bar title + body heading).
    expect(find.text('LyricCord'), findsWidgets);
    // About action is present.
    expect(find.byIcon(Icons.info_outline), findsOneWidget);
  });
}
