import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lyricchord/core/constants/app_constants.dart';
import 'package:lyricchord/l10n/app_localizations.dart';
import 'package:lyricchord/providers/song_list_provider.dart';
import 'package:lyricchord/screens/song_list_screen.dart';
import 'package:lyricchord/screens/song_performance_screen.dart';
import 'package:lyricchord/widgets/resizable_split_view.dart';

/// Chooses the layout for the songbook.
///
/// Below [AppConstants.tabletBreakpoint] (600 dp) the list fills the screen and
/// tapping a song navigates. At 600 dp and above the list sits on the left
/// (38% by default, as on Android) with the song on the right. The divider
/// can be dragged to resize the list or hide it ([ResizableSplitView]).
class HomeShell extends StatelessWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth >= AppConstants.tabletBreakpoint;
        if (!isTablet) return const SongListScreen();

        return const ResizableSplitView(
          list: SongListScreen(dualPane: true),
          detail: _DetailPane(),
        );
      },
    );
  }
}

/// The right-hand pane on a tablet: the selected song, or a welcome state when
/// nothing is selected yet.
class _DetailPane extends ConsumerWidget {
  const _DetailPane();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedId = ref.watch(selectedSongIdProvider);

    if (selectedId == null) {
      final theme = Theme.of(context);
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.queue_music,
                size: 72,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context).titleHomePickSong,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context).descHomePickSongMessage,
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

    return SongPerformanceScreen(
      // The list stays on screen beside the pane, so no back button.
      songId: selectedId,
      embedded: true,
    );
  }
}
