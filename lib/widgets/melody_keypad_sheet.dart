import 'package:flutter/material.dart';

import 'package:lyricchord/models/melody_line.dart';
import 'package:lyricchord/services/melody_entry_service.dart';
import 'package:lyricchord/services/melody_parser_service.dart';
import 'package:lyricchord/services/swara_notation_service.dart';
import 'package:lyricchord/widgets/melody_beat_grid.dart';

/// Tap out a `{melody}` line: swaras, marks, a live preview, and a beat count.
///
/// Everything above the buttons is drawn from a **real parse** of what has been
/// entered, so the preview is exactly what the player will sing — there is no
/// second reading of the format anywhere in this file.
///
/// The sheet knows no syntax of its own. Buttons call [MelodyEntry], which owns
/// every token this writes (architecture §4, layer boundaries).
///
/// Returns the finished `{melody}` line, or `null` when the user backs out.
class MelodyKeypadSheet extends StatefulWidget {
  const MelodyKeypadSheet({super.key, this.tala = '', this.initialLine = ''});

  /// The song's tala, used only to count beats against. May be empty.
  final String tala;

  /// A line to load for editing, with or without its `{melody}` prefix.
  final String initialLine;

  @override
  State<MelodyKeypadSheet> createState() => _MelodyKeypadSheetState();
}

class _MelodyKeypadSheetState extends State<MelodyKeypadSheet> {
  static const _parser = MelodyParser();
  static const _swara = SwaraNotation();

  /// The swaras, in pitch order. All sixteen are always offered: the app keeps
  /// no raga → swara table, so hiding one would mean guessing (see the melody
  /// plan §3.4).
  static const List<List<String>> _swaraRows = [
    ['S', 'R1', 'R2', 'R3', 'G1', 'G2', 'G3', 'M1', 'M2'],
    ['P', 'D1', 'D2', 'D3', 'N1', 'N2', 'N3'],
  ];

  late MelodyEntry _entry = MelodyEntry.fromLine(widget.initialLine);

  /// Beats in one cycle of the song's tala, or `null` when it is unknown.
  late final int? _talaBeats = widget.tala.trim().isEmpty
      ? null
      : _swara.talaBeats(widget.tala);

  MelodyLine get _line => _parser.parse(_entry.line);

  void _update(MelodyEntry next) => setState(() => _entry = next);

  /// Asks before throwing away work; a sheet with nothing in it just closes.
  Future<void> _cancel() async {
    if (!_entry.isEmpty && _entry.line != _startingLine) {
      final leave = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Discard this melody?'),
          content: const Text('What you tapped will be lost.'),
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
      if (leave != true) return;
    }
    if (mounted) Navigator.of(context).pop();
  }

  late final String _startingLine = MelodyEntry.fromLine(
    widget.initialLine,
  ).line;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final line = _line;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Pinned: the preview and the count are the whole point of the
            // keypad, so they never scroll out of sight.
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Melody keypad',
                    style: theme.textTheme.titleLarge,
                  ),
                ),
                _BeatCount(
                  beats: line.beatCount,
                  talaBeats: _talaBeats,
                  tala: widget.tala.trim(),
                  fits: line.fitsTala(_talaBeats) ?? false,
                ),
              ],
            ),
            const SizedBox(height: 8),
            _Preview(line: line),
            for (final problem in line.problems)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  problem,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
            const Divider(height: 20),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final row in _swaraRows)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final swara in row)
                              _PadButton(
                                label: swara,
                                onPressed: () => _update(_entry.addNote(swara)),
                              ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _PadButton(
                          label: 'Hold ,',
                          tooltip: 'Ring on for one more beat',
                          onPressed: () => _update(_entry.hold()),
                        ),
                        _PadButton(
                          label: 'Bar |',
                          tooltip: 'Group divider — takes no time',
                          onPressed: () => _update(_entry.barLine()),
                        ),
                        _PadButton(
                          label: 'Share -',
                          tooltip: 'The next note shares this beat',
                          selected: _entry.shareArmed,
                          onPressed: _entry.canShare
                              ? () => _update(_entry.share())
                              : null,
                        ),
                        _PadButton(
                          label: 'Tie ,-',
                          tooltip:
                              'Start the next note part-way through a beat',
                          onPressed: () => _update(_entry.tie()),
                        ),
                        _PadButton(
                          label: 'Silence x',
                          tooltip: 'Stop the sound',
                          onPressed: () => _update(_entry.silence()),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _markButton(MelodyMark.octaveUp, 'Octave ↑'),
                        _markButton(MelodyMark.octaveDown, 'Octave ↓'),
                        _markButton(MelodyMark.slide, 'Slide !'),
                        _markButton(MelodyMark.shake, 'Shake ~'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.backspace_outlined),
                  tooltip: 'Backspace',
                  onPressed: _entry.isEmpty && !_entry.shareArmed
                      ? null
                      : () => _update(_entry.backspace()),
                ),
                TextButton(
                  onPressed: _entry.isEmpty
                      ? null
                      : () => _update(_entry.clear()),
                  child: const Text('Clear'),
                ),
                const Spacer(),
                TextButton(onPressed: _cancel, child: const Text('Cancel')),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: _entry.isEmpty
                      ? null
                      : () => Navigator.of(context).pop(_entry.line),
                  icon: const Icon(Icons.add),
                  label: const Text('Insert'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// A mark button, lit while the mark is on the last note and dead when there
  /// is no note to put it on.
  Widget _markButton(MelodyMark mark, String label) => _PadButton(
    label: label,
    selected: _entry.markActive(mark),
    onPressed: _entry.canMarkLastNote
        ? () => _update(_entry.toggle(mark))
        : null,
  );
}

/// The running beat count, and whether it fills the tala.
class _BeatCount extends StatelessWidget {
  const _BeatCount({
    required this.beats,
    required this.talaBeats,
    required this.tala,
    required this.fits,
  });

  final int beats;
  final int? talaBeats;
  final String tala;
  final bool fits;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // With no tala, or one the app does not know, it says nothing about fit
    // rather than guessing.
    if (talaBeats == null) {
      return Text(
        '$beats ${beats == 1 ? 'beat' : 'beats'}',
        style: theme.textTheme.labelLarge,
      );
    }

    final good = fits && beats > 0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (good) ...[
          Icon(
            Icons.check_circle_outline,
            size: 16,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 4),
        ],
        Text(
          good ? '$beats beats — fits $tala' : '$beats of $talaBeats beats',
          style: theme.textTheme.labelLarge?.copyWith(
            color: good ? theme.colorScheme.primary : null,
          ),
        ),
      ],
    );
  }
}

/// The beat grid, or a hint while nothing has been entered.
class _Preview extends StatelessWidget {
  const _Preview({required this.line});

  final MelodyLine line;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 56),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.centerLeft,
      child: line.beats.isEmpty
          ? Text(
              'Tap a swara to start. Hold adds a beat, Bar marks a group.',
              style: theme.textTheme.bodySmall,
            )
          : MelodyBeatGrid(line: line),
    );
  }
}

/// One keypad key. Lit when [selected], dead when [onPressed] is `null`.
class _PadButton extends StatelessWidget {
  const _PadButton({
    required this.label,
    required this.onPressed,
    this.tooltip,
    this.selected = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final String? tooltip;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final button = selected
        ? FilledButton(onPressed: onPressed, child: Text(label))
        : OutlinedButton(onPressed: onPressed, child: Text(label));

    return tooltip == null ? button : Tooltip(message: tooltip!, child: button);
  }
}
