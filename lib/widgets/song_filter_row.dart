import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lyriccord/providers/song_list_provider.dart';

/// The "All Songs" / "Starred" chips with live counts. The counts come from
/// [songCountsProvider], so they update as songs are added, starred, or
/// deleted.
class SongFilterRow extends ConsumerWidget {
  const SongFilterRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(songFilterProvider);
    final counts = ref.watch(songCountsProvider);

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
            label: Text('All Songs (${counts.total})'),
            selected: filter == SongFilter.all,
            onSelected: (_) => select(SongFilter.all),
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            label: Text('Starred (${counts.starred})'),
            selected: filter == SongFilter.starred,
            onSelected: (_) => select(SongFilter.starred),
          ),
        ],
      ),
    );
  }
}
