import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lyricchord/providers/metronome_runtime_provider.dart';
import 'package:lyricchord/services/metronome_calculator.dart';

/// The bottom sheet for setting the metronome's tempo by hand.
///
/// Opened by a long press on the metronome button. Offers three ways to set the
/// speed — the -/+ buttons, the slider, and tapping along to the music — plus a
/// way back to the song's own saved tempo. The beat keeps playing while this is
/// open, so a change can be heard straight away.
class MetronomeTempoSheet extends ConsumerStatefulWidget {
  const MetronomeTempoSheet({
    super.key,
    required this.songBpm,
    this.nowOverride,
  });

  /// The tempo saved with the song, or 0 when it has none.
  final int songBpm;

  /// Test seam: where the time of each tap comes from.
  ///
  /// Normally a [Stopwatch] reading real time. A widget test moves a fake clock
  /// instead, which a real stopwatch would not follow, so a test passes its own
  /// reading here.
  @visibleForTesting
  final Duration Function()? nowOverride;

  /// Opens the sheet over the current screen.
  static Future<void> show(BuildContext context, {required int songBpm}) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => MetronomeTempoSheet(songBpm: songBpm),
    );
  }

  @override
  ConsumerState<MetronomeTempoSheet> createState() =>
      _MetronomeTempoSheetState();
}

class _MetronomeTempoSheetState extends ConsumerState<MetronomeTempoSheet> {
  /// How many taps to average for tap tempo. Four is one bar of 4/4 — enough to
  /// steady an uneven hand without making the user wait.
  static const int _tapsToAverage = 4;

  /// Taps older than this are treated as the start of a new attempt, so a tap
  /// left over from a minute ago cannot drag the average down.
  static const Duration _tapTimeout = Duration(seconds: 3);

  /// When each recent tap happened, oldest first.
  final List<Duration> _taps = [];

  /// Counts time for the taps. A stopwatch is used instead of `DateTime.now()`
  /// so a clock change mid-tap cannot produce a silly tempo.
  final Stopwatch _tapClock = Stopwatch();

  /// The time of this tap, from the test seam if one was given.
  Duration _now() {
    final override = widget.nowOverride;
    if (override != null) return override();
    if (!_tapClock.isRunning) _tapClock.start();
    return _tapClock.elapsed;
  }

  void _onTap() {
    final now = _now();

    if (_taps.isNotEmpty && now - _taps.last > _tapTimeout) {
      _taps.clear();
    }
    _taps.add(now);
    while (_taps.length > _tapsToAverage) {
      _taps.removeAt(0);
    }

    ref.read(metronomeRuntimeProvider.notifier).setFromTaps(_taps);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final runtime = ref.watch(metronomeRuntimeProvider);
    final notifier = ref.read(metronomeRuntimeProvider.notifier);
    final bpm = runtime.effectiveBpm(widget.songBpm);

    final tapsNeeded = _tapsToAverage - _taps.length;
    final String tapHint;
    if (_taps.isEmpty) {
      tapHint = 'Tap along with the music';
    } else if (_taps.length < 2) {
      tapHint = 'Keep tapping…';
    } else {
      tapHint = tapsNeeded > 0
          ? 'Good — $tapsNeeded more tap${tapsNeeded == 1 ? '' : 's'} to steady it'
          : 'Steady';
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Metronome tempo', style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              runtime.isOverridden
                  ? 'Set by you for this session'
                  : widget.songBpm > 0
                  ? "Using this song's saved tempo"
                  : 'This song has no saved tempo',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton.filledTonal(
                  onPressed: bpm > MetronomeCalculator.minBpm
                      ? () => notifier.nudge(-1, songBpm: widget.songBpm)
                      : null,
                  icon: const Icon(Icons.remove),
                  tooltip: 'Slower by 1',
                ),
                Column(
                  children: [
                    Text('$bpm', style: theme.textTheme.displaySmall),
                    Text('BPM', style: theme.textTheme.labelSmall),
                  ],
                ),
                IconButton.filledTonal(
                  onPressed: bpm < MetronomeCalculator.maxBpm
                      ? () => notifier.nudge(1, songBpm: widget.songBpm)
                      : null,
                  icon: const Icon(Icons.add),
                  tooltip: 'Faster by 1',
                ),
              ],
            ),
            Slider(
              value: bpm.toDouble(),
              min: MetronomeCalculator.minBpm.toDouble(),
              max: MetronomeCalculator.maxBpm.toDouble(),
              divisions:
                  MetronomeCalculator.maxBpm - MetronomeCalculator.minBpm,
              label: '$bpm BPM',
              onChanged: (value) => notifier.setOverride(value.round()),
            ),
            const SizedBox(height: 8),
            FilledButton.tonalIcon(
              onPressed: _onTap,
              icon: const Icon(Icons.touch_app_outlined),
              label: const Text('Tap tempo'),
            ),
            const SizedBox(height: 4),
            Text(
              tapHint,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: widget.songBpm > 0 && runtime.isOverridden
                  ? () {
                      notifier.useSongTempo();
                      setState(_taps.clear);
                    }
                  : null,
              icon: const Icon(Icons.restore),
              label: Text(
                widget.songBpm > 0
                    ? 'Use song tempo (${widget.songBpm} BPM)'
                    : 'No song tempo to go back to',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
