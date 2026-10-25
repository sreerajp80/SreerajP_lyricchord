import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guards the localization rule in `CLAUDE.md`: user-visible text comes from
/// `lib/l10n/app_en.arb`, never a string literal in a screen or widget.
///
/// It reads the source of `lib/screens/`, `lib/widgets/` and `lib/main.dart`
/// and fails on a string literal **with words in it** in a place the user
/// sees: `Text('…')`, a user-facing named argument such as `tooltip:` or
/// `labelText:`, a `_showSnack(context, '…')`-style helper, or an exception
/// thrown from UI code. "Words" means two letters in a row once `$name` and
/// `${…}` parts are removed, so `'$count'`, `'${speed}x'` and `'/settings'`
/// pass.
///
/// Known limits: text built in a helper method or returned from a function is
/// not seen. This is a safety net, not a proof — code review still applies.
void main() {
  group('no hard-coded UI text', () {
    test('screens, widgets and main.dart use AppLocalizations', () {
      final files = <File>[
        for (final dir in ['lib/screens', 'lib/widgets'])
          ...Directory(dir)
              .listSync(recursive: true)
              .whereType<File>()
              .where((f) => f.path.endsWith('.dart'))
              .where((f) => !f.path.endsWith('.g.dart')),
        File('lib/main.dart'),
      ];
      expect(
        files.length,
        greaterThan(50),
        reason: 'run from the project root',
      );

      final problems = <String>[];
      for (final file in files) {
        final path = file.path.replaceAll(r'\', '/');
        for (final hit in findHardCodedText(file.readAsStringSync())) {
          if (isAllowed(path, hit.literal)) continue;
          problems.add('$path:${hit.line}  ${hit.literal}');
        }
      }

      expect(
        problems,
        isEmpty,
        reason:
            'Move these texts to lib/l10n/app_en.arb and use '
            'AppLocalizations. Only text that is not words (notation, '
            'symbols) may go on the allow-list in this test, with a reason.\n'
            '${problems.join('\n')}',
      );
    });
  });

  group('the checker itself', () {
    List<String> found(String source) =>
        findHardCodedText(source).map((hit) => hit.literal).toList();

    test('flags words in Text and user-facing arguments', () {
      expect(found("Text('Hello')"), ["'Hello'"]);
      expect(found("IconButton(tooltip: 'Close')"), ["'Close'"]);
      expect(found('InputDecoration(hintText: "Song title")'), [
        '"Song title"',
      ]);
      expect(found("_showSnack(context, 'Saved.')"), ["'Saved.'"]);
      expect(found("throw ImportException('Bad file')"), ["'Bad file'"]);
      expect(found(r"Text('$count songs')"), [r"'$count songs'"]);
    });

    test('does not flag numbers, symbols, routes or comments', () {
      expect(found(r"Text('$count')"), isEmpty);
      expect(found(r"Text('${speed.toStringAsFixed(2)}x')"), isEmpty);
      expect(found(r"Text('${(scale * 100).round()}%')"), isEmpty);
      expect(found("context.push('/settings')"), isEmpty);
      expect(found("// Text('Old label')"), isEmpty);
      expect(found('Text(l10n.appTitle)'), isEmpty);
    });

    test('reports the line number', () {
      final hits = findHardCodedText("a\nb\n  Text('Hi')");
      expect(hits.single.line, 3);
    });

    test('the allow-list only lets through what it names', () {
      expect(
        isAllowed('lib/screens/pitch_drone_settings_screen.dart', "'Pa'"),
        isTrue,
      );
      expect(isAllowed('lib/screens/song_list_screen.dart', "'Pa'"), isFalse);
      expect(
        isAllowed('lib/screens/pitch_drone_settings_screen.dart', "'Pause'"),
        isFalse,
      );
    });
  });
}

/// Literals that look like words but are not text to translate.
///
/// Keyed by file, then the exact literal (with its quotes). Every entry needs
/// a reason. Do not add real words here — move them to the ARB file instead.
const Map<String, Set<String>> _allowed = {
  // Swara names on the Pa / Ma drone interval buttons: notation, like chord
  // names, the same in every language.
  'lib/screens/pitch_drone_settings_screen.dart': {"'Pa'", "'Ma'"},
};

bool isAllowed(String path, String literal) =>
    _allowed[path]?.contains(literal) ?? false;

/// One string literal found in a user-visible place.
class Hit {
  const Hit(this.line, this.literal);

  final int line;
  final String literal;
}

const String _literal = r"""(?:'(?:[^'\\\n]|\\.)*'|"(?:[^"\\\n]|\\.)*")""";

const String _userFacingArgument =
    'tooltip|label|labelText|hintText|helperText|errorText|semanticLabel|'
    'message|title|subtitle|caption|dialogTitle|applicationVersion';

final List<RegExp> _places = [
  RegExp('\\b(?:Text|SelectableText)\\(\\s*($_literal)'),
  RegExp('\\b(?:$_userFacingArgument):\\s*($_literal)'),
  RegExp('\\b_show\\w*\\(\\s*\\w+,\\s*($_literal)'),
  RegExp('Exception\\(\\s*($_literal)'),
];

final RegExp _interpolation = RegExp(r'\$\{[^}]*\}|\$[A-Za-z_]\w*');
final RegExp _word = RegExp('[A-Za-z]{2,}');
final RegExp _lineComment = RegExp(r'//[^\n]*');

/// Every string literal with words in it, in a user-visible place in [source].
List<Hit> findHardCodedText(String source) {
  // Blank out comments but keep their length, so line numbers stay right.
  final code = source.replaceAllMapped(
    _lineComment,
    (m) => ' ' * m.group(0)!.length,
  );

  final hits = <Hit>[];
  for (final place in _places) {
    for (final match in place.allMatches(code)) {
      final literal = match.group(1)!;
      final text = literal
          .substring(1, literal.length - 1)
          .replaceAll(_interpolation, '');
      if (!_word.hasMatch(text)) continue;
      final line = '\n'.allMatches(code.substring(0, match.start)).length + 1;
      hits.add(Hit(line, literal));
    }
  }
  hits.sort((a, b) => a.line.compareTo(b.line));
  return hits;
}
