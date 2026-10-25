import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lyricchord/l10n/app_localizations.dart';
import 'package:lyricchord/l10n/app_localizations_delegates.dart';
import 'package:lyricchord/providers/theme_mode_provider.dart';
import 'package:lyricchord/screens/metronome_settings_screen.dart';
import 'package:lyricchord/services/metronome_audio_service.dart';

import '../helpers/fake_metronome_audio.dart';

void main() {
  late FakeMetronomeAudio audio;

  Future<void> pumpScreen(
    WidgetTester tester,
    Map<String, Object> initialPrefs,
  ) async {
    SharedPreferences.setMockInitialValues(initialPrefs);
    final prefs = await SharedPreferences.getInstance();
    audio = FakeMetronomeAudio();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          metronomeAudioProvider.overrideWithValue(audio),
        ],
        child: const MaterialApp(
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MetronomeSettingsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Scrolls the list up so the last tile is fully inside the test viewport.
  ///
  /// The Test tile sits right on the 600 px bottom edge, and a tap aimed at the
  /// edge lands outside the view and hits nothing.
  Future<void> scrollToBottom(WidgetTester tester) async {
    await tester.drag(find.byType(ListView), const Offset(0, -250));
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

  testWidgets('shows every metronome control', (tester) async {
    await pumpScreen(tester, {});

    expect(find.text('Enable metronome'), findsOneWidget);
    expect(find.text('Flash'), findsOneWidget);
    expect(find.text('Click'), findsOneWidget);
    expect(find.text('Click volume'), findsOneWidget);
    expect(find.text('Beats in a bar'), findsOneWidget);
    expect(find.text('Accent beat 1'), findsOneWidget);
    expect(find.text('Test the sound'), findsOneWidget);
  });

  testWidgets('everything is disabled while Enable is off', (tester) async {
    await pumpScreen(tester, {});

    expect(tileFor(tester, 'Enable metronome').value, isFalse);
    expect(tileFor(tester, 'Flash').onChanged, isNull);
    expect(tileFor(tester, 'Click').onChanged, isNull);
    expect(tileFor(tester, 'Accent beat 1').onChanged, isNull);

    final volume = tester.widget<Slider>(find.byType(Slider));
    expect(volume.onChanged, isNull);
  });

  testWidgets('the controls become usable once Enable is on', (tester) async {
    await pumpScreen(tester, {'metronome_enabled': true});

    expect(tileFor(tester, 'Flash').onChanged, isNotNull);
    expect(tileFor(tester, 'Click').onChanged, isNotNull);
    expect(tileFor(tester, 'Accent beat 1').onChanged, isNotNull);
    expect(tester.widget<Slider>(find.byType(Slider)).onChanged, isNotNull);
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

  testWidgets('the volume slider is disabled when Click is off', (
    tester,
  ) async {
    await pumpScreen(tester, {
      'metronome_enabled': true,
      'metronome_click': false,
    });

    expect(tester.widget<Slider>(find.byType(Slider)).onChanged, isNull);
  });

  testWidgets('turning the accent off saves it', (tester) async {
    await pumpScreen(tester, {'metronome_enabled': true});

    await tester.tap(find.text('Accent beat 1'));
    await tester.pumpAndSettle();

    expect(tileFor(tester, 'Accent beat 1').value, isFalse);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('metronome_accent'), isFalse);
  });

  testWidgets('picking 3 beats in a bar saves it', (tester) async {
    await pumpScreen(tester, {'metronome_enabled': true});

    final segment = find.descendant(
      of: find.byType(SegmentedButton<int>),
      matching: find.text('3'),
    );
    await tester.ensureVisible(segment);
    await tester.tap(segment);
    await tester.pumpAndSettle();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt('metronome_beats_per_bar'), 3);
  });

  testWidgets('the Test button plays one bar, accent first', (tester) async {
    await pumpScreen(tester, {'metronome_enabled': true});

    await scrollToBottom(tester);
    await tester.tap(find.text('Test the sound'));
    await tester.pump();
    // One bar of 4/4 at 100 BPM: 600 ms per beat is plenty of room.
    await tester.pump(const Duration(seconds: 3));

    expect(audio.prepareCount, 1, reason: 'the click must be loaded first');
    expect(audio.played, ['accent', 'normal', 'normal', 'normal']);
    expect(audio.volume, 0.8, reason: 'plays at the saved volume');
    await tester.pumpAndSettle();
  });

  testWidgets('the Test button is disabled while the metronome is off', (
    tester,
  ) async {
    await pumpScreen(tester, {});

    final tile = tester.widget<ListTile>(
      find.ancestor(
        of: find.text('Test the sound'),
        matching: find.byType(ListTile),
      ),
    );
    expect(tile.onTap, isNull);
  });

  testWidgets('the test bar follows the chosen beats in a bar', (tester) async {
    await pumpScreen(tester, {
      'metronome_enabled': true,
      'metronome_beats_per_bar': 2,
    });

    await scrollToBottom(tester);
    await tester.tap(find.text('Test the sound'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));

    expect(audio.played, ['accent', 'normal']);
    await tester.pumpAndSettle();
  });
}
