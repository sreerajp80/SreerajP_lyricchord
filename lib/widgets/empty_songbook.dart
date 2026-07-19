import 'package:flutter/material.dart';

/// The friendly state shown when the list has nothing in it.
///
/// The wording changes depending on why the list is empty, so a failed search
/// does not read like an empty songbook.
class EmptySongbook extends StatelessWidget {
  const EmptySongbook({
    super.key,
    this.searching = false,
    this.starredOnly = false,
  });

  /// True when the list is empty because the search matched nothing.
  final bool searching;

  /// True when the list is empty because the Starred filter is on.
  final bool starredOnly;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final IconData icon;
    final String title;
    final String message;

    if (searching) {
      icon = Icons.search_off;
      title = 'No matches';
      message = 'No song matched your search. Try different words.';
    } else if (starredOnly) {
      icon = Icons.star_border;
      title = 'No starred songs';
      message = 'Tap the star on a song to keep it here.';
    } else {
      icon = Icons.library_music_outlined;
      title = 'Your songbook is empty';
      message = 'Tap + to write your first lyric chord sheet.';
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
