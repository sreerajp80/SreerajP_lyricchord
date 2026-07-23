import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:lyriccord/core/errors/app_exception.dart';
import 'package:lyriccord/models/song_note.dart';
import 'package:lyriccord/providers/database_provider.dart';
import 'package:lyriccord/providers/song_list_provider.dart';
import 'package:lyriccord/widgets/empty_songbook.dart';
import 'package:lyriccord/widgets/song_card.dart';
import 'package:lyriccord/widgets/song_filter_row.dart';
import 'package:lyriccord/widgets/song_search_field.dart';

/// The songbook: search, All/Starred filter, and the list of song cards.
///
/// It is used both as the whole phone screen and as the left pane of the
/// tablet dual-pane layout. In dual-pane mode tapping a card only changes the
/// selection; on a phone it navigates to the song.
class SongListScreen extends ConsumerWidget {
  const SongListScreen({super.key, this.dualPane = false});

  /// True when this list is the left pane of the tablet layout.
  final bool dualPane;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songsAsync = ref.watch(songsStreamProvider);
    final songs = ref.watch(filteredSongsProvider);
    final query = ref.watch(searchQueryProvider);
    final filter = ref.watch(songFilterProvider);
    final selectedId = ref.watch(selectedSongIdProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('LyricCord'),
            Text(
              'Lyrics & Chords Notebook',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'New song',
        onPressed: () => context.push('/new'),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          const SongSearchField(),
          const SongFilterRow(),
          Expanded(
            child: songsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => const EmptySongbook(),
              data: (_) => songs.isEmpty
                  ? EmptySongbook(
                      searching: query.trim().isNotEmpty,
                      starredOnly: filter == SongFilter.starred,
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 88),
                      itemCount: songs.length,
                      itemBuilder: (context, index) {
                        final song = songs[index];
                        return SongCard(
                          key: ValueKey(song.id),
                          song: song,
                          selected: dualPane && song.id == selectedId,
                          onTap: () => _openSong(context, ref, song),
                          onToggleFavorite: () =>
                              _toggleFavorite(context, ref, song),
                          onDuplicate: () => _duplicate(context, ref, song),
                          onDelete: () => _confirmDelete(context, ref, song),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _openSong(BuildContext context, WidgetRef ref, SongNote song) {
    if (dualPane) {
      ref.read(selectedSongIdProvider.notifier).select(song.id);
    } else {
      context.push('/song/${song.id}');
    }
  }

  Future<void> _toggleFavorite(
    BuildContext context,
    WidgetRef ref,
    SongNote song,
  ) async {
    try {
      await ref.read(songRepositoryProvider).toggleFavorite(song);
    } on AppException catch (e) {
      if (context.mounted) _showError(context, e.message);
    }
  }

  Future<void> _duplicate(
    BuildContext context,
    WidgetRef ref,
    SongNote song,
  ) async {
    try {
      final newId = await ref.read(songRepositoryProvider).duplicate(song);
      // On a tablet the list stays visible, so open the new copy in the pane.
      ref.read(selectedSongIdProvider.notifier).select(newId);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Copied "${song.title}".')));
      }
    } on AppException catch (e) {
      if (context.mounted) _showError(context, e.message);
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    SongNote song,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete song?'),
        content: Text('"${song.title}" will be removed from your songbook.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ref.read(songRepositoryProvider).delete(song.id);
      if (ref.read(selectedSongIdProvider) == song.id) {
        ref.read(selectedSongIdProvider.notifier).select(null);
      }
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Deleted "${song.title}".')));
      }
    } on AppException catch (e) {
      if (context.mounted) _showError(context, e.message);
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
