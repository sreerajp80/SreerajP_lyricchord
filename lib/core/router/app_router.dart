import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:lyriccord/screens/about_screen.dart';
import 'package:lyriccord/screens/home_shell.dart';
import 'package:lyriccord/screens/song_detail_placeholder_screen.dart';
import 'package:lyriccord/screens/song_editor_screen.dart';

/// The app's routes, exactly as architecture §13 lists them.
///
/// `/new` and `/song/:id/edit` open the real editor. `/song/:id` still points
/// at [SongDetailPlaceholderScreen]; Phase 4 replaces it with the performance
/// view.
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
        builder: (context, state) => SongDetailPlaceholderScreen(
          songId: _idOf(state),
          phaseLabel: 'Performance view (Phase 4)',
        ),
        routes: [
          GoRoute(
            path: 'edit',
            builder: (context, state) => SongEditorScreen(songId: _idOf(state)),
          ),
        ],
      ),
      GoRoute(path: '/about', builder: (context, state) => const AboutScreen()),
    ],
  );
});

/// Reads the `:id` path parameter. Returns `null` if it is missing or not a
/// number, so a bad link shows the placeholder instead of crashing.
int? _idOf(GoRouterState state) =>
    int.tryParse(state.pathParameters['id'] ?? '');
