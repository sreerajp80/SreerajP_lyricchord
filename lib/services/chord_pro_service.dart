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

import 'package:lyricchord/models/song_note.dart';
import 'package:lyricchord/services/chord_transposer.dart';

/// A `{name: value}` directive line pulled from a ChordPro file.
class _Directive {
  final String name;
  final String value;

  const _Directive(this.name, this.value);
}

/// Parses ChordPro text into a [SongNote] and formats a [SongNote] back out.
class ChordProService {
  const ChordProService();

  static const ChordTransposer _transposer = ChordTransposer();

  /// Reads ChordPro [content] into a new [SongNote].
  ///
  /// The returned song has id `0` and `timestamp` `0`; the caller stamps the
  /// real time when it saves. Understood directives:
  /// - `{title|t: ...}` → title (defaults to "Untitled Song").
  /// - `{artist|a: ...}` → artist.
  /// - `{key|k: ...}` → key (defaults to `C`).
  /// - `{bpm|tempo: ...}` → bpm (keeps `120` if not a whole number).
  /// - `{comment|c: ...}` → kept as a plain lyric line (its text).
  ///
  /// Chorus/verse markers (`soc`/`eoc`/`sov`/`eov`) and any other directive are
  /// skipped. Every other line is a lyric line, kept exactly. Leading and
  /// trailing blank lyric lines are trimmed so an export/import round-trip is
  /// exact.
  SongNote parse(String content) {
    String? title;
    String? artist;
    String? key;
    int? bpm;
    final lyricLines = <String>[];

    final normalized = content.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
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
        case 'comment':
        case 'c':
          lyricLines.add(directive.value);
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
      title: cleanTitle.isEmpty ? 'Untitled Song' : cleanTitle,
      artist: artist?.trim() ?? '',
      lyrics: lyricLines.join('\n'),
      key: cleanKey.isEmpty ? 'C' : cleanKey,
      bpm: bpm ?? 120,
      timestamp: 0,
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
    );

    final out = StringBuffer();
    out.writeln('{title: ${song.title}}');
    if (song.artist.trim().isNotEmpty) {
      out.writeln('{artist: ${song.artist}}');
    }
    out.writeln('{key: $key}');
    out.writeln('{tempo: ${song.bpm}}');
    out.writeln();
    out.write(lyrics);
    return out.toString();
  }

  /// Reads ChordPro [content] that may contain multiple songs separated by
  /// `{new_song}` / `{ns}` directives or separate `{title}` headers.
  List<SongNote> parseMultiple(String content) {
    final normalized = content.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
    final lines = normalized.split('\n');
    final songs = <SongNote>[];

    var currentTitle = <String>[];
    var currentArtist = <String>[];
    var currentKey = <String>[];
    int? currentBpm;
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

      songs.add(
        SongNote(
          title: titleStr.isEmpty ? 'Untitled Song' : titleStr,
          artist: artistStr,
          lyrics: currentLyricLines.join('\n'),
          key: keyStr.isEmpty ? 'C' : keyStr,
          bpm: currentBpm ?? 120,
          timestamp: 0,
        ),
      );

      currentTitle = <String>[];
      currentArtist = <String>[];
      currentKey = <String>[];
      currentBpm = null;
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
        case 'comment':
        case 'c':
          currentLyricLines.add(directive.value);
          hasSongData = true;
        default:
          break;
      }
    }

    flushCurrentSong();

    return songs.isEmpty ? [parse(content)] : songs;
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
}
