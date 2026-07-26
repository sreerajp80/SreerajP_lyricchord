import 'package:flutter/material.dart';
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

    return AlertDialog(
      title: Text(isEditing ? 'Edit Setlist' : 'New Setlist'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Setlist Name',
                hintText: 'e.g. Sunday Gig, Acoustic Practice',
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Please enter a setlist name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                hintText: 'e.g. Venue, lineup, or notes',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(isEditing ? 'Save' : 'Create'),
        ),
      ],
    );
  }
}
