import 'package:material_ui/material_ui.dart';
import 'package:lyricchord/l10n/app_localizations.dart';

import 'package:lyricchord/models/melody_beat.dart';
import 'package:lyricchord/models/melody_line.dart';

/// Draws a melody line as rows of beat boxes, split into tala groups.
///
/// One box per beat, in written order. A bar line becomes a gap between groups
/// rather than a box of its own, because it takes no time — a reader counting
/// the tala needs to see the groups, not a divider sitting in a beat's place.
///
/// A long line wraps onto more rows at its bar lines, so a whole group moves
/// down together. Only a group too wide for the screen on its own breaks, and
/// then between boxes, never inside one.
///
/// A beat holding more than one note (`G3-R2`) draws its notes side by side
/// inside the one box, so the eye can see that they share the beat.
///
/// While a line plays, the sounding box is kept on screen: when it would leave
/// the view, the scrollable around the sheet moves just enough to show it.
///
/// Knows nothing about audio or syntax. It is handed a parsed line and the beat
/// that is sounding, and only draws (architecture §4, layer boundaries).
class MelodyBeatGrid extends StatefulWidget {
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
  State<MelodyBeatGrid> createState() => _MelodyBeatGridState();
}

class _MelodyBeatGridState extends State<MelodyBeatGrid> {
  /// One key per beat, so the sounding box can be found and scrolled to.
  late List<GlobalKey> _beatKeys = _keysFor(widget.line);

  static List<GlobalKey> _keysFor(MelodyLine line) =>
      List.generate(line.beats.length, (_) => GlobalKey());

  @override
  void didUpdateWidget(MelodyBeatGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.line.beats.length != _beatKeys.length) {
      _beatKeys = _keysFor(widget.line);
    }

    final beat = widget.currentBeat;
    if (beat == null || beat == oldWidget.currentBeat) return;

    // Playing moves forward, so normally only the lower edge matters. A jump
    // back (a loop starting again) must reveal the box at the top instead.
    final previous = oldWidget.currentBeat;
    final policy = previous != null && beat < previous
        ? ScrollPositionAlignmentPolicy.keepVisibleAtStart
        : ScrollPositionAlignmentPolicy.keepVisibleAtEnd;
    WidgetsBinding.instance.addPostFrameCallback((_) => _reveal(beat, policy));
  }

  /// Scrolls the views around the grid so the box for [beat] is on screen.
  ///
  /// The policy only moves a view when the box is outside it, so a box that
  /// is already visible causes no movement — and the sheet's own auto-scroll,
  /// when it is running, is not pulled around on every beat.
  void _reveal(int beat, ScrollPositionAlignmentPolicy policy) {
    if (!mounted || beat >= _beatKeys.length) return;
    final boxContext = _beatKeys[beat].currentContext;
    if (boxContext == null) return;
    Scrollable.ensureVisible(
      boxContext,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      alignmentPolicy: policy,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.line.beats.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final style =
        (widget.textStyle ?? theme.textTheme.bodyMedium ?? const TextStyle())
            .copyWith(fontFamily: 'monospace', height: 1.1);

    // The gap between groups is the bar line; the run spacing keeps wrapped
    // rows from touching.
    return Wrap(spacing: 14, runSpacing: 4, children: _groups(context, style));
  }

  /// Splits the beats at every bar line and draws each group as a run of boxes.
  List<Widget> _groups(BuildContext context, TextStyle style) {
    final widgets = <Widget>[];
    var group = <Widget>[];

    void closeGroup() {
      if (group.isEmpty) return;
      // A group is its own Wrap so it moves to a new row as one piece, and
      // breaks between boxes only when it is wider than the row by itself.
      widgets.add(Wrap(runSpacing: 4, children: group));
      group = <Widget>[];
    }

    final beats = widget.line.beats;
    for (var i = 0; i < beats.length; i++) {
      final beat = beats[i];
      if (beat.kind == MelodyBeatKind.barLine) {
        closeGroup();
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
    final isCurrent = widget.currentBeat == index;
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
      key: _beatKeys[index],
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
