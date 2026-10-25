import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lyricchord/l10n/app_localizations.dart';
import 'package:lyricchord/l10n/app_localizations_delegates.dart';
import 'package:lyricchord/widgets/gestures_help_dialog.dart';
import '../helpers/tooltip_expectations.dart';

Future<void> _pump(WidgetTester tester, Widget dialog) {
  return tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: appLocalizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: Center(child: dialog)),
    ),
  );
}

void main() {
  testWidgets('renders all gesture rows and titles', (tester) async {
    await _pump(tester, const GesturesHelpDialog());

    expect(find.text('Gestures & Shortcuts'), findsOneWidget);
    expect(
      find.text('Control the sheet hands-free while playing'),
      findsOneWidget,
    );

    expect(find.text('Double-tap top'), findsOneWidget);
    expect(find.text('Double-tap bottom'), findsOneWidget);
    expect(find.text('Tap with two fingers'), findsOneWidget);
    expect(find.text('Drag with one finger'), findsOneWidget);
    expect(find.text('Two-finger pinch'), findsOneWidget);
    expect(find.text('Full screen'), findsOneWidget);

    expect(find.text('Help Center'), findsOneWidget);
    expect(find.text('Got it'), findsOneWidget);
  });

  testWidgets('showGesturesHelpDialog opens and closes via Got it button', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: appLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showGesturesHelpDialog(context),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expectAllIconButtonsHaveTooltips(tester);

    expect(find.byType(GesturesHelpDialog), findsOneWidget);

    await tester.tap(find.text('Got it'));
    await tester.pumpAndSettle();

    expect(find.byType(GesturesHelpDialog), findsNothing);
  });
}
