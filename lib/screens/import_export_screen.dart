import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:lyricchord/core/errors/app_exception.dart';
import 'package:lyricchord/models/import_preview_args.dart';
import 'package:lyricchord/models/song_note.dart';
import 'package:lyricchord/providers/database_provider.dart';
import 'package:lyricchord/services/chord_pro_service.dart';

/// Settings → Import & Export.
class ImportExportScreen extends ConsumerWidget {
  const ImportExportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Import & Export')),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Import',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.file_open_outlined),
            title: const Text('Import ChordPro file(s)'),
            subtitle: const Text(
              'Pick one or more .cho, .pro, or text files to add songs.',
            ),
            onTap: () => _importChordPro(context, ref),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Export',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.output_rounded),
            title: const Text('Export all songs (ChordPro)'),
            subtitle: const Text(
              'Save your entire songbook as a single ChordPro file.',
            ),
            onTap: () => _exportAllChordPro(context, ref),
          ),
        ],
      ),
    );
  }

  /// Picks ChordPro/text files, parses into songs, and launches import preview.
  Future<void> _importChordPro(BuildContext context, WidgetRef ref) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;

      final allParsedSongs = <SongNote>[];
      final combinedContent = StringBuffer();
      String firstFileName = 'imported.chordpro';

      for (var i = 0; i < result.files.length; i++) {
        final file = result.files[i];
        if (i == 0) firstFileName = file.name;
        final bytes = file.bytes;
        if (bytes == null) continue;
        final content = utf8.decode(bytes, allowMalformed: true);
        combinedContent.writeln(content);
        combinedContent.writeln('\n{new_song}\n');
        final parsed = const ChordProService().parseMultiple(content);
        allParsedSongs.addAll(parsed);
      }

      if (allParsedSongs.isEmpty) {
        throw const ImportException('Could not read any chosen files.');
      }

      if (!context.mounted) return;

      context.push(
        '/import-preview',
        extra: ImportPreviewArgs(
          fileName: result.files.length == 1
              ? firstFileName
              : '${result.files.length} files selected',
          rawContent: combinedContent.toString(),
          parsedSongs: allParsedSongs,
        ),
      );
    } on AppException catch (e) {
      if (context.mounted) _showSnack(context, e.message);
    } catch (_) {
      if (context.mounted) _showSnack(context, 'Could not import the files.');
    }
  }

  /// Exports all songs into a single ChordPro file.
  Future<void> _exportAllChordPro(BuildContext context, WidgetRef ref) async {
    try {
      final songs = await ref.read(songRepositoryProvider).getAllSongs();
      if (songs.isEmpty) {
        if (context.mounted) _showSnack(context, 'No songs to export.');
        return;
      }

      const service = ChordProService();
      final text = service.formatMultiple(songs);
      final path = await FilePicker.platform.saveFile(
        dialogTitle: 'Export all songs as ChordPro',
        fileName: 'lyricchord_all_songs.chordpro',
        bytes: Uint8List.fromList(utf8.encode(text)),
      );
      if (context.mounted && path != null) {
        _showSnack(context, 'Exported ${songs.length} song(s).');
      }
    } catch (_) {
      if (context.mounted) {
        _showSnack(context, 'Could not export songs.');
      }
    }
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
