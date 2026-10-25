// Sanskrit has no Flutter framework strings, so English ones are served instead
// (engineering standard §8.3.1, language pack §1.1). This is the most likely
// Sanskrit runtime failure, so the pack asks for exactly this test.
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:lyricchord/l10n/app_localizations.dart';
import 'package:lyricchord/l10n/app_localizations_delegates.dart';
import 'package:lyricchord/l10n/fallback_localizations.dart';

void main() {
  Future<BuildContext> pumpSanskrit(WidgetTester tester) async {
    late BuildContext captured;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('sa'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: appLocalizationsDelegates,
        home: Builder(
          builder: (context) {
            captured = context;
            return const Scaffold(body: SizedBox());
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    return captured;
  }

  test('Sanskrit is the only fallback language', () {
    expect(kFrameworkFallbackLanguages, {'sa'});
    expect(kFrameworkFallbackLocale, const Locale('en'));
  });

  testWidgets('a date picker opens under Sanskrit, with English buttons', (
    tester,
  ) async {
    final context = await pumpSanskrit(tester);

    showDatePicker(
      context: context,
      initialDate: DateTime(2026, 10, 25),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(DatePickerDialog), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('OK'), findsOneWidget);
  });

  testWidgets('a dialog opens under Sanskrit without errors', (tester) async {
    final context = await pumpSanskrit(tester);

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        content: const SizedBox(width: 10, height: 10),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(MaterialLocalizations.of(dialogContext).okButtonLabel),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('OK'), findsOneWidget);
  });
}
