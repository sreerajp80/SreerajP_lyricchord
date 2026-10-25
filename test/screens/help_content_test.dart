import 'package:flutter_test/flutter_test.dart';
import 'package:lyricchord/l10n/app_localizations_en.dart';
import 'package:lyricchord/screens/help/help_content.dart';

/// The Help hub and every detail page are built straight from [helpTopics], so
/// a badly formed topic would show an empty card or an empty page instead of
/// failing loudly. These checks keep that from shipping.
void main() {
  final l10n = AppLocalizationsEn();
  final topics = helpTopics(l10n);

  group('helpTopics', () {
    test('every id is unique', () {
      final ids = topics.map((topic) => topic.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('every id is a safe route segment', () {
      for (final topic in topics) {
        expect(
          RegExp(r'^[a-z0-9-]+$').hasMatch(topic.id),
          isTrue,
          reason: '"${topic.id}" is used in /settings/help/<id>',
        );
      }
    });

    test('every topic has a title, a summary, an intro and sections', () {
      for (final topic in topics) {
        expect(topic.title.trim(), isNotEmpty, reason: topic.id);
        expect(topic.summary.trim(), isNotEmpty, reason: topic.id);
        expect(topic.intro.trim(), isNotEmpty, reason: topic.id);
        expect(topic.sections, isNotEmpty, reason: topic.id);
      }
    });

    test('every section has a heading and something to show', () {
      for (final topic in topics) {
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
      final ids = topics.map((topic) => topic.id).toSet();
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
      expect(helpTopicById(l10n, 'setlists')?.title, 'Setlists');
      expect(helpTopicById(l10n, 'no-such-topic'), isNull);
    });

    test('the whole help text moved, nothing lost', () {
      final sections = topics.expand((topic) => topic.sections).toList();
      final points = sections.expand((section) => section.points).length;
      final gestures = sections
          .expand((section) => section.gestureItems ?? const [])
          .length;
      expect(topics, hasLength(15));
      // Phase 8 added "Start fresh" (1 section, 3 points) to Your songbook.
      expect(sections, hasLength(74));
      expect(points, 283);
      expect(gestures, 9);
    });

    test('song syntax in braces shows as written', () {
      final melody = helpTopicById(l10n, 'melody')!;
      final text = melody.sections
          .expand((section) => section.points)
          .join(' ');
      expect(text, contains('Example: {melody} P ,  M2 | M2!G3~ ,  | R2 S'));
      expect(text, contains('{tonic: 1 kattai}'));
      expect(text, contains('{tala: misra chapu}'));
    });

    test('apostrophes show as one quote', () {
      final autoScroll = helpTopicById(l10n, 'auto-scroll')!;
      final text = autoScroll.sections
          .expand((section) => section.points)
          .join(' ');
      expect(text, contains("counts that tala's own beats"));
      expect(text, isNot(contains("''")));
    });
  });
}
