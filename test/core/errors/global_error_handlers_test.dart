import 'dart:ui' show ErrorCallback, PlatformDispatcher;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';

import 'package:lyricchord/core/config/app_flavor_config.dart';
import 'package:lyricchord/core/errors/global_error_handlers.dart';
import 'package:lyricchord/core/logging/app_logger.dart';
import 'package:lyricchord/widgets/safe_error_fallback.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FlutterExceptionHandler? savedFlutterOnError;
  late ErrorCallback? savedDispatcherOnError;
  late ErrorWidgetBuilder savedErrorWidgetBuilder;
  late MemoryOutput output;

  setUp(() {
    savedFlutterOnError = FlutterError.onError;
    savedDispatcherOnError = PlatformDispatcher.instance.onError;
    savedErrorWidgetBuilder = ErrorWidget.builder;
    output = MemoryOutput();
    AppLogger.init(
      flavor: const AppFlavorConfig.forTesting(AppFlavor.dev),
      output: output,
      releaseMode: false,
    );
  });

  tearDown(() {
    FlutterError.onError = savedFlutterOnError;
    PlatformDispatcher.instance.onError = savedDispatcherOnError;
    ErrorWidget.builder = savedErrorWidgetBuilder;
    AppLogger.init();
  });

  test('framework errors are logged', () {
    installGlobalErrorHandlers(releaseMode: true);

    FlutterError.onError!(
      FlutterErrorDetails(exception: StateError('layout broke')),
    );

    expect(output.buffer, hasLength(1));
    expect(output.buffer.single.level, Level.error);
  });

  test('uncaught async errors are logged and handled', () {
    installGlobalErrorHandlers(releaseMode: true);

    final handled = PlatformDispatcher.instance.onError!(
      StateError('timer failed'),
      StackTrace.current,
    );

    expect(handled, isTrue);
    expect(output.buffer.single.level, Level.error);
  });

  test('release builds show the safe fallback for a broken widget', () {
    installGlobalErrorHandlers(releaseMode: true);

    final widget = ErrorWidget.builder(
      FlutterErrorDetails(exception: StateError('build failed')),
    );

    expect(widget, isA<SafeErrorFallback>());
  });

  test('debug builds keep Flutter\'s own error widget', () {
    // Tests run in debug mode, so the default is the debug behaviour.
    installGlobalErrorHandlers();

    expect(ErrorWidget.builder, same(savedErrorWidgetBuilder));
  });
}
