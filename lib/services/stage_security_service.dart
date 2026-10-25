import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

/// Result of local biometric or device authentication.
///
/// Only [failure] and [canceled] mean "the person did not unlock". Every other
/// non-success outcome means the check could not run at all, and the caller
/// must not keep the user locked out because of it.
enum StageAuthOutcome { success, failure, canceled, notAvailable, error }

class StageAuthResult {
  final StageAuthOutcome outcome;
  final String? message;

  const StageAuthResult(this.outcome, {this.message});

  bool get isSuccess => outcome == StageAuthOutcome.success;

  /// True when the person was asked and did not pass (wrong finger, or backed
  /// out of the prompt). False for success and for "could not ask at all".
  bool get isDenied =>
      outcome == StageAuthOutcome.failure ||
      outcome == StageAuthOutcome.canceled;
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
        persistAcrossBackgrounding: true,
      );

      return StageAuthResult(
        authenticated ? StageAuthOutcome.success : StageAuthOutcome.failure,
      );
    } on LocalAuthException catch (e) {
      // local_auth 3.x reports failures this way.
      return StageAuthResult(
        outcomeForLocalAuthCode(e.code),
        message: e.description,
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

  /// Maps a `local_auth` error code to a [StageAuthOutcome].
  ///
  /// The person backing out (or the system closing the prompt) is
  /// [StageAuthOutcome.canceled]. No enrolled lock, no hardware, or a lockout
  /// is [StageAuthOutcome.notAvailable]. Anything else is
  /// [StageAuthOutcome.error].
  static StageAuthOutcome outcomeForLocalAuthCode(LocalAuthExceptionCode code) {
    switch (code) {
      case LocalAuthExceptionCode.userCanceled:
      case LocalAuthExceptionCode.systemCanceled:
      case LocalAuthExceptionCode.timeout:
      case LocalAuthExceptionCode.userRequestedFallback:
      case LocalAuthExceptionCode.authInProgress:
        return StageAuthOutcome.canceled;
      case LocalAuthExceptionCode.noCredentialsSet:
      case LocalAuthExceptionCode.noBiometricsEnrolled:
      case LocalAuthExceptionCode.noBiometricHardware:
      case LocalAuthExceptionCode.biometricHardwareTemporarilyUnavailable:
      case LocalAuthExceptionCode.temporaryLockout:
      case LocalAuthExceptionCode.biometricLockout:
        return StageAuthOutcome.notAvailable;
      default:
        return StageAuthOutcome.error;
    }
  }
}

final stageSecurityServiceProvider = Provider<StageSecurityService>((ref) {
  return StageSecurityService();
});
