import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:lyricchord/services/pdf_fit_action.dart';

/// Builds a tiny but real PDF: catalog, one-page tree, one page.
///
/// The offsets in the cross-reference table are computed as the file is built,
/// so `startxref` truly points at the word `xref` — which is what
/// [addFitToPageAction] checks before it touches anything.
Uint8List buildTinyPdf({String catalogExtra = ''}) {
  final objects = <String>[
    '<< /Type /Catalog /Pages 2 0 R$catalogExtra >>',
    '<< /Type /Pages /Kids [3 0 R] /Count 1 >>',
    '<< /Type /Page /Parent 2 0 R /MediaBox [0 0 595 842] >>',
  ];

  final out = StringBuffer('%PDF-1.4\n');
  final offsets = <int>[];
  for (var i = 0; i < objects.length; i++) {
    offsets.add(out.length);
    out.write('${i + 1} 0 obj\n${objects[i]}\nendobj\n');
  }

  final xrefOffset = out.length;
  out.write('xref\n0 ${objects.length + 1}\n');
  out.write('0000000000 65535 f \n');
  for (final offset in offsets) {
    out.write('${offset.toString().padLeft(10, '0')} 00000 n \n');
  }
  out
    ..write('trailer\n<< /Size ${objects.length + 1} /Root 1 0 R >>\n')
    ..write('startxref\n$xrefOffset\n%%EOF\n');

  return Uint8List.fromList(latin1.encode(out.toString()));
}

void main() {
  test('adds an open-at-fit action pointing at the first page', () {
    final pdf = buildTinyPdf();
    final patched = addFitToPageAction(pdf);
    final text = latin1.decode(patched);

    // The original bytes are untouched — this is an incremental update.
    expect(patched.length, greaterThan(pdf.length));
    expect(patched.sublist(0, pdf.length), equals(pdf));

    // The action opens the first page (object 3) fitted to the window.
    expect(text.contains('/OpenAction [3 0 R /Fit]'), isTrue);
    // A new catalog, cross-reference section and trailer were appended.
    expect(text.contains('1 0 obj'), isTrue);
    expect(text.contains('/Prev '), isTrue);
    expect(text.trimRight().endsWith('%%EOF'), isTrue);
  });

  test('the appended startxref points at the appended xref', () {
    final patched = addFitToPageAction(buildTinyPdf());
    final text = latin1.decode(patched);

    final startXref = int.parse(
      RegExp(r'startxref\s+(\d+)\s+%%EOF\s*$').firstMatch(text)!.group(1)!,
    );
    expect(text.startsWith('xref', startXref), isTrue);
  });

  test('leaves a PDF that already opens at a chosen view alone', () {
    final pdf = buildTinyPdf(
      catalogExtra: ' /OpenAction [3 0 R /XYZ null null 1]',
    );
    expect(addFitToPageAction(pdf), same(pdf));
  });

  test('returns the input unchanged when it is not a usable PDF', () {
    final junk = Uint8List.fromList(List<int>.filled(200, 7));
    expect(addFitToPageAction(junk), same(junk));

    final empty = Uint8List(0);
    expect(addFitToPageAction(empty), same(empty));

    final noRoot = Uint8List.fromList(
      latin1.encode(
        '%PDF-1.4\nxref\ntrailer\n<< /Size 4 >>\nstartxref\n9\n%%EOF\n',
      ),
    );
    expect(addFitToPageAction(noRoot), same(noRoot));
  });

  test('returns the input unchanged for a cross-reference stream file', () {
    // startxref points at an object, not at the word "xref", so the file uses
    // a cross-reference stream that this patcher must not try to edit.
    final text =
        '%PDF-1.5\n1 0 obj\n<< /Type /Catalog /Pages 2 0 R >>\nendobj\n'
        'startxref\n9\n%%EOF\n';
    final pdf = Uint8List.fromList(latin1.encode(text));
    expect(addFitToPageAction(pdf), same(pdf));
  });
}
