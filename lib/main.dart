import 'package:flutter/foundation.dart'
    show LicenseEntryWithLineBreaks, LicenseRegistry;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lyricchord/core/router/app_router.dart';
import 'package:lyricchord/data/app_database.dart';
import 'package:lyricchord/providers/database_provider.dart';
import 'package:lyricchord/providers/theme_mode_provider.dart';
import 'package:lyricchord/theme/app_theme.dart';
import 'package:lyricchord/widgets/file_intent_listener.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  _registerFontLicenses();

  // Open the database (seeds the classic songs on first run) and load the saved
  // preferences before the first frame, so the app opens with the right theme.
  final database = AppDatabase();
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const LyricChordApp(),
    ),
  );
}

/// Registers the SIL Open Font Licence for the bundled lyric fonts so they
/// appear in the app's licences page. The text is read lazily from assets the
/// first time the licences are shown.
void _registerFontLicenses() {
  LicenseRegistry.addLicense(() async* {
    final noto = await rootBundle.loadString('assets/fonts/OFL-Noto.txt');
    yield LicenseEntryWithLineBreaks(const [
      'Noto Sans Malayalam',
      'Noto Serif Malayalam',
    ], noto);

    final manjari = await rootBundle.loadString('assets/fonts/OFL-Manjari.txt');
    yield LicenseEntryWithLineBreaks(const ['Manjari'], manjari);

    final gayathri = await rootBundle.loadString(
      'assets/fonts/OFL-Gayathri.txt',
    );
    yield LicenseEntryWithLineBreaks(const ['Gayathri'], gayathri);
  });
}

class LyricChordApp extends ConsumerWidget {
  const LyricChordApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp.router(
      title: 'LyricChord',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: ref.watch(goRouterProvider),
      builder: (context, child) =>
          FileIntentListener(child: child ?? const SizedBox.shrink()),
    );
  }
}
