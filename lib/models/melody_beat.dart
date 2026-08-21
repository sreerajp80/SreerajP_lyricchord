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

/// One beat, or a bar line.
class MelodyBeat {
  /// What this beat holds.
  final MelodyBeatKind kind;

  /// The notes sharing this beat. Empty for anything but [MelodyBeatKind.notes].
  final List<MelodyNote> notes;

  /// How many sub-slots each note in [notes] takes, in the same order.
  ///
  /// Normally every note takes one slot, so `G3-R2` is `[1, 1]` — half a beat
  /// each. A comma inside the group extends the note before it instead of
  /// adding a note, so `G3-,-R2` is `[2, 1]`: Ga for two thirds of the beat,
  /// Ri for the last third.
  final List<int> slots;

  /// The token exactly as the writer typed it.
  final String text;

  const MelodyBeat({
    required this.kind,
    required this.text,
    this.notes = const [],
    this.slots = const [],
  });

  /// A beat holding notes that share it, weighted by [slots].
  ///
  /// Passing no [slots] gives every note one slot, so they share the beat
  /// equally.
  const MelodyBeat.notes(this.notes, this.text, {this.slots = const []})
    : kind = MelodyBeatKind.notes;

  /// A comma — hold the note before it.
  const MelodyBeat.hold([this.text = ','])
    : kind = MelodyBeatKind.hold,
      notes = const [],
      slots = const [];

  /// A bar line, which takes no time.
  const MelodyBeat.barLine([this.text = '|'])
    : kind = MelodyBeatKind.barLine,
      notes = const [],
      slots = const [];

  /// A token that could not be read.
  const MelodyBeat.unknown(this.text)
    : kind = MelodyBeatKind.unknown,
      notes = const [],
      slots = const [];

  /// How many slots [notes] takes up between them.
  ///
  /// Falls back to one slot per note when [slots] was left out, and never
  /// returns zero — the player divides by this.
  int get totalSlots {
    if (slots.isEmpty) return notes.isEmpty ? 1 : notes.length;
    var total = 0;
    for (final slot in slots) {
      total += slot;
    }
    return total <= 0 ? 1 : total;
  }

  /// How many slots the note at [index] takes.
  int slotsAt(int index) {
    if (index < 0 || index >= notes.length) return 1;
    if (index >= slots.length) return 1;
    final slot = slots[index];
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
    if (other.notes.length != notes.length) return false;
    for (var i = 0; i < notes.length; i++) {
      if (other.notes[i] != notes[i]) return false;
      if (other.slotsAt(i) != slotsAt(i)) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
    kind,
    text,
    Object.hashAll(notes),
    Object.hashAll(List<int>.generate(notes.length, slotsAt)),
  );

  @override
  String toString() => 'MelodyBeat.${kind.name}($text)';
}
