import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lyricchord/core/constants/app_constants.dart';
import 'package:lyricchord/providers/theme_mode_provider.dart';
import 'package:lyricchord/screens/chord_settings_screen.dart';

void main() {
  Future<SharedPreferences> pumpChords(
    WidgetTester tester, {
    List<String>? saved,
  }) async {
    SharedPreferences.setMockInitialValues({
      AppConstants.prefCustomChords: ?saved,
    });
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const MaterialApp(home: ChordSettingsScreen()),
      ),
    );
    await tester.pumpAndSettle();
    return prefs;
  }

  testWidgets('starts with the empty state', (tester) async {
    await pumpChords(tester);

    expect(find.text('No custom chords yet.'), findsOneWidget);
  });

  testWidgets('shows the saved chords', (tester) async {
    await pumpChords(tester, saved: ['Cmaj7', 'D/F#']);

    expect(find.text('Cmaj7'), findsOneWidget);
    expect(find.text('D/F#'), findsOneWidget);
  });

  testWidgets('adding a chord lists it and saves it', (tester) async {
    final prefs = await pumpChords(tester);

    await tester.enterText(find.byType(TextField), 'Dsus4');
    await tester.tap(find.widgetWithText(FilledButton, 'Add'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(ListTile, 'Dsus4'), findsOneWidget);
    expect(prefs.getStringList(AppConstants.prefCustomChords), ['Dsus4']);
    // The field is cleared, ready for the next chord.
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      isEmpty,
    );
  });

  testWidgets('a repeated chord is refused with a message', (tester) async {
    await pumpChords(tester, saved: ['Cmaj7']);

    await tester.enterText(find.byType(TextField), 'Cmaj7');
    await tester.tap(find.widgetWithText(FilledButton, 'Add'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(ListTile, 'Cmaj7'), findsOneWidget);
    expect(find.byType(SnackBar), findsOneWidget);
  });

  testWidgets('the delete button removes a chord', (tester) async {
    final prefs = await pumpChords(tester, saved: ['Cmaj7', 'Dsus4']);

    await tester.tap(find.byTooltip('Remove Cmaj7'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(ListTile, 'Cmaj7'), findsNothing);
    expect(find.widgetWithText(ListTile, 'Dsus4'), findsOneWidget);
    expect(prefs.getStringList(AppConstants.prefCustomChords), ['Dsus4']);
  });
}
