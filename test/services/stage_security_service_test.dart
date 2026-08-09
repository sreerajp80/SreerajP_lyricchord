import 'package:flutter_test/flutter_test.dart';
import 'package:lyricchord/services/stage_security_service.dart';

void main() {
  group('StageSecurityService', () {
    test('StageAuthResult exposes correctly outcome properties', () {
      const resultSuccess = StageAuthResult(StageAuthOutcome.success);
      expect(resultSuccess.isSuccess, isTrue);

      const resultFail = StageAuthResult(
        StageAuthOutcome.failure,
        message: 'Auth failed',
      );
      expect(resultFail.isSuccess, isFalse);
      expect(resultFail.message, equals('Auth failed'));
    });
  });
}
