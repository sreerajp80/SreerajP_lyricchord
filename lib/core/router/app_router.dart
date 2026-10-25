import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:lyricchord/screens/about_screen.dart';
import 'package:lyricchord/screens/chord_settings_screen.dart';
import 'package:lyricchord/screens/font_settings_screen.dart';
import 'package:lyricchord/screens/general_settings_screen.dart';
import 'package:lyricchord/screens/help/help_detail_screen.dart';
import 'package:lyricchord/screens/help/help_screen.dart';
import 'package:lyricchord/screens/home_shell.dart';
import 'package:lyricchord/screens/import_export_screen.dart';
import 'package:lyricchord/screens/metronome_settings_screen.dart';
import 'package:lyricchord/screens/pitch_drone_settings_screen.dart';
import 'package:lyricchord/screens/scroll_settings_screen.dart';
import 'package:lyricchord/screens/setlist_detail_screen.dart';
import 'package:lyricchord/screens/setlist_list_screen.dart';
import 'package:lyricchord/screens/settings_screen.dart';
import 'package:lyricchord/screens/song_editor_screen.dart';
import 'package:lyricchord/screens/song_performance_screen.dart';
import 'package:lyricchord/screens/language_settings_screen.dart';
import 'package:lyricchord/screens/theme_settings_screen.dart';

import 'package:lyricchord/screens/import_settings_screen.dart';

import 'package:lyricchord/models/import_preview_args.dart';
import 'package:lyricchord/screens/import_preview_screen.dart';
import 'package:lyricchord/screens/air_qr_receiver_screen.dart';
import 'package:lyricchord/screens/air_qr_transmitter_screen.dart';

/// The app-wide SnackBar host.
///
/// Lets code that sits above any `Scaffold` (such as the file-open listener)
/// still tell the user what happened.
final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

/// The app's routes.
final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      if (state.uri.scheme == 'content' || state.uri.scheme == 'file') {
        return '/';
      }
      return null;
    },
    errorBuilder: (context, state) => const HomeShell(),
    routes: [
      GoRoute(path: '/', builder: (context, state) => const HomeShell()),
      // These two routes need their data in `extra`. Without it (a bare link,
      // or the data lost when the page is rebuilt) a hard cast would throw, so
      // the redirect sends the user to the songbook instead (hard rule 4). The
      // builders check again, so they can never throw even if reached directly.
      GoRoute(
        path: '/air-qr-transmit',
        redirect: (context, state) =>
            state.extra is AirQrTransmitterArgs ? null : '/',
        builder: (context, state) {
          final args = state.extra;
          return args is AirQrTransmitterArgs
              ? AirQrTransmitterScreen(args: args)
              : const HomeShell();
        },
      ),
      GoRoute(
        path: '/air-qr-receive',
        builder: (context, state) => const AirQrReceiverScreen(),
      ),
      GoRoute(
        path: '/import-preview',
        redirect: (context, state) =>
            state.extra is ImportPreviewArgs ? null : '/',
        builder: (context, state) {
          final args = state.extra;
          return args is ImportPreviewArgs
              ? ImportPreviewScreen(args: args)
              : const HomeShell();
        },
      ),
      GoRoute(
        path: '/new',
        builder: (context, state) => const SongEditorScreen(),
      ),
      GoRoute(
        path: '/song/:id',
        builder: (context, state) {
          final songId = _idOf(state);
          final setlistIdStr = state.uri.queryParameters['setlistId'];
          final setlistId = setlistIdStr != null
              ? int.tryParse(setlistIdStr)
              : null;
          return SongPerformanceScreen(songId: songId, setlistId: setlistId);
        },
        routes: [
          GoRoute(
            path: 'edit',
            builder: (context, state) => SongEditorScreen(songId: _idOf(state)),
          ),
        ],
      ),
      GoRoute(
        path: '/setlists',
        builder: (context, state) => const SetlistListScreen(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) =>
                SetlistDetailScreen(setlistId: _idOf(state) ?? 0),
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
                path: 'import-settings',
                builder: (context, state) => const ImportSettingsScreen(),
              ),
              GoRoute(
                path: 'metronome',
                builder: (context, state) => const MetronomeSettingsScreen(),
              ),
              GoRoute(
                path: 'auto-scroll',
                builder: (context, state) => const ScrollSettingsScreen(),
              ),
              GoRoute(
                path: 'pitch-drone',
                builder: (context, state) => const PitchDroneSettingsScreen(),
              ),
            ],
          ),
          GoRoute(
            path: 'themes',
            builder: (context, state) => const ThemeSettingsScreen(),
          ),
          GoRoute(
            path: 'language',
            builder: (context, state) => const LanguageSettingsScreen(),
          ),
          GoRoute(
            path: 'chords',
            builder: (context, state) => const ChordSettingsScreen(),
          ),
          GoRoute(
            path: 'fonts',
            builder: (context, state) => const FontSettingsScreen(),
          ),
          GoRoute(
            path: 'help',
            builder: (context, state) => const HelpScreen(),
            routes: [
              GoRoute(
                path: ':topicId',
                builder: (context, state) => HelpDetailScreen(
                  topicId: state.pathParameters['topicId'] ?? '',
                ),
              ),
            ],
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
