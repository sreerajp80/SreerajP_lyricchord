import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lyricchord/providers/auto_scroll_provider.dart';
import 'package:lyricchord/providers/stage_mode_provider.dart';
import 'package:lyricchord/services/auto_scroll_calculator.dart';

/// The compact auto-scroll controls row shown under the app bar.
///
/// One row: a round Manual / Tempo (M / T) toggle, a round play button, and the
/// chosen mode's control on the right — Manual shows the `− 1.00x +` speed
/// stepper, Tempo shows the `− count +` measures stepper. It only reads and sets
/// [autoScrollProvider]; the actual scrolling is driven by the performance
/// screen, which listens to the same provider. The one-line status text
/// (`Auto-scroll · Key … · … BPM`) lives in the parent header, not here.
class AutoScrollControls extends ConsumerWidget {
  const AutoScrollControls({
    super.key,
    required this.bpm,
    this.showFullScreenButton = true,
  });

  /// The song's tempo, used to disable Tempo play until it has a length.
  final int bpm;

  /// Whether to offer the Stage Mode (full screen) button. Hidden in the
  /// tablet's split view, where full screen would only fill the pane.
  final bool showFullScreenButton;

  static const AutoScrollCalculator _calc = AutoScrollCalculator();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(autoScrollProvider);
    final controls = ref.read(autoScrollProvider.notifier);

    final isTempo = settings.mode == AutoScrollMode.tempo;
    // Tempo cannot play until we have a real length (positive bpm + measures).
    final tempoReady =
        _calc.tempoDuration(
          bpm,
          settings.measures,
          beatsPerMeasure: settings.beatsPerMeasure,
        ) !=
        Duration.zero;
    final canPlay = !isTempo || tempoReady;

    // A Wrap, not a Row, so the row cannot overflow. On a normal phone both
    // groups sit on one line with the stepper pushed right, exactly as before.
    // On a narrow phone with the metronome also showing there is not enough
    // width for both, and the stepper drops to a second line instead of
    // spilling off the edge. Wrapping is better than shrinking here: these are
    // already 40 dp targets, and a musician taps them mid-song.
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      runSpacing: 4,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ModeToggle(mode: settings.mode, onChanged: controls.setMode),
            const SizedBox(width: 12),
            _PlayButton(
              isPlaying: settings.isPlaying,
              onPressed: canPlay ? controls.togglePlay : null,
            ),
            if (showFullScreenButton) ...[
              const SizedBox(width: 8),
              // Same 40 dp circle as the M / T buttons, so the four controls
              // read as one set. Tonal rather than filled: going full screen is
              // a normal action, not the main one — play keeps that.
              SizedBox(
                width: _CircleToggle.size,
                height: _CircleToggle.size,
                child: IconButton.filledTonal(
                  tooltip: 'Full screen',
                  onPressed: ref.read(stageModeProvider.notifier).enter,
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.fullscreen),
                ),
              ),
            ],
          ],
        ),
        // The mode's own control, right-aligned like the mockup.
        if (isTempo)
          _MeasuresStepper(measures: settings.measures, controls: controls)
        else
          _SpeedStepper(speed: settings.speed, controls: controls),
      ],
    );
  }
}

/// The round Manual / Tempo toggle: two circular buttons (M and T). The selected
/// mode is filled with the primary colour; the other is an outlined circle.
class _ModeToggle extends StatelessWidget {
  const _ModeToggle({required this.mode, required this.onChanged});

  final AutoScrollMode mode;
  final ValueChanged<AutoScrollMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _CircleToggle(
          label: 'M',
          tooltip: 'Manual',
          selected: mode == AutoScrollMode.manual,
          onPressed: () => onChanged(AutoScrollMode.manual),
        ),
        const SizedBox(width: 6),
        _CircleToggle(
          label: 'T',
          tooltip: 'Tempo',
          selected: mode == AutoScrollMode.tempo,
          onPressed: () => onChanged(AutoScrollMode.tempo),
        ),
      ],
    );
  }
}

/// A single round mode button. Filled when [selected], outlined otherwise, and
/// always a comfortable tap target.
class _CircleToggle extends StatelessWidget {
  const _CircleToggle({
    required this.label,
    required this.tooltip,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final String tooltip;
  final bool selected;
  final VoidCallback onPressed;

  /// Diameter of the button — kept an easy tap target even though the label is
  /// a single letter. Shared with the full screen button so the whole row of
  /// round controls is one size.
  static const double size = 40;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final child = Text(
      label,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        color: selected ? scheme.onPrimary : scheme.onSurfaceVariant,
      ),
    );

    return Tooltip(
      message: tooltip,
      child: SizedBox(
        width: size,
        height: size,
        child: selected
            ? IconButton.filled(
                onPressed: onPressed,
                style: IconButton.styleFrom(
                  backgroundColor: scheme.primary,
                  foregroundColor: scheme.onPrimary,
                ),
                icon: child,
              )
            : IconButton.outlined(onPressed: onPressed, icon: child),
      ),
    );
  }
}

/// The round filled play / pause button, matching the mockup's primary circle.
class _PlayButton extends StatelessWidget {
  const _PlayButton({required this.isPlaying, required this.onPressed});

  final bool isPlaying;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton.filled(
      tooltip: isPlaying ? 'Pause' : 'Play',
      onPressed: onPressed,
      icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
    );
  }
}

/// The Manual-mode speed as it is shown to the user: always two decimals plus
/// an `x`, so `0.10x`, `1.00x`, `2.00x`.
///
/// Fixed width on purpose — in a stepper the number changes every tap, and a
/// varying width would make the row jump about. Shared with Stage Mode, which
/// flashes the same label when a gesture changes the speed.
String formatSpeedLabel(double speed) => '${speed.toStringAsFixed(2)}x';

/// Manual mode: the `− 1.00x +` speed stepper.
///
/// Built to match [_MeasuresStepper] so the two modes feel like one control
/// that swaps its middle value. The buttons switch off at the ends of the
/// allowed range instead of silently doing nothing.
class _SpeedStepper extends StatelessWidget {
  const _SpeedStepper({required this.speed, required this.controls});

  final double speed;
  final AutoScrollNotifier controls;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canSlow = speed > AutoScrollSettings.minSpeed;
    final canSpeedUp = speed < AutoScrollSettings.maxSpeed;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton.filledTonal(
          tooltip: 'Slower',
          onPressed: canSlow ? controls.decreaseSpeed : null,
          visualDensity: VisualDensity.compact,
          icon: const Icon(Icons.remove),
        ),
        SizedBox(
          // Wider than the measures box: `1.00x` is five characters.
          width: 56,
          child: Text(
            formatSpeedLabel(speed),
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium,
          ),
        ),
        IconButton.filledTonal(
          tooltip: 'Faster',
          onPressed: canSpeedUp ? controls.increaseSpeed : null,
          visualDensity: VisualDensity.compact,
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}

/// Tempo mode: the compact `− count +` measures stepper. The computed length is
/// shown by the parent header's status line, so it is not repeated here.
class _MeasuresStepper extends StatelessWidget {
  const _MeasuresStepper({required this.measures, required this.controls});

  final int measures;
  final AutoScrollNotifier controls;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton.filledTonal(
          tooltip: 'Fewer measures',
          onPressed: controls.decreaseMeasures,
          visualDensity: VisualDensity.compact,
          icon: const Icon(Icons.remove),
        ),
        SizedBox(
          width: 32,
          child: Text(
            '$measures',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium,
          ),
        ),
        IconButton.filledTonal(
          tooltip: 'More measures',
          onPressed: controls.increaseMeasures,
          visualDensity: VisualDensity.compact,
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}
