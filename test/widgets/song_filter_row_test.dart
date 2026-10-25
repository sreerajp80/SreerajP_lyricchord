import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:lyricchord/models/song_note.dart';
import 'package:lyricchord/providers/database_provider.dart';
import 'package:lyricchord/providers/song_list_provider.dart';
import 'package:lyricchord/widgets/song_filter_row.dart';

import '../helpers/fake_song_repository.dart';
import '../helpers/localized_app.dart';

void main() {
  late FakeSongRepository repo;

  setUp(() {
    repo = FakeSongRepository(const [
      SongNote(id: 1, title: 'A', favorite: true, timestamp: 1),
      SongNote(id: 2, title: 'B', timestamp: 2),
      SongNote(id: 3, title: 'C', timestamp: 3),
    ]);
  });

  tearDown(() async => repo.dispose());

  Future<ProviderContainer> pump(WidgetTester tester) async {
    final container = ProviderContainer(
      overrides: [songRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: localizedApp(const Scaffold(body: SongFilterRow())),
      ),
    );
    await tester.pumpAndSettle();
    return container;
  }

  testWidgets('shows both chips with live counts', (tester) async {
    await pump(tester);

    expect(find.text('All Songs (3)'), findsOneWidget);
    expect(find.text('Starred (1)'), findsOneWidget);
  });

  testWidgets('All Songs is selected first; tapping Starred selects it', (
    tester,
  ) async {
    final container = await pump(tester);

    ChoiceChip chip(String text) =>
        tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, text));

    expect(chip('All Songs (3)').selected, isTrue);
    expect(container.read(songFilterProvider), SongFilter.all);

    await tester.tap(find.text('Starred (1)'));
    await tester.pump();

    expect(container.read(songFilterProvider), SongFilter.starred);
    expect(chip('Starred (1)').selected, isTrue);
    expect(chip('All Songs (3)').selected, isFalse);
  });

  testWidgets('counts follow a newly starred song', (tester) async {
    await pump(tester);

    await repo.toggleFavorite(const SongNote(id: 2, title: 'B', timestamp: 2));
    await tester.pumpAndSettle();

    expect(find.text('Starred (2)'), findsOneWidget);
  });
}
