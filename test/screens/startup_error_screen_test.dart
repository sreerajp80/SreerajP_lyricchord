import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lyricchord/screens/startup_error_screen.dart';

void main() {
  testWidgets('explains the failure without technical detail', (tester) async {
    await tester.pumpWidget(
      StartupErrorApp(error: StateError('prefs broken'), onRetry: () {}),
    );

    expect(find.text('Could not start'), findsOneWidget);
    expect(find.textContaining('Your songs have not been changed'), findsOne);
    expect(find.textContaining('prefs broken'), findsNothing);
  });

  testWidgets('Try again runs start-up again', (tester) async {
    var retries = 0;
    await tester.pumpWidget(
      StartupErrorApp(error: StateError('x'), onRetry: () => retries++),
    );

    await tester.tap(find.text('Try again'));

    expect(retries, 1);
  });

  testWidgets('Copy details copies the error and confirms', (tester) async {
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'] as String?;
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );

    await tester.pumpWidget(
      StartupErrorApp(error: StateError('prefs broken'), onRetry: () {}),
    );
    await tester.tap(find.text('Copy details'));
    await tester.pump();

    expect(copied, contains('StateError'));
    expect(copied, contains('prefs broken'));
    expect(find.text('Details copied'), findsOneWidget);
  });
}
