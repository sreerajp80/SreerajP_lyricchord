import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lyriccord/providers/song_list_provider.dart';

/// Temporary stand-in for the screens that later phases build.
///
/// Phase 2 already has a working list, a **+** button and a tablet detail pane,
/// but the performance view (Phase 4) and the editor (Phase 3) do not exist
/// yet. This screen fills those routes so nothing dead-ends.
///
/// **Delete this file in Phase 3/4** when the real screens land.
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
