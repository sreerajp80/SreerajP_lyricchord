import 'dart:convert';
import 'dart:io';
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
import 'package:lyricchord/screens/air_qr_transmitter_screen.dart';

/// Settings → Import & Export.
class ImportExportScreen extends ConsumerWidget {
  const ImportExportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Import & Export')),
      body: SafeArea(
        child: ListView(
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
            ListTile(
              leading: const Icon(
                Icons.qr_code_scanner_rounded,
                color: Colors.cyan,
              ),
              title: const Text('AirQR Scan Import (Camera / Photo)'),
              subtitle: const Text(
                'Scan an animated QR song stream from a bandmate\'s screen.',
              ),
              onTap: () => context.push('/air-qr-receive'),
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
            ListTile(
              leading: const Icon(
                Icons.qr_code_2_rounded,
                color: Colors.purple,
              ),
              title: const Text('Export all songs via AirQR Stream'),
              subtitle: const Text(
                'Broadcast entire songbook as an animated QR stream.',
              ),
              onTap: () => _exportAllAirQr(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  /// Picks ChordPro/text files, parses into songs, and launches import preview.
  Future<void> _importChordPro(BuildContext context, WidgetRef ref) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['cho', 'pro', 'chordpro', 'txt'],
        allowMultiple: true,
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;

      final validFiles = result.files.where((file) {
        final ext = file.extension?.toLowerCase() ?? '';
        final name = file.name.toLowerCase();
        return ext == 'cho' ||
            ext == 'pro' ||
            ext == 'chordpro' ||
            ext == 'txt' ||
            name.endsWith('.cho') ||
            name.endsWith('.pro') ||
            name.endsWith('.chordpro') ||
            name.endsWith('.txt');
      }).toList();

      if (validFiles.isEmpty) {
        throw const ImportException(
          'Only .cho, .pro, .chordpro, and .txt files can be imported.',
        );
      }

      final allParsedSongs = <SongNote>[];
      final combinedContent = StringBuffer();
      String firstFileName = 'imported.chordpro';

      for (var i = 0; i < validFiles.length; i++) {
        final file = validFiles[i];
        if (i == 0) firstFileName = file.name;
        var bytes = file.bytes;
        if (bytes == null && file.path != null) {
          try {
            bytes = File(file.path!).readAsBytesSync();
          } catch (_) {}
        }
        if (bytes == null) continue;
        final content = decodeImportedBytes(bytes);
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
          fileName: validFiles.length == 1
              ? firstFileName
              : '${validFiles.length} files selected',
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
        type: FileType.custom,
        allowedExtensions: const ['chordpro'],
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

  Future<void> _exportAllAirQr(BuildContext context, WidgetRef ref) async {
    try {
      final songs = await ref.read(songRepositoryProvider).getAllSongs();
      if (songs.isEmpty) {
        if (context.mounted) _showSnack(context, 'No songs to share.');
        return;
      }
      const service = ChordProService();
      final text = service.formatMultiple(songs);
      if (context.mounted) {
        context.push(
          '/air-qr-transmit',
          extra: AirQrTransmitterArgs(
            title: 'Full Songbook (${songs.length} songs)',
            chordProPayload: text,
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        _showSnack(context, 'Could not prepare AirQR export.');
      }
    }
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

/// Decodes file bytes into a string, supporting UTF-8 (with BOM stripping)
/// and UTF-16 (little-endian and big-endian).
String decodeImportedBytes(Uint8List bytes) {
  // UTF-16 LE BOM (FF FE)
  if (bytes.length >= 2 && bytes[0] == 0xFF && bytes[1] == 0xFE) {
    return String.fromCharCodes(
      Uint16List.view(
        bytes.buffer,
        bytes.offsetInBytes + 2,
        (bytes.length - 2) ~/ 2,
      ),
    );
  }
  // UTF-16 BE BOM (FE FF)
  if (bytes.length >= 2 && bytes[0] == 0xFE && bytes[1] == 0xFF) {
    final length = (bytes.length - 2) ~/ 2;
    final u16 = Uint16List(length);
    for (var i = 0; i < length; i++) {
      final offset = 2 + (i * 2);
      u16[i] = (bytes[offset] << 8) | bytes[offset + 1];
    }
    return String.fromCharCodes(u16);
  }
  // UTF-8 with optional BOM stripping
  var decoded = utf8.decode(bytes, allowMalformed: true);
  if (decoded.startsWith('\uFEFF')) {
    decoded = decoded.substring(1);
  }
  return decoded;
}
