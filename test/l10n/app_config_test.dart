// Checks the real assets/config/app_config.json against guideline §1.2 and
// engineering standard §8.7.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The declared languages (docs/PROJECT_PROFILE.md §4), template first.
const declaredLanguages = ['en', 'ml', 'sa'];

/// Detail values that are technical, not text a user reads, so they may be a
/// plain string (guideline §1.2): addresses and links.
const technicalDetails = {'email', 'website', 'privacyPolicy'};

void main() {
  final config =
      jsonDecode(File('assets/config/app_config.json').readAsStringSync())
          as Map<String, dynamic>;
  final arbKeys =
      (jsonDecode(File('lib/l10n/app_en.arb').readAsStringSync())
              as Map<String, dynamic>)
          .keys
          .toSet();

  List<String> missingLanguages(String path, Object? value) {
    if (value is! Map) return ['$path is not a per-language map'];
    return [
      for (final lang in declaredLanguages)
        if ((value[lang] as String?)?.trim().isEmpty ?? true)
          '$path.$lang is missing or empty',
    ];
  }

  test('has the required fields', () {
    for (final field in ['appName', 'description', 'version', 'build']) {
      expect(config.containsKey(field), isTrue, reason: 'missing "$field"');
    }
    expect(config['details'], isA<Map<String, dynamic>>());
  });

  test('every text a user reads has every declared language', () {
    final problems = <String>[
      ...missingLanguages('appName', config['appName']),
      ...missingLanguages('description', config['description']),
    ];
    final details = config['details'] as Map<String, dynamic>;
    details.forEach((key, value) {
      if (technicalDetails.contains(key)) return;
      problems.addAll(missingLanguages('details.$key', value));
    });
    expect(problems, isEmpty, reason: problems.join('\n'));
  });

  test('detail keys are lowerCamelCase ids with an aboutDetail label', () {
    final problems = <String>[];
    final details = config['details'] as Map<String, dynamic>;
    for (final key in details.keys) {
      if (!RegExp(r'^[a-z][a-zA-Z0-9]*$').hasMatch(key)) {
        problems.add('"$key" is not lowerCamelCase');
        continue;
      }
      final label = 'aboutDetail${key[0].toUpperCase()}${key.substring(1)}';
      if (!arbKeys.contains(label)) {
        problems.add('"$key" has no ARB label "$label"');
      }
    }
    expect(problems, isEmpty, reason: problems.join('\n'));
  });

  test('version and build match pubspec.yaml', () {
    final line = File(
      'pubspec.yaml',
    ).readAsLinesSync().firstWhere((l) => l.startsWith('version:'));
    final version = line.substring('version:'.length).trim();
    expect('${config['version']}+${config['build']}', version);
  });
}
