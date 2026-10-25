import 'package:material_ui/material_ui.dart';
import 'package:lyricchord/l10n/app_localizations.dart';
import 'package:lyricchord/models/setlist.dart';

/// Dialog to create or edit a setlist's name and description.
class SetlistEditorDialog extends StatefulWidget {
  const SetlistEditorDialog({super.key, this.setlist});

  final Setlist? setlist;

  static Future<Map<String, String>?> show(
    BuildContext context, {
    Setlist? setlist,
  }) {
    return showDialog<Map<String, String>>(
      context: context,
      builder: (context) => SetlistEditorDialog(setlist: setlist),
    );
  }

  @override
  State<SetlistEditorDialog> createState() => _SetlistEditorDialogState();
}

class _SetlistEditorDialogState extends State<SetlistEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.setlist?.name ?? '');
    _descController = TextEditingController(
      text: widget.setlist?.description ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.of(context).pop({
        'name': _nameController.text.trim(),
        'description': _descController.text.trim(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.setlist != null;
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(isEditing ? l10n.titleSetlistEdit : l10n.actionSetlistNew),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: l10n.labelSetlistName,
                hintText: l10n.descSetlistNameHint,
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return l10n.errorSetlistNameRequired;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descController,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: l10n.labelSetlistDescription,
                hintText: l10n.descSetlistDescriptionHint,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(isEditing ? l10n.actionSave : l10n.actionCreate),
        ),
      ],
    );
  }
}
