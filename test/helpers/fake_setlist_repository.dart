import 'dart:async';

import 'package:lyricchord/models/setlist.dart';
import 'package:lyricchord/models/song_note.dart';
import 'package:lyricchord/repositories/setlist_repository.dart';

/// An in-memory [SetlistRepository] for widget tests, so a screen can be
/// pumped without a real database (drift's stream timers outlive a widget
/// test). Song ids are resolved against [songs].
class FakeSetlistRepository implements SetlistRepository {
  FakeSetlistRepository({required this.songs, List<Setlist> initial = const []})
    : _setlists = {
        for (final s in initial) s.id: s.songs.map((song) => song.id).toList(),
      },
      _meta = {for (final s in initial) s.id: s.copyWith(songs: const [])},
      _nextId =
          initial.fold<int>(0, (maxId, s) => s.id > maxId ? s.id : maxId) + 1;

  /// Every song a setlist may refer to.
  final List<SongNote> songs;

  final Map<int, List<int>> _setlists;
  final Map<int, Setlist> _meta;
  final _changes = StreamController<void>.broadcast();
  int _nextId;

  /// The song ids of setlist [id] right now, for assertions.
  List<int> songIdsOf(int id) => List.unmodifiable(_setlists[id] ?? const []);

  /// Whether setlist [id] still exists.
  bool contains(int id) => _meta.containsKey(id);

  Setlist? _build(int id) {
    final meta = _meta[id];
    if (meta == null) return null;
    final byId = {for (final s in songs) s.id: s};
    return meta.copyWith(
      songs: [
        for (final songId in _setlists[id] ?? const <int>[])
          if (byId[songId] != null) byId[songId]!,
      ],
    );
  }

  List<Setlist> _all() => [for (final id in _meta.keys) _build(id)!];

  void _notify() => _changes.add(null);

  @override
  Stream<List<Setlist>> watchAllSetlists() async* {
    yield _all();
    await for (final _ in _changes.stream) {
      yield _all();
    }
  }

  @override
  Stream<Setlist?> watchSetlistById(int id) async* {
    yield _build(id);
    await for (final _ in _changes.stream) {
      yield _build(id);
    }
  }

  @override
  Future<int> insertSetlist({
    required String name,
    String description = '',
    List<int> songIds = const [],
  }) async {
    final id = _nextId++;
    _meta[id] = Setlist(
      id: id,
      name: name,
      description: description,
      createdAt: 0,
      updatedAt: 0,
    );
    _setlists[id] = List.of(songIds);
    _notify();
    return id;
  }

  @override
  Future<void> updateSetlist({
    required int id,
    required String name,
    String description = '',
    List<int>? songIds,
  }) async {
    final meta = _meta[id];
    if (meta == null) return;
    _meta[id] = meta.copyWith(name: name, description: description);
    if (songIds != null) _setlists[id] = List.of(songIds);
    _notify();
  }

  @override
  Future<void> reorderSongs(int setlistId, List<int> songIds) async {
    _setlists[setlistId] = List.of(songIds);
    _notify();
  }

  @override
  Future<void> addSongToSetlist(int setlistId, int songId) async {
    final ids = _setlists.putIfAbsent(setlistId, () => []);
    if (!ids.contains(songId)) ids.add(songId);
    _notify();
  }

  /// When set, [deleteSetlist] throws this instead of deleting.
  Object? deleteError;

  @override
  Future<void> deleteSetlist(int id) async {
    if (deleteError != null) throw deleteError!;
    _meta.remove(id);
    _setlists.remove(id);
    _notify();
  }

  Future<void> dispose() => _changes.close();
}
