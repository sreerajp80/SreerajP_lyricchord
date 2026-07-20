import 'package:flutter/services.dart';

/// Puts `[Chord]` into the lyrics text at the caret.
///
/// Kept as a plain function (not a widget method) so it can be unit tested
/// without building a screen.
///
/// - If text is selected, the selection is replaced.
/// - If the field was never focused there is no valid selection, so the chord
///   is added at the end.
/// - The caret ends up right after the inserted text, so typing carries on
///   where the user left off.
TextEditingValue insertChord(TextEditingValue value, String chord) {
  final marker = '[${chord.trim()}]';
  final text = value.text;
  final selection = value.selection;

  final hasSelection =
      selection.isValid &&
      selection.start >= 0 &&
      selection.end <= text.length &&
      selection.start <= selection.end;

  final start = hasSelection ? selection.start : text.length;
  final end = hasSelection ? selection.end : text.length;

  final newText = text.replaceRange(start, end, marker);
  final caret = start + marker.length;

  return TextEditingValue(
    text: newText,
    selection: TextSelection.collapsed(offset: caret),
  );
}
