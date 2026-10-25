import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:lyricchord/core/config/app_config.dart';
import 'package:lyricchord/core/config/config_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  ConfigService serviceReturning(String text) =>
      ConfigService(loadAsset: (_) async => text);

  test('loads the bundled config with the app name and details', () async {
    final config = await ConfigService().load();

    expect(config.appName.resolve('en'), 'LyricChord');
    expect(config.version, isNot(AppConfig.fallback.version));
    expect(config.details, isNotEmpty);
  });

  test('the bundled config version matches pubspec.yaml', () async {
    final config = await ConfigService().load();
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final match = RegExp(
      r'^version:\s*([^\s+]+)\+(\S+)',
      multiLine: true,
    ).firstMatch(pubspec)!;

    expect(config.version, match.group(1));
    expect(config.build, match.group(2));
  });

  test('broken JSON falls back safely', () async {
    final config = await serviceReturning('{not json').load();

    expect(config.version, AppConfig.fallback.version);
  });

  test('JSON that is not an object falls back safely', () async {
    final config = await serviceReturning('[1, 2, 3]').load();

    expect(config.version, AppConfig.fallback.version);
  });

  test('a missing asset falls back safely', () async {
    final config = await ConfigService(
      loadAsset: (_) => Future.error(const FileSystemException('missing')),
    ).load();

    expect(config.version, AppConfig.fallback.version);
  });

  test('loadAndVerify returns the config whether or not versions match', () {
    const json = '{"appName": "X", "version": "1.2.3", "build": "4"}';
    final matching = PackageInfo(
      appName: 'X',
      packageName: 'p',
      version: '1.2.3',
      buildNumber: '4',
    );
    final different = PackageInfo(
      appName: 'X',
      packageName: 'p',
      version: '9.9.9',
      buildNumber: '1',
    );

    expect(
      serviceReturning(json).loadAndVerify(packageInfo: matching),
      completion(isA<AppConfig>().having((c) => c.version, 'version', '1.2.3')),
    );
    expect(
      serviceReturning(json).loadAndVerify(packageInfo: different),
      completion(isA<AppConfig>().having((c) => c.build, 'build', '4')),
    );
  });
}
