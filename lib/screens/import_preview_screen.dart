import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:lyricchord/core/router/app_router.dart';
import 'package:lyricchord/models/import_preview_args.dart';
import 'package:lyricchord/models/song_note.dart';
import 'package:lyricchord/providers/database_provider.dart';
import 'package:lyricchord/providers/import_settings_provider.dart';
import 'package:lyricchord/services/chord_pro_service.dart';
import 'package:lyricchord/services/chord_sheet_parser.dart';
import 'package:lyricchord/services/import_service.dart';
import 'package:lyricchord/widgets/chord_sheet_view.dart';
import 'package:lyricchord/widgets/rename_imported_song_dialog.dart';

/// Screen allowing the user to preview songs inside an opened .chordpro file
/// before deciding whether to import them into the songbook database.
class ImportPreviewScreen extends ConsumerStatefulWidget {
  final ImportPreviewArgs args;

  const ImportPreviewScreen({super.key, required this.args});

  @override
  ConsumerState<ImportPreviewScreen> createState() =>
      _ImportPreviewScreenState();
}

class _ImportPreviewScreenState extends ConsumerState<ImportPreviewScreen> {
  final Set<int> _selectedIndices = {};
  Set<String> _existingTitles = {};
  bool _isCheckingDuplicates = true;
  bool _isImporting = false;

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < widget.args.parsedSongs.length; i++) {
      _selectedIndices.add(i);
    }
    _checkDuplicates();
  }

  Future<void> _checkDuplicates() async {
    try {
      final repo = ref.read(songRepositoryProvider);
      final allSongs = await repo.getAllSongs();
      final titles = allSongs.map((s) => s.title.trim().toLowerCase()).toSet();
      if (mounted) {
        setState(() {
          _existingTitles = titles;
          _isCheckingDuplicates = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isCheckingDuplicates = false);
      }
    }
  }

  bool _isDuplicate(String title) {
    return _existingTitles.contains(title.trim().toLowerCase());
  }

  void _toggleSelectAll() {
    setState(() {
      if (_selectedIndices.length == widget.args.parsedSongs.length) {
        _selectedIndices.clear();
      } else {
        _selectedIndices.clear();
        for (var i = 0; i < widget.args.parsedSongs.length; i++) {
          _selectedIndices.add(i);
        }
      }
    });
  }

  Future<void> _performImport() async {
    if (_selectedIndices.isEmpty || _isImporting) return;

    setState(() => _isImporting = true);

    final selectedSongs = _selectedIndices
        .map((idx) => widget.args.parsedSongs[idx])
        .toList();

    const chordProService = ChordProService();
    final formattedContent = chordProService.formatMultiple(selectedSongs);

    final repo = ref.read(songRepositoryProvider);
    final strategy = ref.read(importSettingsProvider);
    final importService = ImportService(repository: repo);

    try {
      final res = await importService.importContent(
        content: formattedContent,
        strategy: strategy,
        onAskUserTitle: ({required importedSong, required existingSong}) async {
          if (!mounted) return null;
          return RenameImportedSongDialog.show(
            context,
            importedSong: importedSong,
            existingSong: existingSong,
          );
        },
      );

      if (!mounted) return;

      final messenger = ScaffoldMessenger.of(context);
      final router = ref.read(goRouterProvider);

      if (res.importedSongs.isNotEmpty) {
        if (res.importedSongs.length == 1) {
          messenger.showSnackBar(
            SnackBar(
              content: Text('Imported "${res.importedSongs.first.title}".'),
            ),
          );
          router.go('/song/${res.importedIds.first}');
        } else {
          messenger.showSnackBar(
            SnackBar(
              content: Text('Imported ${res.importedSongs.length} songs.'),
            ),
          );
          router.go('/');
        }
      } else {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isImporting = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Import failed: $e')));
      }
    }
  }

  void _showPreviewSheet(BuildContext context, SongNote song) {
    const parser = ChordSheetParser();
    final parsedSheet = parser.parse(song.lyrics);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        final theme = Theme.of(context);
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Scaffold(
              appBar: AppBar(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(song.title),
                    if (song.artist.isNotEmpty)
                      Text(
                        song.artist,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              body: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      Chip(
                        label: Text('Key: ${song.key}'),
                        visualDensity: VisualDensity.compact,
                      ),
                      Chip(
                        label: Text('${song.bpm} BPM'),
                        visualDensity: VisualDensity.compact,
                      ),
                      if (_isDuplicate(song.title))
                        Chip(
                          avatar: const Icon(Icons.info_outline, size: 16),
                          label: const Text('Already in Songbook'),
                          backgroundColor: theme.colorScheme.errorContainer
                              .withValues(alpha: 0.7),
                          visualDensity: VisualDensity.compact,
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ChordSheetView(lines: parsedSheet, fontSize: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final allSelected =
        _selectedIndices.length == widget.args.parsedSongs.length;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Import Preview'),
            Text(
              widget.args.fileName,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: widget.args.parsedSongs.isEmpty
                ? null
                : _toggleSelectAll,
            child: Text(allSelected ? 'Deselect All' : 'Select All'),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: theme.colorScheme.surfaceContainerHigh,
            child: Row(
              children: [
                Icon(
                  Icons.file_open_outlined,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Found ${widget.args.parsedSongs.length} song${widget.args.parsedSongs.length == 1 ? '' : 's'} in file. Select which songs to import to your songbook.',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
          if (_isCheckingDuplicates)
            const LinearProgressIndicator()
          else
            const Divider(height: 1),
          Expanded(
            child: widget.args.parsedSongs.isEmpty
                ? Center(
                    child: Text(
                      'No valid songs found in this file.',
                      style: theme.textTheme.bodyLarge,
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: widget.args.parsedSongs.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final song = widget.args.parsedSongs[index];
                      final isSelected = _selectedIndices.contains(index);
                      final duplicate = _isDuplicate(song.title);

                      return Card(
                        clipBehavior: Clip.antiAlias,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isSelected
                                ? theme.colorScheme.primary.withValues(
                                    alpha: 0.5,
                                  )
                                : theme.colorScheme.outlineVariant,
                          ),
                        ),
                        child: CheckboxListTile(
                          value: isSelected,
                          onChanged: (checked) {
                            setState(() {
                              if (checked == true) {
                                _selectedIndices.add(index);
                              } else {
                                _selectedIndices.remove(index);
                              }
                            });
                          },
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  song.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              if (duplicate)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.errorContainer,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'In Songbook',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: theme.colorScheme.onErrorContainer,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (song.artist.isNotEmpty)
                                Text(
                                  song.artist,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primaryContainer,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      song.key,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: theme
                                            .colorScheme
                                            .onPrimaryContainer,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${song.bpm} BPM',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const Spacer(),
                                  TextButton.icon(
                                    onPressed: () =>
                                        _showPreviewSheet(context, song),
                                    icon: const Icon(
                                      Icons.remove_red_eye_outlined,
                                      size: 16,
                                    ),
                                    label: const Text('Preview'),
                                    style: TextButton.styleFrom(
                                      visualDensity: VisualDensity.compact,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isImporting
                      ? null
                      : () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go('/');
                          }
                        },
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  onPressed: _selectedIndices.isEmpty || _isImporting
                      ? null
                      : _performImport,
                  icon: _isImporting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.download),
                  label: Text(
                    _isImporting
                        ? 'Importing...'
                        : 'Import Selected (${_selectedIndices.length})',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
