import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lyricchord/services/melody_audio_service.dart';
import 'package:lyricchord/services/melody_parser_service.dart';
import 'package:lyricchord/services/melody_player_service.dart';
import 'package:lyricchord/widgets/melody_line_row.dart';

/// Records what the row asked for, without any real audio device.
class _FakeMelodyAudio implements MelodyAudio {
  MelodySchedule? lastPlayed;
  bool lastLoop = false;
  int stopCalls = 0;
  bool succeed = true;

  @override
  Future<bool> play(MelodySchedule schedule, {bool loop = false}) async {
    lastPlayed = schedule;
    lastLoop = loop;
    return succeed;
  }

  @override
  Future<void> stop() async => stopCalls++;

  @override
  Future<void> setVolume(double volume) async {}

  @override
  Future<void> dispose() async {}
}

void main() {
  const parser = MelodyParser();
  const tonic = 261.63;

  late _FakeMelodyAudio audio;

  setUp(() => audio = _FakeMelodyAudio());

  Future<void> pumpRow(
    WidgetTester tester, {
    String melody = '{melody} P , M2 | M2!G3~ ,  | R2 S',
    double? tonicHz = tonic,
    double? tempoBpm = 68,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [melodyAudioProvider.overrideWithValue(audio)],
        child: MaterialApp(
          home: Scaffold(
            body: MelodyLineRow(
              melody: parser.parse(melody),
              tonicHz: tonicHz,
              tempoBpm: tempoBpm,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('draws the beat grid with a play button', (tester) async {
    await pumpRow(tester);
    expect(find.byIcon(Icons.play_circle), findsOneWidget);
    expect(find.text('P'), findsOneWidget);
    expect(find.text('M2!G3~'), findsOneWidget);
  });

  testWidgets('tapping play sends the schedule to the audio', (tester) async {
    await pumpRow(tester);
    await tester.tap(find.byIcon(Icons.play_circle));
    await tester.pump();

    expect(audio.lastPlayed, isNotNull);
    expect(audio.lastPlayed!.spans, isNotEmpty);
    expect(find.byIcon(Icons.stop_circle), findsOneWidget);

    // Stop the timer so the test does not leave one running.
    await tester.tap(find.byIcon(Icons.stop_circle));
    await tester.pump();
    expect(audio.stopCalls, 1);
  });

  testWidgets('with no tonic the grid draws but play is off', (tester) async {
    await pumpRow(tester, tonicHz: null);

    final button = tester.widget<IconButton>(find.byType(IconButton));
    expect(button.onPressed, isNull);
    expect(find.text('P'), findsOneWidget);
    expect(audio.lastPlayed, isNull);
  });

  testWidgets('with no tempo play is off too', (tester) async {
    await pumpRow(tester, tempoBpm: null);
    final button = tester.widget<IconButton>(find.byType(IconButton));
    expect(button.onPressed, isNull);
  });

  testWidgets('loop and half speed appear once it is playing', (tester) async {
    await pumpRow(tester);
    expect(find.text('Loop'), findsNothing);

    await tester.tap(find.byIcon(Icons.play_circle));
    await tester.pump();

    expect(find.text('Loop'), findsOneWidget);
    expect(find.text('Half speed'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.stop_circle));
    await tester.pump();
  });

  testWidgets('half speed makes the line take twice as long', (tester) async {
    await pumpRow(tester);

    await tester.tap(find.byIcon(Icons.play_circle));
    await tester.pump();
    final fullSpeed = audio.lastPlayed!.total;

    await tester.tap(find.text('Half speed'));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.play_circle));
    await tester.pump();

    expect(audio.lastPlayed!.total, fullSpeed * 2);

    await tester.tap(find.byIcon(Icons.stop_circle));
    await tester.pump();
  });

  testWidgets('loop is passed through to the audio', (tester) async {
    await pumpRow(tester);

    await tester.tap(find.byIcon(Icons.play_circle));
    await tester.pump();
    expect(audio.lastLoop, isFalse);

    await tester.tap(find.text('Loop'));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.stop_circle));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.play_circle));
    await tester.pump();

    expect(audio.lastLoop, isTrue);

    await tester.tap(find.byIcon(Icons.stop_circle));
    await tester.pump();
  });

  testWidgets('says so when the sound will not start', (tester) async {
    audio.succeed = false;
    await pumpRow(tester);

    await tester.tap(find.byIcon(Icons.play_circle));
    await tester.pump();

    expect(find.text('Could not play this melody.'), findsOneWidget);
    // Never left showing a cursor over silence.
    expect(find.byIcon(Icons.stop_circle), findsNothing);
  });

  testWidgets('shows a problem with an unreadable beat', (tester) async {
    await pumpRow(tester, melody: '{melody} S X G');
    expect(find.textContaining('Could not read'), findsOneWidget);
    expect(find.text('X'), findsOneWidget);
  });
}
