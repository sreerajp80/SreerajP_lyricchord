import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lyriccord/core/constants/app_constants.dart';
import 'package:lyriccord/models/lyric_font.dart';
import 'package:lyriccord/providers/theme_mode_provider.dart';
import 'package:lyriccord/screens/font_settings_screen.dart';

void main() {
  Future<SharedPreferences> pumpFonts(
    WidgetTester tester, {
    String? saved,
  }) async {
    SharedPreferences.setMockInitialValues({
      AppConstants.prefLyricFont: ?saved,
    });
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const MaterialApp(home: FontSettingsScreen()),
      ),
    );
    await tester.pumpAndSettle();
    return prefs;
  }

  testWidgets('lists every font choice', (tester) async {
    await pumpFonts(tester);

    for (final font in LyricFont.values) {
      expect(find.text(font.label), findsOneWidget);
    }
  });

  testWidgets('the saved font is selected', (tester) async {
    await pumpFonts(tester, saved: LyricFont.gayathri.id);

    final tile = tester.widget<RadioListTile<LyricFont>>(
      find.widgetWithText(RadioListTile<LyricFont>, 'Gayathri'),
    );
    expect(tile.value, LyricFont.gayathri);

    final group = tester.widget<RadioGroup<LyricFont>>(
      find.byType(RadioGroup<LyricFont>),
    );
    expect(group.groupValue, LyricFont.gayathri);
  });

  testWidgets('picking a font saves the choice', (tester) async {
    final prefs = await pumpFonts(tester);

    await tester.tap(find.text('Manjari'));
    await tester.pumpAndSettle();

    expect(prefs.getString(AppConstants.prefLyricFont), LyricFont.manjari.id);
  });
}
