import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lyricchord/services/html_pdf_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('in.sreerajp.lyricchord/html_pdf');
  const service = HtmlPdfService();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(() {
    messenger.setMockMethodCallHandler(channel, null);
  });

  test('sends convertHtml with html and page arguments', () async {
    MethodCall? seen;
    messenger.setMockMethodCallHandler(channel, (call) async {
      seen = call;
      return Uint8List.fromList(<int>[1, 2, 3]);
    });

    final bytes = await service.convert(html: '<html></html>');

    expect(bytes, Uint8List.fromList(<int>[1, 2, 3]));
    expect(seen?.method, 'convertHtml');
    final args = seen!.arguments as Map;
    expect(args['html'], '<html></html>');
    // widthPts is the widest the page may be; the native side narrows it to
    // the song, but never below minWidthPts.
    expect(args['widthPts'], isA<double>());
    expect(args['minWidthPts'], isA<double>());
    expect(args['minWidthPts'] as double, lessThan(args['widthPts'] as double));
    expect(args['heightPts'], isA<double>());
    expect(args['marginPts'], isA<double>());
    expect(args['timeoutMs'], isA<int>());
  });

  test('throws HtmlPdfException when the channel returns nothing', () async {
    messenger.setMockMethodCallHandler(channel, (call) async => null);

    expect(
      () => service.convert(html: '<html></html>'),
      throwsA(isA<HtmlPdfException>()),
    );
  });

  test('throws HtmlPdfException on a platform error', () async {
    messenger.setMockMethodCallHandler(channel, (call) async {
      throw PlatformException(code: 'convert_failed', message: 'boom');
    });

    expect(
      () => service.convert(html: '<html></html>'),
      throwsA(
        isA<HtmlPdfException>().having(
          (e) => e.message,
          'message',
          contains('boom'),
        ),
      ),
    );
  });

  test(
    'throws HtmlPdfException when no native implementation exists',
    () async {
      // No mock handler registered -> MissingPluginException.
      expect(
        () => service.convert(html: '<html></html>'),
        throwsA(isA<HtmlPdfException>()),
      );
    },
  );
}
