import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lyricchord/core/utils/song_copy.dart';
import 'package:lyricchord/models/pitch_tradition.dart';
import 'package:lyricchord/models/song_note.dart';
import 'package:lyricchord/models/song_title_words.dart';
import 'package:lyricchord/providers/database_provider.dart';
import 'package:lyricchord/services/chord_suggestion_service.dart';

/// The song being written in the editor, before it is saved.
///
/// Immutable, like [SongNote]. It keeps the fields as the user typed them —
/// `bpmText` is the raw text of the BPM field, so a half-typed number does not
/// get "corrected" while the user is still typing. Tidying happens on save.
class SongDraft {
  /// The id of the song being edited. `0` means a brand new song.
  final int id;

  final String title;
  final String artist;
  final String key;

  /// The BPM field's raw text.
  final String bpmText;

  final String lyrics;

  /// Whether the song is starred. Carried through so saving does not lose it.
  final bool favorite;

  /// The song's saved auto-scroll speed. Not editable here — carried through so
  /// saving an edit does not throw away the speed set in the performance view.
  final double scrollSpeed;

  /// The song's saved Tempo-Auto measures, carried through like [scrollSpeed].
  final int scrollMeasures;

  /// True when the song already has a scroll speed of its own. Carried through
  /// so an edit does not make the song fall back to the starting speed in
  /// Settings.
  final bool scrollSpeedSet;

  /// Which notation this song is written in. Decides whether the editor shows
  /// a Key field (Western) or Raga and Tala fields (Indian).
  final PitchTradition tradition;

  /// The raga name. Only meaningful when [tradition] is not Western.
  final String raga;

  /// The tala name. Only meaningful when [tradition] is not Western.
  final String tala;

  /// Chords the user added by hand this session, shown after the suggestions.
  final List<String> customChords;

  /// The song as it was loaded, used to tell whether anything changed.
  final SongDraft? original;

  const SongDraft({
    this.id = 0,
    this.title = '',
    this.artist = '',
    this.key = defaultKey,
    this.bpmText = '$defaultBpm',
    this.lyrics = '',
    this.favorite = false,
    this.scrollSpeed = 1.0,
    this.scrollSpeedSet = false,
    this.scrollMeasures = 32,
    this.tradition = PitchTradition.western,
    this.raga = '',
    this.tala = '',
    this.customChords = const [],
    this.original,
  });

  /// The key a new song starts in.
  static const String defaultKey = 'C';

  /// The tempo a new song starts at, and the fallback for an unreadable one.
  static const int defaultBpm = 120;

  /// The title used when the user saves without typing one.
  static const String fallbackTitle = SongTitleWords.englishUntitled;

  /// Builds a draft from a saved song.
  factory SongDraft.fromSong(SongNote song) {
    final draft = SongDraft(
      id: song.id,
      title: song.title,
      artist: song.artist,
      key: song.key,
      bpmText: '${song.bpm}',
      lyrics: song.lyrics,
      favorite: song.favorite,
      scrollSpeed: song.scrollSpeed,
      scrollMeasures: song.scrollMeasures,
      scrollSpeedSet: song.scrollSpeedSet,
      raga: song.raga,
      tala: song.tala,
      // A song saved before the column existed has no stored tradition. Fall
      // back to the old rule — a raga means Indian — so opening it in the
      // editor never silently flips it to Western.
      tradition:
          song.tradition ??
          (song.isIndian ? PitchTradition.carnatic : PitchTradition.western),
    );
    return draft.copyWith(original: draft);
  }

  SongDraft copyWith({
    int? id,
    String? title,
    String? artist,
    String? key,
    String? bpmText,
    String? lyrics,
    bool? favorite,
    double? scrollSpeed,
    int? scrollMeasures,
    bool? scrollSpeedSet,
    PitchTradition? tradition,
    String? raga,
    String? tala,
    List<String>? customChords,
    SongDraft? original,
  }) {
    return SongDraft(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      key: key ?? this.key,
      bpmText: bpmText ?? this.bpmText,
      lyrics: lyrics ?? this.lyrics,
      favorite: favorite ?? this.favorite,
      scrollSpeed: scrollSpeed ?? this.scrollSpeed,
      scrollMeasures: scrollMeasures ?? this.scrollMeasures,
      scrollSpeedSet: scrollSpeedSet ?? this.scrollSpeedSet,
      tradition: tradition ?? this.tradition,
      raga: raga ?? this.raga,
      tala: tala ?? this.tala,
      customChords: customChords ?? this.customChords,
      original: original ?? this.original,
    );
  }

  /// True when the user has typed something that is not saved yet.
  bool get isDirty {
    final start = original ?? const SongDraft();
    return title != start.title ||
        artist != start.artist ||
        key != start.key ||
        bpmText != start.bpmText ||
        lyrics != start.lyrics ||
        tradition != start.tradition ||
        raga != start.raga ||
        tala != start.tala;
  }

  /// True when this draft is written in swaras rather than chords.
  bool get isIndian => tradition != PitchTradition.western;

  /// The tempo to save: the typed number, or [defaultBpm] when it is missing
  /// or out of a musically sensible range.
  int get bpm {
    final parsed = int.tryParse(bpmText.trim());
    if (parsed == null || parsed < minBpm || parsed > maxBpm) return defaultBpm;
    return parsed;
  }

  /// Lowest tempo accepted from the BPM field.
  static const int minBpm = 20;

  /// Highest tempo accepted from the BPM field.
  static const int maxBpm = 300;

  /// The chords offered by the toolbar: the key's own chords first, then any
  /// custom ones added this session, with no repeats.
  List<String> get chordSuggestions => chordSuggestionsWith(const []);

  /// Like [chordSuggestions], but with the user's saved custom chords
  /// (Settings → Chords) slotted in between the key's chords and this
  /// session's ones. Repeats are dropped.
  List<String> chordSuggestionsWith(List<String> savedChords) {
    const service = ChordSuggestionService();
    final chords = <String>[...service.suggestionsForKey(key)];
    for (final custom in [...savedChords, ...customChords]) {
      final clean = custom.trim();
      if (clean.isNotEmpty && !chords.contains(clean)) chords.add(clean);
    }
    return List.unmodifiable(chords);
  }

  /// Turns the draft into a savable [SongNote], filling in safe defaults.
  SongNote toSong({
    required int timestamp,
    String untitledTitle = fallbackTitle,
  }) {
    final cleanTitle = title.trim();
    return SongNote(
      id: id,
      title: cleanTitle.isEmpty ? untitledTitle : cleanTitle,
      artist: artist.trim(),
      lyrics: lyrics,
      key: key.trim().isEmpty ? defaultKey : key.trim(),
      bpm: bpm,
      favorite: favorite,
      timestamp: timestamp,
      scrollSpeed: scrollSpeed,
      scrollMeasures: scrollMeasures,
      scrollSpeedSet: scrollSpeedSet,
      // Raga and tala are cleared on a Western song, so switching a song back
      // to Western never leaves a stale raga behind to make it look Indian.
      raga: isIndian ? raga.trim() : '',
      tala: isIndian ? tala.trim() : '',
      tradition: tradition,
    );
  }
}

/// Holds the draft for one editor screen.
///
/// The family argument is the song id, with `0` meaning "new song". It is
/// auto-disposed, so leaving the editor throws the draft away and reopening
/// the same song starts from what is stored.
class SongEditorNotifier extends AsyncNotifier<SongDraft> {
  SongEditorNotifier(this.songId);

  /// The song being edited; `0` for a new song.
  final int songId;

  @override
  Future<SongDraft> build() async {
    if (songId == 0) return const SongDraft();

    final song = await ref.watch(songRepositoryProvider).findById(songId);
    if (song == null) return const SongDraft();
    return SongDraft.fromSong(song);
  }

  void setTitle(String value) => _update((d) => d.copyWith(title: value));

  void setArtist(String value) => _update((d) => d.copyWith(artist: value));

  void setKey(String value) => _update((d) => d.copyWith(key: value));

  void setBpmText(String value) => _update((d) => d.copyWith(bpmText: value));

  void setLyrics(String value) => _update((d) => d.copyWith(lyrics: value));

  void setTradition(PitchTradition value) =>
      _update((d) => d.copyWith(tradition: value));

  void setRaga(String value) => _update((d) => d.copyWith(raga: value));

  void setTala(String value) => _update((d) => d.copyWith(tala: value));

  /// Adds a chord typed in the custom-chord dialog to the toolbar.
  /// Blank text and repeats are ignored.
  void addCustomChord(String chord) {
    final clean = chord.trim();
    if (clean.isEmpty) return;
    _update((d) {
      if (d.chordSuggestions.contains(clean)) return d;
      return d.copyWith(customChords: [...d.customChords, clean]);
    });
  }

  /// Saves the draft and returns the song's id.
  ///
  /// Creates the song when it is new, updates it otherwise. Storage problems
  /// come back as a `StorageException` for the screen to show in a `SnackBar`.
  Future<int> save({SongTitleWords words = SongTitleWords.english}) async {
    final draft = state.value;
    if (draft == null) return 0;

    final repository = ref.read(songRepositoryProvider);
    final song = draft.toSong(
      timestamp: DateTime.now().millisecondsSinceEpoch,
      untitledTitle: words.untitled,
    );

    if (draft.id == 0) {
      final newId = await repository.insert(song);
      _update((d) => _saved(song.copyWith(id: newId), d.customChords));
      return newId;
    }

    await repository.update(song);
    _update((d) => _saved(song, d.customChords));
    return song.id;
  }

  /// Saves the current draft as a brand-new song (an arrangement variant) and
  /// returns the new song's id.
  ///
  /// Unlike [save], this never overwrites the song being edited: it inserts a
  /// new row titled `"<title> (Copy)"`, carrying whatever key, lyrics, and other
  /// changes the user has made in this session. The editor's own draft is left
  /// as it was, still pointing at the original song.
  Future<int> saveAsCopy({
    SongTitleWords words = SongTitleWords.english,
  }) async {
    final draft = state.value;
    if (draft == null) return 0;

    final repository = ref.read(songRepositoryProvider);
    final source = draft.toSong(
      timestamp: DateTime.now().millisecondsSinceEpoch,
      untitledTitle: words.untitled,
    );
    final copy = source.copyWith(
      id: 0,
      title: copiedTitle(source.title, words),
      favorite: false,
    );
    return repository.insert(copy);
  }

  /// The draft after a successful save: clean again (so it is no longer
  /// dirty), but still offering the custom chords added this session.
  SongDraft _saved(SongNote song, List<String> customChords) =>
      SongDraft.fromSong(song).copyWith(customChords: customChords);

  void _update(SongDraft Function(SongDraft draft) change) {
    final draft = state.value;
    if (draft == null) return;
    state = AsyncData(change(draft));
  }
}

/// The editor state for one song. Pass `0` for a new song.
final songEditorProvider = AsyncNotifierProvider.autoDispose
    .family<SongEditorNotifier, SongDraft, int>(SongEditorNotifier.new);
