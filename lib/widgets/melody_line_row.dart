import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lyricchord/models/melody_line.dart';
import 'package:lyricchord/providers/melody_player_provider.dart';
import 'package:lyricchord/widgets/melody_beat_grid.dart';

/// One melody line in the sheet: a play button, the beat grid, and the controls
/// for looping and half speed.
///
/// The buttons appear only while this line is the one loaded in the player, so
/// a sheet with eight melody lines does not turn into a wall of icons.
///
/// With no tonic the grid still draws but nothing can be played — there is no
/// real pitch to turn Sa into a frequency, and humming a guessed one would
/// teach the wrong thing.
class MelodyLineRow extends ConsumerWidget {
  const MelodyLineRow({
    super.key,
    required this.melody,
    this.tonicHz,
    this.tempoBpm,
    this.textStyle,
  });

  /// The parsed tune for the lyric line above this one.
  final MelodyLine melody;

  /// The frequency of the song's Sa, or `null` when the song names no tonic.
  final double? tonicHz;

  /// Beats per minute, or `null` when the song has none.
  final double? tempoBpm;

  /// Style for the swara text in the grid.
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final playback = ref.watch(melodyPlayerProvider);

    final isThisLine = playback.line == melody;
    final canPlay =
        (tonicHz ?? 0) > 0 && (tempoBpm ?? 0) > 0 && !melody.isEmpty;
    final isPlaying = isThisLine && playback.playing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _PlayButton(
              playing: isPlaying,
              enabled: canPlay,
              onPressed: () => _toggle(ref, playing: isPlaying),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: MelodyBeatGrid(
                line: melody,
                currentBeat: isThisLine ? playback.currentBeat : null,
                textStyle: textStyle,
              ),
            ),
          ],
        ),
        if (isThisLine && canPlay)
          Padding(
            padding: const EdgeInsets.only(left: 36, top: 2),
            child: Wrap(
              spacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _Toggle(
                  label: 'Loop',
                  selected: playback.loop,
                  onChanged: (value) => ref
                      .read(melodyPlayerProvider.notifier)
                      .setLoop(loop: value),
                ),
                _Toggle(
                  label: 'Half speed',
                  selected: playback.isHalfSpeed,
                  onChanged: (value) => ref
                      .read(melodyPlayerProvider.notifier)
                      .setHalfSpeed(half: value),
                ),
              ],
            ),
          ),
        if (melody.hasProblems)
          Padding(
            padding: const EdgeInsets.only(left: 36, top: 2),
            child: Text(
              melody.problems.first,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _toggle(WidgetRef ref, {required bool playing}) async {
    final notifier = ref.read(melodyPlayerProvider.notifier);
    if (playing) {
      await notifier.stop();
      return;
    }

    final tonic = tonicHz;
    final tempo = tempoBpm;
    if (tonic == null || tempo == null) return;

    final started = await notifier.play(
      melody,
      tonicHz: tonic,
      tempoBpm: tempo,
    );
    if (!started && ref.context.mounted) {
      // Say so rather than showing a cursor over silence — a player that looks
      // like it is working while nothing comes out is the bug this avoids.
      ScaffoldMessenger.maybeOf(ref.context)?.showSnackBar(
        const SnackBar(content: Text('Could not play this melody.')),
      );
    }
  }
}

/// The round play/stop button at the start of a melody line.
class _PlayButton extends StatelessWidget {
  const _PlayButton({
    required this.playing,
    required this.enabled,
    required this.onPressed,
  });

  final bool playing;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return IconButton(
      onPressed: enabled ? onPressed : null,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      iconSize: 20,
      color: scheme.primary,
      tooltip: enabled
          ? (playing ? 'Stop' : 'Hum this line')
          : 'Add a {tonic: ...} line to hear this',
      icon: Icon(playing ? Icons.stop_circle : Icons.play_circle),
    );
  }
}

/// A small on/off chip for loop and half speed.
class _Toggle extends StatelessWidget {
  const _Toggle({
    required this.label,
    required this.selected,
    required this.onChanged,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onChanged,
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
