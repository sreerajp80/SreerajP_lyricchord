import 'package:flutter/material.dart';

import 'package:lyricchord/models/song_note.dart';

/// Dialog shown when a duplicate title is encountered and user-suggested name mode is active.
class RenameImportedSongDialog extends StatefulWidget {
  final SongNote importedSong;
  final SongNote existingSong;

  const RenameImportedSongDialog({
    super.key,
    required this.importedSong,
    required this.existingSong,
  });

  static Future<String?> show(
    BuildContext context, {
    required SongNote importedSong,
    required SongNote existingSong,
  }) {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => RenameImportedSongDialog(
        importedSong: importedSong,
        existingSong: existingSong,
      ),
    );
  }

  @override
  State<RenameImportedSongDialog> createState() =>
      _RenameImportedSongDialogState();
}

class _RenameImportedSongDialogState extends State<RenameImportedSongDialog> {
  late final TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.importedSong.title);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Duplicate Song Title'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'A song titled "${widget.existingSong.title}" already exists in your songbook.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            const Text(
              'Enter a new title for the imported song:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _controller,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Song Title',
                border: OutlineInputBorder(),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: const Text('Save with New Title'),
        ),
      ],
    );
  }
}
