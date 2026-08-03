import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lyricchord/models/song_note.dart';
import 'package:lyricchord/providers/auto_scroll_provider.dart';
import 'package:lyricchord/providers/database_provider.dart';

import '../helpers/fake_song_repository.dart';

void main() {
  late ProviderContainer container;

  setUp(() => container = ProviderContainer());
  tearDown(() => container.dispose());

  AutoScrollSettings read() => container.read(autoScrollProvider);
  AutoScrollNotifier notifier() => container.read(autoScrollProvider.notifier);

  test('starts in manual mode, paused, at the defaults', () {
    final s = read();
    expect(s.mode, AutoScrollMode.manual);
    expect(s.speed, AutoScrollSettings.defaultSpeed);
    expect(s.measures, AutoScrollSettings.defaultMeasures);
    expect(s.isPlaying, isFalse);
  });

  test('play and pause flip the playing flag', () {
    notifier().play();
    expect(read().isPlaying, isTrue);
    notifier().pause();
    expect(read().isPlaying, isFalse);
    notifier().togglePlay();
    expect(read().isPlaying, isTrue);
  });

  test('changing mode pauses so nothing keeps moving at the old speed', () {
    notifier().play();
    notifier().setMode(AutoScrollMode.tempo);
    expect(read().mode, AutoScrollMode.tempo);
    expect(read().isPlaying, isFalse);
  });

  test('setSpeed snaps to the step grid and clamps to the range', () {
    notifier().setSpeed(1.5);
    expect(read().speed, 1.5);

    // 1.17 is not on the 0.05 grid — it lands on the nearest step.
    notifier().setSpeed(1.17);
    expect(read().speed, 1.15);

    notifier().setSpeed(9);
    expect(read().speed, AutoScrollSettings.maxSpeed);

    notifier().setSpeed(0);
    expect(read().speed, AutoScrollSettings.minSpeed);

    notifier().setSpeed(double.nan);
    expect(read().speed, AutoScrollSettings.minSpeed);
  });

  test('speed steps up and down and stops at both ends', () {
    notifier().increaseSpeed();
    expect(read().speed, closeTo(1.05, 1e-9));
    notifier().decreaseSpeed();
    expect(read().speed, closeTo(1.0, 1e-9));

    for (var i = 0; i < 200; i++) {
      notifier().decreaseSpeed();
    }
    expect(read().speed, AutoScrollSettings.minSpeed);

    for (var i = 0; i < 200; i++) {
      notifier().increaseSpeed();
    }
    expect(read().speed, AutoScrollSettings.maxSpeed);
  });

  test('stepping many times never drifts off the grid', () {
    // Plain double addition would make 0.1 + 0.05 + 0.05 != 0.2. Every value
    // must stay an exact multiple of the step.
    for (var i = 0; i < 30; i++) {
      notifier().increaseSpeed();
      final hundredths = read().speed * 100;
      expect(hundredths, closeTo(hundredths.roundToDouble(), 1e-9));
      expect(hundredths.round() % 5, 0);
    }
  });

  test('measures step and clamp to the allowed range', () {
    notifier().increaseMeasures();
    expect(read().measures, AutoScrollSettings.defaultMeasures + 4);

    for (var i = 0; i < 200; i++) {
      notifier().decreaseMeasures();
    }
    expect(read().measures, AutoScrollSettings.minMeasures);

    for (var i = 0; i < 200; i++) {
      notifier().increaseMeasures();
    }
    expect(read().measures, AutoScrollSettings.maxMeasures);
  });

  test('reportContentExtent ignores junk and stores a real length', () {
    notifier().reportContentExtent(1234);
    expect(read().contentExtent, 1234);
    notifier().reportContentExtent(-5);
    expect(read().contentExtent, 0);
    notifier().reportContentExtent(double.infinity);
    expect(read().contentExtent, 0);
  });

  test('resetAll returns everything to the defaults', () {
    notifier()
      ..setMode(AutoScrollMode.tempo)
      ..setSpeed(0.5)
      ..increaseMeasures()
      ..play()
      ..reportContentExtent(999);

    notifier().resetAll();

    expect(read(), const AutoScrollSettings());
  });

  group('saving per song', () {
    late FakeSongRepository repository;
    late ProviderContainer songContainer;

    /// Long enough for the debounce timer to fire.
    const afterDebounce = Duration(milliseconds: 900);

    setUp(() {
      repository = FakeSongRepository([
        const SongNote(
          id: 7,
          title: 'Test Song',
          timestamp: 7,
          scrollSpeed: 0.75,
          scrollMeasures: 48,
        ),
      ]);
      songContainer = ProviderContainer(
        overrides: [songRepositoryProvider.overrideWithValue(repository)],
      );
    });

    tearDown(() async {
      songContainer.dispose();
      await repository.dispose();
    });

    AutoScrollSettings readSong() => songContainer.read(autoScrollProvider);
    AutoScrollNotifier songNotifier() =>
        songContainer.read(autoScrollProvider.notifier);

    test('loadForSong applies the values saved for that song', () {
      songNotifier().loadForSong(7, speed: 0.75, measures: 48);

      final s = readSong();
      expect(s.songId, 7);
      expect(s.speed, 0.75);
      expect(s.measures, 48);
      expect(s.isPlaying, isFalse);
      expect(s.mode, AutoScrollMode.manual);
    });

    test('loading the same song again keeps what the user just set', () {
      songNotifier().loadForSong(7, speed: 0.75, measures: 48);
      songNotifier().setSpeed(1.25);

      // The song stream emits again (our own write came back) — the live value
      // must survive.
      songNotifier().loadForSong(7, speed: 0.75, measures: 48);

      expect(readSong().speed, 1.25);
    });

    test('a burst of speed changes writes once, after the debounce', () async {
      songNotifier().loadForSong(7, speed: 0.75, measures: 48);
      songNotifier()
        ..increaseSpeed()
        ..increaseSpeed()
        ..increaseSpeed();

      expect(repository.savedScrollCalls, 0, reason: 'not written yet');

      await Future<void>.delayed(afterDebounce);

      expect(repository.savedScrollCalls, 1);
      final saved = await repository.findById(7);
      expect(saved!.scrollSpeed, closeTo(0.90, 1e-9));
      expect(saved.timestamp, 7, reason: 'saving speed must not re-stamp');
    });

    test('measures are saved too', () async {
      songNotifier().loadForSong(7, speed: 0.75, measures: 48);
      songNotifier().increaseMeasures();

      await Future<void>.delayed(afterDebounce);

      final saved = await repository.findById(7);
      expect(saved!.scrollMeasures, 52);
    });

    test('flushSave writes at once, without waiting', () async {
      songNotifier().loadForSong(7, speed: 0.75, measures: 48);
      songNotifier().setSpeed(1.40);

      await songNotifier().flushSave();

      expect(repository.savedScrollCalls, 1);
      expect((await repository.findById(7))!.scrollSpeed, closeTo(1.40, 1e-9));
    });

    test('flushSave with nothing pending writes nothing', () async {
      songNotifier().loadForSong(7, speed: 0.75, measures: 48);

      await songNotifier().flushSave();

      expect(repository.savedScrollCalls, 0);
    });

    test('nothing is saved when no song is loaded', () async {
      songNotifier().setSpeed(1.40);

      await Future<void>.delayed(afterDebounce);

      expect(repository.savedScrollCalls, 0);
    });
  });
}
