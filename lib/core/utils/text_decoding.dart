import 'dart:convert';
import 'dart:typed_data';

/// Decodes imported file bytes into a string.
///
/// Understands UTF-8 (with or without a byte-order mark) and UTF-16 little- or
/// big-endian with a byte-order mark. Never throws: bad UTF-8 becomes the
/// replacement character, and an odd trailing UTF-16 byte is dropped
/// (CLAUDE.md hard rule 4 — an imported file is untrusted input).
///
/// UTF-16 is decoded byte by byte rather than through a `Uint16List` view: a
/// view needs an even start offset and uses the phone's own byte order, so it
/// could throw or garble text depending on where the bytes came from.
String decodeImportedBytes(Uint8List bytes) {
  // UTF-16 LE BOM (FF FE)
  if (bytes.length >= 2 && bytes[0] == 0xFF && bytes[1] == 0xFE) {
    return _decodeUtf16(bytes, bigEndian: false);
  }
  // UTF-16 BE BOM (FE FF)
  if (bytes.length >= 2 && bytes[0] == 0xFE && bytes[1] == 0xFF) {
    return _decodeUtf16(bytes, bigEndian: true);
  }
  // UTF-8 with optional BOM stripping
  var decoded = utf8.decode(bytes, allowMalformed: true);
  if (decoded.startsWith('﻿')) {
    decoded = decoded.substring(1);
  }
  return decoded;
}

/// How much of a file [looksLikeBinary] looks at.
const int _binaryProbeBytes = 8192;

/// True when [bytes] look like a binary file (a photo, a PDF, an archive)
/// rather than text.
///
/// Without this, any file decodes to *some* text and the ChordPro parser turns
/// any text into a song, so opening a photo saved a song full of garbage
/// (CLAUDE.md hard rule 4). Only the first 8 KB are checked. A zero byte, or
/// more than 10 % of the characters failing to decode as UTF-8, means binary.
/// A file with a UTF-16 byte-order mark is text: UTF-16 holds zero bytes
/// legitimately. Empty input is not binary. Never throws.
bool looksLikeBinary(Uint8List bytes) {
  if (bytes.isEmpty) return false;
  if (bytes.length >= 2 &&
      ((bytes[0] == 0xFF && bytes[1] == 0xFE) ||
          (bytes[0] == 0xFE && bytes[1] == 0xFF))) {
    return false;
  }
  final probe = bytes.length > _binaryProbeBytes
      ? Uint8List.sublistView(bytes, 0, _binaryProbeBytes)
      : bytes;
  if (probe.contains(0)) return true;

  final decoded = utf8.decode(probe, allowMalformed: true);
  if (decoded.isEmpty) return false;
  var bad = 0;
  for (final rune in decoded.runes) {
    if (rune == 0xFFFD) bad++;
  }
  // The probe may cut a multi-byte letter in half at its end; one stray
  // replacement character there is not a sign of a binary file.
  if (bad <= 1) return false;
  return bad / decoded.runes.length > 0.10;
}

/// Decodes UTF-16 [bytes] that start with a 2-byte byte-order mark.
String _decodeUtf16(Uint8List bytes, {required bool bigEndian}) {
  final length = (bytes.length - 2) ~/ 2;
  final units = Uint16List(length);
  for (var i = 0; i < length; i++) {
    final first = bytes[2 + i * 2];
    final second = bytes[2 + i * 2 + 1];
    units[i] = bigEndian ? (first << 8) | second : (second << 8) | first;
  }
  return String.fromCharCodes(units);
}
