import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:lyricchord/core/errors/app_exception.dart';
import 'package:lyricchord/models/setlist.dart';
import 'package:lyricchord/providers/database_provider.dart';
import 'package:lyricchord/providers/setlist_provider.dart';
import 'package:lyricchord/widgets/setlist_editor_dialog.dart';
import 'package:lyricchord/widgets/setlist_song_picker_sheet.dart';

/// Screen displaying and editing an ordered setlist.
class SetlistDetailScreen extends ConsumerWidget {
  const SetlistDetailScreen({super.key, required this.setlistId});

  final int setlistId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final setlistAsync = ref.watch(setlistByIdProvider(setlistId));
    final theme = Theme.of(context);

    return setlistAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Setlist')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Scaffold(
        appBar: AppBar(title: const Text('Setlist')),
        body: Center(child: Text('Error loading setlist: $err')),
      ),
      data: (setlist) {
        if (setlist == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Setlist')),
            body: const Center(child: Text('Setlist not found.')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(setlist.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Edit setlist info',
                onPressed: () => _editSetlist(context, ref, setlist),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Delete setlist',
                onPressed: () => _deleteSetlist(context, ref, setlist),
              ),
            ],
          ),
          floatingActionButton: setlist.songs.isNotEmpty
              ? FloatingActionButton.extended(
                  onPressed: () => _performSetlist(context, ref, setlist, 0),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Perform Setlist'),
                )
              : null,
          body: Column(
            children: [
              if (setlist.description.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      setlist.description,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Row(
                  children: [
                    Text(
                      '${setlist.songCount} ${setlist.songCount == 1 ? 'Song' : 'Songs'}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    OutlinedButton.icon(
                      onPressed: () => _addSongs(context, ref, setlist),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Songs'),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: setlist.songs.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.queue_music,
                              size: 64,
                              color: theme.colorScheme.outline,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No songs in this setlist',
                              style: theme.textTheme.titleSmall,
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              onPressed: () => _addSongs(context, ref, setlist),
                              icon: const Icon(Icons.add),
                              label: const Text('Add Songs Now'),
                            ),
                          ],
                        ),
                      )
                    : ReorderableListView.builder(
                        padding: const EdgeInsets.only(bottom: 88),
                        itemCount: setlist.songs.length,
                        onReorderItem: (oldIndex, newIndex) => _reorderSongs(
                          context,
                          ref,
                          setlist,
                          oldIndex,
                          newIndex,
                        ),
                        itemBuilder: (context, index) {
                          final song = setlist.songs[index];
                          return Card(
                            key: ValueKey(song.id),
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                radius: 14,
                                backgroundColor:
                                    theme.colorScheme.primaryContainer,
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onPrimaryContainer,
                                  ),
                                ),
                              ),
                              title: Text(
                                song.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                '${song.artist.isNotEmpty ? '${song.artist} • ' : ''}Key: ${song.key} • ${song.bpm} BPM',
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.remove_circle_outline,
                                    ),
                                    color: theme.colorScheme.error,
                                    tooltip: 'Remove from setlist',
                                    onPressed: () => _removeSong(
                                      context,
                                      ref,
                                      setlist,
                                      song.id,
                                    ),
                                  ),
                                  ReorderableDragStartListener(
                                    index: index,
                                    child: const Icon(Icons.drag_handle),
                                  ),
                                ],
                              ),
                              onTap: () =>
                                  _performSetlist(context, ref, setlist, index),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _performSetlist(
    BuildContext context,
    WidgetRef ref,
    Setlist setlist,
    int initialIndex,
  ) {
    if (setlist.songs.isEmpty) return;
    ref.read(activeSetlistIdProvider.notifier).setActiveSetlist(setlist.id);
    final songId = setlist.songs[initialIndex].id;
    context.push('/song/$songId?setlistId=${setlist.id}');
  }

  Future<void> _editSetlist(
    BuildContext context,
    WidgetRef ref,
    Setlist setlist,
  ) async {
    final result = await SetlistEditorDialog.show(context, setlist: setlist);
    if (result == null) return;

    try {
      await ref
          .read(setlistRepositoryProvider)
          .updateSetlist(
            id: setlist.id,
            name: result['name']!,
            description: result['description'] ?? '',
          );
    } on AppException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  Future<void> _deleteSetlist(
    BuildContext context,
    WidgetRef ref,
    Setlist setlist,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete setlist?'),
        content: Text(
          '"${setlist.name}" will be deleted. Songs in your library will not be deleted.',
        ),
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

    if (confirm != true) return;

    try {
      await ref.read(setlistRepositoryProvider).deleteSetlist(setlist.id);
      if (context.mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Deleted setlist "${setlist.name}".')),
        );
      }
    } on AppException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  Future<void> _addSongs(
    BuildContext context,
    WidgetRef ref,
    Setlist setlist,
  ) async {
    final currentIds = setlist.songs.map((s) => s.id).toList();
    final selectedIds = await SetlistSongPickerSheet.show(
      context,
      alreadySelectedSongIds: currentIds,
    );
    if (selectedIds == null) return;

    try {
      await ref
          .read(setlistRepositoryProvider)
          .reorderSongs(setlist.id, selectedIds);
    } on AppException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  Future<void> _reorderSongs(
    BuildContext context,
    WidgetRef ref,
    Setlist setlist,
    int oldIndex,
    int newIndex,
  ) async {
    final ids = setlist.songs.map((s) => s.id).toList();
    final item = ids.removeAt(oldIndex);
    ids.insert(newIndex, item);

    try {
      await ref.read(setlistRepositoryProvider).reorderSongs(setlist.id, ids);
    } on AppException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  Future<void> _removeSong(
    BuildContext context,
    WidgetRef ref,
    Setlist setlist,
    int songId,
  ) async {
    final ids = setlist.songs
        .map((s) => s.id)
        .where((id) => id != songId)
        .toList();
    try {
      await ref.read(setlistRepositoryProvider).reorderSongs(setlist.id, ids);
    } on AppException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }
}
