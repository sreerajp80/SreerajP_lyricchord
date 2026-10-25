import 'package:material_ui/material_ui.dart';

import 'package:lyricchord/l10n/app_localizations.dart';

/// The Quick Chord Inserter: a scrolling row of chord chips plus a button for
/// adding a chord that is not in the list.
///
/// Pure UI. It is given the chords to show and reports taps back; working out
/// which chords belong to a key is the service's job.
class ChordInserterBar extends StatelessWidget {
  const ChordInserterBar({
    super.key,
    required this.chords,
    required this.onChordTap,
    required this.onCustomChord,
  });

  /// The chords to show, already in display order.
  final List<String> chords;

  /// Called with the chord the user tapped.
  final ValueChanged<String> onChordTap;

  /// Called with the chord typed in the custom-chord dialog.
  final ValueChanged<String> onCustomChord;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant),
          bottom: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            for (final chord in chords) ...[
              ActionChip(
                label: Text(chord),
                tooltip: l10n.tooltipChordInserterInsert(chord),
                onPressed: () => onChordTap(chord),
              ),
              const SizedBox(width: 8),
            ],
            ActionChip(
              avatar: const Icon(Icons.add, size: 18),
              label: Text(l10n.actionChordInserterCustom),
              tooltip: l10n.tooltipChordInserterCustom,
              onPressed: () => _askForChord(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _askForChord(BuildContext context) async {
    final chord = await showDialog<String>(
      context: context,
      builder: (dialogContext) => const _CustomChordDialog(),
    );

    if (chord != null && chord.trim().isNotEmpty) onCustomChord(chord.trim());
  }
}

/// The "add your own chord" dialog.
///
/// A [StatefulWidget] so it owns its [TextEditingController] and disposes it
/// only when the dialog route is fully gone. Disposing the controller right
/// after `showDialog` returns (while the close animation is still running)
/// would rebuild the field with a disposed controller and throw.
class _CustomChordDialog extends StatefulWidget {
  const _CustomChordDialog();

  @override
  State<_CustomChordDialog> createState() => _CustomChordDialogState();
}

class _CustomChordDialogState extends State<_CustomChordDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.titleChordInserterDialog),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: InputDecoration(
          labelText: l10n.labelChordInserterChord,
          hintText: l10n.labelChordInserterChordHint,
        ),
        onSubmitted: (value) => Navigator.of(context).pop(value),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: Text(l10n.actionAdd),
        ),
      ],
    );
  }
}
