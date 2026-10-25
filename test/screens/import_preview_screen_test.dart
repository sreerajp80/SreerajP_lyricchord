import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lyricchord/l10n/app_localizations.dart';
import 'package:lyricchord/l10n/app_localizations_delegates.dart';
import 'package:lyricchord/models/import_preview_args.dart';
import 'package:lyricchord/models/song_note.dart';
import 'package:lyricchord/providers/database_provider.dart';
import 'package:lyricchord/screens/import_preview_screen.dart';

import '../helpers/fake_song_repository.dart';
import '../helpers/tooltip_expectations.dart';

void main() {
  testWidgets('ImportPreviewScreen renders file name and parsed song list', (
    WidgetTester tester,
  ) async {
    final fakeRepo = FakeSongRepository([
      const SongNote(
        id: 1,
        title: 'Jingle Bells',
        artist: 'James Pierpont',
        lyrics: 'Jingle bells',
        key: 'G',
        timestamp: 100,
      ),
    ]);

    const args = ImportPreviewArgs(
      fileName: 'selected_songs.chordpro',
      rawContent: '{t: Jingle Bells}\n{t: Silent Night}',
      parsedSongs: [
        SongNote(
          title: 'Jingle Bells',
          artist: 'James Pierpont',
          lyrics: '[G]Jingle bells',
          key: 'G',
          timestamp: 0,
        ),
        SongNote(
          title: 'Silent Night',
          artist: 'Franz Xaver Gruber',
          lyrics: '[C]Silent night',
          bpm: 80,
          timestamp: 0,
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [songRepositoryProvider.overrideWithValue(fakeRepo)],
        child: const MaterialApp(
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ImportPreviewScreen(args: args),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expectAllIconButtonsHaveTooltips(tester);

    expect(find.text('Import Preview'), findsOneWidget);
    expect(find.text('selected_songs.chordpro'), findsOneWidget);
    expect(find.text('Jingle Bells'), findsOneWidget);
    expect(find.text('Silent Night'), findsOneWidget);
    expect(find.text('In Songbook'), findsOneWidget);
    expect(find.text('Import (2)'), findsOneWidget);
  });

  testWidgets('Toggling selection updates button count', (
    WidgetTester tester,
  ) async {
    final fakeRepo = FakeSongRepository();

    const args = ImportPreviewArgs(
      fileName: 'test.chordpro',
      rawContent: '{t: Song 1}\n{t: Song 2}',
      parsedSongs: [
        SongNote(title: 'Song 1', lyrics: 'Lyrics 1', timestamp: 0),
        SongNote(
          title: 'Song 2',
          lyrics: 'Lyrics 2',
          key: 'D',
          bpm: 100,
          timestamp: 0,
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [songRepositoryProvider.overrideWithValue(fakeRepo)],
        child: const MaterialApp(
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ImportPreviewScreen(args: args),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Import (2)'), findsOneWidget);

    // Tap "Deselect All" to uncheck all
    await tester.tap(find.text('Deselect All'));
    await tester.pumpAndSettle();

    expect(find.text('Import (0)'), findsOneWidget);
    expect(find.text('Select All'), findsOneWidget);

    // Tap "Select All" to re-check all
    await tester.tap(find.text('Select All'));
    await tester.pumpAndSettle();

    expect(find.text('Import (2)'), findsOneWidget);
  });

  testWidgets('Preview button opens modal with song lyrics', (
    WidgetTester tester,
  ) async {
    final fakeRepo = FakeSongRepository();

    const args = ImportPreviewArgs(
      fileName: 'test.chordpro',
      rawContent: '{t: Custom Song}',
      parsedSongs: [
        SongNote(
          title: 'Custom Song',
          artist: 'Test Artist',
          lyrics: '[G]Hello [C]World',
          key: 'G',
          timestamp: 0,
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [songRepositoryProvider.overrideWithValue(fakeRepo)],
        child: const MaterialApp(
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ImportPreviewScreen(args: args),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('Preview'));
    await tester.pumpAndSettle();

    expect(find.text('Test Artist'), findsNWidgets(2));
    expect(find.textContaining('Hello'), findsOneWidget);
    expect(find.textContaining('World'), findsOneWidget);
  });
}
