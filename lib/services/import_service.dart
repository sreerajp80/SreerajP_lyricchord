import 'package:lyricchord/models/import_settings.dart';
import 'package:lyricchord/models/song_note.dart';
import 'package:lyricchord/repositories/song_repository.dart';
import 'package:lyricchord/services/chord_pro_service.dart';

/// Result summary of an import operation.
class ImportResult {
  final List<SongNote> importedSongs;
  final List<int> importedIds;
  final int totalParsed;

  const ImportResult({
    required this.importedSongs,
    required this.importedIds,
    required this.totalParsed,
  });
}

/// Abstract handler callback for prompting user for title when [ImportDuplicateStrategy.userSuggested] is active.
typedef UserTitlePromptHandler =
    Future<String?> Function({
      required SongNote importedSong,
      required SongNote existingSong,
    });

/// Orchestrates importing ChordPro content with duplicate resolution.
class ImportService {
  final SongRepository repository;
  final ChordProService chordProService;

  const ImportService({
    required this.repository,
    this.chordProService = const ChordProService(),
  });

  /// Formats timestamp for title suffix e.g., "(2026-07-26 07:45)"
  static String formatTimestamp(DateTime dt) {
    final yyyy = dt.year.toString().padLeft(4, '0');
    final mm = dt.month.toString().padLeft(2, '0');
    final dd = dt.day.toString().padLeft(2, '0');
    final hh = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '($yyyy-$mm-$dd $hh:$min)';
  }

  /// Processes raw ChordPro [content] into songs and saves them per [strategy].
  Future<ImportResult> importContent({
    required String content,
    required ImportDuplicateStrategy strategy,
    UserTitlePromptHandler? onAskUserTitle,
    String untitledTitle = ChordProService.defaultUntitledTitle,
  }) {
    return importSongs(
      songs: chordProService.parseMultiple(
        content,
        untitledTitle: untitledTitle,
      ),
      strategy: strategy,
      onAskUserTitle: onAskUserTitle,
    );
  }

  /// Saves already-parsed [songs] per [strategy].
  ///
  /// The import preview calls this with the very songs it showed, so what is
  /// saved is exactly what the user saw — no second trip through ChordPro text.
  Future<ImportResult> importSongs({
    required List<SongNote> songs,
    required ImportDuplicateStrategy strategy,
    UserTitlePromptHandler? onAskUserTitle,
  }) async {
    final parsedList = songs;
    final importedSongs = <SongNote>[];
    final importedIds = <int>[];

    final now = DateTime.now();

    for (final parsed in parsedList) {
      final existing = await repository.findByTitle(parsed.title);

      if (existing == null) {
        // No duplicate - insert directly
        final stamped = parsed.copyWith(timestamp: now.millisecondsSinceEpoch);
        final id = await repository.insert(stamped);
        importedSongs.add(stamped);
        importedIds.add(id);
        continue;
      }

      // Handle duplicate based on strategy
      switch (strategy) {
        case ImportDuplicateStrategy.overwrite:
          final updated = _overwrite(
            existing,
            parsed,
            now,
          ).copyWith(title: parsed.title);
          await repository.update(updated);
          importedSongs.add(updated);
          importedIds.add(existing.id);
          break;

        case ImportDuplicateStrategy.renameImported:
          final newTitle = '${parsed.title} ${formatTimestamp(now)}';
          final stamped = parsed.copyWith(
            title: newTitle,
            timestamp: now.millisecondsSinceEpoch,
          );
          final id = await repository.insert(stamped);
          importedSongs.add(stamped);
          importedIds.add(id);
          break;

        case ImportDuplicateStrategy.renameExisting:
          final renamedExistingTitle =
              '${existing.title} ${formatTimestamp(now)}';
          await repository.update(
            existing.copyWith(title: renamedExistingTitle),
          );
          final stamped = parsed.copyWith(
            timestamp: now.millisecondsSinceEpoch,
          );
          final id = await repository.insert(stamped);
          importedSongs.add(stamped);
          importedIds.add(id);
          break;

        case ImportDuplicateStrategy.userSuggested:
          String? userTitle;
          if (onAskUserTitle != null) {
            userTitle = await onAskUserTitle(
              importedSong: parsed,
              existingSong: existing,
            );
          }

          if (userTitle == null || userTitle.trim().isEmpty) {
            // Fallback if dialog dismissed / cancelled: default to timestamping imported song
            userTitle = '${parsed.title} ${formatTimestamp(now)}';
          } else {
            userTitle = userTitle.trim();
          }

          if (userTitle.toLowerCase() == existing.title.trim().toLowerCase()) {
            // User typed same name -> overwrite
            final updated = _overwrite(existing, parsed, now);
            await repository.update(updated);
            importedSongs.add(updated);
            importedIds.add(existing.id);
          } else {
            final stamped = parsed.copyWith(
              title: userTitle,
              timestamp: now.millisecondsSinceEpoch,
            );
            final id = await repository.insert(stamped);
            importedSongs.add(stamped);
            importedIds.add(id);
          }
          break;
      }
    }

    return ImportResult(
      importedSongs: importedSongs,
      importedIds: importedIds,
      totalParsed: parsedList.length,
    );
  }

  /// [existing] with the content of [parsed] written over it.
  ///
  /// Carries the raga, tala and tradition as well as the words and tempo: an
  /// Indian song imported over a Western one must not keep the Western
  /// tradition, or the transposer would treat its swaras as chords. The
  /// existing title, favourite star and scroll settings are kept.
  SongNote _overwrite(SongNote existing, SongNote parsed, DateTime now) {
    return SongNote(
      id: existing.id,
      title: existing.title,
      artist: parsed.artist,
      lyrics: parsed.lyrics,
      key: parsed.key,
      bpm: parsed.bpm,
      favorite: existing.favorite,
      timestamp: now.millisecondsSinceEpoch,
      scrollSpeed: existing.scrollSpeed,
      scrollMeasures: existing.scrollMeasures,
      scrollSpeedSet: existing.scrollSpeedSet,
      raga: parsed.raga,
      tala: parsed.tala,
      tradition: parsed.tradition,
    );
  }
}
