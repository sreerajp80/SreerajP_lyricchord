import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// What happened when Stage Quiet Mode was asked to silence the phone.
enum QuietModeResult {
  /// The ringer is now silent.
  on,

  /// Android needs "Do Not Disturb access" for LyricChord first.
  needsAccess,

  /// This platform cannot change the ringer (iOS does not allow it).
  unsupported,

  /// Android refused for another reason.
  failed,
}

/// Stage Quiet Mode service for silencing incoming call ringers and notification chimes
/// during stage performance, preserving media playback for pitch drones and metronomes.
///
/// Leverages native AudioManager channels adapted from SreerajPContactSphere.
/// The Android side saves the previous ringer mode to disk before changing it,
/// so it is put back even if the app is killed while quiet.
class StageQuietModeService {
  static const MethodChannel _channel = MethodChannel(
    'in.sreerajp.lyricchord/quiet_mode',
  );

  bool _isQuietActive = false;

  bool get isQuietActive => _isQuietActive;

  /// Whether this platform can silence the ringer at all.
  bool get isSupported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  /// Mutes incoming call ringer and notification alerts.
  Future<QuietModeResult> enableQuietMode() async {
    if (!isSupported) return QuietModeResult.unsupported;
    try {
      final status = await _channel.invokeMethod<String>('enableQuietMode');
      final result = switch (status) {
        'ok' => QuietModeResult.on,
        'needs_access' => QuietModeResult.needsAccess,
        _ => QuietModeResult.failed,
      };
      _isQuietActive = result == QuietModeResult.on;
      return result;
    } on MissingPluginException {
      _isQuietActive = false;
      return QuietModeResult.unsupported;
    } catch (_) {
      _isQuietActive = false;
      return QuietModeResult.failed;
    }
  }

  /// Restores previous ringer mode and notification alert settings.
  Future<bool> disableQuietMode() async {
    if (!isSupported) {
      _isQuietActive = false;
      return true;
    }
    try {
      final result = await _channel.invokeMethod<bool>('disableQuietMode');
      _isQuietActive = false;
      return result ?? true;
    } catch (_) {
      _isQuietActive = false;
      return false;
    }
  }

  /// Opens the system page where the user grants Do Not Disturb access.
  Future<bool> openAccessSettings() async {
    if (!isSupported) return false;
    try {
      return await _channel.invokeMethod<bool>('openQuietModeAccessSettings') ??
          false;
    } catch (_) {
      return false;
    }
  }
}

final stageQuietModeServiceProvider = Provider<StageQuietModeService>((ref) {
  return StageQuietModeService();
});
