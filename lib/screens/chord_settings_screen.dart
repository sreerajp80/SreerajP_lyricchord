import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lyricchord/providers/custom_chords_provider.dart';

/// Settings → Chords: the user's own chord notations.
///
/// Chords saved here (e.g. `Cmaj7`, `D/F#`) are always offered in the
/// editor's Quick Chord Inserter, after the key's own chords. Entries are
/// trimmed, capped in length, and never duplicated, so bad input stays
/// harmless (CLAUDE.md hard rule 4).
class ChordSettingsScreen extends ConsumerStatefulWidget {
  const ChordSettingsScreen({super.key});

  @override
  ConsumerState<ChordSettingsScreen> createState() =>
      _ChordSettingsScreenState();
}

class _ChordSettingsScreenState extends ConsumerState<ChordSettingsScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    final text = _controller.text;
    if (text.trim().isEmpty) return;

    final added = await ref.read(customChordsProvider.notifier).add(text);
    if (!mounted) return;

    if (added) {
      _controller.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not add that chord. Use at most '
            '${CustomChordsNotifier.maxChordLength} characters and no '
            'repeats.',
          ),
        ),
      );
    }
  }

  Future<void> _remove(String chord) async {
    await ref.read(customChordsProvider.notifier).remove(chord);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Removed "$chord".')));
  }

  @override
  Widget build(BuildContext context) {
    final chords = ref.watch(customChordsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Chords')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Add your own chord notations. They always appear in the '
              "editor's chord bar, after the key's own chords.",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    maxLength: CustomChordsNotifier.maxChordLength,
                    decoration: const InputDecoration(
                      labelText: 'Chord notation',
                      hintText: 'F#m7, Cmaj7, D/F#',
                      border: OutlineInputBorder(),
                      counterText: '',
                    ),
                    onSubmitted: (_) => _add(),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: _add,
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                ),
              ],
            ),
          ),
          Expanded(
            child: chords.isEmpty
                ? Center(
                    child: Text(
                      'No custom chords yet.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: chords.length,
                    itemBuilder: (context, index) {
                      final chord = chords[index];
                      return ListTile(
                        key: ValueKey(chord),
                        leading: const Icon(Icons.music_note_outlined),
                        title: Text(chord),
                        trailing: IconButton(
                          icon: const Icon(Icons.close),
                          tooltip: 'Remove $chord',
                          onPressed: () => _remove(chord),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
