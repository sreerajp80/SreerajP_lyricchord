import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lyricchord/l10n/app_localizations.dart';
import 'package:lyricchord/l10n/app_localizations_delegates.dart';
import 'package:lyricchord/services/chord_sheet_parser.dart';
import 'package:lyricchord/services/melody_audio_service.dart';
import 'package:lyricchord/services/melody_parser_service.dart';
import 'package:lyricchord/services/melody_player_service.dart';
import 'package:lyricchord/widgets/melody_line_row.dart';
import 'package:lyricchord/theme/app_colors.dart';
import 'package:lyricchord/theme/app_theme.dart';
import 'package:lyricchord/widgets/chord_sheet_view.dart';

void main() {
  const line = ChordLine([
    ChordSegment(chord: 'G', text: 'Amazing '),
    ChordSegment(chord: 'C', text: 'Grace'),
  ]);

  testWidgets('renders chords with high contrast primary color in light mode', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: appLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.light(),
        home: const Scaffold(body: ChordSheetView(lines: [line], fontSize: 16)),
      ),
    );

    final chordTextWidget = tester.widget<Text>(find.text('G'));
    expect(chordTextWidget.style?.color, equals(AppColors.lightPrimary));
  });

  testWidgets('renders chords with high contrast primary color in dark mode', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: appLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.dark(),
        home: const Scaffold(body: ChordSheetView(lines: [line], fontSize: 16)),
      ),
    );

    final chordTextWidget = tester.widget<Text>(find.text('G'));
    expect(chordTextWidget.style?.color, equals(AppColors.darkPrimary));
  });

  group('swaram lines', () {
    const swaram = ChordLine([
      ChordSegment(text: 'Sa - Ri - Ga - Ma - | Pa - Dha - Ni - Sa -'),
    ], kind: ChordLineKind.swaram);

    testWidgets('draws in the fixed-width font and never wraps', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.light(),
          home: const Scaffold(
            body: ChordSheetView(lines: [swaram], fontSize: 16),
          ),
        ),
      );

      final text = tester.widget<Text>(
        find.text('Sa - Ri - Ga - Ma - | Pa - Dha - Ni - Sa -'),
      );
      expect(text.style?.fontFamily, 'monospace');
      expect(text.style?.color, equals(AppColors.lightPrimary));
      // The beat grid only reads correctly on one unbroken row.
      expect(text.softWrap, isFalse);
      expect(text.maxLines, 1);
    });

    testWidgets('is drawn compactly so a long phrase stays on screen', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.light(),
          home: const Scaffold(
            body: ChordSheetView(lines: [swaram], fontSize: 16),
          ),
        ),
      );

      final text = tester.widget<Text>(
        find.text('Sa - Ri - Ga - Ma - | Pa - Dha - Ni - Sa -'),
      );
      // Smaller than the lyrics, with no extra tracking and a tight line box.
      expect(text.style?.fontSize, lessThan(16));
      expect(text.style?.letterSpacing ?? 0, 0);
      expect(text.style?.height, lessThan(1.2));
    });

    testWidgets('scrolls sideways instead of wrapping', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.light(),
          home: const Scaffold(
            body: ChordSheetView(lines: [swaram], fontSize: 16),
          ),
        ),
      );

      final scrollView = tester.widget<SingleChildScrollView>(
        find.ancestor(
          of: find.text('Sa - Ri - Ga - Ma - | Pa - Dha - Ni - Sa -'),
          matching: find.byType(SingleChildScrollView),
        ),
      );
      expect(scrollView.scrollDirection, Axis.horizontal);
    });

    testWidgets('a lyric line is still laid out as words with chords', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.light(),
          home: const Scaffold(
            body: ChordSheetView(lines: [line], fontSize: 16),
          ),
        ),
      );

      expect(find.byType(Wrap), findsOneWidget);
    });
  });

  group('show melody', () {
    const parser = MelodyParser();

    ChordLine melodyLine() {
      final melody = parser.parse('{melody} P , M2 | R2 S');
      return ChordLine(
        [ChordSegment(text: melody.source)],
        kind: ChordLineKind.melody,
        melody: melody,
      );
    }

    Future<void> pumpSheet(WidgetTester tester, {required bool showMelody}) {
      return tester.pumpWidget(
        ProviderScope(
          overrides: [melodyAudioProvider.overrideWithValue(_SilentAudio())],
          child: MaterialApp(
            localizationsDelegates: appLocalizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: AppTheme.light(),
            home: Scaffold(
              body: ChordSheetView(
                lines: [line, melodyLine()],
                fontSize: 16,
                showMelody: showMelody,
                melodyTonicHz: 261.63,
                melodyTempoBpm: 68,
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('draws the melody row when on', (tester) async {
      await pumpSheet(tester, showMelody: true);

      expect(find.byType(MelodyLineRow), findsOneWidget);
    });

    testWidgets('drops the melody row when off, keeping the lyrics', (
      tester,
    ) async {
      await pumpSheet(tester, showMelody: false);

      expect(find.byType(MelodyLineRow), findsNothing);
      expect(find.text('Amazing '), findsOneWidget);
    });
  });
}

/// A melody audio device that makes no sound, so the row can be built in a
/// test without touching a real audio player.
class _SilentAudio implements MelodyAudio {
  @override
  Future<bool> play(MelodySchedule schedule, {bool loop = false}) async => true;

  @override
  Future<void> stop() async {}

  @override
  Future<void> setVolume(double volume) async {}

  @override
  Future<void> dispose() async {}
}
