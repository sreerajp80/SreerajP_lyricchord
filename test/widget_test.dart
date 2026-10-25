// Smoke test: the app boots into the songbook and shows the songs.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lyricchord/main.dart';
import 'package:lyricchord/providers/database_provider.dart';
import 'package:lyricchord/providers/theme_mode_provider.dart';

import 'helpers/fake_song_repository.dart';
import 'helpers/tooltip_expectations.dart';

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
    expectAllIconButtonsHaveTooltips(tester);

    expect(find.text('LyricChord'), findsOneWidget);
    expect(find.text('Lyrics & Chords Notebook'), findsOneWidget);
    expect(
      find.text('Krishna Nee Begane Baro (Raga Yamunakalyani)'),
      findsOneWidget,
    );
  });

  // go_router picks the page type by looking for a MaterialApp above it. If it
  // cannot find one (for example, an SDK-Material go_router under the
  // material_ui MaterialApp), it falls back to pages with no transition.
  testWidgets('routes are Material pages, so screens keep their transition', (
    tester,
  ) async {
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

    final navigator = tester.widget<Navigator>(find.byType(Navigator).first);
    expect(navigator.pages, isNotEmpty);
    expect(navigator.pages.last, isA<MaterialPage<void>>());
  });
}
