import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lyricchord/core/constants/app_constants.dart';
import 'package:lyricchord/core/router/app_router.dart';
import 'package:lyricchord/core/utils/text_decoding.dart';
import 'package:lyricchord/l10n/app_localizations.dart';
import 'package:lyricchord/models/import_preview_args.dart';
import 'package:lyricchord/models/song_note.dart';
import 'package:lyricchord/services/chord_pro_service.dart';

/// Why a file handed to the app could not be imported.
enum FileIntentProblem { tooLarge, unreadable, noSongs }

/// What a file-open message from the platform turned into.
///
/// Either [args] (ready for the import preview) or [problem] is set, or
/// neither when there was nothing to do.
class FileIntentOutcome {
  const FileIntentOutcome._({this.args, this.problem, this.fileName = ''});

  static const FileIntentOutcome nothing = FileIntentOutcome._();

  final ImportPreviewArgs? args;
  final FileIntentProblem? problem;
  final String fileName;
}

/// Service listening for incoming Android file intents (.chordpro files).
class FileIntentListener extends ConsumerStatefulWidget {
  final Widget child;

  const FileIntentListener({super.key, required this.child});

  /// Turns the platform's file data into an import preview or a problem.
  ///
  /// The Android side sends `fileName` plus either `bytes` (the raw file, at
  /// most [AppConstants.maxImportFileBytes]) or `error` (`too_large` /
  /// `unreadable`). An older `content` string is still accepted. Never throws:
  /// the file is untrusted input (CLAUDE.md hard rule 4). A song with no
  /// title is named [untitledTitle].
  static FileIntentOutcome readPayload(
    Map<Object?, Object?>? data, {
    String untitledTitle = ChordProService.defaultUntitledTitle,
  }) {
    if (data == null) return FileIntentOutcome.nothing;
    final rawName = data['fileName'];
    final fileName = rawName is String && rawName.trim().isNotEmpty
        ? rawName
        : 'imported.chordpro';

    FileIntentOutcome problem(FileIntentProblem p) =>
        FileIntentOutcome._(problem: p, fileName: fileName);

    try {
      final error = data['error'];
      if (error == 'too_large') return problem(FileIntentProblem.tooLarge);
      if (error != null) return problem(FileIntentProblem.unreadable);

      final bytes = data['bytes'];
      final String content;
      if (bytes is Uint8List) {
        if (bytes.length > AppConstants.maxImportFileBytes) {
          return problem(FileIntentProblem.tooLarge);
        }
        // A photo or other binary file is not a song sheet.
        if (looksLikeBinary(bytes)) {
          return problem(FileIntentProblem.unreadable);
        }
        content = decodeImportedBytes(bytes);
      } else if (data['content'] is String) {
        content = data['content']! as String;
        if (content.length > AppConstants.maxImportFileBytes) {
          return problem(FileIntentProblem.tooLarge);
        }
      } else {
        return problem(FileIntentProblem.unreadable);
      }

      if (content.trim().isEmpty) return problem(FileIntentProblem.noSongs);
      final List<SongNote> parsedSongs = const ChordProService().parseMultiple(
        content,
        untitledTitle: untitledTitle,
      );
      if (parsedSongs.isEmpty) return problem(FileIntentProblem.noSongs);

      return FileIntentOutcome._(
        fileName: fileName,
        args: ImportPreviewArgs(
          fileName: fileName,
          rawContent: content,
          parsedSongs: parsedSongs,
        ),
      );
    } catch (_) {
      return problem(FileIntentProblem.unreadable);
    }
  }

  @override
  ConsumerState<FileIntentListener> createState() => _FileIntentListenerState();
}

class _FileIntentListenerState extends ConsumerState<FileIntentListener> {
  static const MethodChannel _channel = MethodChannel(
    'in.sreerajp.lyricchord/file_intent',
  );

  @override
  void initState() {
    super.initState();
    _channel.setMethodCallHandler(_handleMethodCall);
    _checkInitialFile();
  }

  @override
  void dispose() {
    _channel.setMethodCallHandler(null);
    super.dispose();
  }

  Future<void> _checkInitialFile() async {
    try {
      final fileData = await _channel.invokeMethod<Map<Object?, Object?>>(
        'getInitialFile',
      );
      _process(fileData);
    } catch (_) {
      // No platform side (iOS / tests) or nothing to open.
    }
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    if (call.method == 'onFileOpened' && call.arguments is Map) {
      _process(call.arguments as Map<Object?, Object?>);
    }
  }

  void _process(Map<Object?, Object?>? fileData) {
    if (fileData == null) return;

    // Parsed after the frame, where the localizations can be read: a song
    // with no title is saved under the user's own word for "Untitled Song".
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final outcome = FileIntentListener.readPayload(
        fileData,
        untitledTitle: AppLocalizations.of(context).labelUntitledSong,
      );
      if (outcome.args == null && outcome.problem == null) return;
      final args = outcome.args;
      if (args != null) {
        ref.read(goRouterProvider).push('/import-preview', extra: args);
        return;
      }
      _showProblem(outcome.problem!, outcome.fileName);
    });
  }

  void _showProblem(FileIntentProblem problem, String fileName) {
    final messenger = rootScaffoldMessengerKey.currentState;
    if (messenger == null) return;
    final l10n = AppLocalizations.of(context);
    final message = switch (problem) {
      FileIntentProblem.tooLarge => l10n.errorImportFileTooLarge(
        fileName,
        AppConstants.maxImportFileBytes ~/ (1024 * 1024),
      ),
      FileIntentProblem.unreadable => l10n.errorImportFileUnreadable(fileName),
      FileIntentProblem.noSongs => l10n.errorImportNoSongsFound(fileName),
    };
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
