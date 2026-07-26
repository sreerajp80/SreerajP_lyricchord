import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lyricchord/providers/auto_scroll_provider.dart';

void main() {
  late ProviderContainer container;

  setUp(() => container = ProviderContainer());
  tearDown(() => container.dispose());

  AutoScrollSettings read() => container.read(autoScrollProvider);
  AutoScrollNotifier notifier() => container.read(autoScrollProvider.notifier);

  test('starts in manual mode, paused, at the defaults', () {
    final s = read();
    expect(s.mode, AutoScrollMode.manual);
    expect(s.speed, 1.0);
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

  test('only accepts one of the offered speeds', () {
    notifier().setSpeed(2.0);
    expect(read().speed, 2.0);
    notifier().setSpeed(1.7);
    expect(read().speed, 2.0);
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
}
