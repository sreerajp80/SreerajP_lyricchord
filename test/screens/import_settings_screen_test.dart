import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lyricchord/l10n/app_localizations.dart';
import 'package:lyricchord/l10n/app_localizations_delegates.dart';
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
          child: const MaterialApp(
            localizationsDelegates: appLocalizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: ImportSettingsScreen(),
          ),
        ),
      );

      expect(find.text('Import Settings'), findsOneWidget);
      expect(find.text('Overwrite'), findsOneWidget);
      expect(find.text('Rename imported'), findsOneWidget);
      expect(find.text('Rename existing'), findsOneWidget);
      expect(find.text('Ask for a new name'), findsOneWidget);

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
