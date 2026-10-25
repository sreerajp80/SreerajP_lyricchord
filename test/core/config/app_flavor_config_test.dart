import 'package:flutter_test/flutter_test.dart';

import 'package:lyricchord/core/config/app_flavor_config.dart';

void main() {
  group('AppFlavorConfig.parse', () {
    test('reads dev, ignoring case and spaces', () {
      expect(AppFlavorConfig.parse('dev'), AppFlavor.dev);
      expect(AppFlavorConfig.parse(' DEV '), AppFlavor.dev);
    });

    test('reads prod', () {
      expect(AppFlavorConfig.parse('prod'), AppFlavor.prod);
    });

    test('anything unknown or empty is prod', () {
      expect(AppFlavorConfig.parse(''), AppFlavor.prod);
      expect(AppFlavorConfig.parse('staging'), AppFlavor.prod);
      expect(AppFlavorConfig.parse('devv'), AppFlavor.prod);
    });
  });

  test('a test run without --flavor counts as prod', () {
    expect(AppFlavorConfig.instance.isProd, isTrue);
  });

  test('verbose logging is on for dev only', () {
    expect(
      const AppFlavorConfig.forTesting(AppFlavor.dev).enableVerboseLogging,
      isTrue,
    );
    expect(
      const AppFlavorConfig.forTesting(AppFlavor.prod).enableVerboseLogging,
      isFalse,
    );
  });
}
