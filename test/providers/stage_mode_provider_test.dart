import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lyricchord/core/constants/app_constants.dart';
import 'package:lyricchord/providers/stage_mode_provider.dart';
import 'package:lyricchord/providers/theme_mode_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('StageModeNotifier', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    StageModeState read() => container.read(stageModeProvider);
    StageModeNotifier notifier() => container.read(stageModeProvider.notifier);

    test('starts off, with no HUD', () {
      expect(read().enabled, isFalse);
      expect(read().hudVisible, isFalse);
    });

    test('entering shows the HUD, so the way out is on screen', () {
      notifier().enter();
      expect(read().enabled, isTrue);
      expect(read().hudVisible, isTrue);
    });

    test('leaving clears everything', () {
      notifier().enter();
      notifier().exit();
      expect(read(), const StageModeState());
    });

    test('toggle goes in and back out', () {
      notifier().toggle();
      expect(read().enabled, isTrue);
      notifier().toggle();
      expect(read().enabled, isFalse);
    });

    test('a tap shows the HUD and a second tap hides it', () {
      notifier().enter();
      notifier().hideHud();
      expect(read().hudVisible, isFalse);

      notifier().toggleHud();
      expect(read().hudVisible, isTrue);
      notifier().toggleHud();
      expect(read().hudVisible, isFalse);
    });

    test('the HUD cannot be shown while Stage Mode is off', () {
      notifier().showHud();
      expect(read().hudVisible, isFalse);
    });
  });

  group('StageHelpSeenNotifier', () {
    Future<ProviderContainer> containerWith({bool seen = false}) async {
      SharedPreferences.setMockInitialValues({
        if (seen) AppConstants.prefStageHelpSeen: true,
      });
      final prefs = await SharedPreferences.getInstance();
      return ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
    }

    test('is false the first time and true once marked', () async {
      final container = await containerWith();
      addTearDown(container.dispose);

      expect(container.read(stageHelpSeenProvider), isFalse);

      await container.read(stageHelpSeenProvider.notifier).markSeen();
      expect(container.read(stageHelpSeenProvider), isTrue);
    });

    test('stays true across a restart', () async {
      final container = await containerWith(seen: true);
      addTearDown(container.dispose);

      expect(container.read(stageHelpSeenProvider), isTrue);
    });
  });
}
