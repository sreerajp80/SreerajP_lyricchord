import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:lyricchord/widgets/safe_error_fallback.dart';

import '../helpers/localized_app.dart';

void main() {
  testWidgets('shows a calm message and an icon, no error detail', (
    tester,
  ) async {
    await tester.pumpWidget(localizedApp(const SafeErrorFallback()));

    expect(
      find.text('This part of the screen could not be shown.'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
  });

  testWidgets('without the app strings it still shows the icon', (
    tester,
  ) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: SafeErrorFallback(),
      ),
    );

    expect(find.byIcon(Icons.error_outline), findsOneWidget);
    expect(find.byType(Text), findsNothing);
  });
}
