import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Stage Quiet Mode service for silencing incoming call ringers and notification chimes
/// during stage performance, preserving media playback for pitch drones and metronomes.
///
/// Leverages native AudioManager channels adapted from SreerajPContactSphere.
class StageQuietModeService {
  static const MethodChannel _channel = MethodChannel(
    'in.sreerajp.lyricchord/quiet_mode',
  );

  bool _isQuietActive = false;

  bool get isQuietActive => _isQuietActive;

  /// Mutes incoming call ringer and notification alerts.
  Future<bool> enableQuietMode() async {
    try {
      final result = await _channel.invokeMethod<bool>('enableQuietMode');
      _isQuietActive = result ?? false;
      return _isQuietActive;
    } catch (_) {
      _isQuietActive = false;
      return false;
    }
  }

  /// Restores previous ringer mode and notification alert settings.
  Future<bool> disableQuietMode() async {
    try {
      final result = await _channel.invokeMethod<bool>('disableQuietMode');
      _isQuietActive = false;
      return result ?? true;
    } catch (_) {
      _isQuietActive = false;
      return false;
    }
  }
}

final stageQuietModeServiceProvider = Provider<StageQuietModeService>((ref) {
  return StageQuietModeService();
});
