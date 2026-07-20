import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lyriccord/providers/database_provider.dart';
import 'package:lyriccord/screens/song_editor_screen.dart';
import 'package:lyriccord/widgets/chord_inserter_bar.dart';

import '../helpers/fake_song_repository.dart';

void main() {
  late FakeSongRepository repo;

  setUp(() {
    repo = FakeSongRepository.seeded();
  });

  tearDown(() async {
    await repo.dispose();
  });

  Future<void> pumpEditor(WidgetTester tester, {int? songId}) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(500, 1100);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [songRepositoryProvider.overrideWithValue(repo)],
        child: MaterialApp(home: SongEditorScreen(songId: songId)),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// The lyrics field is the only borderless multi-line field on the screen.
  Finder lyricsField() => find.byWidgetPredicate(
    (w) => w is TextField && w.maxLines == null && w.expands,
  );

  testWidgets('a new song opens an empty editor in C', (tester) async {
    await pumpEditor(tester);

    expect(find.text('New Song Note'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'C'), findsOneWidget);
    // The C-major suggestions are on the toolbar.
    expect(find.widgetWithText(ActionChip, 'Dm'), findsOneWidget);
    expect(find.widgetWithText(ActionChip, 'G7'), findsOneWidget);
  });

  testWidgets('an existing song opens with its values', (tester) async {
    await pumpEditor(tester, songId: 1);

    expect(find.text('Edit Song Note'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Amazing Grace'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Traditional'), findsOneWidget);
    expect(find.widgetWithText(TextField, '80'), findsOneWidget);
  });

  testWidgets('the suggestions follow the key that is typed', (tester) async {
    await pumpEditor(tester);

    await tester.enterText(find.widgetWithText(TextField, 'C'), 'Am');
    await tester.pumpAndSettle();

    expect(find.widgetWithText(ActionChip, 'Am'), findsOneWidget);
    expect(find.widgetWithText(ActionChip, 'Bdim'), findsOneWidget);
  });

  testWidgets('tapping a chord inserts it into the lyrics', (tester) async {
    await pumpEditor(tester);

    await tester.tap(find.widgetWithText(ActionChip, 'F'));
    await tester.pumpAndSettle();

    final field = tester.widget<TextField>(lyricsField());
    expect(field.controller!.text, '[F]');
  });

  testWidgets('a custom chord is added to the toolbar', (tester) async {
    await pumpEditor(tester);

    await tester.tap(find.widgetWithText(ActionChip, 'Custom'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).last, 'Cmaj7');
    await tester.tap(find.widgetWithText(FilledButton, 'Add'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(ActionChip, 'Cmaj7'), findsOneWidget);
    final field = tester.widget<TextField>(lyricsField());
    expect(field.controller!.text, '[Cmaj7]');
  });

  testWidgets('saving a new song stores it', (tester) async {
    await pumpEditor(tester);

    await tester.enterText(
      find.widgetWithText(TextField, 'Song title'),
      'My New Song',
    );
    await tester.enterText(lyricsField(), 'a line of words');
    await tester.tap(find.widgetWithText(TextButton, 'Save'));
    await tester.pumpAndSettle();

    final songs = await repo.watchAllSongs().first;
    expect(songs.map((s) => s.title), contains('My New Song'));
    expect(
      songs.firstWhere((s) => s.title == 'My New Song').lyrics,
      'a line of words',
    );
  });

  testWidgets('editing an existing song updates it', (tester) async {
    await pumpEditor(tester, songId: 1);

    await tester.enterText(
      find.widgetWithText(TextField, 'Amazing Grace'),
      'Amazing Grace (live)',
    );
    await tester.tap(find.widgetWithText(TextButton, 'Save'));
    await tester.pumpAndSettle();

    final songs = await repo.watchAllSongs().first;
    expect(songs, hasLength(3));
    expect(songs.map((s) => s.title), contains('Amazing Grace (live)'));
  });

  testWidgets('cancel asks before throwing edits away', (tester) async {
    await pumpEditor(tester);

    await tester.enterText(
      find.widgetWithText(TextField, 'Song title'),
      'Half written',
    );
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(find.text('Discard changes?'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Keep editing'));
    await tester.pumpAndSettle();

    expect(find.byType(ChordInserterBar), findsOneWidget);
    final songs = await repo.watchAllSongs().first;
    expect(songs, hasLength(3));
  });
}
