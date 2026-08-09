import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lyricchord/providers/auto_scroll_provider.dart';
import 'package:lyricchord/providers/stage_mode_provider.dart';
import 'package:lyricchord/services/auto_scroll_calculator.dart';
import 'package:lyricchord/widgets/auto_scroll_controls.dart';
import 'package:lyricchord/widgets/pitch_drone_controls.dart';

/// The translucent control bar of Stage Mode.
///
/// It sits at the bottom of the full-screen lyrics, slides in on a single tap
/// and slides away again after [StageModeState.hudTimeout]. Every Stage Mode
/// gesture has a button here as well — the gestures are shortcuts for people who
/// learn them, never the only way to do something.
///
/// The exit button leaves Stage Mode only; it does not leave the song. In Stage
/// Mode the app bar (and its back arrow) is hidden, so this is the visible way
/// back.
class StageHud extends ConsumerWidget {
  const StageHud({
    super.key,
    required this.visible,
    required this.title,
    required this.currentKey,
    required this.bpm,
    this.raga,
    this.tala,
  });

  /// True while the bar should be on screen.
  final bool visible;

  /// The song on show, for the read-out on the right.
  final String title;

  /// The key the sheet sounds in right now — already transposed. Not shown for
  /// a song that names a raga; see [_readOut].
  final String currentKey;

  /// The song's tempo.
  final int bpm;

  /// The song's raga, when it names one in a `{raga: …}` directive.
  final String? raga;

  /// The song's tala, when it names one in a `{tala: …}` directive.
  final String? tala;

  static const AutoScrollCalculator _calc = AutoScrollCalculator();

  /// Height the bar takes, including its outer padding. The gesture layer uses
  /// this to keep its double-taps off the buttons while the bar is showing.
  static const double height = 84;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settings = ref.watch(autoScrollProvider);
    final controls = ref.read(autoScrollProvider.notifier);
    final stage = ref.read(stageModeProvider.notifier);

    final isTempo = settings.mode == AutoScrollMode.tempo;
    final tempoReady =
        _calc.tempoDuration(
          bpm,
          settings.measures,
          beatsPerMeasure: settings.beatsPerMeasure,
        ) !=
        Duration.zero;
    final canPlay = !isTempo || tempoReady;

    return IgnorePointer(
      // When hidden the bar must not swallow taps meant for the lyrics.
      ignoring: !visible,
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: const Duration(milliseconds: 180),
        child: AnimatedSlide(
          offset: visible ? Offset.zero : const Offset(0, 0.4),
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Material(
                color: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.92,
                ),
                elevation: 6,
                borderRadius: BorderRadius.circular(28),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            IconButton(
                              tooltip: 'Exit full screen',
                              onPressed: stage.exit,
                              icon: const Icon(Icons.fullscreen_exit),
                            ),
                            IconButton(
                              tooltip: 'Lock Stage View',
                              onPressed: stage.lockStage,
                              icon: const Icon(Icons.lock_outline),
                            ),
                            IconButton(
                              tooltip: ref.watch(stageModeProvider).isQuietMode
                                  ? 'Stage Quiet Mode (Active)'
                                  : 'Stage Quiet Mode (Mute ringer/alerts)',
                              onPressed: stage.toggleQuietMode,
                              icon: Icon(
                                ref.watch(stageModeProvider).isQuietMode
                                    ? Icons.notifications_off
                                    : Icons.notifications_active_outlined,
                                color: ref.watch(stageModeProvider).isQuietMode
                                    ? theme.colorScheme.error
                                    : null,
                              ),
                            ),
                            _ModeButton(
                              label: 'M',
                              selected: !isTempo,
                              onPressed: () =>
                                  controls.setMode(AutoScrollMode.manual),
                            ),
                            _ModeButton(
                              label: 'T',
                              selected: isTempo,
                              onPressed: () =>
                                  controls.setMode(AutoScrollMode.tempo),
                            ),
                            IconButton.filled(
                              tooltip: settings.isPlaying ? 'Pause' : 'Play',
                              onPressed: canPlay ? controls.togglePlay : null,
                              icon: Icon(
                                settings.isPlaying
                                    ? Icons.pause
                                    : Icons.play_arrow,
                              ),
                            ),
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              onPressed: () {
                                showModalBottomSheet<void>(
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (_) => PitchDroneControlsSheet(
                                    songKey: currentKey,
                                  ),
                                );
                              },
                              icon: const Icon(Icons.graphic_eq),
                            ),
                            const SizedBox(width: 8),
                            _StepperRow(
                              label: isTempo
                                  ? '${settings.measures}'
                                  : formatSpeedLabel(settings.speed),
                              onLess: isTempo
                                  ? controls.decreaseMeasures
                                  : controls.decreaseSpeed,
                              onMore: isTempo
                                  ? controls.increaseMeasures
                                  : controls.increaseSpeed,
                              lessTooltip: isTempo ? 'Fewer bars' : 'Slower',
                              moreTooltip: isTempo ? 'More bars' : 'Faster',
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
                        child: Text(
                          _readOut,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// The one-line read-out under the buttons.
  ///
  /// `Jingle Bells · Key G · 120 BPM` for a Western song. A song that names a
  /// raga shows its raga and tala instead of a key — a Western note letter has
  /// no place on an Indian sheet, and a swara is already named relative to Sa.
  String get _readOut {
    final parts = <String>[title];

    if (raga != null && raga!.isNotEmpty) {
      parts.add('Raga ${raga!}');
      if (tala != null && tala!.isNotEmpty) parts.add('Tala ${tala!}');
    } else {
      parts.add('Key $currentKey');
    }

    parts.add('$bpm BPM');
    return parts.join('  ·  ');
  }
}

/// A small `M` / `T` mode button, filled when it is the mode in use.
class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Text(
      label,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        color: selected ? scheme.onPrimary : scheme.onSurfaceVariant,
      ),
    );

    return IconButton(
      tooltip: label == 'M' ? 'Manual' : 'Tempo',
      onPressed: onPressed,
      visualDensity: VisualDensity.compact,
      style: selected
          ? IconButton.styleFrom(backgroundColor: scheme.primary)
          : null,
      icon: text,
    );
  }
}

/// The `− value +` pair used for both speed and bars, so the bar keeps the same
/// shape when the mode changes.
class _StepperRow extends StatelessWidget {
  const _StepperRow({
    required this.label,
    required this.onLess,
    required this.onMore,
    required this.lessTooltip,
    required this.moreTooltip,
  });

  final String label;
  final VoidCallback onLess;
  final VoidCallback onMore;
  final String lessTooltip;
  final String moreTooltip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton.filledTonal(
          tooltip: lessTooltip,
          onPressed: onLess,
          visualDensity: VisualDensity.compact,
          icon: const Icon(Icons.remove),
        ),
        SizedBox(
          width: 56,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium,
          ),
        ),
        IconButton.filledTonal(
          tooltip: moreTooltip,
          onPressed: onMore,
          visualDensity: VisualDensity.compact,
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}
