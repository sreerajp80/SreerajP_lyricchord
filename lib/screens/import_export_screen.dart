import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:lyriccord/core/errors/app_exception.dart';
import 'package:lyriccord/providers/database_provider.dart';
import 'package:lyriccord/services/chord_pro_service.dart';

/// Settings → Import.
///
/// Import lives here: pick a ChordPro/text file, parse it into a song, save
/// it, and open it. Export stays per song on the song screen (share / PDF).
class ImportExportScreen extends ConsumerWidget {
  const ImportExportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Import')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.file_open_outlined),
            title: const Text('Import ChordPro file'),
            subtitle: const Text(
              'Pick a .cho, .pro, or plain text file to add it as a song.',
            ),
            onTap: () => _importChordPro(context, ref),
          ),
        ],
      ),
    );
  }

  /// Picks a ChordPro/text file, parses it into a song, saves it, and opens it.
  ///
  /// All IO lives here at the screen edge: the parser stays pure. A bad file
  /// never touches the database — parsing cannot throw, and any read/save
  /// failure is shown as a `SnackBar` (CLAUDE.md hard rule 4).
  Future<void> _importChordPro(BuildContext context, WidgetRef ref) async {
    try {
      final result = await FilePicker.platform.pickFiles(withData: true);
      // The user cancelled the picker.
      if (result == null || result.files.isEmpty) return;

      final bytes = result.files.first.bytes;
      if (bytes == null) {
        throw const ImportException('Could not read the chosen file.');
      }

      const service = ChordProService();
      final song = service
          .parse(utf8.decode(bytes, allowMalformed: true))
          .copyWith(timestamp: DateTime.now().millisecondsSinceEpoch);
      final id = await ref.read(songRepositoryProvider).insert(song);

      if (!context.mounted) return;
      _showSnack(context, 'Imported "${song.title}".');
      context.push('/song/$id');
    } on AppException catch (e) {
      if (context.mounted) _showSnack(context, e.message);
    } catch (_) {
      if (context.mounted) _showSnack(context, 'Could not import the file.');
    }
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
