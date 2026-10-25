import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:lyricchord/models/song_note.dart';
import 'package:lyricchord/providers/database_provider.dart';
import 'package:lyricchord/widgets/setlist_song_picker_sheet.dart';

import '../helpers/fake_song_repository.dart';
import '../helpers/localized_app.dart';

void main() {
  late FakeSongRepository repo;

  setUp(() {
    repo = FakeSongRepository(const [
      SongNote(id: 1, title: 'Amazing Grace', artist: 'Trad', timestamp: 3),
      SongNote(id: 2, title: 'Jingle Bells', key: 'G', timestamp: 2),
      SongNote(id: 3, title: 'Rising Sun', artist: 'Folk', timestamp: 1),
    ]);
  });

  tearDown(() async => repo.dispose());

  /// Opens the sheet from a button and returns a holder for its result.
  Future<List<List<int>?>> open(
    WidgetTester tester, {
    List<int> already = const [],
  }) async {
    final results = <List<int>?>[];
    await tester.pumpWidget(
      ProviderScope(
        overrides: [songRepositoryProvider.overrideWithValue(repo)],
        child: localizedApp(
          Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () async => results.add(
                  await SetlistSongPickerSheet.show(
                    context,
                    alreadySelectedSongIds: already,
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    return results;
  }

  testWidgets('lists every song with its key, and ticks the chosen ones', (
    tester,
  ) async {
    await open(tester, already: [2]);

    expect(find.text('Add Songs to Setlist'), findsOneWidget);
    expect(find.text('Amazing Grace'), findsOneWidget);
    expect(find.text('Jingle Bells'), findsOneWidget);
    expect(find.text('Done (1)'), findsOneWidget);

    final ticked = tester.widget<CheckboxListTile>(
      find.widgetWithText(CheckboxListTile, 'Jingle Bells'),
    );
    expect(ticked.value, isTrue);
  });

  testWidgets('search narrows by title or artist', (tester) async {
    await open(tester);

    await tester.enterText(find.byType(TextField), 'folk');
    await tester.pump();
    expect(find.text('Rising Sun'), findsOneWidget);
    expect(find.text('Amazing Grace'), findsNothing);

    await tester.enterText(find.byType(TextField), 'zzz');
    await tester.pump();
    expect(find.text('No songs found'), findsOneWidget);
  });

  testWidgets('Done returns the picked ids, keeping the old ones first', (
    tester,
  ) async {
    final results = await open(tester, already: [3]);

    await tester.tap(find.text('Amazing Grace'));
    await tester.pump();
    await tester.tap(find.text('Done (2)'));
    await tester.pumpAndSettle();

    expect(results.single, [3, 1]);
  });

  testWidgets('unticking a song drops it', (tester) async {
    final results = await open(tester, already: [1, 2]);

    await tester.tap(find.text('Amazing Grace'));
    await tester.pump();
    await tester.tap(find.text('Done (1)'));
    await tester.pumpAndSettle();

    expect(results.single, [2]);
  });
}
