import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:lyricchord/core/errors/app_exception.dart';
import 'package:lyricchord/core/utils/chord_insert.dart';
import 'package:lyricchord/providers/custom_chords_provider.dart';
import 'package:lyricchord/providers/database_provider.dart';
import 'package:lyricchord/providers/lyric_font_provider.dart';
import 'package:lyricchord/providers/setlist_provider.dart';
import 'package:lyricchord/providers/song_editor_provider.dart';
import 'package:lyricchord/providers/song_list_provider.dart';
import 'package:lyricchord/widgets/chord_inserter_bar.dart';
import 'package:lyricchord/widgets/song_meta_fields.dart';

/// Write a new song or change an existing one.
///
/// Top bar: close, the screen title, and Save. Then the meta fields, the Quick
/// Chord Inserter, and a large borderless lyrics area — the aim is that writing
/// lyrics feels like a plain notepad with chords one tap away.
class SongEditorScreen extends ConsumerStatefulWidget {
  const SongEditorScreen({super.key, this.songId});

  /// The song to edit, or `null` to write a new one.
  final int? songId;

  @override
  ConsumerState<SongEditorScreen> createState() => _SongEditorScreenState();
}

class _SongEditorScreenState extends ConsumerState<SongEditorScreen> {
  final _titleController = TextEditingController();
  final _artistController = TextEditingController();
  final _keyController = TextEditingController();
  final _bpmController = TextEditingController();
  final _lyricsController = TextEditingController();
  final _lyricsFocus = FocusNode();

  /// Drives undo/redo for the lyrics field. Wired to the lyrics [TextField] so
  /// it records both typing and chord insertions, and read by the app-bar
  /// Undo/Redo buttons to know when they are usable.
  final _undoController = UndoHistoryController();

  /// Optional setlist ID to add song to upon saving.
  int? _selectedSetlistId;

  /// The family key: `0` stands for "new song".
  late final int _songId = widget.songId ?? 0;

  /// True once the loaded song has been copied into the text fields, so a
  /// later rebuild never overwrites what the user is typing.
  bool _filled = false;

  bool _saving = false;

  /// True while the meta fields (title/artist/key/tempo/setlist) are folded
  /// away to give the lyrics field more room. Driven by lyrics focus, but the
  /// user can also open it back up by tapping the summary row.
  bool _metaCollapsed = false;

  @override
  void initState() {
    super.initState();
    // Typing lyrics folds the meta fields away so the lyrics area is tall;
    // leaving the lyrics field brings them back.
    _lyricsFocus.addListener(_onLyricsFocusChange);
    // Fill the fields as soon as the draft loads. Done through a manual
    // listener so it happens outside build().
    ref.listenManual(songEditorProvider(_songId), (previous, next) {
      final draft = next.value;
      if (draft == null || _filled) return;
      _titleController.text = draft.title;
      _artistController.text = draft.artist;
      _keyController.text = draft.key;
      _bpmController.text = draft.bpmText;
      _lyricsController.text = draft.lyrics;
      _filled = true;
      // Loading the song is not an edit — throw away the history so the first
      // Undo cannot wipe an existing song back to empty.
      _undoController.value = UndoHistoryValue.empty;
    }, fireImmediately: true);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _artistController.dispose();
    _keyController.dispose();
    _bpmController.dispose();
    _lyricsController.dispose();
    _lyricsFocus.removeListener(_onLyricsFocusChange);
    _lyricsFocus.dispose();
    _undoController.dispose();
    super.dispose();
  }

  /// Folds the meta fields away while the lyrics field is focused, and brings
  /// them back when focus leaves.
  void _onLyricsFocusChange() {
    final collapsed = _lyricsFocus.hasFocus;
    if (collapsed == _metaCollapsed) return;
    setState(() => _metaCollapsed = collapsed);
  }

  SongEditorNotifier get _editor =>
      ref.read(songEditorProvider(_songId).notifier);

  @override
  Widget build(BuildContext context) {
    final draftAsync = ref.watch(songEditorProvider(_songId));
    final setlists = ref.watch(setlistsStreamProvider).value ?? const [];
    final isNew = _songId == 0;

    final isDirty = draftAsync.value?.isDirty ?? false;

    return PopScope(
      // A clean draft can just leave; a changed one asks first.
      canPop: !isDirty,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _close();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'Cancel',
            onPressed: _close,
          ),
          title: Text(isNew ? 'New Song Note' : 'Edit Song Note'),
          actions: [
            ValueListenableBuilder<UndoHistoryValue>(
              valueListenable: _undoController,
              builder: (context, value, _) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.undo),
                    tooltip: 'Undo',
                    onPressed: value.canUndo ? _undo : null,
                  ),
                  IconButton(
                    icon: const Icon(Icons.redo),
                    tooltip: 'Redo',
                    onPressed: value.canRedo ? _redo : null,
                  ),
                ],
              ),
            ),
            TextButton.icon(
              onPressed: _saving ? null : _save,
              icon: const Icon(Icons.check),
              label: const Text('Save'),
            ),
            // "Save as copy" only makes sense for an existing song — for a new
            // one, plain Save already creates a new song.
            if (!isNew)
              PopupMenuButton<VoidCallback>(
                tooltip: 'More options',
                onSelected: (action) => action(),
                itemBuilder: (menuContext) => [
                  PopupMenuItem<VoidCallback>(
                    value: _saving ? null : _saveAsCopy,
                    enabled: !_saving,
                    child: const ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.content_copy_outlined),
                      title: Text('Save as copy'),
                    ),
                  ),
                ],
              ),
            const SizedBox(width: 8),
          ],
        ),
        body: draftAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text('This song could not be opened.'),
            ),
          ),
          data: (draft) => Column(
            children: [
              // The meta block folds away while the lyrics field is focused so
              // the lyrics area gets the room. A compact summary takes its place
              // and can be tapped to open the fields back up. AnimatedSize keeps
              // the height change smooth while the child swaps.
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                alignment: Alignment.topCenter,
                child: _metaCollapsed
                    ? _MetaSummary(
                        titleController: _titleController,
                        keyController: _keyController,
                        bpmController: _bpmController,
                        onTap: () => setState(() => _metaCollapsed = false),
                      )
                    : SongMetaFields(
                        titleController: _titleController,
                        artistController: _artistController,
                        keyController: _keyController,
                        bpmController: _bpmController,
                        onTitleChanged: _editor.setTitle,
                        onArtistChanged: _editor.setArtist,
                        onKeyChanged: _editor.setKey,
                        onBpmChanged: _editor.setBpmText,
                        selectedSetlistId: _selectedSetlistId,
                        availableSetlists: setlists,
                        onSetlistChanged: (id) =>
                            setState(() => _selectedSetlistId = id),
                      ),
              ),
              const SizedBox(height: 12),
              ChordInserterBar(
                chords: draft.chordSuggestionsWith(
                  ref.watch(customChordsProvider),
                ),
                onChordTap: _insertChord,
                onCustomChord: _addCustomChord,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: TextField(
                    controller: _lyricsController,
                    focusNode: _lyricsFocus,
                    undoController: _undoController,
                    onChanged: _editor.setLyrics,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    keyboardType: TextInputType.multiline,
                    textCapitalization: TextCapitalization.sentences,
                    style: TextStyle(
                      fontFamily: ref.watch(lyricFontProvider).family,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText:
                          'Write your lyrics here.\n'
                          'Tap a chord above to drop it in at the cursor.',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Puts `[Chord]` where the caret is and keeps typing focus on the lyrics.
  void _insertChord(String chord) {
    final updated = insertChord(_lyricsController.value, chord);
    _lyricsController.value = updated;
    _editor.setLyrics(updated.text);
    _lyricsFocus.requestFocus();
  }

  void _addCustomChord(String chord) {
    _editor.addCustomChord(chord);
    _insertChord(chord);
  }

  /// Steps the lyrics back one edit. A programmatic change like this does not
  /// fire `onChanged`, so the draft is synced by hand and focus is returned to
  /// the field.
  void _undo() {
    _undoController.undo();
    _editor.setLyrics(_lyricsController.text);
    _lyricsFocus.requestFocus();
  }

  /// Steps the lyrics forward one edit (the reverse of [_undo]).
  void _redo() {
    _undoController.redo();
    _editor.setLyrics(_lyricsController.text);
    _lyricsFocus.requestFocus();
  }

  /// Saves the current draft as a brand-new song, leaving the original as it
  /// was. Handy for building an arrangement variant (e.g. the same song in a
  /// different key).
  Future<void> _saveAsCopy() async {
    setState(() => _saving = true);
    try {
      final id = await _editor.saveAsCopy();
      if (!mounted) return;
      if (_selectedSetlistId != null) {
        await ref
            .read(setlistRepositoryProvider)
            .addSongToSetlist(_selectedSetlistId!, id);
      }
      // On a tablet the list stays visible, so open the new copy in the pane.
      ref.read(selectedSongIdProvider.notifier).select(id);
      _leave();
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final id = await _editor.save();
      if (!mounted) return;
      if (_selectedSetlistId != null) {
        await ref
            .read(setlistRepositoryProvider)
            .addSongToSetlist(_selectedSetlistId!, id);
      }
      // On a tablet the list stays visible, so show the saved song there.
      ref.read(selectedSongIdProvider.notifier).select(id);
      _leave();
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  /// Cancel. Asks first when there are unsaved edits.
  Future<void> _close() async {
    final draft = ref.read(songEditorProvider(_songId)).value;
    if (draft == null || !draft.isDirty) {
      _leave();
      return;
    }

    final discard = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text('Your edits to this song will not be saved.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Keep editing'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );

    if (discard == true && mounted) _leave();
  }

  /// Leaves the editor, whichever way we got here.
  ///
  /// Normally we came from the list, so a plain pop is right. If the editor was
  /// opened straight from a link there is nothing to pop, so go back to the
  /// songbook instead.
  void _leave() {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
      return;
    }
    GoRouter.maybeOf(context)?.go('/');
  }
}

/// The one-line stand-in shown while the meta fields are folded away.
///
/// Reads straight from the editor's controllers so it always reflects the
/// latest title / key / tempo. Tapping it opens the full fields back up.
class _MetaSummary extends StatelessWidget {
  const _MetaSummary({
    required this.titleController,
    required this.keyController,
    required this.bpmController,
    required this.onTap,
  });

  final TextEditingController titleController;
  final TextEditingController keyController;
  final TextEditingController bpmController;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = titleController.text.trim();
    final key = keyController.text.trim();
    final bpm = bpmController.text.trim();

    final parts = <String>[
      title.isEmpty ? 'Untitled' : title,
      if (key.isNotEmpty) 'Key $key',
      if (bpm.isNotEmpty) '$bpm BPM',
    ];

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                parts.join('  ·  '),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall,
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.expand_more, color: theme.colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
