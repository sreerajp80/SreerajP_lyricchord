import 'package:flutter_test/flutter_test.dart';

import 'package:lyricchord/l10n/app_localizations_en.dart';

void main() {
  final l10n = AppLocalizationsEn();

  test('song counts use the right singular and plural', () {
    expect(l10n.labelSetlistSongCount(1), '1 song');
    expect(l10n.labelSetlistSongCount(2), '2 songs');
    expect(l10n.labelSetlistSongCount(0), '0 songs');
    expect(l10n.titleSetlistSongCount(1), '1 Song');
    expect(l10n.titleSetlistSongCount(3), '3 Songs');
  });

  test('selected-song messages are plural-correct', () {
    expect(l10n.titleSongListSelectedCount(1), '1 selected');
    expect(l10n.titleSongListSelectedCount(2), '2 selected');
    expect(l10n.titleSongListDeleteMany(1), 'Delete 1 song?');
    expect(l10n.titleSongListDeleteMany(4), 'Delete 4 songs?');
    expect(l10n.bodySongListExported(1), 'Exported 1 song.');
    expect(l10n.bodySongListExported(5), 'Exported 5 songs.');
    expect(l10n.bodySongListDeletedMany(1), 'Deleted 1 song.');
    expect(l10n.bodySongListDeletedMany(2), 'Deleted 2 songs.');
    expect(l10n.titleSongListShareDialog(1), 'Share 1 song');
    expect(l10n.titleSongListShareDialog(2), 'Share 2 songs');
    expect(l10n.titleSongListAirQr(1), '1 Selected Song');
    expect(l10n.titleSongListAirQr(3), '3 Selected Songs');
  });

  test('editor counts are plural-correct', () {
    expect(l10n.labelMelodyKeypadBeats(1), '1 beat');
    expect(l10n.labelMelodyKeypadBeats(3), '3 beats');
    expect(l10n.descMelodyKeypadFits(1, 'Eka'), '1 beat — fits Eka');
    expect(l10n.descMelodyKeypadFits(8, 'Adi'), '8 beats — fits Adi');
    expect(l10n.labelMelodyKeypadOfBeats(5, 8), '5 of 8 beats');
    expect(l10n.actionCarnaticSheetInsertLines(1), 'Insert 1 line');
    expect(l10n.actionCarnaticSheetInsertLines(4), 'Insert 4 lines');
    expect(l10n.descCarnaticSheetAnyaHint(1), contains('appears in 1 cycle.'));
    expect(l10n.descCarnaticSheetAnyaHint(2), contains('appears in 2 cycles.'));
  });

  test('editor placeholders keep song syntax intact', () {
    expect(l10n.tooltipChordInserterInsert('F#m7'), 'Insert [F#m7]');
    expect(
      l10n.tooltipMelodyLineNeedsTonic('{tonic: ...}'),
      'Needs a {tonic: ...} line',
    );
    expect(
      l10n.errorEditorNeedsTala('{tala: ...}'),
      'Add a {tala: ...} line first — the notation is checked against the '
      "tala's beats.",
    );
    expect(
      l10n.descEditorTalaWarning('Adi', 'Carnatic'),
      '"Adi" is usually a Carnatic tala. You can still save it.',
    );
    expect(
      l10n.descCarnaticSheetFit(1, 1, 'case means note length'),
      '1 of 1 cycles fit the tala — read with case means note length.',
    );
  });

  test('performance view counts are plural-correct', () {
    expect(l10n.labelInfoBars(1), '1 bar');
    expect(l10n.labelInfoBars(32), '32 bars');
    expect(l10n.descMetronomeTapsNeeded(1), 'Good — 1 more tap to steady it');
    expect(l10n.descMetronomeTapsNeeded(3), 'Good — 3 more taps to steady it');
  });

  test('performance view placeholders', () {
    expect(l10n.titlePerfSetlistPosition('Sunday', 2, 7), 'Sunday (2/7)');
    expect(l10n.labelInfoKeyTransposed('A', '+2'), 'Key A (+2)');
    expect(l10n.labelInfoKey('G'), 'Key G');
    expect(l10n.labelInfoBpm(96), '96 BPM');
    expect(l10n.bodyPerfExported('Hey Jude'), 'Exported "Hey Jude".');
    expect(l10n.labelDroneYourSa('5 kattai'), 'Your Sa:  5 kattai');
    expect(l10n.descMelodyGridUnreadable('Qx'), 'could not read Qx');
  });

  test('settings sentences keep their words together', () {
    expect(
      l10n.descDroneSettingsTestWesternMajor('G'),
      'Test plays: Western major chord on G',
    );
    expect(
      l10n.descDroneSettingsTestWesternMinor('A'),
      'Test plays: Western minor chord on A',
    );
    expect(
      l10n.descDroneSettingsTestClassical('5 kattai', 'Pa'),
      'Test plays: Classical drone on 5 kattai + Pa',
    );
    expect(
      l10n.errorChordSettingsAddFailed(12),
      'Could not add that chord. Use at most 12 characters and no repeats.',
    );
    expect(
      l10n.labelAboutVersion(l10n.labelAboutVersionBuild('1.2.0', '7')),
      'Version 1.2.0 (build 7)',
    );
    expect(l10n.actionScrollResetTo('1.00x'), 'Reset to 1.00x');
  });

  test('import, export and AirQR counts are plural-correct', () {
    expect(l10n.bodyImportExportExported(1), 'Exported 1 song.');
    expect(l10n.bodyImportExportExported(40), 'Exported 40 songs.');
    expect(l10n.titleImportExportFullSongbook(1), 'Songbook (1 song)');
    expect(l10n.titleImportExportFullSongbook(9), 'Songbook (9 songs)');
    expect(l10n.descImportExportFilesSelected(3), '3 files selected');
    expect(l10n.descImportPreviewFound(1), startsWith('Found 1 song in file.'));
    expect(
      l10n.descImportPreviewFound(2),
      startsWith('Found 2 songs in file.'),
    );
    expect(l10n.bodyImportPreviewImportedMany(5), 'Imported 5 songs.');
  });

  test('AirQR frame lines and counters', () {
    expect(
      l10n.descAirQrTransmitterParityFrame(3, 12),
      'Frame 3/12 • Fountain FEC',
    );
    expect(
      l10n.descAirQrTransmitterBlockFrame(1, 12, 1),
      'Frame 1/12 • Block 1',
    );
    expect(
      l10n.descAirQrTransmitterSize(2048, 12),
      '2048 bytes • 12 Optical Frames',
    );
    expect(l10n.descAirQrHudCaptured(3, 4), 'Captured: 3 / 4 Blocks');
    expect(l10n.labelAirQrHudMissing(1), 'Missing: 1');
    expect(l10n.labelAirQrFps('12.5'), '12.5 FPS');
    expect(
      l10n.errorImportPreviewFailed('disk full'),
      'Import failed: disk full',
    );
  });

  test('apostrophes still show as one quote with escaping on', () {
    expect(l10n.descMetronomeUsingSongTempo, "Using this song's saved tempo");
    expect(l10n.descChordSettingsIntro, contains("editor's chord bar"));
    expect(l10n.descChordSettingsIntro, contains("key's own chords"));
    expect(l10n.descImportExportScanSubtitle, contains("bandmate's screen"));
    expect(l10n.errorEditorNeedsTala('{tala: ...}'), contains("tala's beats"));
  });

  test('placeholders fill in names and numbers', () {
    expect(l10n.bodySongListCopied('Hey Jude'), 'Copied "Hey Jude".');
    expect(l10n.labelSongFilterAll(12), 'All Songs (12)');
    expect(l10n.labelSongCardBpm(90), '90 BPM');
    expect(l10n.descSetlistSongDetails('G', 72), 'Key: G • 72 BPM');
    expect(
      l10n.descSetlistSongDetailsWithArtist('Traditional', 'D', 100),
      'Traditional • Key: D • 100 BPM',
    );
    expect(l10n.titleSetlistAirQr('Sunday'), 'Setlist: Sunday');
  });
}
