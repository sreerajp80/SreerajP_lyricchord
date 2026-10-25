import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:lyricchord/providers/stage_mode_provider.dart';
import 'package:lyricchord/services/stage_quiet_mode_service.dart';
import 'package:lyricchord/services/stage_security_service.dart';
import 'package:lyricchord/widgets/stage_feedback.dart';

import '../helpers/localized_app.dart';

/// Answers every unlock with a fixed [StageAuthResult].
class _FakeSecurity extends StageSecurityService {
  _FakeSecurity(this.result);

  final StageAuthResult result;

  @override
  Future<StageAuthResult> authenticate({
    String reason = 'Authenticate to unlock Stage View',
  }) async => result;
}

/// Answers enable with a fixed [QuietModeResult] and counts settings opens.
class _FakeQuiet extends StageQuietModeService {
  _FakeQuiet(this.enableResult);

  final QuietModeResult enableResult;
  int settingsOpened = 0;

  @override
  bool get isSupported => true;

  @override
  Future<QuietModeResult> enableQuietMode() async => enableResult;

  @override
  Future<bool> disableQuietMode() async => true;

  @override
  Future<bool> openAccessSettings() async {
    settingsOpened++;
    return true;
  }
}

void main() {
  late ProviderContainer container;

  /// Pumps a button that runs [action], with Stage Mode already on.
  Future<void> pump(
    WidgetTester tester, {
    StageAuthOutcome auth = StageAuthOutcome.success,
    QuietModeResult quiet = QuietModeResult.on,
    required Future<void> Function(BuildContext, WidgetRef) action,
  }) async {
    container = ProviderContainer(
      overrides: [
        stageSecurityServiceProvider.overrideWithValue(
          _FakeSecurity(StageAuthResult(auth)),
        ),
        stageQuietModeServiceProvider.overrideWithValue(_FakeQuiet(quiet)),
      ],
    );
    addTearDown(container.dispose);
    container.read(stageModeProvider.notifier).enter();
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: localizedApp(
          Scaffold(
            body: Consumer(
              builder: (context, ref, _) => TextButton(
                onPressed: () => action(context, ref),
                child: const Text('go'),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> tapGo(WidgetTester tester) async {
    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();
  }

  group('unlockStageWithFeedback', () {
    testWidgets('a plain success unlocks with no message', (tester) async {
      await pump(tester, action: unlockStageWithFeedback);
      container.read(stageModeProvider.notifier).lockStage();

      await tapGo(tester);

      expect(container.read(stageModeProvider).isLocked, isFalse);
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('a failed check stays locked and says so', (tester) async {
      await pump(
        tester,
        auth: StageAuthOutcome.failure,
        action: unlockStageWithFeedback,
      );
      container.read(stageModeProvider.notifier).lockStage();

      await tapGo(tester);

      expect(container.read(stageModeProvider).isLocked, isTrue);
      expect(
        find.text('Stage is still locked. Unlock to continue.'),
        findsOneWidget,
      );
    });

    testWidgets('no screen lock unlocks anyway and says so', (tester) async {
      await pump(
        tester,
        auth: StageAuthOutcome.notAvailable,
        action: unlockStageWithFeedback,
      );
      container.read(stageModeProvider.notifier).lockStage();

      await tapGo(tester);

      expect(container.read(stageModeProvider).isLocked, isFalse);
      expect(
        find.text('Stage unlocked. Screen lock check was not available.'),
        findsOneWidget,
      );
    });
  });

  group('toggleQuietModeWithFeedback', () {
    testWidgets('on, then off, each with its message', (tester) async {
      await pump(tester, action: toggleQuietModeWithFeedback);

      await tapGo(tester);
      expect(container.read(stageModeProvider).isQuietMode, isTrue);
      expect(
        find.text('Quiet Mode on: calls and notifications are silenced.'),
        findsOneWidget,
      );

      await tapGo(tester);
      expect(container.read(stageModeProvider).isQuietMode, isFalse);
      expect(find.text('Quiet Mode off: ringer restored.'), findsOneWidget);
    });

    testWidgets('needing access offers to open settings', (tester) async {
      await pump(
        tester,
        quiet: QuietModeResult.needsAccess,
        action: toggleQuietModeWithFeedback,
      );

      await tapGo(tester);

      expect(container.read(stageModeProvider).isQuietMode, isFalse);
      expect(
        find.text(
          'To silence calls, allow Do Not Disturb access for LyricChord.',
        ),
        findsOneWidget,
      );
      await tester.tap(find.text('Open settings'));
      await tester.pump();
      final quiet = container.read(stageQuietModeServiceProvider) as _FakeQuiet;
      expect(quiet.settingsOpened, 1);
    });

    testWidgets('unsupported and failed each have a message', (tester) async {
      await pump(
        tester,
        quiet: QuietModeResult.unsupported,
        action: toggleQuietModeWithFeedback,
      );
      await tapGo(tester);
      expect(
        find.text('Quiet Mode is not available on this device.'),
        findsOneWidget,
      );
    });

    testWidgets('a refused change says the phone was not silenced', (
      tester,
    ) async {
      await pump(
        tester,
        quiet: QuietModeResult.failed,
        action: toggleQuietModeWithFeedback,
      );
      await tapGo(tester);
      expect(find.text('Could not silence the phone.'), findsOneWidget);
    });
  });
}
