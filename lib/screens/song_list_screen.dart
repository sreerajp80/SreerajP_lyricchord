import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:printing/printing.dart';

import 'package:lyricchord/core/errors/app_exception.dart';
import 'package:lyricchord/core/utils/safe_file_name.dart';
import 'package:lyricchord/models/song_note.dart';
import 'package:lyricchord/providers/database_provider.dart';
import 'package:lyricchord/providers/lyric_font_provider.dart';
import 'package:lyricchord/providers/song_list_provider.dart';
import 'package:lyricchord/screens/setlist_list_screen.dart';
import 'package:lyricchord/services/chord_pro_service.dart';
import 'package:lyricchord/services/html_pdf_service.dart';
import 'package:lyricchord/services/pdf_export_service.dart';
import 'package:lyricchord/widgets/empty_songbook.dart';
import 'package:lyricchord/widgets/song_card.dart';
import 'package:lyricchord/widgets/song_filter_row.dart';
import 'package:lyricchord/widgets/song_search_field.dart';

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
    final selectedIds = ref.watch(multiSongSelectionProvider);
    final isSelectionMode = selectedIds.isNotEmpty;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          leading: isSelectionMode
              ? IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: 'Cancel selection',
                  onPressed: () =>
                      ref.read(multiSongSelectionProvider.notifier).clear(),
                )
              : null,
          title: isSelectionMode
              ? Text('${selectedIds.length} selected')
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('LyricChord'),
                    Text(
                      'Lyrics & Chords Notebook',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
          actions: isSelectionMode
              ? [
                  IconButton(
                    icon: const Icon(Icons.output_rounded),
                    tooltip: 'Export selected (ChordPro)',
                    onPressed: () =>
                        _exportSelectedChordPro(context, ref, songs),
                  ),
                  IconButton(
                    icon: const Icon(Icons.share_outlined),
                    tooltip: 'Share selected',
                    onPressed: () => _shareSelected(context, ref, songs),
                  ),
                  IconButton(
                    icon: Icon(
                      selectedIds.length == songs.length
                          ? Icons.deselect
                          : Icons.select_all,
                    ),
                    tooltip: selectedIds.length == songs.length
                        ? 'Deselect all'
                        : 'Select all',
                    onPressed: () => _toggleSelectAll(ref, songs),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Delete selected',
                    onPressed: () => _confirmDeleteSelected(context, ref),
                  ),
                ]
              : [
                  IconButton(
                    icon: const Icon(Icons.settings_outlined),
                    tooltip: 'Settings',
                    onPressed: () => context.push('/settings'),
                  ),
                ],
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.music_note), text: 'Songs'),
              Tab(icon: Icon(Icons.playlist_play), text: 'Setlists'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Column(
              children: [
                const SongSearchField(),
                const SongFilterRow(),
                Expanded(
                  child: songsAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
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
                              final isChecked = selectedIds.contains(song.id);
                              return SongCard(
                                key: ValueKey(song.id),
                                song: song,
                                selected: dualPane && song.id == selectedId,
                                isSelectionMode: isSelectionMode,
                                isChecked: isChecked,
                                onTap: () {
                                  if (isSelectionMode) {
                                    ref
                                        .read(
                                          multiSongSelectionProvider.notifier,
                                        )
                                        .toggle(song.id);
                                  } else {
                                    _openSong(context, ref, song);
                                  }
                                },
                                onLongPress: () {
                                  if (!isSelectionMode) {
                                    ref
                                        .read(
                                          multiSongSelectionProvider.notifier,
                                        )
                                        .toggle(song.id);
                                  }
                                },
                                onToggleFavorite: () =>
                                    _toggleFavorite(context, ref, song),
                                onDuplicate: () =>
                                    _duplicate(context, ref, song),
                                onDelete: () =>
                                    _confirmDelete(context, ref, song),
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
            const SetlistListScreen(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          tooltip: 'New song',
          onPressed: () => context.push('/new'),
          child: const Icon(Icons.add),
        ),
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

  void _toggleSelectAll(WidgetRef ref, List<SongNote> songs) {
    final notifier = ref.read(multiSongSelectionProvider.notifier);
    final selectedIds = ref.read(multiSongSelectionProvider);
    if (selectedIds.length == songs.length) {
      notifier.clear();
    } else {
      notifier.selectAll(songs.map((s) => s.id));
    }
  }

  Future<void> _exportSelectedChordPro(
    BuildContext context,
    WidgetRef ref,
    List<SongNote> allVisibleSongs,
  ) async {
    final selectedIds = ref.read(multiSongSelectionProvider);
    final selectedSongs = allVisibleSongs
        .where((s) => selectedIds.contains(s.id))
        .toList();

    if (selectedSongs.isEmpty) return;

    try {
      const service = ChordProService();
      final text = service.formatMultiple(selectedSongs);
      final path = await FilePicker.platform.saveFile(
        dialogTitle: 'Export selected songs as ChordPro',
        fileName: selectedSongs.length == 1
            ? '${safeFileName(selectedSongs.first.title)}.chordpro'
            : 'selected_songs.chordpro',
        bytes: Uint8List.fromList(utf8.encode(text)),
      );
      if (context.mounted && path != null) {
        ref.read(multiSongSelectionProvider.notifier).clear();
        _showError(context, 'Exported ${selectedSongs.length} song(s).');
      }
    } catch (_) {
      if (context.mounted) {
        _showError(context, 'Could not export selected songs.');
      }
    }
  }

  Future<void> _shareSelected(
    BuildContext context,
    WidgetRef ref,
    List<SongNote> allVisibleSongs,
  ) async {
    final selectedIds = ref.read(multiSongSelectionProvider);
    final selectedSongs = allVisibleSongs
        .where((s) => selectedIds.contains(s.id))
        .toList();

    if (selectedSongs.isEmpty) return;

    String chosenFormat = 'chordpro';

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Share ${selectedSongs.length} selected song(s)'),
              content: RadioGroup<String>(
                groupValue: chosenFormat,
                onChanged: (val) {
                  if (val != null) {
                    setDialogState(() => chosenFormat = val);
                  }
                },
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RadioListTile<String>(
                      title: Text('ChordPro (.chordpro)'),
                      value: 'chordpro',
                    ),
                    RadioListTile<String>(
                      title: Text('PDF (.pdf)'),
                      value: 'pdf',
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () =>
                      Navigator.of(dialogContext).pop(chosenFormat),
                  child: const Text('Share'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == null) return;

    if (!context.mounted) return;

    if (result == 'chordpro') {
      await _shareChordPro(context, ref, selectedSongs);
    } else if (result == 'pdf') {
      await _sharePdf(context, ref, selectedSongs);
    }
  }

  Future<void> _shareChordPro(
    BuildContext context,
    WidgetRef ref,
    List<SongNote> selectedSongs,
  ) async {
    try {
      const service = ChordProService();
      final text = service.formatMultiple(selectedSongs);
      final fileName = selectedSongs.length == 1
          ? '${safeFileName(selectedSongs.first.title)}.chordpro'
          : 'selected_songs.chordpro';

      final bytes = Uint8List.fromList(utf8.encode(text));
      await Printing.sharePdf(bytes: bytes, filename: fileName);
      if (context.mounted) {
        ref.read(multiSongSelectionProvider.notifier).clear();
      }
    } catch (_) {
      if (context.mounted) {
        _showError(context, 'Could not share selected songs.');
      }
    }
  }

  Future<void> _sharePdf(
    BuildContext context,
    WidgetRef ref,
    List<SongNote> selectedSongs,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context, rootNavigator: true);

    var dialogOpen = true;
    void closeDialog() {
      if (dialogOpen) {
        dialogOpen = false;
        navigator.pop();
      }
    }

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      const service = PdfExportService();
      final font = ref.read(lyricFontProvider);
      final html = await service.buildHtmlForMultiple(
        selectedSongs,
        font: font,
      );
      const converter = HtmlPdfService();
      final bytes = await converter
          .convert(html: html)
          .timeout(const Duration(seconds: 30));
      closeDialog();

      if (bytes.isEmpty) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Could not generate PDF.')),
        );
        return;
      }

      final fileName = selectedSongs.length == 1
          ? '${safeFileName(selectedSongs.first.title)}.pdf'
          : 'selected_songs.pdf';

      await Printing.sharePdf(bytes: bytes, filename: fileName);
      if (context.mounted) {
        ref.read(multiSongSelectionProvider.notifier).clear();
      }
    } catch (_) {
      closeDialog();
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not share selected songs as PDF.')),
      );
    }
  }

  Future<void> _confirmDeleteSelected(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final selectedIds = ref.read(multiSongSelectionProvider);
    if (selectedIds.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Delete ${selectedIds.length} songs?'),
        content: const Text(
          'Selected songs will be removed from your songbook.',
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

    if (confirmed != true) return;

    try {
      final repo = ref.read(songRepositoryProvider);
      final count = selectedIds.length;
      for (final id in selectedIds) {
        await repo.delete(id);
      }
      ref.read(multiSongSelectionProvider.notifier).clear();
      if (context.mounted) {
        _showError(context, 'Deleted $count song(s).');
      }
    } on AppException catch (e) {
      if (context.mounted) _showError(context, e.message);
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
