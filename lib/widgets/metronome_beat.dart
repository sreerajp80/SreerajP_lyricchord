import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lyricchord/l10n/app_localizations.dart';

import 'package:lyricchord/providers/metronome_provider.dart';
import 'package:lyricchord/providers/metronome_runtime_provider.dart';
import 'package:lyricchord/services/metronome_audio_service.dart';
import 'package:lyricchord/services/metronome_calculator.dart';
import 'package:lyricchord/widgets/metronome_tempo_sheet.dart';

/// The round metronome button in the performance controls header.
///
/// Shown only when the metronome is enabled in settings (the parent decides
/// that). Tapping it starts or stops the beat, independent of auto-scroll. A long
/// press opens the tempo sheet.
///
/// On each beat it plays a synthesized click through
/// [MetronomeAudioService] — beat 1 of the bar gets a higher, louder accent so
/// you can hear where the bar starts — and flashes the button while showing the
/// counted beat number (1 2 3 4).
///
/// **Timing.** Each beat is scheduled by its own timer, aimed at
/// `start + beatIndex * 60/bpm`. The target always comes from the start time, so
/// errors never pile up, and the click does not have to wait for the next screen
/// frame the way it did before (which made it up to ~16 ms late, and worse while
/// the chord sheet was busy drawing).
class MetronomeBeat extends ConsumerStatefulWidget {
  const MetronomeBeat({
    super.key,
    required this.bpm,
    required this.active,
    this.nowOverride,
  });

  /// The song's saved tempo. 0 means the song has none — the metronome then
  /// falls back to the last used tempo instead of refusing to start.
  final int bpm;

  /// True when this is the song on screen. A swiped-away page stops its beat so
  /// no click keeps playing off-screen.
  final bool active;

  /// Test seam: where "how long has it been running" comes from.
  ///
  /// Normally a [Stopwatch] reading real time. A widget test's clock is a fake
  /// one — its timers fire on fake time while a real stopwatch stays frozen — so
  /// a test passes its own reading here to keep the two in step.
  @visibleForTesting
  final Duration Function()? nowOverride;

  @override
  ConsumerState<MetronomeBeat> createState() => _MetronomeBeatState();
}

class _MetronomeBeatState extends ConsumerState<MetronomeBeat>
    with WidgetsBindingObserver {
  static const MetronomeCalculator _calc = MetronomeCalculator();

  /// Runs from the moment the widget appears, so [_now] always has a reading.
  final Stopwatch _monotonic = Stopwatch();

  /// The reading of [_now] when the beat was started. Elapsed time is measured
  /// against this, so the beat cannot drift even if a timer fires slightly late.
  Duration _startedAt = Duration.zero;

  /// Fires the next beat.
  Timer? _beatTimer;

  /// Turns the flash back off part-way through the beat.
  Timer? _flashTimer;

  /// True while the beat is running.
  bool _running = false;

  /// Which beat we are on, counting from 0 at the start.
  int _beatIndex = 0;

  /// Whether the button is currently lit.
  bool _flashOn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _monotonic.start();
  }

  /// The current time reading, from the test seam if one was given.
  Duration _now() => widget.nowOverride?.call() ?? _monotonic.elapsed;

  /// How long the beat has been running.
  Duration get _elapsed => _now() - _startedAt;

  @override
  void didUpdateWidget(MetronomeBeat oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Stop when the page is swiped away.
    if (!widget.active && _running) _stop();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Stop rather than leave a timer clicking while the app is in the
    // background — the old Ticker version paused instead, then jumped.
    if (state != AppLifecycleState.resumed && _running) _stop();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _beatTimer?.cancel();
    _flashTimer?.cancel();
    _monotonic.stop();
    super.dispose();
  }

  /// The tempo actually being played: the user's, else the song's, else the last
  /// one used.
  int get _bpm => ref.read(metronomeRuntimeProvider).effectiveBpm(widget.bpm);

  void _toggle() {
    if (_running) {
      _stop();
    } else {
      _start();
    }
  }

  void _start() {
    // Loading the click now means the very first beat is not late.
    ref.read(metronomeAudioProvider).prepare();

    _beatIndex = 0;
    _startedAt = _now();
    setState(() => _running = true);
    _fireBeat();
  }

  void _stop() {
    _beatTimer?.cancel();
    _beatTimer = null;
    _flashTimer?.cancel();
    _flashTimer = null;
    setState(() {
      _running = false;
      _flashOn = false;
      _beatIndex = 0;
    });
  }

  /// Sounds and shows the beat we are on, then schedules the next one.
  void _fireBeat() {
    if (!mounted || !_running) return;
    if (!widget.active) {
      _stop();
      return;
    }

    final settings = ref.read(metronomeSettingsProvider);
    final bpm = _bpm;
    if (bpm <= 0) {
      _stop();
      return;
    }

    if (settings.click) {
      final audio = ref.read(metronomeAudioProvider);
      final isAccent =
          settings.accent &&
          _calc.beatInBar(_beatIndex, settings.beatsPerBar) == 0;
      if (isAccent) {
        audio.playAccent();
      } else {
        audio.playNormal();
      }
    }

    if (settings.flash) {
      setState(() => _flashOn = true);
      _flashTimer?.cancel();
      _flashTimer = Timer(_calc.flashDuration(bpm), () {
        if (mounted) setState(() => _flashOn = false);
      });
    }

    _scheduleNextBeat(bpm);
  }

  /// Arms the timer for the beat after this one.
  ///
  /// The wait is measured from the stopwatch to the next beat's exact place in
  /// the song, so a timer that fires 3 ms late makes the *next* wait 3 ms
  /// shorter instead of pushing every later beat back.
  void _scheduleNextBeat(int bpm) {
    final nextIndex = _beatIndex + 1;
    final wait = _calc.timeUntilBeat(nextIndex, bpm, _elapsed);

    _beatTimer?.cancel();
    _beatTimer = Timer(wait, () {
      if (!mounted || !_running) return;
      // setState is not needed here: _fireBeat rebuilds for the flash, and the
      // beat number is drawn in the same pass.
      _beatIndex = nextIndex;
      _fireBeat();
    });
  }

  Future<void> _openTempoSheet() async {
    await MetronomeTempoSheet.show(context, songBpm: widget.bpm);
    // The tempo may have changed while the sheet was open. The next beat is
    // already armed at the old speed, so re-aim it from where we are now.
    if (!mounted || !_running) return;
    _scheduleNextBeat(_bpm);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final settings = ref.watch(metronomeSettingsProvider);
    // Watched, not read, so the button's label follows a tempo change made in
    // the sheet.
    final runtime = ref.watch(metronomeRuntimeProvider);
    final bpm = runtime.effectiveBpm(widget.bpm);
    final enabled = bpm > 0;

    final Color background;
    final Color foreground;
    if (!enabled) {
      background = scheme.surfaceContainerHighest;
      foreground = scheme.onSurfaceVariant.withValues(alpha: 0.4);
    } else if (_flashOn) {
      background = scheme.primary;
      foreground = scheme.onPrimary;
    } else {
      background = scheme.surfaceContainerHighest;
      foreground = scheme.primary;
    }

    final Widget face;
    if (_running) {
      // While running the button counts the bar, so the position is readable
      // even at a glance and even with the sound off.
      final count = _calc.displayBeat(_beatIndex, settings.beatsPerBar);
      face = Text(
        '$count',
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
          color: foreground,
          height: 1,
        ),
      );
    } else {
      face = Icon(Icons.av_timer, size: 22, color: foreground);
    }

    return Tooltip(
      message: _running
          ? AppLocalizations.of(context).tooltipMetronomeStop
          : AppLocalizations.of(context).tooltipMetronomeStart,
      child: SizedBox(
        width: 40,
        height: 40,
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: _toggle,
            onLongPress: _openTempoSheet,
            child: AnimatedScale(
              scale: _flashOn ? 1.15 : 1.0,
              duration: _flashOn
                  ? Duration.zero
                  : const Duration(milliseconds: 90),
              child: AnimatedContainer(
                duration: _flashOn
                    ? Duration.zero
                    : const Duration(milliseconds: 90),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: background,
                  shape: BoxShape.circle,
                ),
                child: face,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
