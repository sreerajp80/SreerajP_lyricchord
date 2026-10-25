// Every screen must work in every declared language (engineering standard
// §8.7): no overflow, no errors, and no English text leaking through under
// Malayalam or Sanskrit. This pumps the main screens once per language.
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lyricchord/l10n/app_localizations.dart';
import 'package:lyricchord/l10n/app_localizations_delegates.dart';
import 'package:lyricchord/providers/database_provider.dart';
import 'package:lyricchord/providers/theme_mode_provider.dart';
import 'package:lyricchord/screens/chord_settings_screen.dart';
import 'package:lyricchord/screens/font_settings_screen.dart';
import 'package:lyricchord/screens/general_settings_screen.dart';
import 'package:lyricchord/screens/help/help_content.dart';
import 'package:lyricchord/screens/help/help_detail_screen.dart';
import 'package:lyricchord/screens/help/help_screen.dart';
import 'package:lyricchord/screens/home_shell.dart';
import 'package:lyricchord/screens/import_export_screen.dart';
import 'package:lyricchord/screens/import_settings_screen.dart';
import 'package:lyricchord/screens/language_settings_screen.dart';
import 'package:lyricchord/screens/metronome_settings_screen.dart';
import 'package:lyricchord/screens/pitch_drone_settings_screen.dart';
import 'package:lyricchord/screens/scroll_settings_screen.dart';
import 'package:lyricchord/screens/settings_screen.dart';
import 'package:lyricchord/screens/song_editor_screen.dart';
import 'package:lyricchord/screens/theme_settings_screen.dart';
import 'package:lyricchord/theme/app_theme.dart';

import '../helpers/fake_song_repository.dart';

/// English values that may show unchanged in another language: brand names,
/// formats and notation (the same list as translation_parity_test.dart).
const _sameAsEnglishAllowed = <String>{
  'titleApp',
  'labelSongListFormatChordPro',
  'labelSongListFormatPdf',
  'labelMetronomeBpmUnit',
  'labelSongCardBpm',
  'labelInfoBpm',
  'labelEditorSummaryBpm',
  'labelAirQrFps',
  'labelSongMetaKeyHint',
  'labelSongMetaTempoHint',
  'labelChordInserterChordHint',
  'titlePerfSetlistPosition',
};

Map<String, String> _arb(String code) {
  final map =
      jsonDecode(File('lib/l10n/app_$code.arb').readAsStringSync())
          as Map<String, dynamic>;
  return {
    for (final e in map.entries)
      if (!e.key.startsWith('@')) e.key: e.value as String,
  };
}

/// The English texts that must not appear under [code]: every plain English
/// message (no placeholders) that the language translates differently.
Set<String> _englishOnly(String code) {
  final english = _arb('en');
  final other = _arb(code);
  return {
    for (final e in english.entries)
      if (!_sameAsEnglishAllowed.contains(e.key) &&
          !e.value.contains('{') &&
          e.value.trim().length > 2 &&
          other[e.key] != e.value)
        e.value.replaceAll("''", "'"),
  };
}

/// Every text on screen, from plain and rich text widgets.
List<String> _visibleTexts(WidgetTester tester) => [
  for (final widget in tester.widgetList(find.byType(RichText)))
    (widget as RichText).text.toPlainText(),
];

/// Loads a bundled font so Malayalam and Devanagari text is measured with
/// its real glyph widths. Without it the test font draws every character as
/// a wide square, which makes Indic words look far longer than on a phone.
Future<void> _loadFont(String family, String asset) async {
  final loader = FontLoader(family)
    ..addFont(rootBundle.load(asset).then((data) => data));
  await loader.load();
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await _loadFont(
      'Noto Sans Malayalam',
      'assets/fonts/NotoSansMalayalam-Regular.ttf',
    );
    await _loadFont(
      'Noto Sans Devanagari',
      'assets/fonts/NotoSansDevanagari-Regular.ttf',
    );
  });

  final screens = <String, Widget Function()>{
    'home': () => const HomeShell(),
    'settings': () => const SettingsScreen(),
    'general': () => const GeneralSettingsScreen(),
    'import & export': () => const ImportExportScreen(),
    'import settings': () => const ImportSettingsScreen(),
    'scroll settings': () => const ScrollSettingsScreen(),
    'metronome settings': () => const MetronomeSettingsScreen(),
    'pitch & drone settings': () => const PitchDroneSettingsScreen(),
    'themes': () => const ThemeSettingsScreen(),
    'chords': () => const ChordSettingsScreen(),
    'fonts': () => const FontSettingsScreen(),
    'language': () => const LanguageSettingsScreen(),
    'editor': () => const SongEditorScreen(),
    'help hub': () => const HelpScreen(),
  };

  for (final locale in AppLocalizations.supportedLocales) {
    final code = locale.languageCode;
    final englishOnly = code == 'en' ? <String>{} : _englishOnly(code);
    final helpIds = helpTopics(lookupAppLocalizations(locale)).map((t) => t.id);

    final all = <String, Widget Function()>{
      ...screens,
      for (final id in helpIds)
        'help: $id': () => HelpDetailScreen(topicId: id),
    };

    for (final entry in all.entries) {
      testWidgets('$code: ${entry.key} builds with no overflow or English', (
        tester,
      ) async {
        // A small phone, so long words are the most likely to overflow.
        tester.view.physicalSize = const Size(360, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final repo = FakeSongRepository.seeded();
        addTearDown(repo.dispose);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              songRepositoryProvider.overrideWithValue(repo),
              sharedPreferencesProvider.overrideWithValue(prefs),
            ],
            child: MaterialApp(
              locale: locale,
              theme: AppTheme.light(),
              localizationsDelegates: appLocalizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: entry.value(),
            ),
          ),
        );
        // Bounded pumping: the editor's blinking cursor never settles.
        for (var i = 0; i < 30; i++) {
          await tester.pump(const Duration(milliseconds: 16));
        }

        expect(tester.takeException(), isNull);
        final leaked = _visibleTexts(
          tester,
        ).where(englishOnly.contains).toSet();
        expect(leaked, isEmpty, reason: 'English text under $code');

        // Leave no timers running when the test ends.
        await tester.pumpWidget(const SizedBox());
      });
    }
  }
}
