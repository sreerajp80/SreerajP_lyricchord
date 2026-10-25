import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lyricchord/providers/song_list_provider.dart';
import 'package:lyricchord/l10n/app_localizations.dart';

/// The "All Songs" / "Starred" chips with live counts. The counts come from
/// [songCountsProvider], so they update as songs are added, starred, or
/// deleted.
class SongFilterRow extends ConsumerWidget {
  const SongFilterRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(songFilterProvider);
    final counts = ref.watch(songCountsProvider);
    final l10n = AppLocalizations.of(context);

    void select(SongFilter value) =>
        ref.read(songFilterProvider.notifier).setFilter(value);

    // The chips scroll sideways instead of overflowing, so a narrow phone or a
    // large text-size setting can never clip them.
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      child: Row(
        children: [
          ChoiceChip(
            label: Text(l10n.labelSongFilterAll(counts.total)),
            selected: filter == SongFilter.all,
            onSelected: (_) => select(SongFilter.all),
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            label: Text(l10n.labelSongFilterStarred(counts.starred)),
            selected: filter == SongFilter.starred,
            onSelected: (_) => select(SongFilter.starred),
          ),
        ],
      ),
    );
  }
}
