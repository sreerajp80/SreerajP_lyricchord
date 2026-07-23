import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lyriccord/providers/theme_mode_provider.dart';
import 'package:lyriccord/screens/chord_settings_screen.dart';
import 'package:lyriccord/screens/font_settings_screen.dart';
import 'package:lyriccord/screens/general_settings_screen.dart';
import 'package:lyriccord/screens/import_export_screen.dart';
import 'package:lyriccord/screens/metronome_settings_screen.dart';
import 'package:lyriccord/screens/settings_screen.dart';
import 'package:lyriccord/screens/theme_settings_screen.dart';

void main() {
  Future<void> pumpSettings(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    // The real routes, with About stubbed out so this test does not depend
    // on the About screen's asset loading.
    final router = GoRouter(
      initialLocation: '/settings',
      routes: [
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
          routes: [
            GoRoute(
              path: 'general',
              builder: (context, state) => const GeneralSettingsScreen(),
              routes: [
                GoRoute(
                  path: 'import',
                  builder: (context, state) => const ImportExportScreen(),
                ),
                GoRoute(
                  path: 'metronome',
                  builder: (context, state) => const MetronomeSettingsScreen(),
                ),
              ],
            ),
            GoRoute(
              path: 'themes',
              builder: (context, state) => const ThemeSettingsScreen(),
            ),
            GoRoute(
              path: 'chords',
              builder: (context, state) => const ChordSettingsScreen(),
            ),
            GoRoute(
              path: 'fonts',
              builder: (context, state) => const FontSettingsScreen(),
            ),
          ],
        ),
        GoRoute(
          path: '/about',
          builder: (context, state) => const Scaffold(body: Text('About stub')),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows the five settings cards', (tester) async {
    await pumpSettings(tester);

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('General'), findsOneWidget);
    expect(find.text('Themes'), findsOneWidget);
    expect(find.text('Chords'), findsOneWidget);
    expect(find.text('Fonts'), findsOneWidget);
    expect(find.text('About'), findsOneWidget);
    expect(find.byType(Card), findsNWidgets(5));
  });

  testWidgets('the General card opens the General screen', (tester) async {
    await pumpSettings(tester);

    await tester.tap(find.text('General'));
    await tester.pumpAndSettle();

    expect(find.byType(GeneralSettingsScreen), findsOneWidget);
    expect(find.text('Import'), findsOneWidget);
    expect(find.text('Metronome'), findsOneWidget);
  });

  testWidgets('General → Import opens the import screen', (tester) async {
    await pumpSettings(tester);

    await tester.tap(find.text('General'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Import'));
    await tester.pumpAndSettle();

    expect(find.byType(ImportExportScreen), findsOneWidget);
    expect(find.text('Import ChordPro file'), findsOneWidget);
  });

  testWidgets('General → Metronome opens the metronome screen', (tester) async {
    await pumpSettings(tester);

    await tester.tap(find.text('General'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Metronome'));
    await tester.pumpAndSettle();

    expect(find.byType(MetronomeSettingsScreen), findsOneWidget);
    expect(find.text('Enable metronome'), findsOneWidget);
  });

  testWidgets('the Themes card opens the theme choices', (tester) async {
    await pumpSettings(tester);

    await tester.tap(find.text('Themes'));
    await tester.pumpAndSettle();

    expect(find.byType(ThemeSettingsScreen), findsOneWidget);
    expect(find.text('System theme'), findsOneWidget);
    expect(find.text('Light theme'), findsOneWidget);
    expect(find.text('Dark theme'), findsOneWidget);
  });

  testWidgets('the Chords card opens the custom chords screen', (tester) async {
    await pumpSettings(tester);

    await tester.tap(find.text('Chords'));
    await tester.pumpAndSettle();

    expect(find.byType(ChordSettingsScreen), findsOneWidget);
  });

  testWidgets('the Fonts card opens the font choices', (tester) async {
    await pumpSettings(tester);

    await tester.tap(find.text('Fonts'));
    await tester.pumpAndSettle();

    expect(find.byType(FontSettingsScreen), findsOneWidget);
  });

  testWidgets('the About card opens the About route', (tester) async {
    await pumpSettings(tester);

    await tester.tap(find.text('About'));
    await tester.pumpAndSettle();

    expect(find.text('About stub'), findsOneWidget);
  });

  testWidgets('back returns from a sub-screen to Settings', (tester) async {
    await pumpSettings(tester);

    await tester.tap(find.text('Themes'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(find.byType(SettingsScreen), findsOneWidget);
  });

  testWidgets('picking a theme saves it', (tester) async {
    await pumpSettings(tester);

    await tester.tap(find.text('Themes'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dark theme'));
    await tester.pumpAndSettle();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('theme_mode'), 'dark');
  });
}
