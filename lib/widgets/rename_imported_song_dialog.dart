import 'package:material_ui/material_ui.dart';

import 'package:lyricchord/l10n/app_localizations.dart';

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

  /// Returns the new title, but only once the form says it is not empty.
  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.of(context).pop(_controller.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.titleRenameImport),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.descRenameImportExists(widget.existingSong.title),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.descRenameImportPrompt,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _controller,
              autofocus: true,
              decoration: InputDecoration(
                labelText: l10n.labelRenameImport,
                border: const OutlineInputBorder(),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return l10n.errorRenameImportRequired;
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _submit,
          child: Text(l10n.actionRenameImportSave),
        ),
      ],
    );
  }
}
