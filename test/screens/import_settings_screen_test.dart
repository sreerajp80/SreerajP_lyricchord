import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lyricchord/models/import_settings.dart';
import 'package:lyricchord/providers/import_settings_provider.dart';
import 'package:lyricchord/providers/theme_mode_provider.dart';
import 'package:lyricchord/screens/import_settings_screen.dart';

void main() {
  testWidgets(
    'ImportSettingsScreen displays all strategies and changes selection',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          child: const MaterialApp(home: ImportSettingsScreen()),
        ),
      );

      expect(find.text('Import Settings'), findsOneWidget);
      expect(find.text('Overwrite'), findsOneWidget);
      expect(find.text('Rename imported songs'), findsOneWidget);
      expect(find.text('Rename existing songs'), findsOneWidget);
      expect(
        find.text('User suggested name for imported song'),
        findsOneWidget,
      );

      await tester.tap(find.text('Overwrite'));
      await tester.pumpAndSettle();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(ImportSettingsScreen)),
      );
      expect(
        container.read(importSettingsProvider),
        ImportDuplicateStrategy.overwrite,
      );
    },
  );
}
