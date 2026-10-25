import 'package:material_ui/material_ui.dart';
import 'package:lyricchord/l10n/app_localizations.dart';

import 'package:lyricchord/models/melody_beat.dart';
import 'package:lyricchord/models/melody_line.dart';

/// Draws a melody line as a row of beat boxes, split into tala groups.
///
/// One box per beat, in written order. A bar line becomes a gap between groups
/// rather than a box of its own, because it takes no time — a reader counting
/// the tala needs to see the groups, not a divider sitting in a beat's place.
///
/// A beat holding more than one note (`G3-R2`) draws its notes side by side
/// inside the one box, so the eye can see that they share the beat.
///
/// Knows nothing about audio or syntax. It is handed a parsed line and the beat
/// that is sounding, and only draws (architecture §4, layer boundaries).
class MelodyBeatGrid extends StatelessWidget {
  const MelodyBeatGrid({
    super.key,
    required this.line,
    this.currentBeat,
    this.textStyle,
  });

  /// The line to draw.
  final MelodyLine line;

  /// The index into [MelodyLine.beats] that is sounding, or `null` when the
  /// line is not playing. That box is highlighted.
  final int? currentBeat;

  /// Style for the swara text. Falls back to the theme's monospace body style,
  /// because beats only read correctly when the columns line up.
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    if (line.beats.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final style = (textStyle ?? theme.textTheme.bodyMedium ?? const TextStyle())
        .copyWith(fontFamily: 'monospace', height: 1.1);

    // Wide lines must scroll on their own rather than squeezing the boxes to
    // nothing — a fourteen-beat ata tala line will not fit a phone.
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: _groups(context, style)),
    );
  }

  /// Splits the beats at every bar line and draws each group as a run of boxes.
  List<Widget> _groups(BuildContext context, TextStyle style) {
    final widgets = <Widget>[];
    var group = <Widget>[];

    void closeGroup() {
      if (group.isEmpty) return;
      widgets.add(Row(mainAxisSize: MainAxisSize.min, children: group));
      group = <Widget>[];
    }

    for (var i = 0; i < line.beats.length; i++) {
      final beat = line.beats[i];
      if (beat.kind == MelodyBeatKind.barLine) {
        closeGroup();
        widgets.add(const SizedBox(width: 14));
        continue;
      }
      group.add(_box(context, beat, i, style));
    }
    closeGroup();

    return widgets;
  }

  /// One beat box.
  Widget _box(
    BuildContext context,
    MelodyBeat beat,
    int index,
    TextStyle style,
  ) {
    final scheme = Theme.of(context).colorScheme;
    final isCurrent = currentBeat == index;
    final isBroken = beat.kind == MelodyBeatKind.unknown;

    final Color background;
    final Color foreground;
    if (isCurrent) {
      background = scheme.primary;
      foreground = scheme.onPrimary;
    } else if (isBroken) {
      background = scheme.errorContainer;
      foreground = scheme.onErrorContainer;
    } else {
      background = scheme.surfaceContainerHighest;
      foreground = scheme.onSurface;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 1),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      constraints: const BoxConstraints(minWidth: 34),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: scheme.outlineVariant, width: 0.5),
      ),
      child: Semantics(
        label: _spokenLabel(beat, AppLocalizations.of(context)),
        child: Text(
          _label(beat),
          textAlign: TextAlign.center,
          style: style.copyWith(color: foreground),
        ),
      ),
    );
  }

  /// What the box shows: the token as the writer typed it.
  ///
  /// Showing their spelling rather than a re-spelling means `Ma2` stays `Ma2`
  /// and the grid always matches the text they are editing.
  String _label(MelodyBeat beat) => switch (beat.kind) {
    MelodyBeatKind.hold => ',',
    MelodyBeatKind.barLine => '|',
    _ => beat.text,
  };

  /// What a screen reader says for this box.
  String _spokenLabel(MelodyBeat beat, AppLocalizations l10n) =>
      switch (beat.kind) {
        MelodyBeatKind.hold => l10n.labelMelodyGridHold,
        MelodyBeatKind.barLine => l10n.labelMelodyGridBarLine,
        MelodyBeatKind.unknown => l10n.descMelodyGridUnreadable(beat.text),
        MelodyBeatKind.notes => beat.text,
      };
}
