import 'package:material_ui/material_ui.dart';
import 'package:lyricchord/l10n/app_localizations.dart';

import 'package:lyricchord/services/chord_shape_service.dart';
import 'package:lyricchord/widgets/guitar_chord_diagram.dart';
import 'package:lyricchord/widgets/harmonium_chord_diagram.dart';
import 'package:lyricchord/widgets/swara_keyboard_diagram.dart';

/// Opens the Chord Reference Guide dialog for [chords].
///
/// [chords] should already be transposed to the current key and free of
/// duplicates (the performance screen builds it with
/// `ChordTransposer.chordsUsed`). An empty list shows a friendly message.
///
/// Pass `swaraMode: true` for a song written in swaras. See
/// [ChordReferenceDialog.swaraMode].
Future<void> showChordReferenceDialog(
  BuildContext context, {
  required List<String> chords,
  bool swaraMode = false,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => ChordReferenceDialog(chords: chords, swaraMode: swaraMode),
  );
}

/// The Chord Reference Guide: the song's chords drawn as guitar and harmonium
/// diagrams, one tab each.
///
/// In [swaraMode] it becomes the **Swara Reference** instead: one view, no
/// tabs, each swara drawn at its own position on a harmonium keyboard.
///
/// Pure UI. It asks [ChordShapeService] for each chord's shape and hands the
/// result to the diagram widgets — it does no note theory itself.
class ChordReferenceDialog extends StatelessWidget {
  const ChordReferenceDialog({
    super.key,
    required this.chords,
    this.swaraMode = false,
  });

  /// The chords to show, already transposed and de-duplicated. In [swaraMode]
  /// these are swaras (`Sa`, `Ma`), written the way the song writes them.
  final List<String> chords;

  /// True for a song written in swaras.
  ///
  /// A swara is one note, not a chord, so there is no guitar fingering to show
  /// and no second tab. Drawing a chord shape for `Sa` would be an invention —
  /// which is exactly what this screen used to do.
  final bool swaraMode;

  static const ChordShapeService _shapes = ChordShapeService();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 8, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    swaraMode
                        ? l10n.actionPerfSwaraReference
                        : l10n.titleChordRef,
                    style: theme.textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  tooltip: l10n.actionClose,
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          Flexible(child: swaraMode ? _swaraBody(l10n) : _chordBody(l10n)),
        ],
      ),
    );
  }

  /// One scrolling grid of keyboards, each showing where that swara sits.
  Widget _swaraBody(AppLocalizations l10n) {
    if (chords.isEmpty) return _Empty(message: l10n.emptyChordRefNoSwaras);

    return _DiagramGrid(
      chords: chords,
      builder: (swara) => SwaraKeyboardDiagram(swara: swara),
    );
  }

  /// The two-tab guitar and harmonium view, unchanged.
  Widget _chordBody(AppLocalizations l10n) {
    if (chords.isEmpty) return _Empty(message: l10n.emptyChordRefNoChords);

    return DefaultTabController(
      length: 2,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TabBar(
            tabs: [
              Tab(
                icon: const Icon(Icons.music_note),
                text: l10n.tabChordRefGuitar,
              ),
              Tab(
                icon: const Icon(Icons.piano),
                text: l10n.tabChordRefHarmonium,
              ),
            ],
          ),
          Flexible(
            child: TabBarView(
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

/// Shown when the song has nothing to draw.
class _Empty extends StatelessWidget {
  const _Empty({required this.message});

  final String message;

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
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
