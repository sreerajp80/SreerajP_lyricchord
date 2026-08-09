import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lyricchord/providers/stage_mode_provider.dart';

void main() {
  group('StageModeNotifier', () {
    test('initial state has stage mode, lock mode and quiet mode disabled', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(stageModeProvider);
      expect(state.enabled, isFalse);
      expect(state.hudVisible, isFalse);
      expect(state.isLocked, isFalse);
      expect(state.isQuietMode, isFalse);
    });

    test('entering stage mode enables full screen and HUD', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(stageModeProvider.notifier);
      notifier.enter();

      final state = container.read(stageModeProvider);
      expect(state.enabled, isTrue);
      expect(state.hudVisible, isTrue);
    });

    test('locking stage mode sets isLocked true and hides HUD', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(stageModeProvider.notifier);
      notifier.enter();
      notifier.lockStage();

      final state = container.read(stageModeProvider);
      expect(state.isLocked, isTrue);
      expect(state.hudVisible, isFalse);
    });

    test(
      'unlockStageWithAuth unlocks stage mode when security is not available',
      () async {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        final notifier = container.read(stageModeProvider.notifier);
        notifier.enter();
        notifier.lockStage();

        final unlocked = await notifier.unlockStageWithAuth();
        expect(unlocked, isTrue);

        final state = container.read(stageModeProvider);
        expect(state.isLocked, isFalse);
        expect(state.hudVisible, isTrue);
      },
    );

    test('toggling quiet mode updates state correctly', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(stageModeProvider.notifier);
      await notifier.toggleQuietMode();

      var state = container.read(stageModeProvider);
      expect(state.isQuietMode, isTrue);

      await notifier.toggleQuietMode();
      state = container.read(stageModeProvider);
      expect(state.isQuietMode, isFalse);
    });
  });
}
