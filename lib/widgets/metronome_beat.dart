import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lyriccord/providers/metronome_provider.dart';
import 'package:lyriccord/services/metronome_calculator.dart';

/// The round metronome button in the performance controls header.
///
/// Shown only when the metronome is enabled in settings (the parent decides
/// that). Tapping it starts or stops a beat at the song's [bpm], independent of
/// auto-scroll. On each beat it plays the built-in click (if Click is on) and
/// flashes the button (if Flash is on). It owns its own [Ticker], so the beat is
/// worked out from real elapsed time and does not drift.
class MetronomeBeat extends ConsumerStatefulWidget {
  const MetronomeBeat({super.key, required this.bpm, required this.active});

  /// The song's tempo. A value of 0 or less disables the button.
  final int bpm;

  /// True when this is the song on screen. A swiped-away page stops its beat so
  /// no click keeps playing off-screen.
  final bool active;

  @override
  ConsumerState<MetronomeBeat> createState() => _MetronomeBeatState();
}

class _MetronomeBeatState extends ConsumerState<MetronomeBeat>
    with SingleTickerProviderStateMixin {
  static const MetronomeCalculator _calc = MetronomeCalculator();

  /// How much of each beat the flash stays lit (0.0–1.0). A short pulse.
  static const double _flashPortion = 0.18;

  late final Ticker _ticker;

  /// True while the beat is running.
  bool _running = false;

  /// The last beat number we fired a click for, so each beat clicks once.
  /// Starts at -1 so the very first beat (0) fires the moment we start.
  int _lastBeatIndex = -1;

  /// Whether the button is currently lit for the flash.
  bool _flashOn = false;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
  }

  @override
  void didUpdateWidget(MetronomeBeat oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Stop if the page is no longer on screen, or the tempo became unusable.
    if ((!widget.active || widget.bpm <= 0) && _running) {
      _stop();
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _toggle() {
    if (_running) {
      _stop();
    } else {
      _start();
    }
  }

  void _start() {
    if (widget.bpm <= 0) return;
    _lastBeatIndex = -1;
    _ticker.start();
    setState(() => _running = true);
  }

  void _stop() {
    if (_ticker.isActive) _ticker.stop();
    setState(() {
      _running = false;
      _flashOn = false;
    });
  }

  void _onTick(Duration elapsed) {
    if (!widget.active) {
      _stop();
      return;
    }
    final perBeat = _calc.secondsPerBeat(widget.bpm);
    if (perBeat <= 0) return;

    final settings = ref.read(metronomeSettingsProvider);

    final beat = _calc.beatIndexAt(elapsed, widget.bpm);
    if (beat != _lastBeatIndex) {
      _lastBeatIndex = beat;
      if (settings.click) SystemSound.play(SystemSoundType.click);
    }

    // The flash is derived from where we are inside the current beat, so it
    // stays in step with the click without a second timer.
    final seconds = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
    final phase = (seconds % perBeat) / perBeat;
    final wantFlash = settings.flash && phase < _flashPortion;
    if (wantFlash != _flashOn) {
      setState(() => _flashOn = wantFlash);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final enabled = widget.bpm > 0;

    final Color background;
    final Color foreground;
    if (!enabled) {
      background = scheme.surfaceContainerHighest;
      foreground = scheme.onSurfaceVariant.withValues(alpha: 0.4);
    } else if (_flashOn) {
      background = scheme.primary;
      foreground = scheme.onPrimary;
    } else if (_running) {
      background = scheme.primaryContainer;
      foreground = scheme.onPrimaryContainer;
    } else {
      background = scheme.surfaceContainerHighest;
      foreground = scheme.primary;
    }

    return Tooltip(
      message: !enabled
          ? 'No tempo set'
          : _running
          ? 'Stop metronome'
          : 'Start metronome',
      child: SizedBox(
        width: 40,
        height: 40,
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: enabled ? _toggle : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 90),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: background,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _running ? Icons.stop : Icons.av_timer,
                size: 22,
                color: foreground,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
