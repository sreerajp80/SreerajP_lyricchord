import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:lyriccord/screens/about_screen.dart';
import 'package:lyriccord/screens/chord_settings_screen.dart';
import 'package:lyriccord/screens/font_settings_screen.dart';
import 'package:lyriccord/screens/general_settings_screen.dart';
import 'package:lyriccord/screens/home_shell.dart';
import 'package:lyriccord/screens/import_export_screen.dart';
import 'package:lyriccord/screens/metronome_settings_screen.dart';
import 'package:lyriccord/screens/settings_screen.dart';
import 'package:lyriccord/screens/song_editor_screen.dart';
import 'package:lyriccord/screens/song_performance_screen.dart';
import 'package:lyriccord/screens/theme_settings_screen.dart';

/// The app's routes, exactly as architecture §13 lists them.
final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const HomeShell()),
      GoRoute(
        path: '/new',
        builder: (context, state) => const SongEditorScreen(),
      ),
      GoRoute(
        path: '/song/:id',
        builder: (context, state) =>
            SongPerformanceScreen(songId: _idOf(state)),
        routes: [
          GoRoute(
            path: 'edit',
            builder: (context, state) => SongEditorScreen(songId: _idOf(state)),
          ),
        ],
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
        routes: [
          GoRoute(
            path: 'general',
            builder: (context, state) => const GeneralSettingsScreen(),
            routes: [
              GoRoute(
                path: 'import',
                builder: (context, state) => const ImportExportScreen(),
              ),
              GoRoute(
                path: 'metronome',
                builder: (context, state) => const MetronomeSettingsScreen(),
              ),
            ],
          ),
          GoRoute(
            path: 'themes',
            builder: (context, state) => const ThemeSettingsScreen(),
          ),
          GoRoute(
            path: 'chords',
            builder: (context, state) => const ChordSettingsScreen(),
          ),
          GoRoute(
            path: 'fonts',
            builder: (context, state) => const FontSettingsScreen(),
          ),
        ],
      ),
      GoRoute(path: '/about', builder: (context, state) => const AboutScreen()),
    ],
  );
});

/// Reads the `:id` path parameter. Returns `null` if it is missing or not a
/// number, so a bad link shows a "song not found" message instead of crashing.
int? _idOf(GoRouterState state) =>
    int.tryParse(state.pathParameters['id'] ?? '');
