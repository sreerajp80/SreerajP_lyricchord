import 'package:flutter_test/flutter_test.dart';

import 'package:lyricchord/core/errors/app_exception.dart';
import 'package:lyricchord/l10n/app_localizations_en.dart';
import 'package:lyricchord/l10n/l10n_labels.dart';
import 'package:lyricchord/models/carnatic_import_result.dart';
import 'package:lyricchord/models/import_settings.dart';
import 'package:lyricchord/models/lyric_font.dart';
import 'package:lyricchord/models/melody_line.dart';
import 'package:lyricchord/models/pitch_drone_settings.dart';
import 'package:lyricchord/models/pitch_tradition.dart';

void main() {
  final l10n = AppLocalizationsEn();

  test('every notation tradition has its own name', () {
    final names = PitchTradition.values.map((t) => t.label(l10n)).toList();
    expect(names, ['Western', 'Carnatic', 'Hindustani']);
  });

  test('every import duplicate choice has a label and a description', () {
    for (final strategy in ImportDuplicateStrategy.values) {
      expect(strategy.label(l10n), isNotEmpty);
      expect(strategy.description(l10n), isNotEmpty);
    }
    final labels = ImportDuplicateStrategy.values.map((s) => s.label(l10n));
    expect(labels.toSet(), hasLength(ImportDuplicateStrategy.values.length));
    expect(ImportDuplicateStrategy.overwrite.label(l10n), 'Overwrite');
  });

  test('chord qualities are named', () {
    expect(ChordQuality.major.label(l10n), 'Major');
    expect(ChordQuality.minor.label(l10n), 'Minor');
  });

  test('only the system font gets a translated name', () {
    expect(LyricFont.system.displayLabel(l10n), 'System default');
    for (final font in LyricFont.values.where((f) => f != LyricFont.system)) {
      expect(font.displayLabel(l10n), font.label);
    }
  });

  test('every storage failure has its own sentence', () {
    final texts = StorageFailure.values.map((f) => f.text(l10n)).toSet();
    expect(texts, hasLength(StorageFailure.values.length));
    expect(StorageFailure.saveSong.text(l10n), 'Could not save the song.');
    expect(
      StorageFailure.deleteSetlist.text(l10n),
      'Could not delete setlist.',
    );
  });

  test('a storage exception shows translated words, others their message', () {
    const storage = StorageException(
      'Could not delete the song.',
      kind: StorageFailure.deleteSong,
    );
    const import = ImportException('Already translated text.');
    expect(storage.text(l10n), 'Could not delete the song.');
    expect(import.text(l10n), 'Already translated text.');
  });

  test('drone errors read as before', () {
    expect(DroneError.chordCue.text(l10n), 'Could not play the chord cue.');
    expect(DroneError.pitchCue.text(l10n), 'Could not play the pitch cue.');
    expect(DroneError.startDrone.text(l10n), 'Could not start the drone.');
  });

  test('melody problems read as before', () {
    expect(
      const MelodyProblem(
        MelodyProblemKind.unreadablePiece,
        token: 'Qx',
        piece: 'Qx',
      ).text(l10n),
      'Could not read "Qx" in "Qx".',
    );
    expect(
      const MelodyProblem(
        MelodyProblemKind.nothingToPlay,
        token: '-',
      ).text(l10n),
      'Nothing to play in "-".',
    );
  });

  test('Carnatic problems read as before, with the cycle in front', () {
    expect(
      const CarnaticUnknownTala('Nonsense').text(l10n),
      'Could not work out how many beats "Nonsense" has.',
    );
    expect(const CarnaticNoNotation().text(l10n), 'No notation found to read.');
    expect(
      const CarnaticCyclesOffTala(fitting: 1, total: 2, tala: 'Adi').text(l10n),
      '1 of 2 cycles land on Adi. The rest are the wrong length, so some '
      'beats will be off.',
    );
    expect(
      const CarnaticReadingsTie().text(l10n),
      startsWith('Both readings of upper/lower case score the same'),
    );
    expect(
      const CarnaticUnreadableCharacter(
        character: 'q',
        token: 'qa',
      ).inCycle(2).text(l10n),
      'Cycle 2: could not read "q" in "qa"',
    );
    expect(
      const CarnaticWrongLength(got: 3.5, wanted: 14).inCycle(1).text(l10n),
      'Cycle 1: reads as 3.5 aksharakalas, but this tala wants 14',
    );
    expect(
      const CarnaticNothingReadable().inCycle(3).text(l10n),
      'Cycle 3: nothing readable',
    );
  });

  test('every Carnatic case reading has its own label', () {
    expect(CarnaticCaseReading.duration.label(l10n), 'case means note length');
    expect(CarnaticCaseReading.octave.label(l10n), 'case means octave');
    final labels = CarnaticCaseReading.values.map((r) => r.label(l10n));
    expect(labels.toSet(), hasLength(CarnaticCaseReading.values.length));
  });
}
