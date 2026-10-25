import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import 'package:lyricchord/l10n/app_localizations.dart';
import 'package:lyricchord/l10n/app_localizations_delegates.dart';
import 'package:lyricchord/theme/app_theme.dart';

/// The whole app when start-up fails (engineering standard §4.5, §11.4): a
/// plain explanation, a way to try again, and a way to copy the details for a
/// bug report. It needs nothing that start-up sets up — no database, no saved
/// settings — so it cannot fail the same way.
class StartupErrorApp extends StatelessWidget {
  const StartupErrorApp({
    super.key,
    required this.error,
    this.stackTrace,
    required this.onRetry,
  });

  final Object error;
  final StackTrace? stackTrace;

  /// Runs start-up again.
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).titleApp,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      localizationsDelegates: appLocalizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: StartupErrorScreen(
        details: '${error.runtimeType}: $error\n${stackTrace ?? ''}',
        onRetry: onRetry,
      ),
    );
  }
}

/// The screen inside [StartupErrorApp].
class StartupErrorScreen extends StatelessWidget {
  const StartupErrorScreen({
    super.key,
    required this.details,
    required this.onRetry,
  });

  /// Technical details, copied only when the user asks for them.
  final String details;
  final VoidCallback onRetry;

  Future<void> _copyDetails(BuildContext context) async {
    final message = AppLocalizations.of(context).bodyDetailsCopied;
    final messenger = ScaffoldMessenger.of(context);
    await Clipboard.setData(ClipboardData(text: details));
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.titleStartupFailed,
                  style: theme.textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.descStartupFailed,
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: onRetry,
                  child: Text(l10n.actionTryAgain),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => _copyDetails(context),
                  child: Text(l10n.actionCopyDetails),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
