import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lyriccord/providers/auto_scroll_provider.dart';
import 'package:lyriccord/services/auto_scroll_calculator.dart';

/// The compact auto-scroll controls row shown under the app bar.
///
/// One row: a round Manual / Tempo (M / T) toggle, a round play button, and the
/// chosen mode's control on the right — Manual shows the 0.5x / 1x / 2x speed
/// chips, Tempo shows the `− count +` measures stepper. It only reads and sets
/// [autoScrollProvider]; the actual scrolling is driven by the performance
/// screen, which listens to the same provider. The one-line status text
/// (`Auto-scroll · Key … · … BPM`) lives in the parent header, not here.
class AutoScrollControls extends ConsumerWidget {
  const AutoScrollControls({super.key, required this.bpm});

  /// The song's tempo, used to disable Tempo play until it has a length.
  final int bpm;

  static const AutoScrollCalculator _calc = AutoScrollCalculator();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(autoScrollProvider);
    final controls = ref.read(autoScrollProvider.notifier);

    final isTempo = settings.mode == AutoScrollMode.tempo;
    // Tempo cannot play until we have a real length (positive bpm + measures).
    final tempoReady =
        _calc.tempoDuration(bpm, settings.measures) != Duration.zero;
    final canPlay = !isTempo || tempoReady;

    return Row(
      children: [
        _ModeToggle(mode: settings.mode, onChanged: controls.setMode),
        const SizedBox(width: 12),
        _PlayButton(
          isPlaying: settings.isPlaying,
          onPressed: canPlay ? controls.togglePlay : null,
        ),
        const Spacer(),
        // The mode's own control, right-aligned like the mockup.
        if (isTempo)
          _MeasuresStepper(measures: settings.measures, controls: controls)
        else
          _SpeedChips(speed: settings.speed, controls: controls),
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
  /// a single letter.
  static const double _size = 40;

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
        width: _size,
        height: _size,
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

/// Manual mode: the 0.5x / 1x / 2x speed chips.
class _SpeedChips extends StatelessWidget {
  const _SpeedChips({required this.speed, required this.controls});

  final double speed;
  final AutoScrollNotifier controls;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        for (final choice in AutoScrollSettings.speedChoices)
          ChoiceChip(
            label: Text(_speedLabel(choice)),
            showCheckmark: false,
            selected: speed == choice,
            onSelected: (_) => controls.setSpeed(choice),
          ),
      ],
    );
  }

  /// `0.5x` / `1x` / `2x` — drops a trailing `.0`.
  String _speedLabel(double speed) {
    final text = speed == speed.roundToDouble() ? '${speed.round()}' : '$speed';
    return '${text}x';
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
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}
