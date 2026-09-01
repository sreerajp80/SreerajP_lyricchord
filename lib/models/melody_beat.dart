/// One beat of a melody line — or the bar line between two groups of beats.
///
/// A beat is the unit of *time*. Whatever sits inside it shares that time
/// equally, so `G3-R2` is two notes of half a beat each and `G3-R2-S` is three
/// of a third each.
library;

import 'package:lyricchord/models/melody_note.dart';

/// What a beat holds.
enum MelodyBeatKind {
  /// One or more notes, sharing the beat equally.
  notes,

  /// A comma: keep the note before this one sounding for one more beat.
  hold,

  /// A bar line. Takes no time — it only marks where a tala group starts, so
  /// the reader can keep their place and the grid can draw the groups.
  barLine,

  /// A token this could not read. Kept so the line still lines up with what the
  /// writer typed instead of silently shifting every later beat one place left
  /// (hard rule 4 — never crash, never corrupt).
  unknown,
}

/// What one slot inside a beat carries.
enum MelodySlotKind {
  /// A note, struck at the start of the slot.
  note,

  /// Nothing sounds. Written `x`.
  ///
  /// Different from [tie]: silence *stops* whatever was ringing, a tie keeps it
  /// going. Without this a note could not stop part-way through a beat.
  silence,

  /// Whatever sounded before keeps sounding. Written as a `,` in the first slot.
  ///
  /// This is what lets a note start part-way through a beat: the slots before it
  /// carry the previous sound rather than a new one.
  tie,
}

/// One slot inside a beat: a note, silence, or a tie to what came before.
///
/// Slots divide their beat equally, weighted by [count]. `Ga3-x` is two slots of
/// half a beat; `Ga3-,-x` is three of a third each, the first two being Ga.
class MelodySlot {
  final MelodySlotKind kind;

  /// The note, when [kind] is [MelodySlotKind.note]. `null` otherwise.
  final MelodyNote? note;

  /// How many sub-slots this takes. Always at least one.
  final int count;

  const MelodySlot.note(MelodyNote this.note, {this.count = 1})
    : kind = MelodySlotKind.note;

  const MelodySlot.silence({this.count = 1})
    : kind = MelodySlotKind.silence,
      note = null;

  const MelodySlot.tie({this.count = 1})
    : kind = MelodySlotKind.tie,
      note = null;

  /// A copy taking [count] sub-slots.
  MelodySlot withCount(int value) {
    final safe = value <= 0 ? 1 : value;
    return switch (kind) {
      MelodySlotKind.note => MelodySlot.note(note!, count: safe),
      MelodySlotKind.silence => MelodySlot.silence(count: safe),
      MelodySlotKind.tie => MelodySlot.tie(count: safe),
    };
  }

  @override
  bool operator ==(Object other) =>
      other is MelodySlot &&
      other.kind == kind &&
      other.note == note &&
      other.count == count;

  @override
  int get hashCode => Object.hash(kind, note, count);

  @override
  String toString() => 'MelodySlot.${kind.name}(${note?.text ?? ''} x$count)';
}

/// One beat, or a bar line.
class MelodyBeat {
  /// What this beat holds.
  final MelodyBeatKind kind;

  /// What this beat is made of, in order.
  ///
  /// This is the beat's real content. [notes] and [slots] are views onto it,
  /// kept because most callers only care about the notes.
  final List<MelodySlot> parts;

  /// The token exactly as the writer typed it.
  final String text;

  const MelodyBeat({
    required this.kind,
    required this.text,
    this.parts = const [],
  });

  /// A beat holding notes that share it, weighted by [slots].
  ///
  /// Passing no [slots] gives every note one slot, so they share the beat
  /// equally. Kept for callers that only ever write notes; a beat that needs
  /// silence or a tie uses [MelodyBeat.fromSlots].
  factory MelodyBeat.notes(
    List<MelodyNote> notes,
    String text, {
    List<int> slots = const [],
  }) {
    return MelodyBeat.fromSlots([
      for (var i = 0; i < notes.length; i++)
        MelodySlot.note(
          notes[i],
          count: i < slots.length && slots[i] > 0 ? slots[i] : 1,
        ),
    ], text);
  }

  /// A beat built from slots, which may be notes, silence or ties.
  const MelodyBeat.fromSlots(this.parts, this.text)
    : kind = MelodyBeatKind.notes;

  /// A comma — hold the note before it.
  const MelodyBeat.hold([this.text = ','])
    : kind = MelodyBeatKind.hold,
      parts = const [];

  /// A bar line, which takes no time.
  const MelodyBeat.barLine([this.text = '|'])
    : kind = MelodyBeatKind.barLine,
      parts = const [];

  /// A token that could not be read.
  const MelodyBeat.unknown(this.text)
    : kind = MelodyBeatKind.unknown,
      parts = const [];

  /// The notes in this beat, in order. Silence and ties are left out.
  List<MelodyNote> get notes => [
    for (final part in parts)
      if (part.note != null) part.note!,
  ];

  /// How many sub-slots each note in [notes] takes, in the same order.
  ///
  /// `G3-R2` is `[1, 1]` — half a beat each. A comma after a note extends it, so
  /// `G3-,-R2` is `[2, 1]`: Ga for two thirds of the beat, Ri for the last
  /// third.
  List<int> get slots => [
    for (final part in parts)
      if (part.note != null) part.count,
  ];

  /// How many slots the beat is divided into, counting silence and ties.
  ///
  /// Never returns zero — the player divides by this.
  int get totalSlots {
    if (parts.isEmpty) return 1;
    var total = 0;
    for (final part in parts) {
      total += part.count;
    }
    return total <= 0 ? 1 : total;
  }

  /// How many slots the note at [index] takes.
  int slotsAt(int index) {
    final list = slots;
    if (index < 0 || index >= list.length) return 1;
    final slot = list[index];
    return slot <= 0 ? 1 : slot;
  }

  /// True when this takes up a beat of time.
  ///
  /// Bar lines do not. Everything else does, including an unreadable token —
  /// dropping its time would shift the whole rest of the line.
  bool get takesTime => kind != MelodyBeatKind.barLine;

  @override
  bool operator ==(Object other) {
    if (other is! MelodyBeat) return false;
    if (other.kind != kind || other.text != text) return false;
    if (other.parts.length != parts.length) return false;
    for (var i = 0; i < parts.length; i++) {
      if (other.parts[i] != parts[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(kind, text, Object.hashAll(parts));

  @override
  String toString() => 'MelodyBeat.${kind.name}($text)';
}
