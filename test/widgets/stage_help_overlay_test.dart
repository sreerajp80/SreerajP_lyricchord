import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:lyricchord/widgets/stage_help_overlay.dart';

import '../helpers/localized_app.dart';

void main() {
  testWidgets('lists every stage gesture with what it does', (tester) async {
    await tester.pumpWidget(
      localizedApp(Scaffold(body: StageHelpOverlay(onDismiss: () {}))),
    );

    expect(find.text('Full screen'), findsOneWidget);
    expect(find.text('Tap once'), findsOneWidget);
    expect(find.text('Pinch'), findsOneWidget);
    expect(find.text('Back'), findsOneWidget);
    expect(find.text('Tap anywhere to start'), findsOneWidget);
    // Six gestures, each with its own icon.
    expect(
      find.descendant(
        of: find.byType(StageHelpOverlay),
        matching: find.byType(Icon),
      ),
      findsNWidgets(6),
    );
  });

  testWidgets('a tap anywhere closes it', (tester) async {
    var dismissed = 0;
    await tester.pumpWidget(
      localizedApp(
        Scaffold(body: StageHelpOverlay(onDismiss: () => dismissed++)),
      ),
    );

    await tester.tap(find.text('Pinch'));
    expect(dismissed, 1);
  });
}
