import 'package:flutter/material.dart';

import 'package:lyriccord/services/chord_shape_service.dart';

/// Draws one guitar chord as a fretboard diagram.
///
/// Pure UI: it is handed a ready-made [GuitarChordShape] and only draws it. It
/// shows six strings, a few frets, a finger dot on each pressed string, `O` for
/// an open string, `X` for a muted string, and a fret number when the chord
/// sits up the neck.
///
/// When [shape] is `null` the chord has no known fingering, so it shows a short
/// "not available" note instead — never an error (CLAUDE.md hard rule 4).
class GuitarChordDiagram extends StatelessWidget {
  const GuitarChordDiagram({
    super.key,
    required this.name,
    required this.shape,
    this.width = 96,
  });

  /// The chord label shown under the diagram.
  final String name;

  /// The fingering to draw, or `null` when none is known.
  final GuitarChordShape? shape;

  /// The drawing width in logical pixels. Height follows from it.
  final double width;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shape = this.shape;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // The painted fretboard is invisible to a screen reader, so name it.
        Semantics(
          image: true,
          label: shape == null
              ? 'No guitar chord diagram for $name'
              : 'Guitar chord diagram for $name',
          child: SizedBox(
            width: width,
            height: width * 1.25,
            child: shape == null
                ? _NoShape(color: theme.colorScheme.onSurfaceVariant)
                : CustomPaint(
                    painter: _GuitarChordPainter(
                      shape: shape,
                      lineColor: theme.colorScheme.onSurfaceVariant,
                      dotColor: theme.colorScheme.primary,
                      dotTextColor: theme.colorScheme.onPrimary,
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

/// The "no diagram" placeholder for a chord we cannot draw on guitar.
class _NoShape extends StatelessWidget {
  const _NoShape({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.help_outline, color: color),
            const SizedBox(height: 4),
            Text(
              'No diagram',
              textAlign: TextAlign.center,
              style: TextStyle(color: color, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

/// Paints the fretboard, strings, and finger dots for one chord.
class _GuitarChordPainter extends CustomPainter {
  _GuitarChordPainter({
    required this.shape,
    required this.lineColor,
    required this.dotColor,
    required this.dotTextColor,
  });

  final GuitarChordShape shape;
  final Color lineColor;
  final Color dotColor;
  final Color dotTextColor;

  /// How many fret spaces the grid shows.
  static const int _fretCount = 5;
  static const int _stringCount = 6;

  @override
  void paint(Canvas canvas, Size size) {
    // The window of frets shown. A chord near the nut starts at fret 1 and
    // draws the nut as a thick bar; a chord up the neck starts at its lowest
    // pressed fret and shows that number on the left.
    final maxFret = shape.maxFret;
    final startFret = maxFret <= _fretCount ? 1 : shape.minFret;
    final showNut = startFret == 1;

    // Leave room at the top for the O/X markers and at the left for a fret
    // number.
    const topPad = 16.0;
    final leftPad = showNut ? 6.0 : 16.0;
    const rightPad = 6.0;
    const bottomPad = 4.0;

    final gridWidth = size.width - leftPad - rightPad;
    final gridHeight = size.height - topPad - bottomPad;
    final stringGap = gridWidth / (_stringCount - 1);
    final fretGap = gridHeight / _fretCount;

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Vertical string lines.
    for (var s = 0; s < _stringCount; s++) {
      final x = leftPad + s * stringGap;
      canvas.drawLine(
        Offset(x, topPad),
        Offset(x, topPad + gridHeight),
        linePaint,
      );
    }

    // Horizontal fret lines.
    for (var f = 0; f <= _fretCount; f++) {
      final y = topPad + f * fretGap;
      canvas.drawLine(
        Offset(leftPad, y),
        Offset(leftPad + gridWidth, y),
        linePaint,
      );
    }

    // The nut: a thick top bar when the diagram starts at fret 1.
    if (showNut) {
      final nutPaint = Paint()
        ..color = lineColor
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.square;
      canvas.drawLine(
        Offset(leftPad, topPad),
        Offset(leftPad + gridWidth, topPad),
        nutPaint,
      );
    } else {
      // Show the starting fret number to the left of the top space.
      _drawText(
        canvas,
        '$startFret',
        Offset(leftPad - 12, topPad + fretGap / 2),
        color: lineColor,
        fontSize: 10,
        align: TextAlign.right,
      );
    }

    final dotPaint = Paint()
      ..color = dotColor
      ..style = PaintingStyle.fill;

    for (var s = 0; s < _stringCount; s++) {
      final fret = shape.frets[s];
      final x = leftPad + s * stringGap;

      if (fret < 0) {
        // Muted string: an X above the nut.
        _drawText(
          canvas,
          'X',
          Offset(x, topPad - 10),
          color: lineColor,
          fontSize: 11,
        );
        continue;
      }
      if (fret == 0) {
        // Open string: an O above the nut.
        _drawText(
          canvas,
          'O',
          Offset(x, topPad - 10),
          color: lineColor,
          fontSize: 11,
        );
        continue;
      }

      // A pressed fret: a filled dot centred in its fret space.
      final row = fret - startFret; // 0-based space within the window
      final y = topPad + row * fretGap + fretGap / 2;
      canvas.drawCircle(Offset(x, y), fretGap * 0.28, dotPaint);
    }
  }

  /// Draws [text] centred (or right-aligned) at [center].
  void _drawText(
    Canvas canvas,
    String text,
    Offset center, {
    required Color color,
    required double fontSize,
    TextAlign align = TextAlign.center,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
      textAlign: align,
      textDirection: TextDirection.ltr,
    )..layout();

    final dx = align == TextAlign.right
        ? center.dx - painter.width
        : center.dx - painter.width / 2;
    painter.paint(canvas, Offset(dx, center.dy - painter.height / 2));
  }

  @override
  bool shouldRepaint(_GuitarChordPainter oldDelegate) =>
      oldDelegate.shape != shape ||
      oldDelegate.lineColor != lineColor ||
      oldDelegate.dotColor != dotColor;
}
