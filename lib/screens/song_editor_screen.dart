import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:lyriccord/core/errors/app_exception.dart';
import 'package:lyriccord/core/utils/chord_insert.dart';
import 'package:lyriccord/providers/song_editor_provider.dart';
import 'package:lyriccord/providers/song_list_provider.dart';
import 'package:lyriccord/widgets/chord_inserter_bar.dart';
import 'package:lyriccord/widgets/song_meta_fields.dart';

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

  /// The family key: `0` stands for "new song".
  late final int _songId = widget.songId ?? 0;

  /// True once the loaded song has been copied into the text fields, so a
  /// later rebuild never overwrites what the user is typing.
  bool _filled = false;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
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
    }, fireImmediately: true);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _artistController.dispose();
    _keyController.dispose();
    _bpmController.dispose();
    _lyricsController.dispose();
    _lyricsFocus.dispose();
    super.dispose();
  }

  SongEditorNotifier get _editor =>
      ref.read(songEditorProvider(_songId).notifier);

  @override
  Widget build(BuildContext context) {
    final draftAsync = ref.watch(songEditorProvider(_songId));
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
            TextButton.icon(
              onPressed: _saving ? null : _save,
              icon: const Icon(Icons.check),
              label: const Text('Save'),
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
              SongMetaFields(
                titleController: _titleController,
                artistController: _artistController,
                keyController: _keyController,
                bpmController: _bpmController,
                onTitleChanged: _editor.setTitle,
                onArtistChanged: _editor.setArtist,
                onKeyChanged: _editor.setKey,
                onBpmChanged: _editor.setBpmText,
              ),
              const SizedBox(height: 12),
              ChordInserterBar(
                chords: draft.chordSuggestions,
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
                    onChanged: _editor.setLyrics,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    keyboardType: TextInputType.multiline,
                    textCapitalization: TextCapitalization.sentences,
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

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final id = await _editor.save();
      if (!mounted) return;
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
