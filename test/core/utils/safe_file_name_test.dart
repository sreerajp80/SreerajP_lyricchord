import 'package:flutter_test/flutter_test.dart';

import 'package:lyricchord/core/utils/safe_file_name.dart';

void main() {
  test('keeps a plain English title, spaces become underscores', () {
    expect(safeFileName('Amazing Grace'), 'Amazing_Grace');
  });

  test('keeps a Malayalam title so it can be the file name', () {
    // The whole title is Malayalam — the old ASCII-only cleaner dropped it all
    // and fell back to "song". It must now survive.
    expect(safeFileName('ടെസ്റ്റ്'), 'ടെസ്റ്റ്');
  });

  test('keeps a mixed Malayalam + English title', () {
    expect(safeFileName('ഗാനം Song'), 'ഗാനം_Song');
  });

  test('removes characters that are illegal in file names', () {
    expect(safeFileName('a/b:c*d?e"f<g>h|i\\j'), 'abcdefghij');
  });

  test('collapses runs of whitespace to a single underscore', () {
    expect(safeFileName('  many   spaces  '), 'many_spaces');
  });

  test('falls back to "song" when nothing usable is left', () {
    expect(safeFileName('///'), 'song');
    expect(safeFileName('   '), 'song');
    expect(safeFileName(''), 'song');
  });
}
