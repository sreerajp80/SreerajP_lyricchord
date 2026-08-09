import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

/// Result of local biometric or device authentication.
enum StageAuthOutcome { success, failure, canceled, notAvailable, error }

class StageAuthResult {
  final StageAuthOutcome outcome;
  final String? message;

  const StageAuthResult(this.outcome, {this.message});

  bool get isSuccess => outcome == StageAuthOutcome.success;
}

/// Local authentication service for Stage Security (Stage Lock Mode).
///
/// Leverages `local_auth` hardware biometrics and device screen lock PIN/Pattern/Password,
/// following the security architecture of SreerajP_Authenticator
/// (https://github.com/sreerajp80/sreerajp_authenticator).
class StageSecurityService {
  final LocalAuthentication _localAuth;

  StageSecurityService({LocalAuthentication? localAuth})
    : _localAuth = localAuth ?? LocalAuthentication();

  /// Checks whether biometric or device PIN/Pattern security is available.
  Future<bool> isSecurityAvailable() async {
    try {
      final isSupported = await _localAuth.isDeviceSupported();
      if (!isSupported) return false;
      final canCheck = await _localAuth.canCheckBiometrics;
      return canCheck || isSupported;
    } catch (_) {
      return false;
    }
  }

  /// Prompts the user to authenticate using biometric or device PIN/Pattern.
  Future<StageAuthResult> authenticate({
    String reason = 'Authenticate to unlock Stage View',
  }) async {
    try {
      final isAvailable = await isSecurityAvailable();
      if (!isAvailable) {
        return const StageAuthResult(
          StageAuthOutcome.notAvailable,
          message: 'Device security features (biometric/PIN) not available.',
        );
      }

      final authenticated = await _localAuth.authenticate(
        localizedReason: reason,
        biometricOnly: false,
        persistAcrossBackgrounding: true,
      );

      return StageAuthResult(
        authenticated ? StageAuthOutcome.success : StageAuthOutcome.failure,
      );
    } on PlatformException catch (e) {
      final code = e.code.toLowerCase();
      if (code.contains('cancel')) {
        return const StageAuthResult(StageAuthOutcome.canceled);
      }
      if (code.contains('notenrolled') ||
          code.contains('notavailable') ||
          code.contains('passcodenotset') ||
          code.contains('notsupported')) {
        return StageAuthResult(
          StageAuthOutcome.notAvailable,
          message: e.message,
        );
      }
      return StageAuthResult(StageAuthOutcome.error, message: e.message);
    } catch (e) {
      return StageAuthResult(StageAuthOutcome.error, message: e.toString());
    }
  }
}

final stageSecurityServiceProvider = Provider<StageSecurityService>((ref) {
  return StageSecurityService();
});
