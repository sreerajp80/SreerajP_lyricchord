import 'package:flutter_test/flutter_test.dart';
import 'package:lyricchord/services/melody_parser_service.dart';
import 'package:lyricchord/services/melody_player_service.dart';

void main() {
  const parser = MelodyParser();
  const player = MelodyPlayerService();

  // 60 bpm makes one beat exactly one second, so every expectation below reads
  // as plain arithmetic instead of a rounded millisecond count.
  const tempo = 60.0;
  const tonic = 261.63; // C4

  group('frequencyOf', () {
    test('Sa is the tonic itself', () {
      expect(player.frequencyOf(0, tonic), closeTo(tonic, 0.001));
    });

    test('an octave up doubles, an octave down halves', () {
      expect(player.frequencyOf(12, tonic), closeTo(tonic * 2, 0.001));
      expect(player.frequencyOf(-12, tonic), closeTo(tonic / 2, 0.001));
    });

    test('Pa lands exactly on the drone fifth', () {
      // The shruti drone sounds Pa at exactly 1.5 x Sa. The melody must agree,
      // or a held Pa beats slowly against the drone it should lock into.
      expect(player.frequencyOf(7, tonic), closeTo(tonic * 1.5, 0.001));
    });

    test('Ma1 lands exactly on the drone fourth', () {
      expect(player.frequencyOf(5, tonic), closeTo(tonic * 4 / 3, 0.001));
    });

    test('every key is its whole-number ratio', () {
      const ratios = [
        1.0,
        16 / 15,
        9 / 8,
        6 / 5,
        5 / 4,
        4 / 3,
        45 / 32,
        3 / 2,
        8 / 5,
        5 / 3,
        16 / 9,
        15 / 8,
      ];

      for (var position = 0; position < ratios.length; position++) {
        expect(
          player.frequencyOf(position, tonic),
          closeTo(tonic * ratios[position], 0.001),
          reason: 'position $position',
        );
      }
    });

    test('the ratios are used in every octave, above and below', () {
      // Ga3 is 5/4 wherever it is sung.
      expect(player.frequencyOf(4 + 12, tonic), closeTo(tonic * 2.5, 0.001));
      expect(player.frequencyOf(4 - 12, tonic), closeTo(tonic * 0.625, 0.001));
    });

    test('it is not equal temperament', () {
      // Ga3 is the widest gap: just 5/4 is about 14 cents flat of the equal
      // tempered major third, which is what makes a held third sound settled.
      final just = player.frequencyOf(4, tonic);
      const equal = tonic * 1.259921; // 2^(4/12)
      expect(just, lessThan(equal));
      expect(equal - just, greaterThan(2.0));
    });
  });

  group('the shake', () {
    /// The one span of a single-note line.
    MelodySpan only(String melody, {double bpm = tempo}) => player
        .schedule(parser.parse(melody), tonicHz: tonic, tempoBpm: bpm)
        .spans
        .first;

    test('a plain note does not shake', () {
      expect(only('{melody} G3').shakes, isFalse);
    });

    test('a marked note shakes', () {
      final span = only('{melody} G3~');
      expect(span.shakes, isTrue);
      expect(span.shakeDepthSemitones, MelodyPlayerService.shakeDepthSemitones);
    });

    test('the swing follows the tempo', () {
      // 120 bpm x 2 swings a beat = 4 Hz.
      expect(only('{melody} G3~', bpm: 120).shakeHz, closeTo(4.0, 0.001));
      expect(player.shakeHzFor(90), closeTo(3.0, 0.001));
    });

    test('the swing is clamped at both ends', () {
      // A crawl would give a lazy scoop, a sprint a buzz; neither reads as a
      // shake.
      expect(player.shakeHzFor(40), MelodyPlayerService.shakeMinHz);
      expect(player.shakeHzFor(400), MelodyPlayerService.shakeMaxHz);
    });

    test('a note too short for a full swing is sung plain', () {
      // At 240 bpm a beat is 250 ms, and four notes sharing it are 62 ms each.
      final schedule = player.schedule(
        parser.parse('{melody} G3~-R2~-S~-N3~'),
        tonicHz: tonic,
        tempoBpm: 240,
      );
      for (final span in schedule.spans) {
        expect(span.shakes, isFalse);
      }
    });

    test('a held note is long enough, even when its own beat is not', () {
      // At 400 bpm a beat is 150 ms — under the minimum on its own. The hold
      // stretches the note to 300 ms, which is over it, so the decision has to
      // wait until every span has its final length.
      expect(only('{melody} G3~', bpm: 400).shakes, isFalse);
      expect(only('{melody} G3~ ,', bpm: 400).shakes, isTrue);
    });

    test('slowing the line down slows the swing with it', () {
      final full = player.schedule(
        parser.parse('{melody} G3~'),
        tonicHz: tonic,
        tempoBpm: 180,
      );
      final half = player.schedule(
        parser.parse('{melody} G3~'),
        tonicHz: tonic,
        tempoBpm: 180,
        speed: MelodyPlayerService.halfSpeed,
      );

      expect(full.spans.first.shakeHz, closeTo(6.0, 0.001));
      expect(half.spans.first.shakeHz, closeTo(3.0, 0.001));
    });

    test('a note that slides and shakes carries both', () {
      final span = only('{melody} M2!G3~');
      expect(span.shakes, isTrue);
      expect(span.fromFrequency, closeTo(player.frequencyOf(6, tonic), 0.001));
    });

    test('silence never shakes', () {
      final schedule = player.schedule(
        parser.parse('{melody} x'),
        tonicHz: tonic,
        tempoBpm: tempo,
      );
      expect(schedule.spans.first.shakes, isFalse);
    });
  });

  group('timing', () {
    test('one note per beat fills a second each', () {
      final schedule = player.schedule(
        parser.parse('{melody} S R G M'),
        tonicHz: tonic,
        tempoBpm: tempo,
      );
      expect(schedule.spans.length, 4);
      expect(schedule.total, const Duration(seconds: 4));
      for (final span in schedule.spans) {
        expect(span.duration, const Duration(seconds: 1));
      }
    });

    test('a bar line takes no time', () {
      final withBars = player.schedule(
        parser.parse('{melody} P , M | G , | R S'),
        tonicHz: tonic,
        tempoBpm: tempo,
      );
      expect(withBars.total, const Duration(seconds: 7));
    });

    test('a hold extends the note instead of striking it again', () {
      final schedule = player.schedule(
        parser.parse('{melody} S , , R'),
        tonicHz: tonic,
        tempoBpm: tempo,
      );
      expect(schedule.spans.length, 2);
      expect(schedule.spans.first.duration, const Duration(seconds: 3));
      expect(schedule.spans.last.duration, const Duration(seconds: 1));
      expect(schedule.total, const Duration(seconds: 4));
    });

    test('a shared beat splits evenly and still totals one beat', () {
      final schedule = player.schedule(
        parser.parse('{melody} M2-G3-R2-S'),
        tonicHz: tonic,
        tempoBpm: tempo,
      );
      expect(schedule.spans.length, 4);
      expect(schedule.total, const Duration(seconds: 1));
      for (final span in schedule.spans) {
        expect(span.duration.inMilliseconds, closeTo(250, 1));
      }
    });

    test('an odd split still adds up to exactly one beat', () {
      final schedule = player.schedule(
        parser.parse('{melody} G3-R2-S'),
        tonicHz: tonic,
        tempoBpm: tempo,
      );
      final sum = schedule.spans.fold<int>(
        0,
        (total, span) => total + span.duration.inMicroseconds,
      );
      expect(sum, 1000000);
    });

    test('a comma inside a group weights the split', () {
      final schedule = player.schedule(
        parser.parse('{melody} G3-,-R2'),
        tonicHz: tonic,
        tempoBpm: tempo,
      );
      expect(schedule.spans.length, 2);
      expect(schedule.spans.first.duration.inMilliseconds, closeTo(667, 1));
      expect(schedule.spans.last.duration.inMilliseconds, closeTo(333, 1));
    });

    test('spans run back to back with no gaps', () {
      final schedule = player.schedule(
        parser.parse('{melody} P , M2 | M2!G3~ ,  | R2 S'),
        tonicHz: tonic,
        tempoBpm: tempo,
      );
      for (var i = 1; i < schedule.spans.length; i++) {
        expect(schedule.spans[i].start, schedule.spans[i - 1].end);
      }
      expect(schedule.spans.last.end, schedule.total);
    });
  });

  group('speed', () {
    test('half speed doubles every duration', () {
      final line = parser.parse('{melody} S , R G');
      final full = player.schedule(line, tonicHz: tonic, tempoBpm: tempo);
      final half = player.schedule(
        line,
        tonicHz: tonic,
        tempoBpm: tempo,
        speed: MelodyPlayerService.halfSpeed,
      );
      expect(half.total, full.total * 2);
      for (var i = 0; i < full.spans.length; i++) {
        expect(half.spans[i].duration, full.spans[i].duration * 2);
      }
    });

    test('speed never changes the pitch', () {
      final line = parser.parse('{melody} S R G');
      final full = player.schedule(line, tonicHz: tonic, tempoBpm: tempo);
      final half = player.schedule(
        line,
        tonicHz: tonic,
        tempoBpm: tempo,
        speed: MelodyPlayerService.halfSpeed,
      );
      for (var i = 0; i < full.spans.length; i++) {
        expect(half.spans[i].frequency, full.spans[i].frequency);
      }
    });
  });

  group('unreadable input', () {
    test('an unknown beat is silence but keeps its beat', () {
      final schedule = player.schedule(
        parser.parse('{melody} S Q G'),
        tonicHz: tonic,
        tempoBpm: tempo,
      );
      expect(schedule.total, const Duration(seconds: 3));
      expect(schedule.spans[1].isSilence, isTrue);
      expect(schedule.spans[2].start, const Duration(seconds: 2));
    });

    test('a leading comma is silence, not a crash', () {
      final schedule = player.schedule(
        parser.parse('{melody} , S'),
        tonicHz: tonic,
        tempoBpm: tempo,
      );
      expect(schedule.spans.first.isSilence, isTrue);
      expect(schedule.total, const Duration(seconds: 2));
    });

    test('a bad tonic or tempo plays nothing rather than dividing by zero', () {
      final line = parser.parse('{melody} S R G');
      expect(
        player.schedule(line, tonicHz: 0, tempoBpm: tempo).isEmpty,
        isTrue,
      );
      expect(
        player.schedule(line, tonicHz: tonic, tempoBpm: 0).isEmpty,
        isTrue,
      );
      expect(
        player
            .schedule(line, tonicHz: tonic, tempoBpm: tempo, speed: 0)
            .isEmpty,
        isTrue,
      );
      expect(player.schedule(line, tonicHz: -1, tempoBpm: -1).isEmpty, isTrue);
    });

    test('an empty line plays nothing', () {
      expect(
        player
            .schedule(parser.parse('{melody}'), tonicHz: tonic, tempoBpm: tempo)
            .isEmpty,
        isTrue,
      );
    });
  });

  group('beatAt', () {
    test('finds the beat sounding at a moment', () {
      final line = parser.parse('{melody} S R | G M');
      final schedule = player.schedule(line, tonicHz: tonic, tempoBpm: tempo);
      expect(schedule.beatAt(const Duration(milliseconds: 500)), 0);
      expect(schedule.beatAt(const Duration(milliseconds: 1500)), 1);
      // Beat index 2 is the bar line, which takes no time, so the third sung
      // beat is index 3.
      expect(schedule.beatAt(const Duration(milliseconds: 2500)), 3);
      expect(schedule.beatAt(const Duration(seconds: 9)), isNull);
    });
  });

  group('the slide', () {
    const parser = MelodyParser();
    const player = MelodyPlayerService();

    MelodySchedule scheduleOf(String line) =>
        player.schedule(parser.parse(line), tonicHz: 240, tempoBpm: 60);

    test('a written start pitch is used', () {
      // Ma2 slides into Ga3: the glide starts on Ma, above the target.
      final span = scheduleOf('{melody} Ma2!Ga3').spans.first;

      expect(span.fromFrequency, isNotNull);
      expect(span.fromFrequency, greaterThan(span.frequency));
      expect(span.fromFrequency, closeTo(player.frequencyOf(6, 240), 0.01));
    });

    test('a bare ! scoops in from a semitone below', () {
      final span = scheduleOf('{melody} !Ga3').spans.first;

      expect(span.fromFrequency, isNotNull);
      expect(span.fromFrequency, lessThan(span.frequency));
      expect(span.fromFrequency, closeTo(player.frequencyOf(4 - 1, 240), 0.01));
    });

    test('a plain note has no glide', () {
      expect(scheduleOf('{melody} Ga3').spans.first.fromFrequency, isNull);
    });

    test('a slide held over a beat keeps its glide', () {
      // The hold stretches the span rather than adding one, so the glide has to
      // travel with it or the note would lose its slide when held.
      final spans = scheduleOf('{melody} !Ga3 ,').spans;

      expect(spans, hasLength(1));
      expect(spans.first.fromFrequency, isNotNull);
      expect(spans.first.duration.inMilliseconds, closeTo(2000, 50));
    });
  });
}
