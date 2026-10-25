import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lyricchord/l10n/app_localizations.dart';
import 'package:lyricchord/l10n/app_localizations_delegates.dart';
import 'package:lyricchord/providers/auto_scroll_provider.dart';
import 'package:lyricchord/providers/stage_mode_provider.dart';
import 'package:lyricchord/widgets/scroll_gesture_layer.dart';

void main() {
  // The layer fills the whole 800x600 test window, so these are the two halves.
  const upper = Offset(400, 150);
  const lower = Offset(400, 450);

  late ProviderContainer container;

  Future<void> pumpLayer(
    WidgetTester tester, {
    bool singleTapTogglesHud = true,
  }) async {
    container = ProviderContainer();
    addTearDown(container.dispose);
    // Stage Mode is on for most of these, so the HUD has something to toggle.
    container.read(stageModeProvider.notifier).enter();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: ScrollGestureLayer(
              singleTapTogglesHud: singleTapTogglesHud,
              child: const ColoredBox(color: Colors.black),
            ),
          ),
        ),
      ),
    );
  }

  /// Two quick taps at the same spot, inside the double-tap window.
  Future<void> doubleTapAt(WidgetTester tester, Offset spot) async {
    await tester.tapAt(spot);
    await tester.pump(const Duration(milliseconds: 60));
    await tester.tapAt(spot);
    await tester.pump();
  }

  /// Waits past the double-tap window so a lone tap is settled as a single tap.
  Future<void> settleTap(WidgetTester tester) =>
      tester.pump(const Duration(milliseconds: 400));

  AutoScrollSettings scroll() => container.read(autoScrollProvider);

  testWidgets('a single tap toggles the control bar', (tester) async {
    await pumpLayer(tester);
    // Entering shows the HUD; hide it so the tap has something to do.
    container.read(stageModeProvider.notifier).hideHud();

    await tester.tapAt(upper);
    await settleTap(tester);
    expect(container.read(stageModeProvider).hudVisible, isTrue);

    await tester.tapAt(upper);
    await settleTap(tester);
    expect(container.read(stageModeProvider).hudVisible, isFalse);
  });

  testWidgets('double-tap up is faster, double-tap down is slower', (
    tester,
  ) async {
    await pumpLayer(tester);
    final start = scroll().speed;

    await doubleTapAt(tester, upper);
    expect(scroll().speed, closeTo(start + AutoScrollSettings.speedStep, 1e-9));

    await doubleTapAt(tester, lower);
    await doubleTapAt(tester, lower);
    expect(scroll().speed, closeTo(start - AutoScrollSettings.speedStep, 1e-9));
  });

  testWidgets('a double-tap does not also toggle the control bar', (
    tester,
  ) async {
    await pumpLayer(tester);
    container.read(stageModeProvider.notifier).hideHud();

    await doubleTapAt(tester, upper);
    await settleTap(tester);

    expect(container.read(stageModeProvider).hudVisible, isFalse);
  });

  testWidgets(
    'with the HUD flag off a single tap does nothing but double-taps still work',
    (tester) async {
      // The normal song view has no control bar to show, so a lone tap must be
      // left alone. The speed taps have to keep working there all the same.
      await pumpLayer(tester, singleTapTogglesHud: false);
      container.read(stageModeProvider.notifier).hideHud();
      final start = scroll().speed;

      await tester.tapAt(upper);
      await settleTap(tester);
      expect(container.read(stageModeProvider).hudVisible, isFalse);

      await doubleTapAt(tester, upper);
      expect(
        scroll().speed,
        closeTo(start + AutoScrollSettings.speedStep, 1e-9),
      );
    },
  );

  testWidgets('the speed stops at the ends of the range', (tester) async {
    await pumpLayer(tester);

    for (var i = 0; i < 40; i++) {
      await doubleTapAt(tester, lower);
      await tester.pump(const Duration(milliseconds: 400));
    }
    expect(scroll().speed, AutoScrollSettings.minSpeed);
  });

  testWidgets('in Tempo mode the double-taps change the bars', (tester) async {
    await pumpLayer(tester);
    container.read(autoScrollProvider.notifier).setMode(AutoScrollMode.tempo);
    final start = scroll().measures;

    await doubleTapAt(tester, upper);
    expect(scroll().measures, start + AutoScrollSettings.measuresStep);

    await doubleTapAt(tester, lower);
    await doubleTapAt(tester, lower);
    expect(scroll().measures, start - AutoScrollSettings.measuresStep);
  });

  testWidgets('a two-finger tap plays and pauses', (tester) async {
    await pumpLayer(tester);
    expect(scroll().isPlaying, isFalse);

    Future<void> twoFingerTap() async {
      final first = await tester.startGesture(const Offset(150, 400));
      final second = await tester.startGesture(const Offset(250, 400));
      await first.up();
      await second.up();
      await tester.pump();
    }

    await twoFingerTap();
    expect(scroll().isPlaying, isTrue);

    await twoFingerTap();
    expect(scroll().isPlaying, isFalse);
  });

  testWidgets('a two-finger tap still plays when the fingers wobble', (
    tester,
  ) async {
    // A real finger never lands perfectly still — it always sends a few move
    // events. Each finger must be judged against where it went down, not
    // against the other finger's position.
    await pumpLayer(tester);

    final first = await tester.startGesture(const Offset(150, 300));
    final second = await tester.startGesture(const Offset(300, 300));
    await first.moveBy(const Offset(2, 3));
    await second.moveBy(const Offset(-3, 2));
    await first.up();
    await second.up();
    await tester.pump();

    expect(scroll().isPlaying, isTrue);
  });

  testWidgets('a two-finger tap still plays when it is slow', (tester) async {
    // Putting two fingers down and lifting them takes a person longer than a
    // single quick tap does — 400 ms here, well past the one-finger limit.
    // The times must be set on the events themselves: the widget reads the
    // pointer clock, which `tester.pump` does not move.
    await pumpLayer(tester);

    final first = await tester.startGesture(const Offset(150, 300));
    final second = await tester.startGesture(const Offset(300, 300));
    await first.up(timeStamp: const Duration(milliseconds: 400));
    await second.up(timeStamp: const Duration(milliseconds: 400));
    await tester.pump();

    expect(scroll().isPlaying, isTrue);
  });

  testWidgets('a long two-finger hold is not a tap', (tester) async {
    // Resting two fingers on the sheet must not toggle play.
    await pumpLayer(tester);

    final first = await tester.startGesture(const Offset(150, 300));
    final second = await tester.startGesture(const Offset(300, 300));
    await first.up(timeStamp: const Duration(seconds: 2));
    await second.up(timeStamp: const Duration(seconds: 2));
    await tester.pump();

    expect(scroll().isPlaying, isFalse);
  });

  testWidgets('a two-finger drag does not play', (tester) async {
    await pumpLayer(tester);

    final first = await tester.startGesture(const Offset(150, 300));
    final second = await tester.startGesture(const Offset(300, 300));
    await first.moveBy(const Offset(0, -200));
    await second.moveBy(const Offset(0, -200));
    await first.up();
    await second.up();
    await tester.pump();

    expect(scroll().isPlaying, isFalse);
  });

  testWidgets('a pinch does not play', (tester) async {
    // Pinching is how the font size is changed, so it must never toggle play.
    await pumpLayer(tester);

    final first = await tester.startGesture(const Offset(200, 300));
    final second = await tester.startGesture(const Offset(250, 300));
    await first.moveBy(const Offset(-120, 0));
    await second.moveBy(const Offset(120, 0));
    await first.up();
    await second.up();
    await tester.pump();

    expect(scroll().isPlaying, isFalse);
  });

  testWidgets('a drag scrolls and changes nothing', (tester) async {
    await pumpLayer(tester);
    container.read(stageModeProvider.notifier).hideHud();
    final start = scroll().speed;

    await tester.dragFrom(const Offset(200, 500), const Offset(0, -200));
    await settleTap(tester);

    expect(scroll().speed, start);
    expect(scroll().isPlaying, isFalse);
    expect(container.read(stageModeProvider).hudVisible, isFalse);
  });
}
