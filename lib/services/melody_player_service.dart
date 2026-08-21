/// Works out *when* each note of a melody line sounds, and at what pitch.
///
/// Pure logic — no audio, no widgets, no timers. It turns a `MelodyLine` plus a
/// tonic and a tempo into a plain list of spans, which the audio layer renders
/// and the grid uses to move its cursor. Keeping the arithmetic here is what
/// makes the timing testable without playing a sound (architecture §4).
///
/// **Phase 1 ignores the gamaka marks.** A slide (`!`) and a shake (`~`) are
/// parsed and carried on the note, but every span comes out as a steady tone.
/// Shaping them is phase 3; writing them now means files stay correct until
/// then.
library;

import 'dart:math' as math;

import 'package:lyricchord/models/melody_beat.dart';
import 'package:lyricchord/models/melody_line.dart';
import 'package:lyricchord/models/melody_note.dart';

/// One stretch of sound (or silence) in a scheduled melody.
class MelodySpan {
  /// Pitch in Hz. Zero means silence — an unreadable beat, or a hold with
  /// nothing before it.
  final double frequency;

  /// When this span starts, measured from the beginning of the line.
  final Duration start;

  /// How long it sounds.
  final Duration duration;

  /// Which beat of `MelodyLine.beats` this came from, so the grid can light up
  /// the right box.
  final int beatIndex;

  /// The note itself, or `null` for silence. Carries the slide and shake marks
  /// for phase 3.
  final MelodyNote? note;

  const MelodySpan({
    required this.frequency,
    required this.start,
    required this.duration,
    required this.beatIndex,
    this.note,
  });

  /// When this span ends.
  Duration get end => start + duration;

  /// True when nothing is sung for this span.
  bool get isSilence => frequency <= 0;

  @override
  String toString() =>
      'MelodySpan(${frequency.toStringAsFixed(1)}Hz, '
      '${start.inMilliseconds}ms +${duration.inMilliseconds}ms)';
}

/// A whole melody line laid out in time.
class MelodySchedule {
  /// The spans, in order, with no gaps between them.
  final List<MelodySpan> spans;

  /// How long the whole line takes.
  final Duration total;

  const MelodySchedule({required this.spans, required this.total});

  /// An empty schedule — nothing to play.
  static const MelodySchedule empty = MelodySchedule(
    spans: [],
    total: Duration.zero,
  );

  /// True when there is nothing to play.
  bool get isEmpty => spans.isEmpty;

  /// Which beat is sounding at [position], or `null` when nothing is.
  ///
  /// This is what moves the cursor along the grid.
  int? beatAt(Duration position) {
    for (final span in spans) {
      if (position >= span.start && position < span.end) return span.beatIndex;
    }
    return null;
  }
}

/// Turns a parsed melody line into a timed schedule.
class MelodyPlayerService {
  const MelodyPlayerService();

  /// Full speed. Passed as `speed` to [schedule].
  static const double normalSpeed = 1.0;

  /// Half speed, for learning a line before singing it up to tempo.
  static const double halfSpeed = 0.5;

  /// The frequency of a note [semitonesFromSa] away from a Sa at [tonicHz].
  ///
  /// Equal steps for now. Real singing tunes each swara as a whole-number ratio
  /// against the drone, which sounds noticeably more locked in — that swap is
  /// phase 3 and changes nothing else, because only this one line decides pitch.
  double frequencyOf(int semitonesFromSa, double tonicHz) =>
      tonicHz * math.pow(2, semitonesFromSa / 12.0);

  /// Lays [line] out in time.
  ///
  /// [tempoBpm] is beats per minute at full speed; [speed] scales it, so
  /// [halfSpeed] makes every note twice as long. A tempo or tonic that is zero
  /// or negative gives an empty schedule rather than a division by zero.
  MelodySchedule schedule(
    MelodyLine line, {
    required double tonicHz,
    required double tempoBpm,
    double speed = normalSpeed,
  }) {
    if (tonicHz <= 0 || tempoBpm <= 0 || speed <= 0) {
      return MelodySchedule.empty;
    }
    if (line.isEmpty) return MelodySchedule.empty;

    final beatMicros = (60000000 / (tempoBpm * speed)).round();
    if (beatMicros <= 0) return MelodySchedule.empty;

    final spans = <MelodySpan>[];
    var cursor = Duration.zero;

    for (var beatIndex = 0; beatIndex < line.beats.length; beatIndex++) {
      final beat = line.beats[beatIndex];
      final beatLength = Duration(microseconds: beatMicros);

      switch (beat.kind) {
        // Takes no time at all — it only marks where a tala group starts.
        case MelodyBeatKind.barLine:
          continue;

        // Keep the note before it sounding. Stretching the last span rather
        // than adding a new one is what stops the note being struck again.
        case MelodyBeatKind.hold:
          if (spans.isEmpty || spans.last.isSilence) {
            spans.add(
              MelodySpan(
                frequency: 0,
                start: cursor,
                duration: beatLength,
                beatIndex: beatIndex,
              ),
            );
          } else {
            final last = spans.removeLast();
            spans.add(
              MelodySpan(
                frequency: last.frequency,
                start: last.start,
                duration: last.duration + beatLength,
                beatIndex: last.beatIndex,
                note: last.note,
              ),
            );
          }
          cursor += beatLength;

        // Silence, but it still takes its beat. Dropping it would shift every
        // later note earlier and quietly break the rest of the line.
        case MelodyBeatKind.unknown:
          spans.add(
            MelodySpan(
              frequency: 0,
              start: cursor,
              duration: beatLength,
              beatIndex: beatIndex,
            ),
          );
          cursor += beatLength;

        case MelodyBeatKind.notes:
          final totalSlots = beat.totalSlots;
          var used = 0;
          for (var i = 0; i < beat.notes.length; i++) {
            final note = beat.notes[i];
            final slots = beat.slotsAt(i);

            // Measured from the beat's own start each time, so rounding cannot
            // build up across a beat of three or five notes.
            final from = Duration(
              microseconds: (beatMicros * used / totalSlots).round(),
            );
            final to = Duration(
              microseconds: (beatMicros * (used + slots) / totalSlots).round(),
            );

            spans.add(
              MelodySpan(
                frequency: frequencyOf(note.semitonesFromSa, tonicHz),
                start: cursor + from,
                duration: to - from,
                beatIndex: beatIndex,
                note: note,
              ),
            );
            used += slots;
          }
          cursor += beatLength;
      }
    }

    return MelodySchedule(spans: spans, total: cursor);
  }
}
