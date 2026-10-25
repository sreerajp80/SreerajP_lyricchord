import 'package:flutter/foundation.dart'
    show LicenseEntryWithLineBreaks, LicenseRegistry;
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lyricchord/core/config/app_flavor_config.dart';
import 'package:lyricchord/core/constants/app_version.g.dart';
import 'package:lyricchord/core/errors/global_error_handlers.dart';
import 'package:lyricchord/core/logging/app_logger.dart';
import 'package:lyricchord/core/router/app_router.dart';
import 'package:lyricchord/core/startup/app_startup.dart';
import 'package:lyricchord/l10n/app_localizations.dart';
import 'package:lyricchord/l10n/app_localizations_delegates.dart';
import 'package:lyricchord/providers/locale_provider.dart';
import 'package:lyricchord/providers/theme_mode_provider.dart';
import 'package:lyricchord/theme/app_theme.dart';
import 'package:lyricchord/widgets/file_intent_listener.dart';

/// Start-up order (engineering standard §4.5; documented in
/// `docs/architecture.md` §5).
Future<void> main() async {
  // 1. Flutter bindings.
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Logging, then the global error handlers, so every later step can log.
  AppLogger.init();
  installGlobalErrorHandlers();
  AppLogger.info(
    'App start: flavor=${AppFlavorConfig.instance.flavor.name}, '
    'version=$kAppVersion',
  );

  _registerFontLicenses();

  // Steps 3 and 4 (desktop FFI set-up, secure storage) do not apply: the app
  // is mobile-only and keeps no secrets.
  await AppStartup.start(app: const LyricChordApp());
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

    final devanagari = await rootBundle.loadString(
      'assets/fonts/OFL-Noto-Devanagari.txt',
    );
    yield LicenseEntryWithLineBreaks(const [
      'Noto Sans Devanagari',
    ], devanagari);

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
      onGenerateTitle: (context) => AppLocalizations.of(context).titleApp,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      // null follows the phone; resolveAppLocale then picks a supported one.
      locale: ref.watch(localeProvider),
      localeResolutionCallback: (device, supported) =>
          resolveAppLocale(device, supported),
      localizationsDelegates: appLocalizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: ref.watch(goRouterProvider),
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      builder: (context, child) =>
          FileIntentListener(child: child ?? const SizedBox.shrink()),
    );
  }
}
