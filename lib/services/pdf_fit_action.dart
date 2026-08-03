/// Adds an "open zoomed so the page fits" hint to a finished PDF.
///
/// The Android renderer (`LcHtmlToPdf`) gives back plain PDF bytes with no
/// `/OpenAction`, so a viewer opens the file at whatever zoom it likes. This
/// adds `/OpenAction [<first page> /Fit]` to the document catalog, which asks
/// the viewer to fit the whole first page in the window.
///
/// It is only a hint: desktop readers (Adobe, Foxit) follow it, most phone
/// viewers pick their own zoom. The text is made bigger by
/// [PdfExportService]'s layout, not by this.
///
/// The bytes are changed by an **incremental update** — everything already in
/// the file is left byte-for-byte alone and a new catalog, cross-reference
/// section and trailer are appended. That is the standard way to edit a PDF
/// without recomputing every offset in it.
///
/// Output only — no UI, no navigation, no network.
///
/// **It never breaks an export.** Anything unexpected (a cross-reference
/// stream instead of a table, a missing `/Root`, an odd dictionary, empty
/// input) makes it return the original bytes unchanged. A less convenient
/// opening zoom is never worth a broken PDF (CLAUDE.md hard rule 4).
library;

import 'dart:convert';
import 'dart:typed_data';

/// Returns [pdf] with an "open at fit-page" action, or [pdf] unchanged if the
/// action cannot be added safely.
Uint8List addFitToPageAction(Uint8List pdf) {
  try {
    return _addFitToPageAction(pdf) ?? pdf;
  } catch (_) {
    // Any parse surprise at all: hand back exactly what came in.
    return pdf;
  }
}

/// The real work. Returns `null` when the file is not one we can safely edit.
Uint8List? _addFitToPageAction(Uint8List pdf) {
  if (pdf.length < 32) return null;

  // Latin-1 maps every byte 1:1, so this is a lossless view of the bytes and
  // the offsets below are byte offsets. Only ASCII structure is read; binary
  // streams are never touched, because nothing existing is rewritten.
  final text = latin1.decode(pdf, allowInvalid: true);

  final startXref = _lastStartXref(text);
  if (startXref == null) return null;

  // A classic cross-reference table starts with the word "xref". If it does
  // not, this is a cross-reference stream, which needs a different (and much
  // riskier) edit — leave the file alone.
  if (!text.startsWith('xref', startXref)) return null;

  final trailer = _lastTrailerDict(text);
  if (trailer == null) return null;

  final root = _rootRef(trailer);
  if (root == null) return null;

  final size = _intValue(trailer, 'Size');
  if (size == null) return null;

  final catalog = _findObject(text, root.number, root.generation);
  if (catalog == null) return null;
  if (!catalog.body.contains('/Type')) return null;
  if (!catalog.body.contains('/Catalog')) return null;

  // Already opens at a chosen view — respect it.
  if (catalog.body.contains('/OpenAction')) return null;

  final firstPage = _firstPageRef(text, catalog.body);
  if (firstPage == null) return null;

  // --- Build the appended update -------------------------------------------

  final out = StringBuffer();

  // Start on a fresh line so the new object cannot glue onto the old %%EOF.
  final needsNewline = !text.endsWith('\n') && !text.endsWith('\r');
  if (needsNewline) out.write('\n');

  final catalogOffset = pdf.length + (needsNewline ? 1 : 0);

  out
    ..write('${root.number} ${root.generation} obj\n')
    ..write('<<${catalog.body} /OpenAction [')
    ..write('${firstPage.number} ${firstPage.generation} R /Fit]>>\n')
    ..write('endobj\n');

  final xrefOffset = catalogOffset + (out.length - (needsNewline ? 1 : 0));

  // A cross-reference entry is exactly 20 bytes: 10-digit offset, space,
  // 5-digit generation, space, "n", space, newline.
  final offsetField = catalogOffset.toString().padLeft(10, '0');
  final genField = root.generation.toString().padLeft(5, '0');

  out
    ..write('xref\n')
    ..write('${root.number} 1\n')
    ..write('$offsetField $genField n \n')
    ..write('trailer\n')
    // No new object was created, so /Size is unchanged. /Prev chains back to
    // the cross-reference section already in the file.
    ..write(
      '<< /Size $size /Root ${root.number} ${root.generation} R '
      '/Prev $startXref >>\n',
    )
    ..write('startxref\n')
    ..write('$xrefOffset\n')
    ..write('%%EOF\n');

  final tail = latin1.encode(out.toString());
  final result = Uint8List(pdf.length + tail.length)
    ..setRange(0, pdf.length, pdf)
    ..setRange(pdf.length, pdf.length + tail.length, tail);
  return result;
}

// --- Small PDF parsing helpers ----------------------------------------------

/// An indirect reference, as in `12 0 R`.
class _Ref {
  const _Ref(this.number, this.generation);

  final int number;
  final int generation;
}

/// An indirect object's dictionary body, without the outer `<<` and `>>`.
class _PdfObject {
  const _PdfObject(this.body);

  final String body;
}

/// The offset written after the file's last `startxref`.
int? _lastStartXref(String text) {
  final at = text.lastIndexOf('startxref');
  if (at < 0) return null;
  final match = RegExp(r'startxref\s+(\d+)').matchAsPrefix(text, at);
  if (match == null) return null;
  final value = int.tryParse(match.group(1)!);
  if (value == null || value <= 0 || value >= text.length) return null;
  return value;
}

/// The dictionary body of the file's last `trailer`, without `<<` and `>>`.
String? _lastTrailerDict(String text) {
  final at = text.lastIndexOf('trailer');
  if (at < 0) return null;
  final open = text.indexOf('<<', at);
  if (open < 0) return null;
  return _dictBody(text, open);
}

/// Reads `/Root n g R` out of a dictionary body.
_Ref? _rootRef(String dict) {
  final match = RegExp(r'/Root\s+(\d+)\s+(\d+)\s+R').firstMatch(dict);
  if (match == null) return null;
  return _Ref(int.parse(match.group(1)!), int.parse(match.group(2)!));
}

/// Reads a plain integer entry such as `/Size 42` out of a dictionary body.
int? _intValue(String dict, String name) {
  final match = RegExp('/$name\\s+(\\d+)').firstMatch(dict);
  if (match == null) return null;
  return int.tryParse(match.group(1)!);
}

/// Finds the indirect object `number generation obj << … >>` and returns its
/// dictionary body. Returns `null` if it is missing or is not a dictionary
/// (for example, a catalog packed inside an object stream).
_PdfObject? _findObject(String text, int number, int generation) {
  final header = RegExp(
    '(?:^|[^0-9])$number\\s+$generation\\s+obj',
    multiLine: true,
  );
  for (final match in header.allMatches(text)) {
    final open = text.indexOf('<<', match.end);
    if (open < 0) continue;
    // The dictionary must follow the header directly, not belong to a later
    // object; anything between them can only be whitespace.
    if (text.substring(match.end, open).trim().isNotEmpty) continue;
    final body = _dictBody(text, open);
    if (body != null) return _PdfObject(body);
  }
  return null;
}

/// Walks down `/Pages` → `/Kids` until it reaches the first `/Type /Page`.
_Ref? _firstPageRef(String text, String catalogDict) {
  final pages = RegExp(r'/Pages\s+(\d+)\s+(\d+)\s+R').firstMatch(catalogDict);
  if (pages == null) return null;

  var node = _Ref(int.parse(pages.group(1)!), int.parse(pages.group(2)!));

  // A page tree is shallow in practice; the limit only stops a damaged file
  // with a loop in it from spinning forever.
  for (var depth = 0; depth < 8; depth++) {
    final object = _findObject(text, node.number, node.generation);
    if (object == null) return null;
    if (RegExp(r'/Type\s*/Page\b').hasMatch(object.body)) return node;

    final kids = RegExp(
      r'/Kids\s*\[(.*?)\]',
      dotAll: true,
    ).firstMatch(object.body);
    if (kids == null) return null;
    final first = RegExp(r'(\d+)\s+(\d+)\s+R').firstMatch(kids.group(1)!);
    if (first == null) return null;
    node = _Ref(int.parse(first.group(1)!), int.parse(first.group(2)!));
  }
  return null;
}

/// Returns the body of the dictionary that starts with `<<` at [open],
/// excluding the outer `<<` and `>>`. Returns `null` if it is never closed.
String? _dictBody(String text, int open) {
  var depth = 0;
  var i = open;
  while (i < text.length - 1) {
    final pair = text.substring(i, i + 2);
    if (pair == '<<') {
      depth++;
      i += 2;
      continue;
    }
    if (pair == '>>') {
      depth--;
      if (depth == 0) return text.substring(open + 2, i);
      i += 2;
      continue;
    }
    i++;
  }
  return null;
}
