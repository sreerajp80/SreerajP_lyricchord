import 'package:flutter/services.dart';

/// Hiding and restoring the phone's system bars for Stage Mode.
///
/// Kept in one small place on purpose. Leaving the bars hidden would strand the
/// user in an app with no way out, so every call to [enterImmersive] must have a
/// matching [exitImmersive] — the performance screen pairs them in `dispose`
/// and on app pause as well as when Stage Mode is switched off.
class SystemUi {
  const SystemUi._();

  /// Hides the status and navigation bars.
  ///
  /// `immersiveSticky` means a swipe from an edge shows the bars for a moment
  /// and then hides them again on its own, so a stray touch mid-song does not
  /// leave the chrome on screen.
  static Future<void> enterImmersive() {
    return SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  /// Puts the system bars back the way the rest of the app expects them.
  static Future<void> exitImmersive() {
    return SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: SystemUiOverlay.values,
    );
  }
}
