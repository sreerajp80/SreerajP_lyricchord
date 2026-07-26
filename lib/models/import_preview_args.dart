import 'package:lyricchord/models/song_note.dart';

/// Payload passed to [ImportPreviewScreen] when opening a .chordpro file.
class ImportPreviewArgs {
  final String fileName;
  final String rawContent;
  final List<SongNote> parsedSongs;

  const ImportPreviewArgs({
    required this.fileName,
    required this.rawContent,
    required this.parsedSongs,
  });
}
