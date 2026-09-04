import 'package:flutter_test/flutter_test.dart';
import 'package:lyricchord/screens/help/help_content.dart';

/// The Help hub and every detail page are built straight from [helpTopics], so
/// a badly formed topic would show an empty card or an empty page instead of
/// failing loudly. These checks keep that from shipping.
void main() {
  group('helpTopics', () {
    test('every id is unique', () {
      final ids = helpTopics.map((topic) => topic.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('every id is a safe route segment', () {
      for (final topic in helpTopics) {
        expect(
          RegExp(r'^[a-z0-9-]+$').hasMatch(topic.id),
          isTrue,
          reason: '"${topic.id}" is used in /settings/help/<id>',
        );
      }
    });

    test('every topic has a title, a summary, an intro and sections', () {
      for (final topic in helpTopics) {
        expect(topic.title.trim(), isNotEmpty, reason: topic.id);
        expect(topic.summary.trim(), isNotEmpty, reason: topic.id);
        expect(topic.intro.trim(), isNotEmpty, reason: topic.id);
        expect(topic.sections, isNotEmpty, reason: topic.id);
      }
    });

    test('every section has a heading and something to show', () {
      for (final topic in helpTopics) {
        for (final section in topic.sections) {
          expect(section.heading.trim(), isNotEmpty, reason: topic.id);
          final hasPoints = section.points.isNotEmpty;
          final hasGestures = section.gestureItems?.isNotEmpty ?? false;
          expect(
            hasPoints || hasGestures,
            isTrue,
            reason: '${topic.id} / ${section.heading}',
          );
          for (final point in section.points) {
            expect(point.trim(), isNotEmpty, reason: topic.id);
          }
        }
      }
    });

    test('the topics people look for are all present', () {
      final ids = helpTopics.map((topic) => topic.id).toSet();
      expect(
        ids,
        containsAll(<String>[
          'songbook',
          'editor',
          'setlists',
          'transpose',
          'auto-scroll',
          'full-screen',
          'metronome',
          'pitch-pipe-drone',
          'melody',
          'indian-songs',
          'select-songs',
          'import',
          'export',
          'airqr',
          'appearance',
        ]),
      );
    });

    test('helpTopicById finds a topic and returns null for an unknown id', () {
      expect(helpTopicById('setlists')?.title, 'Setlists');
      expect(helpTopicById('no-such-topic'), isNull);
    });
  });
}
