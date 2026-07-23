import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lyriccord/models/song_note.dart';
import 'package:lyriccord/widgets/song_card.dart';

void main() {
  Future<void> pumpCard(
    WidgetTester tester, {
    required SongNote song,
    VoidCallback? onTap,
    VoidCallback? onToggleFavorite,
    VoidCallback? onDuplicate,
    VoidCallback? onDelete,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SongCard(
            song: song,
            onTap: onTap ?? () {},
            onToggleFavorite: onToggleFavorite ?? () {},
            onDuplicate: onDuplicate ?? () {},
            onDelete: onDelete ?? () {},
          ),
        ),
      ),
    );
  }

  testWidgets('shows title, artist, key badge and BPM badge', (tester) async {
    await pumpCard(tester, song: _song());

    expect(find.text('Amazing Grace'), findsOneWidget);
    expect(find.text('Traditional'), findsOneWidget);
    expect(find.text('G'), findsOneWidget);
    expect(find.text('80 BPM'), findsOneWidget);
  });

  testWidgets('hides the artist line when there is no artist', (tester) async {
    await pumpCard(tester, song: _song(artist: ''));

    expect(find.text('Amazing Grace'), findsOneWidget);
    expect(find.text('Traditional'), findsNothing);
  });

  testWidgets('shows a filled star only for a favorite song', (tester) async {
    await pumpCard(tester, song: _song(favorite: false));
    expect(find.byIcon(Icons.star_border), findsOneWidget);

    await pumpCard(tester, song: _song(favorite: true));
    expect(find.byIcon(Icons.star), findsOneWidget);
  });

  testWidgets('badges expose full screen-reader labels', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpCard(tester, song: _song());

    // The short badge text stays on screen, but a screen reader hears the full
    // wording (accessibility pass, Phase 8). The card merges its labels into one
    // node, so match the full wording within it rather than as a whole label.
    expect(find.bySemanticsLabel(RegExp('Key G')), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp('80 beats per minute')),
      findsOneWidget,
    );

    handle.dispose();
  });

  testWidgets('fires the tap, star, duplicate and delete callbacks', (
    tester,
  ) async {
    var tapped = 0;
    var starred = 0;
    var duplicated = 0;
    var deleted = 0;

    await pumpCard(
      tester,
      song: _song(),
      onTap: () => tapped++,
      onToggleFavorite: () => starred++,
      onDuplicate: () => duplicated++,
      onDelete: () => deleted++,
    );

    await tester.tap(find.text('Amazing Grace'));
    await tester.tap(find.byIcon(Icons.star));
    await tester.tap(find.byIcon(Icons.content_copy_outlined));
    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pump();

    expect(tapped, 1);
    expect(starred, 1);
    expect(duplicated, 1);
    expect(deleted, 1);
  });
}

SongNote _song({String artist = 'Traditional', bool favorite = true}) =>
    SongNote(
      id: 1,
      title: 'Amazing Grace',
      artist: artist,
      lyrics: '[G]Amazing grace',
      key: 'G',
      bpm: 80,
      favorite: favorite,
      timestamp: 1,
    );
