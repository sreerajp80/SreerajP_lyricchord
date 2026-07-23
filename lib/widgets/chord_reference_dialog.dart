import 'package:flutter/material.dart';

import 'package:lyriccord/services/chord_shape_service.dart';
import 'package:lyriccord/widgets/guitar_chord_diagram.dart';
import 'package:lyriccord/widgets/harmonium_chord_diagram.dart';

/// Opens the Chord Reference Guide dialog for [chords].
///
/// [chords] should already be transposed to the current key and free of
/// duplicates (the performance screen builds it with
/// `ChordTransposer.chordsUsed`). An empty list shows a friendly message.
Future<void> showChordReferenceDialog(
  BuildContext context, {
  required List<String> chords,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => ChordReferenceDialog(chords: chords),
  );
}

/// The Chord Reference Guide: the song's chords drawn as guitar and harmonium
/// diagrams, one tab each.
///
/// Pure UI. It asks [ChordShapeService] for each chord's shape and hands the
/// result to the diagram widgets — it does no note theory itself.
class ChordReferenceDialog extends StatelessWidget {
  const ChordReferenceDialog({super.key, required this.chords});

  /// The chords to show, already transposed and de-duplicated.
  final List<String> chords;

  static const ChordShapeService _shapes = ChordShapeService();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      child: DefaultTabController(
        length: 2,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 8, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Chord Reference',
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.music_note), text: 'Guitar'),
                Tab(icon: Icon(Icons.piano), text: 'Harmonium'),
              ],
            ),
            Flexible(
              child: chords.isEmpty
                  ? const _NoChords()
                  : TabBarView(
                      children: [
                        _DiagramGrid(
                          chords: chords,
                          builder: (chord) => GuitarChordDiagram(
                            name: chord,
                            shape: _shapes.guitarShape(chord),
                          ),
                        ),
                        _DiagramGrid(
                          chords: chords,
                          builder: (chord) => HarmoniumChordDiagram(
                            name: chord,
                            shape: _shapes.harmoniumShape(chord),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A scrolling, wrapping grid of chord diagrams.
class _DiagramGrid extends StatelessWidget {
  const _DiagramGrid({required this.chords, required this.builder});

  final List<String> chords;
  final Widget Function(String chord) builder;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 20,
        runSpacing: 20,
        alignment: WrapAlignment.center,
        children: [for (final chord in chords) builder(chord)],
      ),
    );
  }
}

/// Shown when the song has no chords to draw.
class _NoChords extends StatelessWidget {
  const _NoChords();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.music_off_outlined,
            size: 48,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          Text(
            'No chords in this song',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
