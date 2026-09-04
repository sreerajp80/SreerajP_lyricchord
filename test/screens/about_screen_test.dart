import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lyricchord/core/config/app_config.dart';
import 'package:lyricchord/core/constants/app_version.g.dart';
import 'package:lyricchord/core/constants/build_date.g.dart';
import 'package:lyricchord/providers/config_provider.dart';
import 'package:lyricchord/screens/about_screen.dart';

void main() {
  const testConfig = AppConfig(
    appName: 'LyricChord',
    description: 'A lyrics & chords notebook for musicians.',
    // Deliberately stale values: the screen must prefer the generated ones.
    version: '0.0.1',
    build: '1',
    details: {'Author': 'Sreeraj P'},
  );

  Future<void> pumpAbout(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appConfigProvider.overrideWith((ref) async => testConfig)],
        child: const MaterialApp(home: AboutScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows the generated version, not the config version', (
    tester,
  ) async {
    await pumpAbout(tester);

    final parts = kAppVersion.split('+');
    final expected = parts.length == 2
        ? 'Version ${parts[0]} (build ${parts[1]})'
        : 'Version $kAppVersion';

    expect(find.text(expected), findsOneWidget);
    expect(find.text('Version 0.0.1 (build 1)'), findsNothing);
  });

  testWidgets('shows the generated build date', (tester) async {
    await pumpAbout(tester);

    expect(find.text('Build date'), findsOneWidget);
    expect(find.text(kBuildDate), findsOneWidget);
  });
}
