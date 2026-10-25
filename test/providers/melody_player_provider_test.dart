import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lyricchord/providers/melody_player_provider.dart';
import 'package:lyricchord/services/melody_audio_service.dart';
import 'package:lyricchord/services/melody_parser_service.dart';
import 'package:lyricchord/services/melody_player_service.dart';

/// Records what the player asked for, and starts or fails on demand.
class _FakeMelodyAudio implements MelodyAudio {
  _FakeMelodyAudio({this.starts = true});

  final bool starts;
  final List<bool> playedWithLoop = [];
  int stops = 0;

  @override
  Future<bool> play(MelodySchedule schedule, {bool loop = false}) async {
    playedWithLoop.add(loop);
    return starts;
  }

  @override
  Future<void> stop() async => stops++;

  @override
  Future<void> setVolume(double volume) async {}

  @override
  Future<void> dispose() async {}
}

void main() {
  const parser = MelodyParser();
  // Four beats at 600 BPM: the whole line lasts 0.4 s.
  final line = parser.parse('{melody} Sa Ri2 Ga3 Ma1');
  const fastTempo = 600.0;

  late _FakeMelodyAudio audio;
  late ProviderContainer container;

  ProviderContainer build({bool starts = true}) {
    audio = _FakeMelodyAudio(starts: starts);
    container = ProviderContainer(
      overrides: [melodyAudioProvider.overrideWithValue(audio)],
    );
    addTearDown(container.dispose);
    return container;
  }

  MelodyPlayback read() => container.read(melodyPlayerProvider);
  MelodyPlayerNotifier notifier() =>
      container.read(melodyPlayerProvider.notifier);

  test('starts idle at full speed', () {
    build();

    expect(read().playing, isFalse);
    expect(read().currentBeat, isNull);
    expect(read().isHalfSpeed, isFalse);
  });

  test('play lays the line out and starts the sound', () async {
    build();

    final ok = await notifier().play(line, tonicHz: 220, tempoBpm: fastTempo);

    expect(ok, isTrue);
    expect(read().playing, isTrue);
    expect(read().schedule.isEmpty, isFalse);
    expect(read().currentBeat, 0);
    expect(audio.playedWithLoop, [false]);
  });

  test('the cursor moves and playback ends by itself', () async {
    build();
    await notifier().play(line, tonicHz: 220, tempoBpm: fastTempo);

    await Future<void>.delayed(const Duration(milliseconds: 150));
    expect(read().position, greaterThan(Duration.zero));

    await Future<void>.delayed(const Duration(milliseconds: 500));
    expect(read().playing, isFalse);
    expect(read().position, Duration.zero);
  });

  test('looping keeps playing past the end', () async {
    build();
    notifier().setLoop(loop: true);
    await notifier().play(line, tonicHz: 220, tempoBpm: fastTempo);

    await Future<void>.delayed(const Duration(milliseconds: 600));
    expect(read().playing, isTrue);
    expect(audio.playedWithLoop, [true]);

    await notifier().stop();
    expect(read().playing, isFalse);
    expect(audio.stops, 1);
  });

  test('a sound that will not start reports false and stays stopped', () async {
    build(starts: false);

    final ok = await notifier().play(line, tonicHz: 220, tempoBpm: fastTempo);

    expect(ok, isFalse);
    expect(read().playing, isFalse);
  });

  test('an empty line has nothing to play', () async {
    build();

    final ok = await notifier().play(
      parser.parse('{melody}'),
      tonicHz: 220,
      tempoBpm: fastTempo,
    );

    expect(ok, isFalse);
    expect(audio.playedWithLoop, isEmpty);
  });

  test('switching to half speed stops what is playing', () async {
    build();
    await notifier().play(line, tonicHz: 220, tempoBpm: 60);

    await notifier().setHalfSpeed(half: true);

    expect(read().isHalfSpeed, isTrue);
    expect(read().speed, MelodyPlayerService.halfSpeed);
    expect(read().playing, isFalse);
    expect(audio.stops, 1);

    // Asking for the speed it already has changes nothing.
    await notifier().setHalfSpeed(half: true);
    expect(audio.stops, 1);
  });
}
