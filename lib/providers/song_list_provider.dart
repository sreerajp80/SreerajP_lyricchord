import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lyricchord/models/song_note.dart';
import 'package:lyricchord/providers/database_provider.dart';

/// Which songs the list shows: every song, or only the starred ones.
enum SongFilter { all, starred }

/// Live counts shown next to the All / Starred filter chips.
class SongCounts {
  /// How many songs exist in total.
  final int total;

  /// How many of those are starred.
  final int starred;

  const SongCounts({required this.total, required this.starred});

  @override
  bool operator ==(Object other) =>
      other is SongCounts && other.total == total && other.starred == starred;

  @override
  int get hashCode => Object.hash(total, starred);

  @override
  String toString() => 'SongCounts(total: $total, starred: $starred)';
}

/// Every song in the database, newest activity first, as a live stream.
final songsStreamProvider = StreamProvider<List<SongNote>>((ref) {
  return ref.watch(songRepositoryProvider).watchAllSongs();
});

/// One song by id, as a live stream. Emits `null` when the song is gone.
final songByIdProvider = StreamProvider.family<SongNote?, int>((ref, id) {
  return ref.watch(songRepositoryProvider).watchSongById(id);
});

/// The text typed into the search box. Empty means "no search".
class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  /// Replaces the current search text.
  void setQuery(String query) => state = query;

  /// Clears the search text.
  void clear() => state = '';
}

/// The current search text.
final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(
  SearchQueryNotifier.new,
);

/// The chosen All / Starred filter.
class SongFilterNotifier extends Notifier<SongFilter> {
  @override
  SongFilter build() => SongFilter.all;

  /// Switches the filter.
  void setFilter(SongFilter filter) => state = filter;
}

/// The current All / Starred filter.
final songFilterProvider = NotifierProvider<SongFilterNotifier, SongFilter>(
  SongFilterNotifier.new,
);

/// The songs actually shown in the list: all songs, narrowed by the starred
/// filter and then by the search text.
///
/// Search is case-insensitive and looks at the title, the artist, and the
/// lyrics. It is done in memory over the whole (small, local) list, which is
/// what architecture §11 asks for.
final filteredSongsProvider = Provider<List<SongNote>>((ref) {
  final songs = ref.watch(songsStreamProvider).value ?? const <SongNote>[];
  final filter = ref.watch(songFilterProvider);
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();

  return filterSongs(songs, filter: filter, query: query);
});

/// The live totals behind the filter chips. Counts ignore the search text so
/// the chips keep showing the size of the whole songbook.
final songCountsProvider = Provider<SongCounts>((ref) {
  final songs = ref.watch(songsStreamProvider).value ?? const <SongNote>[];
  return SongCounts(
    total: songs.length,
    starred: songs.where((song) => song.favorite).length,
  );
});

/// The song shown in the tablet detail pane. `null` means nothing is selected
/// yet, so the pane shows its welcome state.
class SelectedSongIdNotifier extends Notifier<int?> {
  @override
  int? build() => null;

  /// Selects a song (or clears the selection with `null`).
  void select(int? id) => state = id;
}

/// The id of the song selected in the tablet dual-pane layout.
final selectedSongIdProvider = NotifierProvider<SelectedSongIdNotifier, int?>(
  SelectedSongIdNotifier.new,
);

/// Multi-selection state for batch song actions (export, delete).
class MultiSongSelectionNotifier extends Notifier<Set<int>> {
  @override
  Set<int> build() => const {};

  void toggle(int id) {
    if (state.contains(id)) {
      state = Set.of(state)..remove(id);
    } else {
      state = Set.of(state)..add(id);
    }
  }

  void selectAll(Iterable<int> ids) {
    state = Set.of(ids);
  }

  void clear() {
    state = const {};
  }
}

final multiSongSelectionProvider =
    NotifierProvider<MultiSongSelectionNotifier, Set<int>>(
      MultiSongSelectionNotifier.new,
    );

/// Pure filtering used by [filteredSongsProvider]. Exposed on its own so it can
/// be unit tested without building a provider container.
///
/// [query] must already be trimmed and lower-cased.
List<SongNote> filterSongs(
  List<SongNote> songs, {
  required SongFilter filter,
  required String query,
}) {
  final starredOnly = filter == SongFilter.starred;
  return songs
      .where((song) {
        if (starredOnly && !song.favorite) return false;
        if (query.isEmpty) return true;
        return song.title.toLowerCase().contains(query) ||
            song.artist.toLowerCase().contains(query) ||
            song.lyrics.toLowerCase().contains(query);
      })
      .toList(growable: false);
}
