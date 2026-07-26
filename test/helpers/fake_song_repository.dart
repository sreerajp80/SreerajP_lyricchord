import 'dart:async';

import 'package:lyricchord/core/utils/song_copy.dart';
import 'package:lyricchord/models/song_note.dart';
import 'package:lyricchord/repositories/song_repository.dart';

/// An in-memory stand-in for [SongRepository], used by widget tests.
///
/// Widget tests should check the screen, not SQLite. Driving a real drift
/// database from `testWidgets` is slow and non-deterministic: the fake-async
/// clock cannot always deliver the database's first result, so the screen
/// stays on its loading spinner and `pumpAndSettle` never settles. The drift
/// path is covered by the repository and provider tests instead.
///
/// This fake emits the current list as soon as a listener arrives, so screens
/// have data on their first frame.
class FakeSongRepository implements SongRepository {
  final _changes = StreamController<List<SongNote>>.broadcast();
  final List<SongNote> _songs;
  int _nextId;

  FakeSongRepository([List<SongNote> initial = const []])
    : _songs = List.of(initial),
      _nextId =
          initial.fold<int>(0, (maxId, s) => s.id > maxId ? s.id : maxId) + 1;

  /// The three seeded songs, matching what the real database ships with.
  factory FakeSongRepository.seeded() => FakeSongRepository([
    const SongNote(
      id: 3,
      title: 'Jingle Bells',
      artist: 'James Lord Pierpont',
      lyrics: '[G]Dashing through the snow',
      key: 'G',
      bpm: 120,
      timestamp: 3,
    ),
    const SongNote(
      id: 2,
      title: 'House of the Rising Sun',
      artist: 'Traditional Folk',
      lyrics: 'There [Am]is a house in New Orleans',
      key: 'Am',
      bpm: 112,
      timestamp: 2,
    ),
    const SongNote(
      id: 1,
      title: 'Amazing Grace',
      artist: 'Traditional',
      lyrics: '[G]Amazing grace, how sweet the sound',
      key: 'G',
      bpm: 80,
      favorite: true,
      timestamp: 1,
    ),
  ]);

  List<SongNote> get _sorted =>
      List.of(_songs)..sort((a, b) => b.timestamp.compareTo(a.timestamp));

  /// The songs stored right now, newest first.
  ///
  /// Test-only synchronous read. Prefer this over `await watchAllSongs().first`
  /// inside a `testWidgets` body: awaiting the broadcast stream there can wedge
  /// the fake-async clock so the test never finishes.
  List<SongNote> get currentSongs => _sorted;

  void _emit() => _changes.add(_sorted);

  @override
  Stream<List<SongNote>> watchAllSongs() {
    return Stream.multi((controller) {
      controller.add(_sorted);
      final sub = _changes.stream.listen(controller.add);
      controller.onCancel = sub.cancel;
    });
  }

  @override
  Future<List<SongNote>> getAllSongs() async => _sorted;

  @override
  Stream<SongNote?> watchSongById(int id) {
    return watchAllSongs().map(
      (songs) => songs.where((s) => s.id == id).firstOrNull,
    );
  }

  @override
  Future<SongNote?> findById(int id) async =>
      _songs.where((s) => s.id == id).firstOrNull;

  @override
  Future<int> insert(SongNote song) async {
    final id = _nextId++;
    _songs.add(song.copyWith(id: id));
    _emit();
    return id;
  }

  @override
  Future<void> update(SongNote song) async {
    final index = _songs.indexWhere((s) => s.id == song.id);
    if (index >= 0) _songs[index] = song;
    _emit();
  }

  @override
  Future<void> toggleFavorite(SongNote song) {
    return update(song.copyWith(favorite: !song.favorite));
  }

  @override
  Future<int> duplicate(SongNote song) {
    return insert(
      song.copyWith(
        id: 0,
        title: copiedTitle(song.title),
        favorite: false,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  @override
  Future<void> delete(int id) async {
    _songs.removeWhere((s) => s.id == id);
    _emit();
  }

  /// Closes the change stream. Call from `tearDown`.
  Future<void> dispose() => _changes.close();

  /// Everything on [SongRepository] not part of its public API (its private
  /// drift field) is unused by the fake.
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
