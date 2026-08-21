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

    test('Pa is a fifth above Sa', () {
      expect(player.frequencyOf(7, tonic), closeTo(392.0, 0.5));
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
        parser.parse('{melody} S X G'),
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
}
