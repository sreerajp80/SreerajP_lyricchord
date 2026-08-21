import 'package:flutter/material.dart';

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

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(
              'Could not open your songbook',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Your songs are still saved. The app could not read them just '
              'now.',
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
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
