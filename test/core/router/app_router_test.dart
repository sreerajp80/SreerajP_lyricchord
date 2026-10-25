import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lyricchord/core/router/app_router.dart';
import 'package:lyricchord/main.dart';
import 'package:lyricchord/models/import_preview_args.dart';
import 'package:lyricchord/models/setlist.dart';
import 'package:lyricchord/models/song_note.dart';
import 'package:lyricchord/providers/database_provider.dart';
import 'package:lyricchord/providers/theme_mode_provider.dart';
import 'package:lyricchord/screens/about_screen.dart';
import 'package:lyricchord/screens/air_qr_transmitter_screen.dart';
import 'package:lyricchord/screens/home_shell.dart';
import 'package:lyricchord/screens/import_preview_screen.dart';
import 'package:lyricchord/screens/import_export_screen.dart';
import 'package:lyricchord/screens/setlist_detail_screen.dart';
import 'package:lyricchord/screens/setlist_list_screen.dart';
import 'package:lyricchord/screens/settings_screen.dart';

import '../../helpers/fake_setlist_repository.dart';
import '../../helpers/fake_song_repository.dart';

void main() {
  late FakeSongRepository songs;
  late FakeSetlistRepository setlists;
  late ProviderContainer container;

  setUp(() {
    songs = FakeSongRepository.seeded();
    setlists = FakeSetlistRepository(
      songs: const [],
      initial: const [
        Setlist(id: 1, name: 'Sunday Gig', createdAt: 0, updatedAt: 0),
      ],
    );
  });

  tearDown(() async {
    await songs.dispose();
    await setlists.dispose();
  });

  Future<void> pumpApp(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        songRepositoryProvider.overrideWithValue(songs),
        setlistRepositoryProvider.overrideWithValue(setlists),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const LyricChordApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> go(WidgetTester tester, String location, {Object? extra}) async {
    container.read(goRouterProvider).go(location, extra: extra);
    // Fixed pumps, not pumpAndSettle: About shows a spinner while it reads the
    // package info, which never arrives in a widget test.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
  }

  testWidgets('the app opens on the songbook', (tester) async {
    await pumpApp(tester);

    expect(find.byType(HomeShell), findsOneWidget);
  });

  testWidgets('each main route opens its screen', (tester) async {
    await pumpApp(tester);

    await go(tester, '/settings');
    expect(find.byType(SettingsScreen), findsOneWidget);

    await go(tester, '/settings/general/import');
    expect(find.byType(ImportExportScreen), findsOneWidget);

    await go(tester, '/about');
    expect(find.byType(AboutScreen), findsOneWidget);

    await go(tester, '/setlists');
    expect(find.byType(SetlistListScreen), findsOneWidget);

    await go(tester, '/setlists/1');
    expect(find.byType(SetlistDetailScreen), findsOneWidget);
    expect(find.text('Sunday Gig'), findsOneWidget);
  });

  testWidgets('a setlist id that is not a number shows "not found"', (
    tester,
  ) async {
    await pumpApp(tester);

    await go(tester, '/setlists/abc');

    expect(find.text('Setlist not found.'), findsOneWidget);
  });

  testWidgets('an unknown route falls back to the songbook', (tester) async {
    await pumpApp(tester);

    await go(tester, '/no/such/page');

    expect(find.byType(HomeShell), findsOneWidget);
  });

  group('routes that need their data in extra', () {
    testWidgets('the import preview without data lands on the songbook', (
      tester,
    ) async {
      await pumpApp(tester);
      await go(tester, '/settings');

      await go(tester, '/import-preview');

      expect(tester.takeException(), isNull);
      expect(find.byType(ImportPreviewScreen), findsNothing);
      expect(find.byType(HomeShell), findsOneWidget);
    });

    testWidgets('the AirQR sender without data lands on the songbook', (
      tester,
    ) async {
      await pumpApp(tester);
      await go(tester, '/settings');

      await go(tester, '/air-qr-transmit', extra: 'not the right data');

      expect(tester.takeException(), isNull);
      expect(find.byType(AirQrTransmitterScreen), findsNothing);
      expect(find.byType(HomeShell), findsOneWidget);
    });

    testWidgets('with their data both routes open their screen', (
      tester,
    ) async {
      await pumpApp(tester);

      await go(
        tester,
        '/import-preview',
        extra: const ImportPreviewArgs(
          fileName: 'song.chordpro',
          rawContent: '{title: X}\n[C]hi',
          parsedSongs: [SongNote(title: 'X', lyrics: '[C]hi', timestamp: 0)],
        ),
      );
      expect(find.byType(ImportPreviewScreen), findsOneWidget);

      await go(
        tester,
        '/air-qr-transmit',
        extra: const AirQrTransmitterArgs(
          title: 'X',
          chordProPayload: '{title: X}\n[C]hi',
        ),
      );
      expect(find.byType(AirQrTransmitterScreen), findsOneWidget);

      // Leave the sender so its frame timer stops before the test ends.
      await go(tester, '/');
    });
  });

  testWidgets('a file link handed to the router lands on the songbook', (
    tester,
  ) async {
    await pumpApp(tester);

    await go(tester, 'content://media/external/file/12');

    expect(find.byType(HomeShell), findsOneWidget);
  });

  test('rootScaffoldMessengerKey is one shared key', () {
    expect(rootScaffoldMessengerKey, same(rootScaffoldMessengerKey));
    expect(rootScaffoldMessengerKey, isA<GlobalKey<ScaffoldMessengerState>>());
  });
}
