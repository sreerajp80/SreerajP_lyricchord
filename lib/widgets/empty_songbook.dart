import 'package:material_ui/material_ui.dart';

import 'package:lyricchord/l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context);

    final IconData icon;
    final String title;
    final String message;

    if (searching) {
      icon = Icons.search_off;
      title = l10n.emptySongbookNoMatchesTitle;
      message = l10n.emptySongbookNoMatchesMessage;
    } else if (starredOnly) {
      icon = Icons.star_border;
      title = l10n.emptySongbookNoStarredTitle;
      message = l10n.emptySongbookNoStarredMessage;
    } else {
      icon = Icons.library_music_outlined;
      title = l10n.emptySongbookEmptyTitle;
      message = l10n.emptySongbookEmptyMessage;
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
