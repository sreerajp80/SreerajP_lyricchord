import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lyricchord/core/constants/app_constants.dart';
import 'package:lyricchord/providers/theme_mode_provider.dart';
import 'package:lyricchord/services/metronome_calculator.dart';

/// The tempo the metronome is using right now.
///
/// Deliberately *not* saved with the other metronome settings. A tweak made for
/// one song is a live, in-the-moment change, so it must not follow the user into
/// the next song — [overrideBpm] is cleared by
/// [MetronomeRuntimeNotifier.useSongTempo]. Only [lastBpm] is remembered, and
/// only so a song with no saved tempo starts somewhere sensible instead of
/// leaving the button dead.
class MetronomeRuntime {
  /// The user's hand-set tempo, or `null` to follow the song.
  final int? overrideBpm;

  /// The tempo last used, remembered across restarts.
  final int lastBpm;

  const MetronomeRuntime({this.overrideBpm, this.lastBpm = defaultBpm});

  /// Used when neither the song nor the user has given a tempo.
  static const int defaultBpm = 100;

  /// The tempo to beat at for a song whose saved tempo is [songBpm].
  ///
  /// The user's hand-set tempo wins; then the song's own tempo; then the last
  /// tempo used. So the button always has something valid to play.
  int effectiveBpm(int songBpm) {
    final chosen = overrideBpm ?? (songBpm > 0 ? songBpm : lastBpm);
    return chosen.clamp(MetronomeCalculator.minBpm, MetronomeCalculator.maxBpm);
  }

  /// True when the tempo showing is the user's, not the song's.
  bool get isOverridden => overrideBpm != null;

  MetronomeRuntime copyWith({
    int? overrideBpm,
    int? lastBpm,
    bool clearOverride = false,
  }) {
    return MetronomeRuntime(
      overrideBpm: clearOverride ? null : (overrideBpm ?? this.overrideBpm),
      lastBpm: lastBpm ?? this.lastBpm,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is MetronomeRuntime &&
      other.overrideBpm == overrideBpm &&
      other.lastBpm == lastBpm;

  @override
  int get hashCode => Object.hash(overrideBpm, lastBpm);

  @override
  String toString() =>
      'MetronomeRuntime(overrideBpm: $overrideBpm, lastBpm: $lastBpm)';
}

/// Holds the live tempo override and the remembered last tempo.
class MetronomeRuntimeNotifier extends Notifier<MetronomeRuntime> {
  static const MetronomeCalculator _calc = MetronomeCalculator();

  @override
  MetronomeRuntime build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final saved = prefs.getInt(AppConstants.prefMetronomeLastBpm);
    return MetronomeRuntime(
      lastBpm: (saved != null && saved > 0)
          ? saved.clamp(MetronomeCalculator.minBpm, MetronomeCalculator.maxBpm)
          : MetronomeRuntime.defaultBpm,
    );
  }

  /// Hand-sets the tempo, clamped to the allowed range.
  Future<void> setOverride(int bpm) async {
    final clamped = bpm.clamp(
      MetronomeCalculator.minBpm,
      MetronomeCalculator.maxBpm,
    );
    state = state.copyWith(overrideBpm: clamped, lastBpm: clamped);
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setInt(AppConstants.prefMetronomeLastBpm, clamped);
  }

  /// Nudges the current tempo by [delta] beats per minute.
  ///
  /// Needs [songBpm] so the first nudge starts from whatever is actually
  /// playing, not from zero.
  Future<void> nudge(int delta, {required int songBpm}) =>
      setOverride(state.effectiveBpm(songBpm) + delta);

  /// Drops the hand-set tempo and goes back to the song's own tempo.
  void useSongTempo() {
    state = state.copyWith(clearOverride: true);
  }

  /// Sets the tempo from tap-tempo taps. Returns false, and changes nothing, if
  /// the taps give no usable tempo (fewer than two taps).
  Future<bool> setFromTaps(List<Duration> taps) async {
    final bpm = _calc.bpmFromTaps(taps);
    if (bpm == null) return false;
    await setOverride(bpm);
    return true;
  }
}

/// The metronome's live tempo. Session-only, except for the remembered last bpm.
final metronomeRuntimeProvider =
    NotifierProvider<MetronomeRuntimeNotifier, MetronomeRuntime>(
      MetronomeRuntimeNotifier.new,
    );
