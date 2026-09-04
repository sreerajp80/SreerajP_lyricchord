/// Normalizes all forms of line breaks to standard Unix `\n`.
///
/// Handles Windows CRLF (`\r\n`), classic Mac CR (`\r`), Unicode line
/// separator (`\u2028`), Unicode paragraph separator (`\u2029`), next line
/// (`\u0085`), and form feed (`\u000C`).
///
/// If the text contains no actual raw newline characters but contains escaped
/// newlines (`\n` or `\r\n`), it safely unescapes them so text from JSON or
/// clipboard payloads keeps its line breaks.
String normalizeLineBreaks(String content) {
  var text = content;
  if (!text.contains('\n') &&
      !text.contains('\r') &&
      (text.contains(r'\n') || text.contains(r'\r'))) {
    text = text
        .replaceAll(r'\r\n', '\n')
        .replaceAll(r'\r', '\n')
        .replaceAll(r'\n', '\n');
  }
  return text
      .replaceAll('\r\n', '\n')
      .replaceAll('\r', '\n')
      .replaceAll('\u2028', '\n')
      .replaceAll('\u2029', '\n\n')
      .replaceAll('\u0085', '\n')
      .replaceAll('\u000C', '\n');
}
