import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lyricchord/l10n/app_localizations.dart';
import 'package:lyricchord/l10n/app_localizations_delegates.dart';
import 'package:lyricchord/core/config/app_config.dart';
import 'package:lyricchord/core/constants/app_version.g.dart';
import 'package:lyricchord/core/constants/build_date.g.dart';
import 'package:lyricchord/providers/config_provider.dart';
import 'package:lyricchord/screens/about_screen.dart';

import '../helpers/tooltip_expectations.dart';

void main() {
  const testConfig = AppConfig(
    appName: LocalizedText.byLocale({'en': 'LyricChord', 'ml': 'LyricChord'}),
    description: LocalizedText.byLocale({
      'en': 'A lyrics & chords notebook for musicians.',
      'ml': 'Malayalam description',
    }),
    // Deliberately stale values: the screen must prefer the generated ones.
    version: '0.0.1',
    build: '1',
    details: {
      'author': LocalizedText.byLocale({'en': 'Sreeraj P'}),
      'email': LocalizedText.plain('support@example.com'),
      'newRowKey': LocalizedText.plain('Shown with its raw key'),
      'empty': LocalizedText.plain('   '),
    },
  );

  Future<void> pumpAbout(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appConfigProvider.overrideWith((ref) async => testConfig)],
        child: const MaterialApp(
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: AboutScreen(),
        ),
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

  testWidgets('detail rows use translated labels and the English values', (
    tester,
  ) async {
    await pumpAbout(tester);

    expect(find.text('Author'), findsOneWidget);
    expect(find.text('Sreeraj P'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('support@example.com'), findsOneWidget);
    expect(
      find.text('A lyrics & chords notebook for musicians.'),
      findsOneWidget,
    );
    expect(find.text('Malayalam description'), findsNothing);
    expectAllIconButtonsHaveTooltips(tester);
  });

  testWidgets('a key with no label yet still shows, under its raw key', (
    tester,
  ) async {
    await pumpAbout(tester);

    expect(find.text('newRowKey'), findsOneWidget);
    expect(find.text('Shown with its raw key'), findsOneWidget);
  });

  testWidgets('a row whose value is blank is skipped', (tester) async {
    await pumpAbout(tester);

    expect(find.text('empty'), findsNothing);
  });
}
