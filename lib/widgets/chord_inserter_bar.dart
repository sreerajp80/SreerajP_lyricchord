import 'package:flutter/material.dart';

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
                tooltip: 'Insert [$chord]',
                onPressed: () => onChordTap(chord),
              ),
              const SizedBox(width: 8),
            ],
            ActionChip(
              avatar: const Icon(Icons.add, size: 18),
              label: const Text('Custom'),
              tooltip: 'Add your own chord',
              onPressed: () => _askForChord(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _askForChord(BuildContext context) async {
    final controller = TextEditingController();
    final chord = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Custom chord'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Chord',
            hintText: 'F#m7, Cmaj7, D/F#',
          ),
          onSubmitted: (value) => Navigator.of(dialogContext).pop(value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(controller.text),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    controller.dispose();

    if (chord != null && chord.trim().isNotEmpty) onCustomChord(chord.trim());
  }
}
