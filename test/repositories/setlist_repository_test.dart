import 'package:flutter_test/flutter_test.dart';
import 'package:lyricchord/data/app_database.dart';
import 'package:lyricchord/models/pitch_tradition.dart';
import 'package:lyricchord/models/song_note.dart';
import 'package:lyricchord/repositories/setlist_repository.dart';
import 'package:lyricchord/repositories/song_repository.dart';

import '../helpers/test_database.dart';

void main() {
  late AppDatabase db;
  late SetlistRepository setlistRepo;
  late SongRepository songRepo;

  setUp(() {
    db = newInMemoryDatabase();
    setlistRepo = SetlistRepository(db);
    songRepo = SongRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('SetlistRepository', () {
    test('seeds Sunday Gig setlist on database creation', () async {
      final setlists = await setlistRepo.watchAllSetlists().first;

      expect(setlists, hasLength(1));
      expect(setlists.first.name, 'Sunday Gig');
      expect(setlists.first.description, 'Acoustic live setlist');
      expect(setlists.first.songCount, 3);
    });

    test('inserts a new setlist with song IDs', () async {
      final songs = await songRepo.watchAllSongs().first;
      final songIds = songs.map((s) => s.id).toList();

      final newId = await setlistRepo.insertSetlist(
        name: 'Acoustic Practice',
        description: 'Weekly practice list',
        songIds: songIds,
      );

      expect(newId, greaterThan(0));

      final setlist = await setlistRepo.watchSetlistById(newId).first;
      expect(setlist, isNotNull);
      expect(setlist!.name, 'Acoustic Practice');
      expect(setlist.description, 'Weekly practice list');
      expect(setlist.songCount, songIds.length);
    });

    test('updates setlist details and reorders songs', () async {
      final setlists = await setlistRepo.watchAllSetlists().first;
      final original = setlists.first;

      final reversedSongIds = original.songs
          .map((s) => s.id)
          .toList()
          .reversed
          .toList();

      await setlistRepo.updateSetlist(
        id: original.id,
        name: 'Sunday Evening Gig',
        description: 'Updated description',
        songIds: reversedSongIds,
      );

      final updated = await setlistRepo.watchSetlistById(original.id).first;
      expect(updated!.name, 'Sunday Evening Gig');
      expect(updated.description, 'Updated description');
      expect(updated.songs.map((s) => s.id).toList(), reversedSongIds);
    });

    test('adds a song to an existing setlist without duplicates', () async {
      final setlists = await setlistRepo.watchAllSetlists().first;
      final setlist = setlists.first;
      final initialCount = setlist.songCount;

      // Create a new song
      final newSongId = await songRepo.insert(
        SongNote(
          title: 'New Test Song',
          artist: 'Test Artist',
          lyrics: 'Line 1',
          key: 'G',
          bpm: 120,
          timestamp: DateTime.now().millisecondsSinceEpoch,
        ),
      );

      // Add to setlist
      await setlistRepo.addSongToSetlist(setlist.id, newSongId);

      var updated = await setlistRepo.watchSetlistById(setlist.id).first;
      expect(updated!.songCount, initialCount + 1);
      expect(updated.songs.last.id, newSongId);

      // Try adding same song again - should not duplicate
      await setlistRepo.addSongToSetlist(setlist.id, newSongId);
      updated = await setlistRepo.watchSetlistById(setlist.id).first;
      expect(updated!.songCount, initialCount + 1);
    });

    test('setlist songs keep their scroll and tradition fields', () async {
      // A song reached through a setlist must be the same song as one reached
      // through the songbook. Dropping fields here lost the saved scroll speed
      // and made an Indian song read as Western.
      final songId = await songRepo.insert(
        SongNote(
          title: 'Mohanam Piece',
          lyrics: '{raga: Mohanam}\n{tala: Adi}\n[Sa]ri ga',
          timestamp: DateTime.now().millisecondsSinceEpoch,
          scrollSpeed: 1.75,
          scrollMeasures: 48,
          raga: 'Mohanam',
          tala: 'Adi',
          tradition: PitchTradition.carnatic,
        ),
      );

      final setlistId = await setlistRepo.insertSetlist(
        name: 'Classical Set',
        songIds: [songId],
      );

      final setlist = await setlistRepo.watchSetlistById(setlistId).first;
      final song = setlist!.songs.single;

      expect(song.scrollSpeed, 1.75);
      expect(song.scrollMeasures, 48);
      expect(song.raga, 'Mohanam');
      expect(song.tala, 'Adi');
      expect(song.tradition, PitchTradition.carnatic);
      expect(song.isIndian, isTrue);
    });

    test('deletes a setlist', () async {
      final setlists = await setlistRepo.watchAllSetlists().first;
      final id = setlists.first.id;

      await setlistRepo.deleteSetlist(id);

      final afterDelete = await setlistRepo.watchAllSetlists().first;
      expect(afterDelete, isEmpty);
    });
  });
}
