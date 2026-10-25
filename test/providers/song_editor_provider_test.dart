import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lyricchord/models/song_title_words.dart';
import 'package:lyricchord/core/utils/chord_insert.dart';
import 'package:lyricchord/providers/database_provider.dart';
import 'package:lyricchord/providers/song_editor_provider.dart';

import '../helpers/fake_song_repository.dart';

void main() {
  group('insertChord (pure)', () {
    TextEditingValue valueOf(String text, {int? start, int? end}) {
      return TextEditingValue(
        text: text,
        selection: start == null
            ? const TextSelection.collapsed(offset: -1)
            : TextSelection(baseOffset: start, extentOffset: end ?? start),
      );
    }

    test('inserts at the caret', () {
      final result = insertChord(valueOf('hello world', start: 6), 'C');
      expect(result.text, 'hello [C]world');
      expect(result.selection.baseOffset, 9);
    });

    test('inserts at the very start', () {
      final result = insertChord(valueOf('hello', start: 0), 'Am');
      expect(result.text, '[Am]hello');
    });

    test('appends when nothing is focused', () {
      final result = insertChord(valueOf('hello'), 'G');
      expect(result.text, 'hello[G]');
      expect(result.selection.baseOffset, 8);
    });

    test('replaces the selected text', () {
      final result = insertChord(valueOf('hello world', start: 0, end: 5), 'D');
      expect(result.text, '[D] world');
    });

    test('trims stray spaces around the chord', () {
      final result = insertChord(valueOf('', start: 0), '  F#m  ');
      expect(result.text, '[F#m]');
    });
  });

  group('SongDraft', () {
    test('a new draft starts in C at 120 BPM', () {
      const draft = SongDraft();
      expect(draft.key, 'C');
      expect(draft.bpm, 120);
      expect(draft.isDirty, isFalse);
    });

    test('a blank title is saved as "Untitled Song"', () {
      const draft = SongDraft(title: '   ');
      expect(draft.toSong(timestamp: 1).title, 'Untitled Song');
    });

    test('a BPM that cannot be read falls back to 120', () {
      expect(const SongDraft(bpmText: '').bpm, 120);
      expect(const SongDraft(bpmText: 'abc').bpm, 120);
      expect(const SongDraft(bpmText: '5').bpm, 120);
      expect(const SongDraft(bpmText: '999').bpm, 120);
      expect(const SongDraft(bpmText: '96').bpm, 96);
    });

    test('an empty key falls back to C', () {
      expect(const SongDraft(key: '  ').toSong(timestamp: 1).key, 'C');
    });

    test('suggestions follow the key and then the custom chords', () {
      const draft = SongDraft(key: 'G', customChords: ['F#m7']);
      expect(draft.chordSuggestions.first, 'G');
      expect(draft.chordSuggestions.last, 'F#m7');
    });
  });

  group('songEditorProvider', () {
    late FakeSongRepository repo;
    late ProviderContainer container;

    setUp(() {
      repo = FakeSongRepository.seeded();
      container = ProviderContainer(
        overrides: [songRepositoryProvider.overrideWithValue(repo)],
      );
    });

    tearDown(() async {
      container.dispose();
      await repo.dispose();
    });

    /// The editor provider is auto-disposed, so a test must hold a listener or
    /// the draft is thrown away between two `read` calls.
    Future<void> open(int songId) async {
      container.listen(songEditorProvider(songId), (previous, next) {});
      await container.read(songEditorProvider(songId).future);
    }

    test('a new song starts from a blank draft', () async {
      await open(0);
      final draft = container.read(songEditorProvider(0)).value!;

      expect(draft.id, 0);
      expect(draft.title, '');
      expect(draft.key, 'C');
      expect(draft.bpmText, '120');
    });

    test('an existing song is loaded into the draft', () async {
      await open(1);
      final draft = container.read(songEditorProvider(1)).value!;

      expect(draft.title, 'Amazing Grace');
      expect(draft.artist, 'Traditional');
      expect(draft.key, 'G');
      expect(draft.bpmText, '80');
      expect(draft.isDirty, isFalse);
    });

    test('editing marks the draft dirty', () async {
      await open(1);
      final editor = container.read(songEditorProvider(1).notifier);

      editor.setTitle('Amazing Grace (live)');

      final draft = container.read(songEditorProvider(1)).value!;
      expect(draft.title, 'Amazing Grace (live)');
      expect(draft.isDirty, isTrue);
    });

    test('the suggestions change when the key changes', () async {
      await open(0);
      final editor = container.read(songEditorProvider(0).notifier);

      expect(
        container.read(songEditorProvider(0)).value!.chordSuggestions.first,
        'C',
      );

      editor.setKey('Am');

      expect(
        container.read(songEditorProvider(0)).value!.chordSuggestions.first,
        'Am',
      );
    });

    test('a custom chord is added once and only when it is new', () async {
      await open(0);
      final editor = container.read(songEditorProvider(0).notifier);

      editor.addCustomChord('Cmaj7');
      editor.addCustomChord('Cmaj7');
      editor.addCustomChord('  ');
      // Already offered by the key, so it must not be repeated.
      editor.addCustomChord('Dm');

      final chords = container.read(songEditorProvider(0)).value!.customChords;
      expect(chords, ['Cmaj7']);
    });

    test('saving a new song creates it', () async {
      await open(0);
      final editor = container.read(songEditorProvider(0).notifier);

      editor.setTitle('New Tune');
      editor.setArtist('Me');
      editor.setKey('D');
      editor.setBpmText('90');
      editor.setLyrics('[D]Hello');

      final id = await editor.save();
      final saved = await repo.watchSongById(id).first;

      expect(saved, isNotNull);
      expect(saved!.title, 'New Tune');
      expect(saved.artist, 'Me');
      expect(saved.key, 'D');
      expect(saved.bpm, 90);
      expect(saved.lyrics, '[D]Hello');
      expect(container.read(songEditorProvider(0)).value!.isDirty, isFalse);
    });

    test('saving an existing song updates it and keeps the star', () async {
      await open(1);
      final editor = container.read(songEditorProvider(1).notifier);

      editor.setTitle('Amazing Grace (live)');
      final id = await editor.save();

      expect(id, 1);
      final saved = await repo.watchSongById(1).first;
      expect(saved!.title, 'Amazing Grace (live)');
      expect(saved.favorite, isTrue);
      // Not a second row.
      final all = await repo.watchAllSongs().first;
      expect(all, hasLength(6));
    });

    test('saving an edit keeps the song\'s saved scroll speed', () async {
      // The speed is set in the performance view, not the editor, so an edit
      // must carry it through untouched.
      await repo.saveScrollSettings(1, speed: 0.45, measures: 16);

      await open(1);
      final editor = container.read(songEditorProvider(1).notifier);
      editor.setTitle('Amazing Grace (slow)');
      await editor.save();

      final saved = await repo.watchSongById(1).first;
      expect(saved!.title, 'Amazing Grace (slow)');
      expect(saved.scrollSpeed, closeTo(0.45, 1e-9));
      expect(saved.scrollMeasures, 16);
    });

    test('saving without a title still works', () async {
      await open(0);
      final editor = container.read(songEditorProvider(0).notifier);

      editor.setLyrics('just words');
      final id = await editor.save();

      final saved = await repo.watchSongById(id).first;
      expect(saved!.title, 'Untitled Song');
    });

    test('a song with no title is saved in the given language', () async {
      await open(0);
      final editor = container.read(songEditorProvider(0).notifier);
      final words = SongTitleWords(
        untitled: 'अनामगीतम्',
        copyOf: (title) => '$title (प्रतिलिपिः)',
      );

      editor.setLyrics('just words');
      final id = await editor.save(words: words);
      final copyId = await editor.saveAsCopy(words: words);

      expect((await repo.watchSongById(id).first)!.title, 'अनामगीतम्');
      expect(
        (await repo.watchSongById(copyId).first)!.title,
        'अनामगीतम् (प्रतिलिपिः)',
      );
    });
  });
}
