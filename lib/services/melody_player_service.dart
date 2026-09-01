/// Works out *when* each note of a melody line sounds, and at what pitch.
///
/// Pure logic — no audio, no widgets, no timers. It turns a `MelodyLine` plus a
/// tonic and a tempo into a plain list of spans, which the audio layer renders
/// and the grid uses to move its cursor. Keeping the arithmetic here is what
/// makes the timing testable without playing a sound (architecture §4).
///
/// Both gamaka marks reach the sound. A slide (`!`) sets the pitch the note is
/// approached from; a shake (`~`) sets a swing rate and depth, worked out here
/// because the rate follows the tempo. The synth renders both — see
/// `PcmSynthService.slideFrequency` and `PcmSynthService.shakeFactor`.
///
/// Pitch is tuned in whole-number ratios against the drone, not in equal steps.
/// See [MelodyPlayerService.justRatios].
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

  /// The note itself, or `null` for silence.
  final MelodyNote? note;

  /// How fast the note shakes, in Hz, or `null` when it does not shake.
  ///
  /// Only set for a note carrying `~` that is long enough to hold a full swing.
  /// The rate is metrical — see [MelodyPlayerService.shakeHzFor].
  final double? shakeHz;

  /// How far the shake swings above the note, in semitones. Zero when it does
  /// not shake.
  final double shakeDepthSemitones;

  /// Where a slide into this note begins, in Hz, or `null` when it does not
  /// slide.
  ///
  /// Worked out here rather than in the audio layer because this is the only
  /// place that knows both the note's `slideFrom` and the song's tonic.
  final double? fromFrequency;

  const MelodySpan({
    required this.frequency,
    required this.start,
    required this.duration,
    required this.beatIndex,
    this.note,
    this.fromFrequency,
    this.shakeHz,
    this.shakeDepthSemitones = 0,
  });

  /// When this span ends.
  Duration get end => start + duration;

  /// True when this span's pitch swings rather than holding still.
  bool get shakes =>
      (shakeHz ?? 0) > 0 && shakeDepthSemitones > 0 && frequency > 0;

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

  /// How each of the twelve keys is tuned against Sa, as a whole-number ratio.
  ///
  /// Not equal steps. A singer tunes to the drone, not to a piano, and the
  /// difference is audible on a held note: the drone's Pa is exactly
  /// `1.5 x Sa` (`PcmSynthService.generateShrutiDroneWav`), while an equal
  /// tempered Pa is two cents flat of that, so a held Pa beats slowly against
  /// the very thing it should lock into. These ratios remove that beating.
  ///
  /// | Position | Swara | Ratio | Cents | Equal temp |
  /// |---|---|---|---|---|
  /// | 0 | Sa | 1/1 | 0 | 0 |
  /// | 1 | Ri 1 | 16/15 | 112 | 100 |
  /// | 2 | Ri 2 | 9/8 | 204 | 200 |
  /// | 3 | Ri 3 / Ga 2 | 6/5 | 316 | 300 |
  /// | 4 | Ga 3 | 5/4 | 386 | 400 |
  /// | 5 | Ma 1 | 4/3 | 498 | 500 |
  /// | 6 | Ma 2 | 45/32 | 590 | 600 |
  /// | 7 | Pa | 3/2 | 702 | 700 |
  /// | 8 | Dha 1 | 8/5 | 814 | 800 |
  /// | 9 | Dha 2 / Ni 1 | 5/3 | 884 | 900 |
  /// | 10 | Dha 3 / Ni 2 | 16/9 | 996 | 1000 |
  /// | 11 | Ni 3 | 15/8 | 1088 | 1100 |
  ///
  /// Ma 2 is the one with no clean answer — 45/32 and 64/45 are both defended
  /// in the literature. 45/32 is used because it is reachable from the notes
  /// around it (`5/4 x 9/8`), so a Ga3-Ma2 phrase stays in tune with itself.
  ///
  /// This is the **twelve-key** scheme, not the 22-sruti one. A position that
  /// carries two names (3, 9, 10) gets one tuning, because the app models one
  /// key there — see `docs/carnatic_notation.md` §2.
  static const List<double> justRatios = [
    1.0, // Sa        1/1
    16 / 15, // Ri 1
    9 / 8, // Ri 2
    6 / 5, // Ri 3 / Ga 2
    5 / 4, // Ga 3
    4 / 3, // Ma 1
    45 / 32, // Ma 2
    3 / 2, // Pa
    8 / 5, // Dha 1
    5 / 3, // Dha 2 / Ni 1
    16 / 9, // Dha 3 / Ni 2
    15 / 8, // Ni 3
  ];

  /// The frequency of a note [semitonesFromSa] away from a Sa at [tonicHz].
  ///
  /// The ratio comes from [justRatios]; the octave is a plain doubling, so the
  /// same swara is in tune with itself wherever it is sung. This is the only
  /// place in the app that turns a swara into a pitch.
  double frequencyOf(int semitonesFromSa, double tonicHz) {
    // Floor division, so a note below Sa lands in the octave below with a
    // position of 0-11 rather than a negative index.
    final octave = (semitonesFromSa / 12).floor();
    final position = semitonesFromSa - octave * 12;
    return tonicHz * math.pow(2, octave) * justRatios[position];
  }

  /// How far the shake (`~`, kampita) swings above the written note.
  ///
  /// One key. The swing goes **up from the note and back**, never around it, so
  /// the written pitch stays what the ear anchors on. Without raga grammar — of
  /// which the app holds none, by decision — a wider swing risks landing on a
  /// note the raga does not contain.
  static const double shakeDepthSemitones = 1.0;

  /// Swings per beat. A gamaka moves with the tala, not at a fixed vibrato
  /// speed, so the rate is worked out from the tempo.
  static const double shakeSwingsPerBeat = 2.0;

  /// The slowest and fastest the shake may run, whatever the tempo.
  ///
  /// A very slow song would otherwise give a lazy scoop and a fast one a buzz,
  /// and neither reads as a shake.
  static const double shakeMinHz = 3.0;
  static const double shakeMaxHz = 8.0;

  /// A note shorter than this is sung plain, however it is marked.
  ///
  /// There is no room for a full swing in less, and half a swing sounds like a
  /// wobble rather than a gamaka.
  static const double shakeMinNoteSeconds = 0.18;

  /// How fast a shake swings at [tempoBpm] beats per minute, in Hz.
  ///
  /// Worked out here rather than in the synth because this is the layer that
  /// knows the tempo — the same split that puts the slide's start pitch here,
  /// because only this layer knows the tonic.
  double shakeHzFor(double tempoBpm) {
    if (tempoBpm <= 0) return shakeMinHz;
    final hz = tempoBpm / 60.0 * shakeSwingsPerBeat;
    return hz.clamp(shakeMinHz, shakeMaxHz);
  }

  /// How far below the note a bare `!` starts, in semitones.
  ///
  /// `M2!G3` says where to slide from. A plain `!G3` does not, so it scoops in
  /// from its nearest neighbour — enough to hear as a slide, not so much that it
  /// sounds like a different note being sung first.
  static const int bareSlideSemitones = 1;

  /// The pitch a slide into [note] starts from, or `null` when it does not
  /// slide.
  double? slideFromHz(MelodyNote note, double tonicHz) {
    if (!note.slide) return null;
    final from = note.slideFrom;
    if (from != null) return frequencyOf(from.semitonesFromSa, tonicHz);
    return frequencyOf(note.semitonesFromSa - bareSlideSemitones, tonicHz);
  }

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
                fromFrequency: last.fromFrequency,
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
          for (final part in beat.parts) {
            final slots = part.count <= 0 ? 1 : part.count;

            // Measured from the beat's own start each time, so rounding cannot
            // build up across a beat of three or five notes.
            final from = Duration(
              microseconds: (beatMicros * used / totalSlots).round(),
            );
            final to = Duration(
              microseconds: (beatMicros * (used + slots) / totalSlots).round(),
            );
            used += slots;

            switch (part.kind) {
              case MelodySlotKind.note:
                final note = part.note!;
                spans.add(
                  MelodySpan(
                    frequency: frequencyOf(note.semitonesFromSa, tonicHz),
                    start: cursor + from,
                    duration: to - from,
                    beatIndex: beatIndex,
                    note: note,
                    fromFrequency: slideFromHz(note, tonicHz),
                  ),
                );

              // Stops whatever was ringing and takes its share of the beat.
              case MelodySlotKind.silence:
                spans.add(
                  MelodySpan(
                    frequency: 0,
                    start: cursor + from,
                    duration: to - from,
                    beatIndex: beatIndex,
                  ),
                );

              // Carries the previous sound on. Stretching the last span rather
              // than adding one is what stops the note being struck again — the
              // same trick the whole-beat hold uses above.
              case MelodySlotKind.tie:
                if (spans.isEmpty || spans.last.isSilence) {
                  spans.add(
                    MelodySpan(
                      frequency: 0,
                      start: cursor + from,
                      duration: to - from,
                      beatIndex: beatIndex,
                    ),
                  );
                } else {
                  final last = spans.removeLast();
                  spans.add(
                    MelodySpan(
                      frequency: last.frequency,
                      start: last.start,
                      duration: last.duration + (to - from),
                      beatIndex: last.beatIndex,
                      note: last.note,
                      fromFrequency: last.fromFrequency,
                    ),
                  );
                }
            }
          }
          cursor += beatLength;
      }
    }

    return MelodySchedule(
      spans: _withShake(spans, tempoBpm * speed),
      total: cursor,
    );
  }

  /// Marks the spans that shake, once every span has its final length.
  ///
  /// This runs at the end rather than when each span is made, because a hold or
  /// a tie **stretches** the span before it. `Ga3~ ,` is one long note, and
  /// deciding on the shake from the first beat alone would call it too short.
  ///
  /// [beatsPerMinute] is the played tempo, speed already applied, so a line
  /// slowed to half speed shakes half as fast — the swings stay on the beat.
  List<MelodySpan> _withShake(List<MelodySpan> spans, double beatsPerMinute) {
    final rate = shakeHzFor(beatsPerMinute);

    return spans
        .map((span) {
          final note = span.note;
          if (note == null || !note.shake || span.isSilence) return span;

          // Too short to hold a full swing, so it is sung plain.
          final seconds = span.duration.inMicroseconds / 1000000;
          if (seconds < shakeMinNoteSeconds) return span;

          return MelodySpan(
            frequency: span.frequency,
            start: span.start,
            duration: span.duration,
            beatIndex: span.beatIndex,
            note: note,
            fromFrequency: span.fromFrequency,
            shakeHz: rate,
            shakeDepthSemitones: shakeDepthSemitones,
          );
        })
        .toList(growable: false);
  }
}
