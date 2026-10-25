import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lyricchord/l10n/app_localizations.dart';
import 'package:lyricchord/l10n/app_localizations_delegates.dart';
import 'package:lyricchord/l10n/language_names.dart';
import 'package:lyricchord/providers/locale_provider.dart';
import 'package:lyricchord/providers/theme_mode_provider.dart';
import 'package:lyricchord/screens/language_settings_screen.dart';

import '../helpers/tooltip_expectations.dart';

void main() {
  Future<SharedPreferences> pumpScreen(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: Consumer(
          builder: (context, ref, _) => MaterialApp(
            locale: ref.watch(localeProvider),
            localizationsDelegates: appLocalizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const LanguageSettingsScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return prefs;
  }

  testWidgets('System default comes first, then each language by its name', (
    tester,
  ) async {
    await pumpScreen(tester);
    expectAllIconButtonsHaveTooltips(tester);

    final titles = tester
        .widgetList<RadioListTile<String>>(find.byType(RadioListTile<String>))
        .map((tile) => (tile.title! as Text).data)
        .toList();
    expect(titles.first, 'System default');
    expect(titles.skip(1), [
      for (final code in availableLanguageCodes) languageEndonym(code),
    ]);
  });

  testWidgets('System default is marked when nothing was chosen', (
    tester,
  ) async {
    await pumpScreen(tester);

    final group = tester.widget<RadioGroup<String>>(
      find.byType(RadioGroup<String>),
    );
    expect(group.groupValue, systemLanguageValue);
  });

  testWidgets('picking English saves it and marks it', (tester) async {
    final prefs = await pumpScreen(tester);

    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();

    expect(prefs.getString('app_language'), 'en');
    final group = tester.widget<RadioGroup<String>>(
      find.byType(RadioGroup<String>),
    );
    expect(group.groupValue, 'en');
  });

  test('endonyms are in each language\'s own script', () {
    expect(languageEndonyms, {
      'en': 'English',
      'ml': 'മലയാളം',
      'sa': 'संस्कृतम्',
    });
  });
}
