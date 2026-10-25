import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:lyricchord/core/errors/app_exception.dart';
import 'package:lyricchord/l10n/app_localizations.dart';
import 'package:lyricchord/l10n/l10n_labels.dart';
import 'package:lyricchord/models/setlist.dart';
import 'package:lyricchord/providers/database_provider.dart';
import 'package:lyricchord/providers/setlist_provider.dart';
import 'package:lyricchord/widgets/setlist_editor_dialog.dart';
import 'package:lyricchord/widgets/setlist_song_picker_sheet.dart';
import 'package:lyricchord/services/chord_pro_service.dart';
import 'package:lyricchord/screens/air_qr_transmitter_screen.dart';

/// Screen displaying and editing an ordered setlist.
class SetlistDetailScreen extends ConsumerWidget {
  const SetlistDetailScreen({super.key, required this.setlistId});

  final int setlistId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final setlistAsync = ref.watch(setlistByIdProvider(setlistId));
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return setlistAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: Text(l10n.titleSetlist)),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Scaffold(
        appBar: AppBar(title: Text(l10n.titleSetlist)),
        body: Center(child: Text(l10n.errorSetlistLoadOne('$err'))),
      ),
      data: (setlist) {
        if (setlist == null) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.titleSetlist)),
            body: Center(child: Text(l10n.errorSetlistNotFound)),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(setlist.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.qr_code_2_rounded),
                tooltip: l10n.tooltipSetlistShareAirQr,
                onPressed: () => _shareSetlistAirQr(context, setlist),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: l10n.tooltipSetlistEditInfo,
                onPressed: () => _editSetlist(context, ref, setlist),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: l10n.tooltipSetlistDelete,
                onPressed: () => _deleteSetlist(context, ref, setlist),
              ),
            ],
          ),
          floatingActionButton: setlist.songs.isNotEmpty
              ? FloatingActionButton.extended(
                  onPressed: () => _performSetlist(context, ref, setlist, 0),
                  icon: const Icon(Icons.play_arrow),
                  label: Text(l10n.actionSetlistPerformAll),
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
                      l10n.titleSetlistSongCount(setlist.songCount),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    OutlinedButton.icon(
                      onPressed: () => _addSongs(context, ref, setlist),
                      icon: const Icon(Icons.add),
                      label: Text(l10n.actionSetlistAddSongs),
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
                              l10n.emptySetlistNoSongs,
                              style: theme.textTheme.titleSmall,
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              onPressed: () => _addSongs(context, ref, setlist),
                              icon: const Icon(Icons.add),
                              label: Text(l10n.actionSetlistAddSongsNow),
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
                                song.artist.isNotEmpty
                                    ? l10n.descSetlistSongDetailsWithArtist(
                                        song.artist,
                                        song.key,
                                        song.bpm,
                                      )
                                    : l10n.descSetlistSongDetails(
                                        song.key,
                                        song.bpm,
                                      ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.remove_circle_outline,
                                    ),
                                    color: theme.colorScheme.error,
                                    tooltip: l10n.tooltipSetlistRemoveSong,
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.text(AppLocalizations.of(context)))),
        );
      }
    }
  }

  Future<void> _deleteSetlist(
    BuildContext context,
    WidgetRef ref,
    Setlist setlist,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.titleSetlistDelete),
        content: Text(l10n.descSetlistDeleteMessage(setlist.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.actionDelete),
          ),
        ],
      ),
    );

    if (confirm != true || !context.mounted) return;

    // Close the screen first, then delete. This screen watches the setlist
    // live, so deleting first made it redraw as "Setlist not found." for a
    // moment before it closed. The page stays visible while its closing
    // animation runs, so the delete also waits for that to finish. Keep what
    // is needed once the screen has gone.
    final repository = ref.read(setlistRepositoryProvider);
    final messenger = ScaffoldMessenger.of(context);
    final route = ModalRoute.of(context);
    context.pop();
    if (route != null) await route.completed;

    try {
      await repository.deleteSetlist(setlist.id);
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.bodySetlistDeleted(setlist.name))),
      );
    } on AppException catch (e) {
      // The setlist is still in the list, so nothing is lost.
      messenger.showSnackBar(SnackBar(content: Text(e.text(l10n))));
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.text(AppLocalizations.of(context)))),
        );
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.text(AppLocalizations.of(context)))),
        );
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.text(AppLocalizations.of(context)))),
        );
      }
    }
  }

  void _shareSetlistAirQr(BuildContext context, Setlist setlist) {
    final l10n = AppLocalizations.of(context);
    if (setlist.songs.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.bodySetlistNothingToShare)));
      return;
    }
    const service = ChordProService();
    final text = service.formatMultiple(setlist.songs);
    context.push(
      '/air-qr-transmit',
      extra: AirQrTransmitterArgs(
        title: l10n.titleSetlistAirQr(setlist.name),
        chordProPayload: text,
      ),
    );
  }
}
