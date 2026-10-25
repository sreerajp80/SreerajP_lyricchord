import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:lyricchord/core/errors/app_exception.dart';
import 'package:lyricchord/l10n/app_localizations.dart';
import 'package:lyricchord/l10n/l10n_labels.dart';
import 'package:lyricchord/providers/database_provider.dart';
import 'package:lyricchord/providers/setlist_provider.dart';
import 'package:lyricchord/widgets/setlist_editor_dialog.dart';

/// Displays the list of all setlists / gig playlists.
class SetlistListScreen extends ConsumerWidget {
  const SetlistListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final setlistsAsync = ref.watch(setlistsStreamProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: setlistsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text(l10n.errorSetlistLoad('$err'))),
        data: (setlists) {
          if (setlists.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.playlist_play,
                      size: 72,
                      color: theme.colorScheme.outline,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.emptySetlistEmptyTitle,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.emptySetlistEmptyMessage,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () => _createSetlist(context, ref),
                      icon: const Icon(Icons.add),
                      label: Text(l10n.actionSetlistCreate),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
            itemCount: setlists.length,
            itemBuilder: (context, index) {
              final setlist = setlists[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 1,
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => context.push('/setlists/${setlist.id}'),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.playlist_play,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                setlist.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                l10n.labelSetlistSongCount(setlist.songCount),
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: theme.colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (setlist.description.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            setlist.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (setlist.songs.isNotEmpty)
                              FilledButton.tonalIcon(
                                onPressed: () {
                                  ref
                                      .read(activeSetlistIdProvider.notifier)
                                      .setActiveSetlist(setlist.id);
                                  final firstSongId = setlist.songs.first.id;
                                  context.push(
                                    '/song/$firstSongId?setlistId=${setlist.id}',
                                  );
                                },
                                icon: const Icon(Icons.play_arrow, size: 18),
                                label: Text(l10n.actionSetlistPerform),
                              ),
                            const SizedBox(width: 8),
                            OutlinedButton(
                              onPressed: () =>
                                  context.push('/setlists/${setlist.id}'),
                              child: Text(l10n.actionSetlistEditSongs),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createSetlist(context, ref),
        icon: const Icon(Icons.add),
        label: Text(l10n.actionSetlistNew),
      ),
    );
  }

  Future<void> _createSetlist(BuildContext context, WidgetRef ref) async {
    final result = await SetlistEditorDialog.show(context);
    if (result == null) return;

    try {
      final id = await ref
          .read(setlistRepositoryProvider)
          .insertSetlist(
            name: result['name']!,
            description: result['description'] ?? '',
          );
      if (context.mounted) {
        context.push('/setlists/$id');
      }
    } on AppException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.text(AppLocalizations.of(context)))),
        );
      }
    }
  }
}
