import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:lyricchord/theme/app_theme.dart';

void main() {
  test('both themes fall back to Malayalam, then Devanagari, fonts', () {
    for (final theme in [AppTheme.light(), AppTheme.dark()]) {
      expect(
        theme.textTheme.bodyMedium?.fontFamilyFallback,
        AppTheme.uiFontFallback,
      );
    }
    expect(AppTheme.uiFontFallback, [
      'Noto Sans Malayalam',
      'Noto Sans Devanagari',
    ]);
  });

  test('every fallback font is bundled and declared in pubspec.yaml', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    for (final family in AppTheme.uiFontFallback) {
      expect(pubspec, contains('family: $family'));
      final file = family.replaceAll(' ', '');
      expect(File('assets/fonts/$file-Regular.ttf').existsSync(), isTrue);
      expect(File('assets/fonts/$file-Bold.ttf').existsSync(), isTrue);
    }
  });
}
