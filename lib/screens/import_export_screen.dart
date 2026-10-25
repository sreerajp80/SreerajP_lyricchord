import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:lyricchord/core/constants/app_constants.dart';
import 'package:lyricchord/core/errors/app_exception.dart';
import 'package:lyricchord/core/utils/text_decoding.dart';
import 'package:lyricchord/l10n/app_localizations.dart';
import 'package:lyricchord/l10n/l10n_labels.dart';
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
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.titleImportExport)),
      body: SafeArea(
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                l10n.titleGeneralImport,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.file_open_outlined),
              title: Text(l10n.labelImportExportPickFiles),
              subtitle: Text(l10n.descImportExportPickFilesSubtitle),
              onTap: () => _importChordPro(context, ref),
            ),
            ListTile(
              leading: const Icon(
                Icons.qr_code_scanner_rounded,
                color: Colors.cyan,
              ),
              title: Text(l10n.labelImportExportScan),
              subtitle: Text(l10n.descImportExportScanSubtitle),
              onTap: () => context.push('/air-qr-receive'),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                l10n.actionExport,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.output_rounded),
              title: Text(l10n.labelImportExportAllChordPro),
              subtitle: Text(l10n.descImportExportAllChordProSubtitle),
              onTap: () => _exportAllChordPro(context, ref),
            ),
            ListTile(
              leading: const Icon(
                Icons.qr_code_2_rounded,
                color: Colors.purple,
              ),
              title: Text(l10n.labelImportExportAllAirQr),
              subtitle: Text(l10n.descImportExportAllAirQrSubtitle),
              onTap: () => _exportAllAirQr(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  /// Picks ChordPro/text files, parses into songs, and launches import preview.
  Future<void> _importChordPro(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    try {
      // Picks several files by default; an empty list means the user cancelled.
      final picked = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['cho', 'pro', 'chordpro', 'txt'],
      );
      if (picked.isEmpty) return;

      final validFiles = picked.where((file) {
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
        throw ImportException(l10n.errorImportExportWrongType);
      }

      final allParsedSongs = <SongNote>[];
      final combinedContent = StringBuffer();
      String firstFileName = 'imported.chordpro';
      final tooLarge = <String>[];
      final unreadable = <String>[];

      for (var i = 0; i < validFiles.length; i++) {
        final file = validFiles[i];
        if (i == 0) firstFileName = file.name;
        Uint8List? bytes;
        try {
          // The size the picker reported, or the real size read from the file
          // when the picker did not report one. Null means it is unknown.
          final size = file.lengthSync() ?? await file.length();
          if (size != null && size > AppConstants.maxImportFileBytes) {
            tooLarge.add(file.name);
            continue;
          }
          bytes = await file.readAsBytes();
        } catch (_) {
          bytes = null;
        }
        // A photo or other binary file is not a song sheet.
        if (bytes == null || looksLikeBinary(bytes)) {
          unreadable.add(file.name);
          continue;
        }
        final content = decodeImportedBytes(bytes);
        combinedContent.writeln(content);
        combinedContent.writeln('\n{new_song}\n');
        final parsed = const ChordProService().parseMultiple(
          content,
          untitledTitle: l10n.labelUntitledSong,
        );
        allParsedSongs.addAll(parsed);
      }

      if (tooLarge.isNotEmpty && context.mounted) {
        _showSnack(
          context,
          AppLocalizations.of(context).errorImportFilesSkippedTooLarge(
            AppConstants.maxImportFileBytes ~/ (1024 * 1024),
            tooLarge.join(', '),
          ),
        );
      }

      if (unreadable.isNotEmpty && context.mounted) {
        _showSnack(
          context,
          AppLocalizations.of(
            context,
          ).errorImportFilesSkippedUnreadable(unreadable.join(', ')),
        );
      }

      if (allParsedSongs.isEmpty) {
        if (tooLarge.isNotEmpty || unreadable.isNotEmpty) return;
        throw ImportException(l10n.errorImportExportNothingRead);
      }

      if (!context.mounted) return;

      context.push(
        '/import-preview',
        extra: ImportPreviewArgs(
          fileName: validFiles.length == 1
              ? firstFileName
              : l10n.descImportExportFilesSelected(validFiles.length),
          rawContent: combinedContent.toString(),
          parsedSongs: allParsedSongs,
        ),
      );
    } on AppException catch (e) {
      if (context.mounted) {
        _showSnack(context, e.text(AppLocalizations.of(context)));
      }
    } catch (_) {
      if (context.mounted) {
        _showSnack(context, l10n.errorImportExportImportFailed);
      }
    }
  }

  /// Exports all songs into a single ChordPro file.
  Future<void> _exportAllChordPro(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    try {
      final songs = await ref.read(songRepositoryProvider).getAllSongs();
      if (songs.isEmpty) {
        if (context.mounted) {
          _showSnack(context, l10n.bodyImportExportNoSongsToExport);
        }
        return;
      }

      const service = ChordProService();
      final text = service.formatMultiple(songs);
      final savedUri = await FilePicker.saveFile(
        dialogTitle: l10n.titleImportExportAllDialog,
        fileName: 'lyricchord_all_songs.chordpro',
        bytes: Uint8List.fromList(utf8.encode(text)),
      );
      if (context.mounted && savedUri != null) {
        _showSnack(context, l10n.bodyImportExportExported(songs.length));
      }
    } catch (_) {
      if (context.mounted) {
        _showSnack(context, l10n.errorImportExportExportFailed);
      }
    }
  }

  Future<void> _exportAllAirQr(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    try {
      final songs = await ref.read(songRepositoryProvider).getAllSongs();
      if (songs.isEmpty) {
        if (context.mounted) {
          _showSnack(context, l10n.bodyImportExportNoSongsToShare);
        }
        return;
      }
      const service = ChordProService();
      final text = service.formatMultiple(songs);
      if (context.mounted) {
        context.push(
          '/air-qr-transmit',
          extra: AirQrTransmitterArgs(
            title: l10n.titleImportExportFullSongbook(songs.length),
            chordProPayload: text,
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        _showSnack(context, l10n.errorImportExportAirQrFailed);
      }
    }
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
