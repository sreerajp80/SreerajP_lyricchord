import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lyricchord/providers/auto_scroll_provider.dart';
import 'package:lyricchord/providers/metronome_provider.dart';
import 'package:lyricchord/providers/performance_provider.dart';
import 'package:lyricchord/services/auto_scroll_calculator.dart';
import 'package:lyricchord/widgets/auto_scroll_controls.dart';
import 'package:lyricchord/widgets/metronome_beat.dart';

/// The compact, always-visible auto-scroll header shown above the chord sheet.
///
/// Only auto-scroll lives here now, so the lyrics keep most of the screen.
/// Transpose and show-chords are in the top-bar overflow menu (the "Performance
/// controls" bottom sheet), and font size is a pinch on the sheet itself.
///
/// It is one short block: the controls row ([AutoScrollControls]) and a single
/// muted status line — `Auto-scroll · Key … · … BPM`, with the computed length
/// appended in Tempo mode.
class PerformanceControls extends ConsumerWidget {
  const PerformanceControls({
    super.key,
    required this.currentKey,
    required this.bpm,
    required this.active,
    this.showFullScreenButton = true,
    this.raga,
    this.tala,
  });

  /// The key the sheet sounds in right now — already transposed.
  final String currentKey;

  /// The song's raga, when it names one in a `{raga: …}` directive.
  final String? raga;

  /// The song's tala, when it names one in a `{tala: …}` directive.
  final String? tala;

  /// The song's tempo, handed to the auto-scroll section for Tempo Auto.
  final int bpm;

  /// True when this is the song on screen. Passed to the metronome so a
  /// swiped-away page's beat stops.
  final bool active;

  /// Whether to offer the Stage Mode button — hidden in the tablet split view.
  final bool showFullScreenButton;

  static const AutoScrollCalculator _calc = AutoScrollCalculator();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final metronomeEnabled = ref.watch(
      metronomeSettingsProvider.select((s) => s.enabled),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: AutoScrollControls(
                  bpm: bpm,
                  showFullScreenButton: showFullScreenButton,
                ),
              ),
              if (metronomeEnabled) ...[
                const SizedBox(width: 12),
                MetronomeBeat(bpm: bpm, active: active),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _statusLine(ref),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (_ragaLine != null)
            Text(
              _ragaLine!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }

  /// `Raga Yamunakalyani · Tala Adi`, or `null` when the song names neither.
  String? get _ragaLine {
    final parts = [
      if (raga != null && raga!.isNotEmpty) 'Raga $raga',
      if (tala != null && tala!.isNotEmpty) 'Tala $tala',
    ];
    return parts.isEmpty ? null : parts.join('  ·  ');
  }

  /// `Auto-scroll · Key G · 120 BPM`, with `(+2)` after the key when transposed,
  /// and ` · 32 bars · 1:04` appended in Tempo mode.
  ///
  /// A song that names a raga shows **no key at all** — just
  /// `Auto-scroll · 120 BPM`, with the raga and tala on the line below. A
  /// Western note letter has no place on an Indian sheet, and a swara is
  /// already named relative to Sa, so there is nothing a key would add.
  String _statusLine(WidgetRef ref) {
    final semitones = ref.watch(
      performanceSettingsProvider.select((s) => s.semitones),
    );
    final settings = ref.watch(autoScrollProvider);

    final isIndian = raga != null && raga!.isNotEmpty;
    final keyHint =
        'Key $currentKey${semitones == 0 ? '' : ' (${_signed(semitones)})'}';
    final base = isIndian
        ? 'Auto-scroll  ·  $bpm BPM'
        : 'Auto-scroll  ·  $keyHint  ·  $bpm BPM';

    if (settings.mode != AutoScrollMode.tempo) return base;

    final duration = _calc.tempoDuration(
      bpm,
      settings.measures,
      beatsPerMeasure: settings.beatsPerMeasure,
    );
    if (duration == Duration.zero) return base;
    return '$base  ·  ${settings.measures} bars  ·  ${_formatDuration(duration)}';
  }

  /// `+2` / `-3`, for the "how far from the written key" hint.
  String _signed(int semitones) => semitones > 0 ? '+$semitones' : '$semitones';

  /// `m:ss` for the computed song length.
  String _formatDuration(Duration duration) {
    final totalSeconds = duration.inSeconds;
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
