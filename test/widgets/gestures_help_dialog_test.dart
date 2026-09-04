import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lyricchord/widgets/gestures_help_dialog.dart';

Future<void> _pump(WidgetTester tester, Widget dialog) {
  return tester.pumpWidget(
    MaterialApp(
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

    expect(find.text('Double-tap top half'), findsOneWidget);
    expect(find.text('Double-tap bottom half'), findsOneWidget);
    expect(find.text('Tap with two fingers'), findsOneWidget);
    expect(find.text('Drag with one finger'), findsOneWidget);
    expect(find.text('Pinch with two fingers'), findsOneWidget);
    expect(find.text('Full screen (Stage Mode)'), findsOneWidget);

    expect(find.text('Help Center'), findsOneWidget);
    expect(find.text('Got it'), findsOneWidget);
  });

  testWidgets('showGesturesHelpDialog opens and closes via Got it button', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
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

    expect(find.byType(GesturesHelpDialog), findsOneWidget);

    await tester.tap(find.text('Got it'));
    await tester.pumpAndSettle();

    expect(find.byType(GesturesHelpDialog), findsNothing);
  });
}
