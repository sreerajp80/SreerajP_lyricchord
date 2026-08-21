import 'package:lyricchord/services/metronome_audio_service.dart';

/// A [MetronomeAudio] that records what it was asked to play instead of making
/// any sound.
///
/// Tests cannot hear audio, so they check that the widget *asked* for the right
/// click at the right time. Using this also keeps a real `AudioPlayer` (and its
/// platform channel) out of widget tests.
class FakeMetronomeAudio implements MetronomeAudio {
  /// One entry per click, in order: `'normal'` or `'accent'`.
  final List<String> played = [];

  /// How many times [prepare] was called.
  int prepareCount = 0;

  /// The last volume set, or null if never set.
  double? volume;

  bool disposed = false;

  /// Just the accent pattern, handy for reading a bar at a glance.
  List<bool> get accents => played.map((p) => p == 'accent').toList();

  void clear() {
    played.clear();
    prepareCount = 0;
  }

  @override
  Future<void> prepare() async => prepareCount++;

  @override
  void playNormal() => played.add('normal');

  @override
  void playAccent() => played.add('accent');

  @override
  Future<void> setVolume(double volume) async => this.volume = volume;

  @override
  Future<void> dispose() async => disposed = true;
}
