import 'package:flutter/material.dart';

import 'package:lyricchord/services/chord_shape_service.dart';

/// Draws one chord on a harmonium/piano keyboard.
///
/// Pure UI: it is handed a ready-made [HarmoniumChordShape] and lights up the
/// keys the chord uses. The root is filled in a stronger shade; a slash-chord
/// bass note (`C/E`) is outlined so it stands out from the other notes.
class HarmoniumChordDiagram extends StatelessWidget {
  const HarmoniumChordDiagram({
    super.key,
    required this.name,
    required this.shape,
    this.width = 132,
  });

  /// The chord label shown under the keyboard.
  final String name;

  /// The notes to light up.
  final HarmoniumChordShape shape;

  /// The drawing width in logical pixels. Height follows from it.
  final double width;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // The painted keyboard is invisible to a screen reader, so name it.
        Semantics(
          image: true,
          label: 'Harmonium chord diagram for $name',
          child: SizedBox(
            width: width,
            height: width * 0.55,
            child: CustomPaint(
              painter: _HarmoniumPainter(
                shape: shape,
                outline: theme.colorScheme.onSurfaceVariant,
                whiteKey: theme.colorScheme.surface,
                blackKey: theme.colorScheme.onSurface,
                highlight: theme.colorScheme.primaryContainer,
                rootHighlight: theme.colorScheme.primary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          name,
          style: theme.textTheme.titleSmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// Paints two octaves of keys and highlights the chord's notes.
class _HarmoniumPainter extends CustomPainter {
  _HarmoniumPainter({
    required this.shape,
    required this.outline,
    required this.whiteKey,
    required this.blackKey,
    required this.highlight,
    required this.rootHighlight,
  });

  final HarmoniumChordShape shape;
  final Color outline;
  final Color whiteKey;
  final Color blackKey;
  final Color highlight;
  final Color rootHighlight;

  /// White-key pitch classes, C to B.
  static const List<int> _whitePitches = [0, 2, 4, 5, 7, 9, 11];

  /// Black keys sit after these white-key indexes (C#, D#, F#, G#, A#).
  /// The value is the black key's pitch class.
  static const Map<int, int> _blackAfterWhite = {0: 1, 1: 3, 3: 6, 4: 8, 5: 10};

  /// How many octaves to draw.
  static const int _octaves = 2;

  @override
  void paint(Canvas canvas, Size size) {
    const whitePerOctave = 7;
    final whiteCount = whitePerOctave * _octaves;
    final whiteWidth = size.width / whiteCount;
    final blackWidth = whiteWidth * 0.6;
    final blackHeight = size.height * 0.62;

    final border = Paint()
      ..color = outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // White keys first, so the black keys draw on top.
    for (var i = 0; i < whiteCount; i++) {
      final pitch = _whitePitches[i % whitePerOctave];
      final x = i * whiteWidth;
      final rect = Rect.fromLTWH(x, 0, whiteWidth, size.height);

      final fill = _fillFor(pitch, isBlack: false);
      canvas.drawRect(rect, Paint()..color = fill ?? whiteKey);
      canvas.drawRect(rect, border);
    }

    // Black keys, positioned between the right white keys.
    for (var octave = 0; octave < _octaves; octave++) {
      for (final entry in _blackAfterWhite.entries) {
        final whiteIndex = octave * whitePerOctave + entry.key;
        final pitch = entry.value;
        final centreX = (whiteIndex + 1) * whiteWidth;
        final rect = Rect.fromLTWH(
          centreX - blackWidth / 2,
          0,
          blackWidth,
          blackHeight,
        );

        final fill = _fillFor(pitch, isBlack: true);
        canvas.drawRect(rect, Paint()..color = fill ?? blackKey);
        canvas.drawRect(rect, border);
      }
    }
  }

  /// The highlight colour for a key, or `null` when the chord does not use it.
  Color? _fillFor(int pitch, {required bool isBlack}) {
    if (pitch == shape.root) return rootHighlight;
    if (shape.notes.contains(pitch)) return highlight;
    if (pitch == shape.bass) return highlight;
    return null;
  }

  @override
  bool shouldRepaint(_HarmoniumPainter oldDelegate) =>
      oldDelegate.shape != shape ||
      oldDelegate.highlight != highlight ||
      oldDelegate.rootHighlight != rootHighlight ||
      oldDelegate.whiteKey != whiteKey ||
      oldDelegate.blackKey != blackKey;
}
