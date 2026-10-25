import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth/local_auth.dart';
import 'package:lyricchord/providers/stage_mode_provider.dart';
import 'package:lyricchord/services/stage_quiet_mode_service.dart';
import 'package:lyricchord/services/stage_security_service.dart';

/// Answers every unlock with a fixed [StageAuthResult].
class _FakeSecurity extends StageSecurityService {
  _FakeSecurity(this.result);

  final StageAuthResult result;

  @override
  Future<StageAuthResult> authenticate({
    String reason = 'Authenticate to unlock Stage View',
  }) async => result;
}

/// Records calls and answers enable with a fixed [QuietModeResult].
class _FakeQuiet extends StageQuietModeService {
  _FakeQuiet(this.enableResult);

  final QuietModeResult enableResult;
  int enableCalls = 0;
  int disableCalls = 0;
  bool _active = false;

  @override
  bool get isQuietActive => _active;

  @override
  bool get isSupported => true;

  @override
  Future<QuietModeResult> enableQuietMode() async {
    enableCalls++;
    _active = enableResult == QuietModeResult.on;
    return enableResult;
  }

  @override
  Future<bool> disableQuietMode() async {
    disableCalls++;
    _active = false;
    return true;
  }
}

ProviderContainer _container({
  StageSecurityService? security,
  StageQuietModeService? quiet,
}) {
  final container = ProviderContainer(
    overrides: [
      if (security != null)
        stageSecurityServiceProvider.overrideWithValue(security),
      if (quiet != null) stageQuietModeServiceProvider.overrideWithValue(quiet),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  group('StageModeNotifier', () {
    test('initial state has stage mode, lock mode and quiet mode disabled', () {
      final container = _container();

      final state = container.read(stageModeProvider);
      expect(state.enabled, isFalse);
      expect(state.hudVisible, isFalse);
      expect(state.isLocked, isFalse);
      expect(state.isQuietMode, isFalse);
    });

    test('entering stage mode enables full screen and HUD', () {
      final container = _container();

      final notifier = container.read(stageModeProvider.notifier);
      notifier.enter();

      final state = container.read(stageModeProvider);
      expect(state.enabled, isTrue);
      expect(state.hudVisible, isTrue);
    });

    test('locking stage mode sets isLocked true and hides HUD', () {
      final container = _container();

      final notifier = container.read(stageModeProvider.notifier);
      notifier.enter();
      notifier.lockStage();

      final state = container.read(stageModeProvider);
      expect(state.isLocked, isTrue);
      expect(state.hudVisible, isFalse);
    });

    group('unlockStageWithAuth', () {
      Future<StageModeState> unlockWith(StageAuthResult result) async {
        final container = _container(security: _FakeSecurity(result));
        final notifier = container.read(stageModeProvider.notifier);
        notifier.enter();
        notifier.lockStage();
        final returned = await notifier.unlockStageWithAuth();
        expect(returned.outcome, result.outcome);
        return container.read(stageModeProvider);
      }

      test('success unlocks and shows the HUD', () async {
        final state = await unlockWith(
          const StageAuthResult(StageAuthOutcome.success),
        );
        expect(state.isLocked, isFalse);
        expect(state.hudVisible, isTrue);
      });

      test('no screen lock set up still unlocks', () async {
        final state = await unlockWith(
          const StageAuthResult(StageAuthOutcome.notAvailable),
        );
        expect(state.isLocked, isFalse);
      });

      test('a platform error never traps the user', () async {
        final state = await unlockWith(
          const StageAuthResult(StageAuthOutcome.error),
        );
        expect(state.isLocked, isFalse);
      });

      test('cancel keeps the stage locked', () async {
        final state = await unlockWith(
          const StageAuthResult(StageAuthOutcome.canceled),
        );
        expect(state.isLocked, isTrue);
      });

      test('a failed check keeps the stage locked', () async {
        final state = await unlockWith(
          const StageAuthResult(StageAuthOutcome.failure),
        );
        expect(state.isLocked, isTrue);
      });

      test('the real service unlocks when the plugin is missing', () async {
        // No platform plugin in a unit test: the check cannot run.
        final container = _container(
          security: StageSecurityService(localAuth: LocalAuthentication()),
        );
        final notifier = container.read(stageModeProvider.notifier);
        notifier.enter();
        notifier.lockStage();
        await notifier.unlockStageWithAuth();
        expect(container.read(stageModeProvider).isLocked, isFalse);
      });
    });

    group('toggleQuietMode', () {
      test('turns on only when the phone really went silent', () async {
        final quiet = _FakeQuiet(QuietModeResult.on);
        final container = _container(quiet: quiet);
        final notifier = container.read(stageModeProvider.notifier);
        notifier.enter();

        final result = await notifier.toggleQuietMode();
        expect(result, QuietModeResult.on);
        expect(container.read(stageModeProvider).isQuietMode, isTrue);

        final off = await notifier.toggleQuietMode();
        expect(off, isNull);
        expect(container.read(stageModeProvider).isQuietMode, isFalse);
        expect(quiet.disableCalls, 1);
      });

      for (final refused in [
        QuietModeResult.needsAccess,
        QuietModeResult.unsupported,
        QuietModeResult.failed,
      ]) {
        test('stays off when the phone answers ${refused.name}', () async {
          final container = _container(quiet: _FakeQuiet(refused));
          final notifier = container.read(stageModeProvider.notifier);
          notifier.enter();

          final result = await notifier.toggleQuietMode();
          expect(result, refused);
          expect(container.read(stageModeProvider).isQuietMode, isFalse);
        });
      }

      test('does nothing outside Stage Mode', () async {
        final quiet = _FakeQuiet(QuietModeResult.on);
        final container = _container(quiet: quiet);

        final result = await container
            .read(stageModeProvider.notifier)
            .toggleQuietMode();
        expect(result, isNull);
        expect(quiet.enableCalls, 0);
        expect(container.read(stageModeProvider).isQuietMode, isFalse);
      });

      test('leaving Stage Mode restores the ringer', () async {
        final quiet = _FakeQuiet(QuietModeResult.on);
        final container = _container(quiet: quiet);
        final notifier = container.read(stageModeProvider.notifier);
        notifier.enter();
        await notifier.toggleQuietMode();

        notifier.exit();
        expect(quiet.disableCalls, 1);
        expect(quiet.isQuietActive, isFalse);
        expect(container.read(stageModeProvider).isQuietMode, isFalse);
      });

      test('entering Stage Mode again starts with Quiet Mode off', () async {
        final container = _container(quiet: _FakeQuiet(QuietModeResult.on));
        final notifier = container.read(stageModeProvider.notifier);
        notifier.enter();
        await notifier.toggleQuietMode();
        notifier.exit();
        notifier.enter();
        expect(container.read(stageModeProvider).isQuietMode, isFalse);
      });
    });
  });
}
