import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:lyricchord/providers/auto_scroll_provider.dart';
import 'package:lyricchord/providers/stage_mode_provider.dart';
import 'package:lyricchord/widgets/auto_scroll_controls.dart';

import '../helpers/localized_app.dart';
import '../helpers/tooltip_expectations.dart';

void main() {
  Future<ProviderContainer> pump(
    WidgetTester tester, {
    bool showFullScreenButton = true,
  }) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: localizedApp(
          Scaffold(
            body: Center(
              child: AutoScrollControls(
                showFullScreenButton: showFullScreenButton,
              ),
            ),
          ),
        ),
      ),
    );
    return container;
  }

  testWidgets('shows the Manual and Tempo toggles with tooltips', (
    tester,
  ) async {
    await pump(tester);

    expect(find.text('M'), findsOneWidget);
    expect(find.text('T'), findsOneWidget);
    expect(find.byTooltip('Manual'), findsOneWidget);
    expect(find.byTooltip('Tempo'), findsOneWidget);
    expect(find.byTooltip('Full screen'), findsOneWidget);
    expectAllIconButtonsHaveTooltips(tester);
  });

  testWidgets('tapping a toggle switches the scroll mode', (tester) async {
    final container = await pump(tester);

    await tester.tap(find.byTooltip('Tempo'));
    await tester.pump();
    expect(container.read(autoScrollProvider).mode, AutoScrollMode.tempo);

    await tester.tap(find.byTooltip('Manual'));
    await tester.pump();
    expect(container.read(autoScrollProvider).mode, AutoScrollMode.manual);
  });

  testWidgets('the full-screen button enters Stage Mode', (tester) async {
    final container = await pump(tester);

    await tester.tap(find.byTooltip('Full screen'));
    await tester.pump();

    expect(container.read(stageModeProvider).enabled, isTrue);
  });

  testWidgets('the full-screen button can be left out', (tester) async {
    await pump(tester, showFullScreenButton: false);

    expect(find.byTooltip('Full screen'), findsNothing);
  });

  test('formatSpeedLabel shows two decimals and an x', () {
    expect(formatSpeedLabel(1, 'en'), '1.00x');
    expect(formatSpeedLabel(0.25, 'en'), '0.25x');
  });
}
