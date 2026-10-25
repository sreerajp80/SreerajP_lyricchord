import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lyricchord/l10n/app_localizations.dart';

import 'package:lyricchord/providers/auto_scroll_provider.dart';
import 'package:lyricchord/providers/metronome_provider.dart';
import 'package:lyricchord/providers/performance_provider.dart';
import 'package:lyricchord/services/auto_scroll_calculator.dart';
import 'package:lyricchord/widgets/auto_scroll_controls.dart';
import 'package:lyricchord/widgets/metronome_beat.dart';
import 'package:lyricchord/widgets/pitch_drone_controls.dart';

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
    this.hasMelody = false,
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

  /// True when the song has at least one `{melody}` line. Only then is the
  /// melody toggle worth drawing — on any other song it would do nothing
  /// visible.
  final bool hasMelody;

  /// Whether to offer the Stage Mode button — hidden in the tablet split view.
  final bool showFullScreenButton;

  static const AutoScrollCalculator _calc = AutoScrollCalculator();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final ragaLine = _ragaLine(l10n);
    final metronomeEnabled = ref.watch(
      metronomeSettingsProvider.select((s) => s.enabled),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Full width on purpose: the Column would otherwise hand the Wrap
          // only as much space as its children need, and `spaceBetween` would
          // have nothing to share out — the two groups would sit touching in
          // the middle instead of at the two edges.
          SizedBox(
            width: double.infinity,
            // A Wrap, not a Row: on a narrow phone with the metronome showing
            // there is not enough width for both groups, and the right-hand
            // group drops to a second line instead of spilling off the edge.
            // Wrapping beats shrinking here — these are 40 dp targets a
            // musician taps mid-song.
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 4,
              children: [
                AutoScrollControls(showFullScreenButton: showFullScreenButton),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const _SpeedReadout(),
                    const _ChordsToggle(),
                    if (hasMelody) const _MelodyToggle(),
                    // Stage Mode has this button too, but Stage Mode is a place
                    // many people never go. A singer needs their starting note
                    // before the song begins, so it belongs on the ordinary
                    // screen as well.
                    IconButton(
                      tooltip: l10n.tooltipPerfDrone,
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.graphic_eq),
                      onPressed: () => showModalBottomSheet<void>(
                        context: context,
                        isScrollControlled: true,
                        builder: (_) => PitchDroneControlsSheet(
                          songKey: currentKey,
                          raga: raga,
                          tala: tala,
                        ),
                      ),
                    ),
                    if (metronomeEnabled) ...[
                      const SizedBox(width: 4),
                      MetronomeBeat(bpm: bpm, active: active),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _statusLine(ref, l10n),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (ragaLine != null)
            Text(
              ragaLine,
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
  String? _ragaLine(AppLocalizations l10n) {
    final parts = [
      if (raga != null && raga!.isNotEmpty) l10n.labelInfoRaga(raga!),
      if (tala != null && tala!.isNotEmpty) l10n.labelInfoTala(tala!),
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
  String _statusLine(WidgetRef ref, AppLocalizations l10n) {
    final semitones = ref.watch(
      performanceSettingsProvider.select((s) => s.semitones),
    );
    final settings = ref.watch(autoScrollProvider);

    final isIndian = raga != null && raga!.isNotEmpty;
    final keyHint = semitones == 0
        ? l10n.labelInfoKey(currentKey)
        : l10n.labelInfoKeyTransposed(currentKey, _signed(semitones));
    final base = [
      l10n.labelInfoAutoScroll,
      if (!isIndian) keyHint,
      l10n.labelInfoBpm(bpm),
    ].join('  ·  ');

    if (settings.mode != AutoScrollMode.tempo) return base;

    final duration = _calc.tempoDuration(
      bpm,
      settings.measures,
      beatsPerMeasure: settings.beatsPerMeasure,
    );
    if (duration == Duration.zero) return base;
    return [
      base,
      l10n.labelInfoBars(settings.measures),
      _formatDuration(duration),
    ].join('  ·  ');
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

/// The Manual-mode speed, shown but not editable.
///
/// The value is changed by double-tapping the sheet, so this is a read-out
/// only. Tempo mode draws nothing here: the status line under the row already
/// carries `… · 32 bars · 1:04`, which is what sets the speed there.
class _SpeedReadout extends ConsumerWidget {
  const _SpeedReadout();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(autoScrollProvider);
    if (settings.mode != AutoScrollMode.manual) return const SizedBox.shrink();

    final theme = Theme.of(context);
    return Tooltip(
      message: AppLocalizations.of(context).tooltipPerfSpeed,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(
          formatSpeedLabel(
            settings.speed,
            AppLocalizations.of(context).localeName,
          ),
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ),
    );
  }
}

/// Hides or shows the chord line above the lyrics.
class _ChordsToggle extends ConsumerWidget {
  const _ChordsToggle();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showing = ref.watch(
      performanceSettingsProvider.select((s) => s.showChords),
    );

    return IconButton(
      tooltip: showing
          ? AppLocalizations.of(context).tooltipPerfHideChords
          : AppLocalizations.of(context).tooltipPerfShowChords,
      visualDensity: VisualDensity.compact,
      isSelected: showing,
      icon: Icon(showing ? Icons.music_note : Icons.music_off),
      onPressed: ref.read(performanceSettingsProvider.notifier).toggleChords,
    );
  }
}

/// Hides or shows the `{melody}` rows. Only drawn for a song that has them.
class _MelodyToggle extends ConsumerWidget {
  const _MelodyToggle();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showing = ref.watch(
      performanceSettingsProvider.select((s) => s.showMelody),
    );

    return IconButton(
      tooltip: showing
          ? AppLocalizations.of(context).tooltipPerfHideMelody
          : AppLocalizations.of(context).tooltipPerfShowMelody,
      visualDensity: VisualDensity.compact,
      isSelected: showing,
      icon: Icon(showing ? Icons.piano : Icons.piano_off),
      onPressed: ref.read(performanceSettingsProvider.notifier).toggleMelody,
    );
  }
}
