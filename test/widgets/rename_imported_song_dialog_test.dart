import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lyricchord/models/song_note.dart';
import 'package:lyricchord/widgets/rename_imported_song_dialog.dart';

import '../helpers/localized_app.dart';

void main() {
  const imported = SongNote(title: 'Amazing Grace', timestamp: 2);
  const existing = SongNote(id: 1, title: 'Amazing Grace', timestamp: 1);

  /// Opens the dialog from a button and returns a holder for its result.
  Future<List<String?>> openDialog(WidgetTester tester) async {
    final results = <String?>[];
    await tester.pumpWidget(
      localizedApp(
        Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async => results.add(
                await RenameImportedSongDialog.show(
                  context,
                  importedSong: imported,
                  existingSong: existing,
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    return results;
  }

  testWidgets('names the song that already exists', (tester) async {
    await openDialog(tester);

    expect(find.text('Duplicate Song Title'), findsOne);
    expect(
      find.text(
        'A song titled "Amazing Grace" already exists in your songbook.',
      ),
      findsOne,
    );
    expect(find.text('Enter a new title for the imported song:'), findsOne);
  });

  testWidgets('an empty title is refused and the dialog stays open', (
    tester,
  ) async {
    final results = await openDialog(tester);

    await tester.enterText(find.byType(TextFormField), '   ');
    await tester.tap(find.text('Save with New Title'));
    await tester.pumpAndSettle();

    expect(find.text('Please enter a title'), findsOne);
    expect(results, isEmpty);
  });

  testWidgets('a new title is returned', (tester) async {
    final results = await openDialog(tester);

    await tester.enterText(find.byType(TextFormField), 'Amazing Grace (live)');
    await tester.tap(find.text('Save with New Title'));
    await tester.pumpAndSettle();

    expect(results.single, 'Amazing Grace (live)');
  });
}
