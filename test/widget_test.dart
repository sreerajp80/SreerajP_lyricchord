// Smoke test: the app boots into the songbook and shows the songs.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lyricchord/main.dart';
import 'package:lyricchord/providers/database_provider.dart';
import 'package:lyricchord/providers/theme_mode_provider.dart';

import 'helpers/fake_song_repository.dart';

void main() {
  late FakeSongRepository repo;

  setUp(() {
    repo = FakeSongRepository.seeded();
  });

  tearDown(() async {
    await repo.dispose();
  });

  testWidgets('app opens on the songbook and lists the songs', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          songRepositoryProvider.overrideWithValue(repo),
        ],
        child: const LyricChordApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('LyricChord'), findsOneWidget);
    expect(find.text('Lyrics & Chords Notebook'), findsOneWidget);
    expect(find.text('Amazing Grace'), findsOneWidget);
  });
}
