import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth/local_auth.dart';
import 'package:lyricchord/services/stage_security_service.dart';

void main() {
  group('StageSecurityService', () {
    test('StageAuthResult exposes correctly outcome properties', () {
      const resultSuccess = StageAuthResult(StageAuthOutcome.success);
      expect(resultSuccess.isSuccess, isTrue);
      expect(resultSuccess.isDenied, isFalse);

      const resultFail = StageAuthResult(
        StageAuthOutcome.failure,
        message: 'Auth failed',
      );
      expect(resultFail.isSuccess, isFalse);
      expect(resultFail.isDenied, isTrue);
      expect(resultFail.message, equals('Auth failed'));
    });

    test('only failure and cancel count as denied', () {
      expect(const StageAuthResult(StageAuthOutcome.canceled).isDenied, isTrue);
      expect(
        const StageAuthResult(StageAuthOutcome.notAvailable).isDenied,
        isFalse,
      );
      expect(const StageAuthResult(StageAuthOutcome.error).isDenied, isFalse);
    });

    group('outcomeForLocalAuthCode', () {
      StageAuthOutcome map(LocalAuthExceptionCode code) =>
          StageSecurityService.outcomeForLocalAuthCode(code);

      test('the person backing out is a cancel', () {
        for (final code in [
          LocalAuthExceptionCode.userCanceled,
          LocalAuthExceptionCode.systemCanceled,
          LocalAuthExceptionCode.timeout,
        ]) {
          expect(map(code), StageAuthOutcome.canceled, reason: code.name);
        }
      });

      test('no lock, no hardware or lockout is not available', () {
        for (final code in [
          LocalAuthExceptionCode.noCredentialsSet,
          LocalAuthExceptionCode.noBiometricsEnrolled,
          LocalAuthExceptionCode.noBiometricHardware,
          LocalAuthExceptionCode.temporaryLockout,
          LocalAuthExceptionCode.biometricLockout,
        ]) {
          expect(map(code), StageAuthOutcome.notAvailable, reason: code.name);
        }
      });

      test('a prompt that cannot be shown is an error, not a denial', () {
        for (final code in [
          LocalAuthExceptionCode.uiUnavailable,
          LocalAuthExceptionCode.unknownError,
        ]) {
          expect(map(code), StageAuthOutcome.error, reason: code.name);
        }
      });
    });
  });
}
