/// Reads and writes the ChordPro interchange format.
///
/// Pure logic — no UI, no storage, no file IO. The screen edge picks the file
/// and saves the result; this service only turns text into a [SongNote] and a
/// [SongNote] back into text (architecture §4, layer boundaries).
///
/// Nothing here throws. A broken or empty file still returns a usable song
/// ("Untitled Song" with safe defaults), which is CLAUDE.md hard rule 4 — the
/// imported file is the one untrusted input, so parsing must never crash.
library;

import 'package:lyricchord/core/utils/line_break_utils.dart';
import 'package:lyricchord/models/song_note.dart';
import 'package:lyricchord/models/song_title_words.dart';
import 'package:lyricchord/services/chord_transposer.dart';
import 'package:lyricchord/services/pitch_naming_service.dart';

/// A `{name: value}` directive line pulled from a ChordPro file.
class _Directive {
  final String name;
  final String value;

  const _Directive(this.name, this.value);
}

/// Parses ChordPro text into a [SongNote] and formats a [SongNote] back out.
class ChordProService {
  const ChordProService();

  /// The title a song without a `{title}` gets when the caller passes none.
  ///
  /// Screens pass the localized word (`labelUntitledSong`) instead, because
  /// the title is saved and a Malayalam or Sanskrit user must not get English.
  static const String defaultUntitledTitle = SongTitleWords.englishUntitled;

  static const ChordTransposer _transposer = ChordTransposer();
  static const PitchNamingService _naming = PitchNamingService();

  /// Reads ChordPro [content] into a new [SongNote].
  ///
  /// The returned song has id `0` and `timestamp` `0`; the caller stamps the
  /// real time when it saves. Understood directives:
  /// - `{title|t: ...}` → title (defaults to [untitledTitle]).
  /// - `{artist|a: ...}` → artist.
  /// - `{key|k: ...}` → key (defaults to `C`).
  /// - `{bpm|tempo: ...}` → bpm (keeps `120` if not a whole number).
  /// - `{raga: ...}` → raga, and marks the song as Indian.
  /// - `{tala: ...}` → tala, which decides Carnatic vs Hindustani.
  /// - `{comment|c: ...}` → kept as a plain lyric line (its text).
  ///
  /// Chorus/verse markers (`soc`/`eoc`/`sov`/`eov`) and any other directive are
  /// skipped. Every other line is a lyric line, kept exactly. Leading and
  /// trailing blank lyric lines are trimmed so an export/import round-trip is
  /// exact.
  SongNote parse(
    String content, {
    String untitledTitle = defaultUntitledTitle,
  }) {
    String? title;
    String? artist;
    String? key;
    int? bpm;
    String? raga;
    String? tala;
    final lyricLines = <String>[];

    final normalized = normalizeLineEndings(content);
    for (final line in normalized.split('\n')) {
      final directive = _matchDirective(line);
      if (directive == null) {
        lyricLines.add(line);
        continue;
      }
      switch (directive.name) {
        case 'title':
        case 't':
          title = directive.value;
        case 'artist':
        case 'a':
          artist = directive.value;
        case 'key':
        case 'k':
          key = directive.value;
        case 'bpm':
        case 'tempo':
          bpm = int.tryParse(directive.value.trim()) ?? bpm;
        case 'raga':
          raga = directive.value;
        case 'tala':
          tala = directive.value;
        case 'comment':
        case 'c':
          lyricLines.add(directive.value);
        case 'melody':
        case 'tonic':
          // Kept inside the lyrics, exactly as written, rather than lifted into
          // a column of its own.
          //
          // A melody belongs beside the line of words it goes with — moving it
          // to the header would lose which line it is the tune for. The tonic
          // sits with it so both travel together through import, export and
          // transposition, and neither needs a database change.
          //
          // `ChordSheetParser` reads them back out: the tonic through
          // `ParsedSheet.directives`, the tune through `ChordLine.melody`.
          //
          // Only the `{melody: ...}` spelling reaches here at all. The usual
          // `{melody} S R G` form does not end in a brace, so it is already
          // treated as an ordinary line and passes through untouched.
          lyricLines.add(line);
        default:
          // A structural marker (chorus/verse) or an unknown directive: drop
          // the directive itself but keep the surrounding spacing.
          break;
      }
    }

    while (lyricLines.isNotEmpty && lyricLines.first.trim().isEmpty) {
      lyricLines.removeAt(0);
    }
    while (lyricLines.isNotEmpty && lyricLines.last.trim().isEmpty) {
      lyricLines.removeLast();
    }

    final cleanTitle = title?.trim() ?? '';
    final cleanKey = key?.trim() ?? '';
    return SongNote(
      title: cleanTitle.isEmpty ? untitledTitle : cleanTitle,
      artist: artist?.trim() ?? '',
      lyrics: lyricLines.join('\n'),
      key: cleanKey.isEmpty ? 'C' : cleanKey,
      bpm: bpm ?? 120,
      timestamp: 0,
      raga: raga?.trim() ?? '',
      tala: tala?.trim() ?? '',
      tradition: _naming.detect(raga: raga, tala: tala),
    );
  }

  /// Writes [song] out as ChordPro text.
  ///
  /// The four metadata directives come first, then a blank line, then the
  /// lyrics. When [semitones] is not zero the lyrics and the `{key}` are
  /// transposed with [ChordTransposer], so an export made while a transpose is
  /// active matches what the performer sees.
  String format(SongNote song, {int semitones = 0}) {
    final key = _transposer.transposeKey(song.key, semitones);
    final lyrics = _transposer.transposeLyrics(
      song.lyrics,
      semitones,
      song.key,
      isIndian: song.isIndian,
    );

    final out = StringBuffer();
    out.writeln('{title: ${song.title}}');
    if (song.artist.trim().isNotEmpty) {
      out.writeln('{artist: ${song.artist}}');
    }
    // An Indian sheet has a raga, not a key. Writing `{key: C}` on one is
    // meaningless, and on re-import it is the kind of stray Western marker that
    // makes the song look like a chord sheet. The PDF export already leaves it
    // out for the same reason.
    if (song.isIndian) {
      if (song.raga.trim().isNotEmpty) out.writeln('{raga: ${song.raga}}');
      if (song.tala.trim().isNotEmpty) out.writeln('{tala: ${song.tala}}');
    } else {
      out.writeln('{key: $key}');
    }
    out.writeln('{tempo: ${song.bpm}}');
    out.writeln();
    out.write(_withoutRagaAndTalaLines(lyrics));
    return out.toString();
  }

  /// Drops any `{raga: …}` / `{tala: …}` line from inside [lyrics].
  ///
  /// Songs written before those became columns still carry the header lines in
  /// their text. [format] now writes them from the columns, so leaving the old
  /// copies in would export each one twice.
  String _withoutRagaAndTalaLines(String lyrics) {
    final kept = normalizeLineEndings(lyrics)
        .split('\n')
        .where((line) => !_ragaOrTalaLine.hasMatch(line.trim()))
        .toList();
    while (kept.isNotEmpty && kept.first.trim().isEmpty) {
      kept.removeAt(0);
    }
    return kept.join('\n');
  }

  /// A whole line that is nothing but a `{raga: …}` or `{tala: …}` directive.
  static final RegExp _ragaOrTalaLine = RegExp(
    r'^\{\s*(raga|tala)\s*:[^{}]*\}$',
    caseSensitive: false,
  );

  /// Reads ChordPro [content] that may contain multiple songs separated by
  /// `{new_song}` / `{ns}` directives or separate `{title}` headers.
  List<SongNote> parseMultiple(
    String content, {
    String untitledTitle = defaultUntitledTitle,
  }) {
    final normalized = normalizeLineEndings(content);
    final lines = normalized.split('\n');
    final songs = <SongNote>[];

    var currentTitle = <String>[];
    var currentArtist = <String>[];
    var currentKey = <String>[];
    int? currentBpm;
    var currentRaga = <String>[];
    var currentTala = <String>[];
    var currentLyricLines = <String>[];
    var hasSongData = false;

    void flushCurrentSong() {
      if (!hasSongData && currentLyricLines.isEmpty && currentTitle.isEmpty) {
        return;
      }
      while (currentLyricLines.isNotEmpty &&
          currentLyricLines.first.trim().isEmpty) {
        currentLyricLines.removeAt(0);
      }
      while (currentLyricLines.isNotEmpty &&
          currentLyricLines.last.trim().isEmpty) {
        currentLyricLines.removeLast();
      }
      final titleStr = currentTitle.isNotEmpty ? currentTitle.last.trim() : '';
      final artistStr = currentArtist.isNotEmpty
          ? currentArtist.last.trim()
          : '';
      final keyStr = currentKey.isNotEmpty ? currentKey.last.trim() : '';
      final ragaStr = currentRaga.isNotEmpty ? currentRaga.last.trim() : '';
      final talaStr = currentTala.isNotEmpty ? currentTala.last.trim() : '';

      songs.add(
        SongNote(
          title: titleStr.isEmpty ? untitledTitle : titleStr,
          artist: artistStr,
          lyrics: currentLyricLines.join('\n'),
          key: keyStr.isEmpty ? 'C' : keyStr,
          bpm: currentBpm ?? 120,
          timestamp: 0,
          raga: ragaStr,
          tala: talaStr,
          tradition: _naming.detect(raga: ragaStr, tala: talaStr),
        ),
      );

      currentTitle = <String>[];
      currentArtist = <String>[];
      currentKey = <String>[];
      currentBpm = null;
      currentRaga = <String>[];
      currentTala = <String>[];
      currentLyricLines = <String>[];
      hasSongData = false;
    }

    for (final line in lines) {
      final directive = _matchDirective(line);
      if (directive == null) {
        if (line.trim().isNotEmpty) {
          hasSongData = true;
        }
        currentLyricLines.add(line);
        continue;
      }

      switch (directive.name) {
        case 'new_song':
        case 'ns':
          flushCurrentSong();
        case 'title':
        case 't':
          if (hasSongData ||
              currentLyricLines.any((l) => l.trim().isNotEmpty) ||
              currentTitle.isNotEmpty) {
            flushCurrentSong();
          }
          currentTitle.add(directive.value);
          hasSongData = true;
        case 'artist':
        case 'a':
          currentArtist.add(directive.value);
          hasSongData = true;
        case 'key':
        case 'k':
          currentKey.add(directive.value);
          hasSongData = true;
        case 'bpm':
        case 'tempo':
          currentBpm = int.tryParse(directive.value.trim()) ?? currentBpm;
          hasSongData = true;
        case 'raga':
          currentRaga.add(directive.value);
          hasSongData = true;
        case 'tala':
          currentTala.add(directive.value);
          hasSongData = true;
        case 'comment':
        case 'c':
          currentLyricLines.add(directive.value);
          hasSongData = true;
        case 'melody':
        case 'tonic':
          // Same reasoning as in [parse]: both stay inside the lyrics so the
          // tune keeps its place beside the words it belongs to.
          currentLyricLines.add(line);
          hasSongData = true;
        default:
          break;
      }
    }

    flushCurrentSong();

    return songs.isEmpty
        ? [parse(content, untitledTitle: untitledTitle)]
        : songs;
  }

  /// Formats multiple [songs] into a single ChordPro text bundle.
  String formatMultiple(List<SongNote> songs, {int semitones = 0}) {
    if (songs.isEmpty) return '';
    return songs
        .map((song) => format(song, semitones: semitones))
        .join('\n\n{new_song}\n\n');
  }

  /// Reads one `{name: value}` directive, or `null` for a normal lyric line.
  ///
  /// A directive is a line that (after trimming) is wrapped in `{ }`. The name
  /// is everything before the first `:`; the value is the rest, so a comment
  /// may itself contain colons.
  _Directive? _matchDirective(String line) {
    final text = line.trim();
    if (text.length < 2 || !text.startsWith('{') || !text.endsWith('}')) {
      return null;
    }
    final inner = text.substring(1, text.length - 1);
    final colon = inner.indexOf(':');
    final name = (colon < 0 ? inner : inner.substring(0, colon))
        .trim()
        .toLowerCase();
    final value = colon < 0 ? '' : inner.substring(colon + 1).trim();
    return _Directive(name, value);
  }

  /// Normalizes all forms of line endings to standard Unix `\n`.
  static String normalizeLineEndings(String content) =>
      normalizeLineBreaks(content);
}
