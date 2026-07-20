import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:lyriccord/providers/song_list_provider.dart';

/// Temporary stand-in for the performance view, which Phase 4 builds.
///
/// The list (Phase 2) and the editor (Phase 3) are real, so this screen only
/// covers `/song/:id` — reading a song. It offers an **Edit** button so the
/// editor is reachable from here on a phone and in the tablet pane.
///
/// **Delete this file in Phase 4** when the performance view lands.
class SongDetailPlaceholderScreen extends ConsumerWidget {
  const SongDetailPlaceholderScreen({
    super.key,
    this.songId,
    required this.phaseLabel,
    this.showAppBar = true,
  });

  /// The song being opened, or `null` for a brand new song.
  final int? songId;

  /// What is coming here, e.g. `'Performance view (Phase 4)'`.
  final String phaseLabel;

  /// False when shown inside the tablet pane, which has its own surroundings.
  final bool showAppBar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final id = songId;

    final body = Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.construction_outlined,
              size: 64,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(phaseLabel, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'This part of LyricCord is not built yet.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (id != null) ...[
              const SizedBox(height: 16),
              _SongTitle(songId: id),
              const SizedBox(height: 16),
              FilledButton.tonalIcon(
                onPressed: () => context.push('/song/$id/edit'),
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit song'),
              ),
            ],
          ],
        ),
      ),
    );

    if (!showAppBar) return body;
    return Scaffold(appBar: AppBar(), body: body);
  }
}

/// Shows the opened song's title, so tapping a card visibly does something.
class _SongTitle extends ConsumerWidget {
  const _SongTitle({required this.songId});

  final int songId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final songAsync = ref.watch(songByIdProvider(songId));

    return songAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (song) => song == null
          ? const SizedBox.shrink()
          : Text(song.title, style: theme.textTheme.titleLarge),
    );
  }
}
