/// Turns a self-contained HTML song sheet into PDF bytes using a native,
/// on-window web view (see the Android `LcHtmlToPdf` class).
///
/// This replaces `Printing.convertHtml`, whose hidden, unattached web view
/// hangs forever on newer Android. The native side here renders the same HTML
/// in a web view that is attached to the window, so the print callbacks fire
/// and a real PDF comes back. Malayalam (and other complex scripts) shape
/// correctly because the platform web view does the shaping.
///
/// Fully offline: the native side loads only the local HTML passed in and
/// blocks all network loading in the web view. No URL is fetched.
///
/// Output only — no UI, no navigation. It talks to the platform over a single
/// method channel and returns bytes; the caller shares them.
library;

import 'package:flutter/services.dart';

/// Thrown when the native renderer cannot produce a PDF (including when the
/// platform has no implementation, such as iOS today).
class HtmlPdfException implements Exception {
  const HtmlPdfException(this.message);

  final String message;

  @override
  String toString() => 'HtmlPdfException: $message';
}

/// Converts HTML to PDF bytes through the `in.sreerajp.lyricchord/html_pdf`
/// method channel.
class HtmlPdfService {
  const HtmlPdfService();

  static const MethodChannel _channel = MethodChannel(
    'in.sreerajp.lyricchord/html_pdf',
  );

  /// A4 page size and margin in PostScript points (1/72 inch), matching the
  /// `@page` size used by [PdfExportService].
  static const double _a4WidthPts = 595.28;
  static const double _a4HeightPts = 841.89;
  static const double _marginPts = 32.0;

  /// Renders [html] to PDF bytes. Throws [HtmlPdfException] on any failure
  /// (bad render, empty result, or an unsupported platform).
  ///
  /// [timeout] is passed to the native side as a hard limit so a stuck render
  /// can never hang; the caller may also wrap this call in its own timeout.
  Future<Uint8List> convert({
    required String html,
    Duration timeout = const Duration(seconds: 20),
  }) async {
    try {
      final bytes = await _channel
          .invokeMethod<Uint8List>('convertHtml', <String, dynamic>{
            'html': html,
            'widthPts': _a4WidthPts,
            'heightPts': _a4HeightPts,
            'marginPts': _marginPts,
            'timeoutMs': timeout.inMilliseconds,
          });
      if (bytes == null || bytes.isEmpty) {
        throw const HtmlPdfException('The PDF renderer returned no data.');
      }
      return bytes;
    } on MissingPluginException {
      // No native implementation on this platform (iOS today).
      throw const HtmlPdfException(
        'PDF export is not available on this device.',
      );
    } on PlatformException catch (e) {
      throw HtmlPdfException(e.message ?? 'The PDF renderer failed.');
    }
  }
}
