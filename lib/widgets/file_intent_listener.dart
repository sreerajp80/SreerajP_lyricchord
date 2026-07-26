import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lyricchord/core/router/app_router.dart';
import 'package:lyricchord/models/import_preview_args.dart';
import 'package:lyricchord/services/chord_pro_service.dart';

/// Service listening for incoming Android file intents (.chordpro files).
class FileIntentListener extends ConsumerStatefulWidget {
  final Widget child;

  const FileIntentListener({super.key, required this.child});

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

  Future<void> _checkInitialFile() async {
    try {
      final fileData = await _channel.invokeMethod<Map>('getInitialFile');
      if (fileData != null) {
        await _processFileIntent(Map<String, String>.from(fileData));
      }
    } catch (_) {}
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    if (call.method == 'onFileOpened') {
      if (call.arguments != null) {
        final fileData = Map<String, String>.from(call.arguments as Map);
        await _processFileIntent(fileData);
      }
    }
  }

  Future<void> _processFileIntent(Map<String, String> fileData) async {
    final content = fileData['content'];
    final fileName = fileData['fileName'] ?? 'imported.chordpro';
    if (content == null || content.trim().isEmpty) return;

    const chordProService = ChordProService();
    final parsedSongs = chordProService.parseMultiple(content);
    if (parsedSongs.isEmpty) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final router = ref.read(goRouterProvider);
      router.push(
        '/import-preview',
        extra: ImportPreviewArgs(
          fileName: fileName,
          rawContent: content,
          parsedSongs: parsedSongs,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
