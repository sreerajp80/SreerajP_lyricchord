import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lyricchord/core/router/app_router.dart';
import 'package:lyricchord/core/startup/app_startup.dart';
import 'package:lyricchord/l10n/app_localizations.dart';
import 'package:lyricchord/l10n/app_localizations_delegates.dart';
import 'package:lyricchord/providers/data_purge_provider.dart';
import 'package:lyricchord/providers/database_provider.dart';
import 'package:lyricchord/providers/theme_mode_provider.dart';

/// A tiny app that proves the start-up overrides are in place.
///
/// It reads the providers without touching the database: the database opens
/// lazily on first query, and a widget test has no app documents folder.
class _ProbeApp extends ConsumerWidget {
  const _ProbeApp();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(sharedPreferencesProvider);
    ref.watch(appDatabaseProvider);
    ref.watch(deleteAllDataProvider);
    return MaterialApp(
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      localizationsDelegates: appLocalizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: Text('started ${prefs.getString('probe')}')),
    );
  }
}

// The failure path (StartupErrorApp with "Try again") is covered by
// test/screens/startup_error_screen_test.dart.

void main() {
  testWidgets('start opens the data and runs the app with its overrides', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'probe': 'ok'});

    await AppStartup.start(app: const _ProbeApp());
    await tester.pump();

    expect(find.text('started ok'), findsOneWidget);
  });

  testWidgets('a start-up notice is shown after the first frame', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await AppStartup.start(
      app: const _ProbeApp(),
      notice: StartupNotice.allDataDeleted,
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    expect(find.text(l10n.bodyAllDataDeleted), findsOneWidget);
  });
}
