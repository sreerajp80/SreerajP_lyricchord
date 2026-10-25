import 'package:material_ui/material_ui.dart';

import 'package:lyricchord/l10n/app_localizations.dart';

/// Shown when the songbook could not be read from the database.
///
/// This is deliberately not the same view as an empty songbook. A database
/// failure used to be drawn as "your songbook is empty", which told the user
/// their songs were gone and gave no clue why. Naming the fault — and offering
/// a retry — is the difference between a scary blank page and a fixable one.
class SongbookError extends StatelessWidget {
  const SongbookError({super.key, required this.error, required this.onRetry});

  /// The failure the song stream reported.
  final Object error;

  /// Called when the user taps Try again.
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(
              l10n.errorSongbookErrorTitle,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.errorSongbookErrorMessage,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            // The raw message, kept small. It is the only way a user can tell
            // us what went wrong on their own phone.
            SelectableText(
              '$error',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.tonalIcon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.actionTryAgain),
            ),
          ],
        ),
      ),
    );
  }
}
