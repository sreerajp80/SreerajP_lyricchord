import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';

import 'package:lyricchord/core/config/app_flavor_config.dart';
import 'package:lyricchord/core/logging/app_logger.dart';

/// Everything printed, one string per log call.
List<String> _printed(MemoryOutput output) =>
    output.buffer.map((event) => event.lines.join('\n')).toList();

void main() {
  late MemoryOutput output;

  setUp(() => output = MemoryOutput());

  // Put the normal console logger back for the other tests.
  tearDown(AppLogger.init);

  test('dev flavor writes debug logs', () {
    AppLogger.init(
      flavor: const AppFlavorConfig.forTesting(AppFlavor.dev),
      output: output,
      releaseMode: false,
    );

    AppLogger.debug('opening the editor');

    expect(_printed(output).single, contains('opening the editor'));
  });

  test('prod flavor drops trace and debug, keeps info and above', () {
    AppLogger.init(
      flavor: const AppFlavorConfig.forTesting(AppFlavor.prod),
      output: output,
      releaseMode: false,
    );

    AppLogger.trace('trace line');
    AppLogger.debug('debug line');
    AppLogger.info('info line');
    AppLogger.warning('warning line');

    final printed = _printed(output);
    expect(printed, hasLength(2));
    expect(printed[0], contains('info line'));
    expect(printed[1], contains('warning line'));
  });

  test('prod release logs only the error type, never its message', () {
    AppLogger.init(
      flavor: const AppFlavorConfig.forTesting(AppFlavor.prod),
      output: output,
      releaseMode: true,
    );

    AppLogger.error(
      'PDF export failed',
      error: StateError('Amazing Grace lyrics here'),
      stackTrace: StackTrace.current,
    );

    final line = _printed(output).single;
    expect(line, contains('PDF export failed'));
    expect(line, contains('StateError'));
    expect(line, isNot(contains('Amazing Grace')));
  });

  test('dev flavor keeps the error message for debugging', () {
    AppLogger.init(
      flavor: const AppFlavorConfig.forTesting(AppFlavor.dev),
      output: output,
      releaseMode: true,
    );

    AppLogger.error('Save failed', error: StateError('disk full'));

    expect(_printed(output).single, contains('disk full'));
  });
}
