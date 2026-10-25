// Every declared language has the same keys as the template, with real
// translations (engineering standard §8.7). The About config has its own
// check in app_config_test.dart.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The template language and the other declared languages
/// (docs/PROJECT_PROFILE.md §4).
const template = 'en';
const otherLanguages = ['ml', 'sa'];

/// Keys allowed to keep the English value in another language: brand names,
/// file formats and units that stay the same everywhere. Keep this short.
const sameAsTemplateAllowed = <String>{
  'titleApp', // LyricChord
  'labelSongListFormatChordPro', // ChordPro (.chordpro)
  'labelSongListFormatPdf', // PDF (.pdf)
  'labelMetronomeBpmUnit', // BPM
  'labelSongCardBpm', // {bpm} BPM
  'labelInfoBpm', // {bpm} BPM
  'labelEditorSummaryBpm', // {bpm} BPM
  'labelAirQrFps', // {fps} FPS
  'labelSongMetaKeyHint', // C, Am, F#m — notation
  'labelSongMetaTempoHint', // 120
  'labelChordInserterChordHint', // F#m7, Cmaj7, D/F# — notation
  'titlePerfSetlistPosition', // {name} ({position}/{total})
};

Map<String, String> _strings(String path) {
  final map = jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
  return {
    for (final e in map.entries)
      if (!e.key.startsWith('@')) e.key: e.value as String,
  };
}

String _arb(String code) => 'lib/l10n/app_$code.arb';

/// The `{name}` placeholders (and plural/select selectors) a message uses;
/// a quoted `'{literal}'` is text, not a placeholder.
Set<String> _placeholders(String message) => RegExp(r'\{(\w+)[,}]')
    .allMatches(message.replaceAll(RegExp(r"'[^']*'"), ''))
    .map((m) => m.group(1)!)
    .toSet();

bool _samePlaceholders(String a, String b) {
  final x = _placeholders(a);
  final y = _placeholders(b);
  return x.length == y.length && x.containsAll(y);
}

void main() {
  final templateStrings = _strings(_arb(template));

  test('the template ARB file exists', () {
    expect(File(_arb(template)).existsSync(), isTrue);
  });

  for (final code in otherLanguages) {
    test('$code: its ARB file exists', () {
      expect(File(_arb(code)).existsSync(), isTrue, reason: _arb(code));
    });

    test('$code: same keys as the template', () {
      final keys = _strings(_arb(code)).keys.toSet();
      final base = templateStrings.keys.toSet();
      expect(keys.difference(base), isEmpty, reason: 'extra keys in $code');
      expect(base.difference(keys), isEmpty, reason: 'missing keys in $code');
    });

    test('$code: no value is a copy of the English one', () {
      final problems = <String>[
        for (final e in _strings(_arb(code)).entries)
          if (!sameAsTemplateAllowed.contains(e.key) &&
              e.value.trim().isNotEmpty &&
              e.value == templateStrings[e.key])
            '${e.key} is untranslated (same as English)',
      ];
      expect(problems, isEmpty, reason: problems.join('\n'));
    });

    test('$code: same placeholders as English', () {
      final problems = <String>[
        for (final e in _strings(_arb(code)).entries)
          if (templateStrings[e.key] != null &&
              !_samePlaceholders(e.value, templateStrings[e.key]!))
            '${e.key}: placeholders differ from English',
      ];
      expect(problems, isEmpty, reason: problems.join('\n'));
    });
  }

  test('the About badge keeps its {heart} marker in every language', () {
    for (final code in [template, ...otherLanguages]) {
      final text = _strings(_arb(code))['madeWithLove'];
      if (text != null) {
        expect(
          text.contains('{heart}'),
          isTrue,
          reason: 'app_$code.arb madeWithLove has no {heart}',
        );
      }
    }
  });

  test('content assets exist in every declared language', () {
    final assets = Directory('assets');
    final problems = <String>[];
    for (final file in assets.listSync(recursive: true).whereType<File>()) {
      final match = RegExp('_$template(\\.[^./\\\\]+)\$').firstMatch(file.path);
      if (match == null) continue;
      for (final code in otherLanguages) {
        final twin = file.path.replaceFirst(
          RegExp('_$template(\\.[^./\\\\]+)\$'),
          '_$code${match.group(1)}',
        );
        if (!File(twin).existsSync()) problems.add('missing $twin');
      }
    }
    expect(problems, isEmpty, reason: problems.join('\n'));
  });
}
