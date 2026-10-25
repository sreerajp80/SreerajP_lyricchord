import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lyricchord/l10n/app_localizations.dart';

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
            AppLocalizations.of(
              context,
            ).errorChordSettingsAddFailed(CustomChordsNotifier.maxChordLength),
          ),
        ),
      );
    }
  }

  Future<void> _remove(String chord) async {
    await ref.read(customChordsProvider.notifier).remove(chord);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context).bodyChordSettingsRemoved(chord),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chords = ref.watch(customChordsProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.titleSettingsChords)),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                l10n.descChordSettingsIntro,
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
                      decoration: InputDecoration(
                        labelText: l10n.labelChordSettings,
                        hintText: l10n.labelChordInserterChordHint,
                        border: const OutlineInputBorder(),
                        counterText: '',
                      ),
                      onSubmitted: (_) => _add(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: _add,
                    icon: const Icon(Icons.add),
                    label: Text(l10n.actionAdd),
                  ),
                ],
              ),
            ),
            Expanded(
              child: chords.isEmpty
                  ? Center(
                      child: Text(
                        l10n.emptyChordSettings,
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
                            tooltip: l10n.tooltipChordSettingsRemove(chord),
                            onPressed: () => _remove(chord),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
