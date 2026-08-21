import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lyricchord/models/melody_line.dart';
import 'package:lyricchord/services/melody_audio_service.dart';
import 'package:lyricchord/services/melody_player_service.dart';

/// What the melody player is doing right now.
///
/// Held as one immutable value so the grid, the buttons and the cursor all read
/// the same state and can never disagree about what is playing.
class MelodyPlayback {
  /// The line being played, or `null` when nothing is.
  final MelodyLine? line;

  /// The line laid out in time. Empty when nothing is playing.
  final MelodySchedule schedule;

  /// True while sound is coming out.
  final bool playing;

  /// True when the line repeats until it is stopped.
  final bool loop;

  /// `1.0` for full speed, `0.5` for half. Only these two are offered — a
  /// slider would invite fiddling with a number that has one useful setting.
  final double speed;

  /// How far into the line playback has reached, for moving the cursor.
  final Duration position;

  const MelodyPlayback({
    this.line,
    this.schedule = MelodySchedule.empty,
    this.playing = false,
    this.loop = false,
    this.speed = MelodyPlayerService.normalSpeed,
    this.position = Duration.zero,
  });

  /// Nothing loaded, nothing playing.
  static const MelodyPlayback idle = MelodyPlayback();

  /// Which beat of `line.beats` is sounding, or `null` when none is.
  int? get currentBeat => playing ? schedule.beatAt(position) : null;

  /// True when the player is set to half speed.
  bool get isHalfSpeed => speed == MelodyPlayerService.halfSpeed;

  MelodyPlayback copyWith({
    MelodyLine? line,
    MelodySchedule? schedule,
    bool? playing,
    bool? loop,
    double? speed,
    Duration? position,
  }) => MelodyPlayback(
    line: line ?? this.line,
    schedule: schedule ?? this.schedule,
    playing: playing ?? this.playing,
    loop: loop ?? this.loop,
    speed: speed ?? this.speed,
    position: position ?? this.position,
  );
}

/// Plays one melody line and keeps the cursor moving along it.
///
/// The sound is rendered as a single file up front (see `MelodyAudioService`),
/// so this timer only moves the cursor — it never decides when a note starts.
/// That is why the cursor can drift a frame or two without the tune drifting
/// at all.
class MelodyPlayerNotifier extends Notifier<MelodyPlayback> {
  static const MelodyPlayerService _player = MelodyPlayerService();

  /// How often the cursor moves. Fast enough to look smooth on a beat grid,
  /// slow enough not to rebuild the screen for nothing.
  static const Duration _tick = Duration(milliseconds: 40);

  Timer? _timer;

  @override
  MelodyPlayback build() {
    ref.onDispose(_cancelTimer);
    return MelodyPlayback.idle;
  }

  /// Starts [line] at [tempoBpm], with Sa at [tonicHz].
  ///
  /// Returns false when there is nothing to play or the sound failed to start,
  /// so the screen can say so instead of showing a cursor over silence.
  Future<bool> play(
    MelodyLine line, {
    required double tonicHz,
    required double tempoBpm,
  }) async {
    final schedule = _player.schedule(
      line,
      tonicHz: tonicHz,
      tempoBpm: tempoBpm,
      speed: state.speed,
    );
    if (schedule.isEmpty) {
      state = state.copyWith(line: line, playing: false);
      return false;
    }

    _cancelTimer();
    state = state.copyWith(
      line: line,
      schedule: schedule,
      playing: true,
      position: Duration.zero,
    );

    final started = await ref
        .read(melodyAudioProvider)
        .play(schedule, loop: state.loop);
    if (!started) {
      state = state.copyWith(playing: false, position: Duration.zero);
      return false;
    }

    _startTimer();
    return true;
  }

  /// Stops playback and parks the cursor at the start.
  Future<void> stop() async {
    _cancelTimer();
    state = state.copyWith(playing: false, position: Duration.zero);
    await ref.read(melodyAudioProvider).stop();
  }

  /// Turns looping on or off.
  ///
  /// Takes effect on the next [play] — changing the release mode of a sound
  /// that is already running is what makes a player stall mid-note.
  void setLoop({required bool loop}) {
    state = state.copyWith(loop: loop);
  }

  /// Switches between full and half speed.
  ///
  /// Stops anything playing, because the rendered file holds the old speed and
  /// carrying on would leave the cursor and the sound disagreeing.
  Future<void> setHalfSpeed({required bool half}) async {
    final speed = half
        ? MelodyPlayerService.halfSpeed
        : MelodyPlayerService.normalSpeed;
    if (speed == state.speed) return;

    if (state.playing) await stop();
    state = state.copyWith(speed: speed);
  }

  void _startTimer() {
    _timer = Timer.periodic(_tick, (_) {
      if (!state.playing) return;

      final next = state.position + _tick;
      if (next < state.schedule.total) {
        state = state.copyWith(position: next);
        return;
      }

      // Reached the end. Looping keeps the sound going, so only the cursor
      // wraps; otherwise everything stops.
      if (state.loop) {
        state = state.copyWith(position: Duration.zero);
      } else {
        _cancelTimer();
        state = state.copyWith(playing: false, position: Duration.zero);
      }
    });
  }

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }
}

/// The melody player.
final melodyPlayerProvider =
    NotifierProvider<MelodyPlayerNotifier, MelodyPlayback>(
      MelodyPlayerNotifier.new,
    );
