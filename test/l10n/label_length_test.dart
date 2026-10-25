// Short UI text must stay short in every declared language (engineering
// standard §8.6), and every ARB key must say which kind of text it is.
import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart'; // `characters` (grapheme clusters)
import 'package:flutter_test/flutter_test.dart';

/// Keys with these prefixes are UI chrome and must fit the length budget.
const shortPrefixes = ['action', 'label', 'title', 'tab', 'nav', 'tooltip'];

/// Keys with these prefixes are descriptive text and may be long.
const longPrefixes = ['desc', 'help', 'empty', 'error', 'body', 'aboutDetail'];

/// Hard limit per language, in visible characters. English and the other
/// Latin-script languages: 20. Malayalam and Sanskrit: 22 (language pack §5).
const limits = {'en': 20, 'ml': 22, 'sa': 22};

/// A `{placeholder}` counts as this many characters (a short number or value).
const placeholderWidth = 3;

/// Keys allowed to go over the limit. Keep this empty: shorten the text
/// instead. A listed key that already fits makes the test fail.
const knownTooLong = <String>{};

/// Each text a message can show: the branches of a plural or select, or the
/// message itself.
List<String> branches(String message) {
  final match = RegExp(
    r'^\{\w+,\s*(plural|select),(.*)\}$',
    dotAll: true,
  ).firstMatch(message);
  if (match == null) return [message];
  final body = match.group(2)!;
  final out = <String>[];
  var depth = 0;
  var start = -1;
  for (var i = 0; i < body.length; i++) {
    if (body[i] == '{') {
      if (depth == 0) start = i + 1;
      depth++;
    } else if (body[i] == '}') {
      depth--;
      if (depth == 0) out.add(body.substring(start, i));
    }
  }
  return out.isEmpty ? [message] : out;
}

/// Visible length of the longest text the message can show.
int visibleLength(String message) {
  var longest = 0;
  for (final text in branches(message)) {
    final withValues = text.replaceAll(
      RegExp(r'\{\w+\}'),
      'x' * placeholderWidth,
    );
    final length = withValues.characters.length;
    if (length > longest) longest = length;
  }
  return longest;
}

Map<String, String> _messages(File file) {
  final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  return {
    for (final e in json.entries)
      if (!e.key.startsWith('@')) e.key: e.value as String,
  };
}

void main() {
  final arbFiles = Directory('lib/l10n')
      .listSync()
      .whereType<File>()
      .where((f) => RegExp(r'app_(\w+)\.arb$').hasMatch(f.path))
      .toList();

  test('there is at least one ARB file', () {
    expect(arbFiles, isNotEmpty);
  });

  test('every key starts with a known category prefix', () {
    final template = arbFiles.firstWhere((f) => f.path.endsWith('app_en.arb'));
    final bad = _messages(template).keys.where(
      (key) => ![
        ...shortPrefixes,
        ...longPrefixes,
      ].any((p) => key.startsWith(p) && key.length > p.length),
    );
    expect(bad, isEmpty, reason: 'Keys without a category prefix: $bad');
  });

  for (final file in arbFiles) {
    final locale = RegExp(r'app_(\w+)\.arb$').firstMatch(file.path)!.group(1)!;

    test('short labels fit the budget in $locale', () {
      final limit = limits[locale];
      expect(
        limit,
        isNotNull,
        reason: 'Add a length limit for "$locale" to `limits`.',
      );

      final problems = <String>[];
      final fixed = <String>[];
      _messages(file).forEach((key, value) {
        if (!shortPrefixes.any(key.startsWith)) return;
        final length = visibleLength(value);
        final allowed = locale == 'en' && knownTooLong.contains(key);
        if (length > limit! && !allowed) {
          problems.add('$key ($length > $limit): "$value"');
        } else if (allowed && length <= limit) {
          fixed.add(key);
        }
      });

      expect(problems, isEmpty, reason: problems.join('\n'));
      expect(
        fixed,
        isEmpty,
        reason: 'Now within the limit; remove from knownTooLong: $fixed',
      );
    });
  }

  group('visibleLength', () {
    test('counts a placeholder as $placeholderWidth characters', () {
      expect(visibleLength('Key {key}'), 4 + placeholderWidth);
    });

    test('checks each plural branch on its own', () {
      expect(
        visibleLength('{count, plural, =1{1 song} other{{count} songs}}'),
        placeholderWidth + 6,
      );
    });

    test('counts Malayalam by visible letters, not code units', () {
      // ക്രമീകരണങ്ങൾ ("Settings") has 7 visible letters.
      expect(visibleLength('ക്രമീകരണങ്ങൾ'), 7);
    });
  });
}
