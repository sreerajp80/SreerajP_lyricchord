import 'package:flutter/material.dart';

import 'package:lyricchord/services/swara_notation_service.dart';

/// Draws one swara on a harmonium keyboard, counted from Sa.
///
/// One octave, with **Sa fixed at the leftmost white key**. The swara's own key
/// is filled; Sa is marked faintly on every diagram so the eye has an anchor to
/// count from.
///
/// The keyboard is drawn relative to Sa, not to C. Nothing here names a Western
/// pitch — position 7 means "seven semitones above Sa, wherever Sa is", which
/// is the same relative counting a Swaram line already uses.
///
/// A token it cannot place draws the bare keyboard with nothing lit. It never
/// guesses and never throws (CLAUDE.md hard rule 4).
class SwaraKeyboardDiagram extends StatelessWidget {
  const SwaraKeyboardDiagram({
    super.key,
    required this.swara,
    this.width = 132,
  });

  /// The swara to light up, as the song writes it (`Sa`, `M2`, `g`).
  final String swara;

  /// The drawing width in logical pixels. Height follows from it.
  final double width;

  static const SwaraNotation _notation = SwaraNotation();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final position = _notation.swaraPosition(swara);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // The painted keyboard is invisible to a screen reader, so name it.
        Semantics(
          image: true,
          label: 'Swara diagram for $swara',
          child: SizedBox(
            width: width,
            height: width * 0.55,
            child: CustomPaint(
              painter: _SwaraKeyboardPainter(
                position: position,
                outline: theme.colorScheme.onSurfaceVariant,
                whiteKey: theme.colorScheme.surface,
                blackKey: theme.colorScheme.onSurface,
                highlight: theme.colorScheme.primary,
                anchor: theme.colorScheme.primaryContainer,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          swara,
          style: theme.textTheme.titleSmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// Paints one octave of keys with Sa at the left and one swara lit.
class _SwaraKeyboardPainter extends CustomPainter {
  _SwaraKeyboardPainter({
    required this.position,
    required this.outline,
    required this.whiteKey,
    required this.blackKey,
    required this.highlight,
    required this.anchor,
  });

  /// Semitones above Sa, or `null` when the swara could not be placed.
  final int? position;

  final Color outline;
  final Color whiteKey;
  final Color blackKey;

  /// Fill for the swara itself.
  final Color highlight;

  /// Fill for Sa, so there is something to count from.
  final Color anchor;

  /// Positions of the white keys, counted from Sa: S R G m P D N.
  static const List<int> _whitePositions = [0, 2, 4, 5, 7, 9, 11];

  /// Black keys sit after these white-key indexes. The value is the black key's
  /// position above Sa: r, g, M, d, n.
  static const Map<int, int> _blackAfterWhite = {0: 1, 1: 3, 3: 6, 4: 8, 5: 10};

  @override
  void paint(Canvas canvas, Size size) {
    final whiteWidth = size.width / _whitePositions.length;
    final blackWidth = whiteWidth * 0.6;
    final blackHeight = size.height * 0.62;

    final border = Paint()
      ..color = outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // White keys first, so the black keys draw on top.
    for (var i = 0; i < _whitePositions.length; i++) {
      final rect = Rect.fromLTWH(i * whiteWidth, 0, whiteWidth, size.height);
      final fill = _fillFor(_whitePositions[i]);
      canvas.drawRect(rect, Paint()..color = fill ?? whiteKey);
      canvas.drawRect(rect, border);
    }

    for (final entry in _blackAfterWhite.entries) {
      final centreX = (entry.key + 1) * whiteWidth;
      final rect = Rect.fromLTWH(
        centreX - blackWidth / 2,
        0,
        blackWidth,
        blackHeight,
      );
      final fill = _fillFor(entry.value);
      canvas.drawRect(rect, Paint()..color = fill ?? blackKey);
      canvas.drawRect(rect, border);
    }
  }

  /// The fill for a key, or `null` to leave it plain.
  ///
  /// The swara itself wins over the Sa anchor, so a diagram for Sa shows one
  /// strongly filled key rather than two.
  Color? _fillFor(int keyPosition) {
    if (keyPosition == position) return highlight;
    if (keyPosition == 0) return anchor;
    return null;
  }

  @override
  bool shouldRepaint(_SwaraKeyboardPainter oldDelegate) =>
      oldDelegate.position != position ||
      oldDelegate.highlight != highlight ||
      oldDelegate.anchor != anchor ||
      oldDelegate.whiteKey != whiteKey ||
      oldDelegate.blackKey != blackKey;
}
