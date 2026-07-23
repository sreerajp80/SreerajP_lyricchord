import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lyriccord/providers/performance_provider.dart';

void main() {
  late ProviderContainer container;
  late PerformanceSettingsNotifier notifier;

  setUp(() {
    container = ProviderContainer();
    notifier = container.read(performanceSettingsProvider.notifier);
  });

  tearDown(() => container.dispose());

  double fontSize() => container.read(performanceSettingsProvider).fontSize;

  group('applyFontScale (pinch zoom)', () {
    test('scales from the start size, not the current size', () {
      notifier.applyFontScale(18, 1.5);
      expect(fontSize(), 27);

      // Same base, bigger factor — no compounding from the 27 above.
      notifier.applyFontScale(18, 1.6);
      expect(fontSize(), closeTo(28.8, 0.001));
    });

    test('clamps at the maximum size', () {
      notifier.applyFontScale(18, 10);
      expect(fontSize(), PerformanceSettings.maxFontSize);
    });

    test('clamps at the minimum size', () {
      notifier.applyFontScale(18, 0.1);
      expect(fontSize(), PerformanceSettings.minFontSize);
    });
  });

  test('resetAll returns to the defaults', () {
    notifier.transposeUp();
    notifier.toggleChords();
    notifier.applyFontScale(18, 1.5);

    notifier.resetAll();

    expect(
      container.read(performanceSettingsProvider),
      const PerformanceSettings(),
    );
  });
}
