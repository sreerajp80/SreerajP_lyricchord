// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get titleApp => 'LyricChord';

  @override
  String get titleAbout => 'About';

  @override
  String get titleSettings => 'Settings';

  @override
  String get titleSongs => 'Songs';

  @override
  String get titleSetlists => 'Setlists';

  @override
  String get labelSearch => 'Search';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionSave => 'Save';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionEdit => 'Edit';

  @override
  String get labelStageUnlockReason => 'Unlock Stage Mode';

  @override
  String get bodyStageUnlockDenied =>
      'Stage is still locked. Unlock to continue.';

  @override
  String get bodyStageUnlockedWithoutCheck =>
      'Stage unlocked. Screen lock check was not available.';

  @override
  String get bodyQuietModeOn =>
      'Quiet Mode on: calls and notifications are silenced.';

  @override
  String get bodyQuietModeOff => 'Quiet Mode off: ringer restored.';

  @override
  String get bodyQuietModeNeedsAccess =>
      'To silence calls, allow Do Not Disturb access for LyricChord.';

  @override
  String get actionQuietModeOpenSettings => 'Open settings';

  @override
  String get errorQuietModeFailed => 'Could not silence the phone.';

  @override
  String get bodyQuietModeUnsupported =>
      'Quiet Mode is not available on this device.';

  @override
  String errorImportFileTooLarge(String fileName, int limitMb) {
    return '$fileName is too large to import (limit $limitMb MB).';
  }

  @override
  String errorImportFileUnreadable(String fileName) {
    return 'Could not read $fileName.';
  }

  @override
  String errorImportNoSongsFound(String fileName) {
    return 'No songs found in $fileName.';
  }

  @override
  String errorImportFilesSkippedTooLarge(int limitMb, String fileNames) {
    return 'Skipped files over $limitMb MB: $fileNames';
  }

  @override
  String errorImportFilesSkippedUnreadable(String fileNames) {
    return 'Could not read: $fileNames';
  }

  @override
  String get errorAirQrTransferFailed =>
      'Transfer failed. Tap Reset and scan again.';

  @override
  String get actionAirQrReset => 'Reset';

  @override
  String get actionCreate => 'Create';

  @override
  String get actionShare => 'Share';

  @override
  String get actionTryAgain => 'Try again';

  @override
  String get titleHomePickSong => 'Pick a song';

  @override
  String get descHomePickSongMessage =>
      'Choose a song on the left to open it here.';

  @override
  String get descAppSubtitle => 'Lyrics & Chords Notebook';

  @override
  String titleSongListSelectedCount(int count) {
    return '$count selected';
  }

  @override
  String get tooltipSongListCancelSelection => 'Cancel selection';

  @override
  String get tooltipSongListExportSelected => 'Export selected';

  @override
  String get tooltipSongListShareSelectedAirQr => 'Send via AirQR';

  @override
  String get tooltipSongListShareSelected => 'Share selected';

  @override
  String get tooltipSongListSelectAll => 'Select all';

  @override
  String get tooltipSongListDeselectAll => 'Deselect all';

  @override
  String get tooltipSongListDeleteSelected => 'Delete selected';

  @override
  String get tooltipSongListScanAirQr => 'Scan AirQR Song';

  @override
  String get tooltipSongListNewSong => 'New song';

  @override
  String get titleSongListExportDialog => 'Export selected';

  @override
  String bodySongListExported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Exported $count songs.',
      one: 'Exported 1 song.',
    );
    return '$_temp0';
  }

  @override
  String get errorSongListExportFailed => 'Could not export selected songs.';

  @override
  String titleSongListShareDialog(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Share $count songs',
      one: 'Share 1 song',
    );
    return '$_temp0';
  }

  @override
  String get labelSongListFormatChordPro => 'ChordPro (.chordpro)';

  @override
  String get labelSongListFormatPdf => 'PDF (.pdf)';

  @override
  String get errorSongListShareFailed => 'Could not share selected songs.';

  @override
  String get errorSongListPdfFailed => 'Could not generate PDF.';

  @override
  String get errorSongListSharePdfFailed =>
      'Could not share selected songs as PDF.';

  @override
  String titleSongListDeleteMany(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Delete $count songs?',
      one: 'Delete 1 song?',
    );
    return '$_temp0';
  }

  @override
  String get descSongListDeleteManyMessage =>
      'Selected songs will be removed from your songbook.';

  @override
  String bodySongListDeletedMany(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Deleted $count songs.',
      one: 'Deleted 1 song.',
    );
    return '$_temp0';
  }

  @override
  String bodySongListCopied(String title) {
    return 'Copied \"$title\".';
  }

  @override
  String get titleSongListDeleteOne => 'Delete song?';

  @override
  String descSongListDeleteOneMessage(String title) {
    return '\"$title\" will be removed from your songbook.';
  }

  @override
  String bodySongListDeletedOne(String title) {
    return 'Deleted \"$title\".';
  }

  @override
  String titleSongListAirQr(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Selected Songs',
      one: '1 Selected Song',
    );
    return '$_temp0';
  }

  @override
  String get emptySongbookNoMatchesTitle => 'No matches';

  @override
  String get emptySongbookNoMatchesMessage =>
      'No song matched your search. Try different words.';

  @override
  String get emptySongbookNoStarredTitle => 'No starred songs';

  @override
  String get emptySongbookNoStarredMessage =>
      'Tap the star on a song to keep it here.';

  @override
  String get emptySongbookEmptyTitle => 'Your songbook is empty';

  @override
  String get emptySongbookEmptyMessage =>
      'Tap + to write your first lyric chord sheet.';

  @override
  String get errorSongbookErrorTitle => 'Could not open your songbook';

  @override
  String get errorSongbookErrorMessage =>
      'Your songs are still saved. The app could not read them just now.';

  @override
  String labelSongCardKeySemantics(String key) {
    return 'Key $key';
  }

  @override
  String labelSongCardBpm(int bpm) {
    return '$bpm BPM';
  }

  @override
  String descSongCardBpmSemantics(int bpm) {
    return '$bpm beats per minute';
  }

  @override
  String get tooltipSongCardAddStar => 'Add to starred';

  @override
  String get tooltipSongCardRemoveStar => 'Remove from starred';

  @override
  String get tooltipSongCardDuplicate => 'Duplicate song';

  @override
  String get tooltipSongCardDelete => 'Delete song';

  @override
  String get descSongSearchHint => 'Search songs, artists, lyrics';

  @override
  String get tooltipSongSearchClear => 'Clear search';

  @override
  String labelSongFilterAll(int count) {
    return 'All Songs ($count)';
  }

  @override
  String labelSongFilterStarred(int count) {
    return 'Starred ($count)';
  }

  @override
  String errorSetlistLoad(String error) {
    return 'Error loading setlists: $error';
  }

  @override
  String get emptySetlistEmptyTitle => 'No setlists yet';

  @override
  String get emptySetlistEmptyMessage =>
      'Create setlists to group and arrange your songs for gigs and rehearsals.';

  @override
  String get actionSetlistCreate => 'Create Setlist';

  @override
  String labelSetlistSongCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count songs',
      one: '1 song',
    );
    return '$_temp0';
  }

  @override
  String get actionSetlistPerform => 'Perform';

  @override
  String get actionSetlistEditSongs => 'Edit Songs';

  @override
  String get actionSetlistNew => 'New Setlist';

  @override
  String get titleSetlist => 'Setlist';

  @override
  String errorSetlistLoadOne(String error) {
    return 'Error loading setlist: $error';
  }

  @override
  String get errorSetlistNotFound => 'Setlist not found.';

  @override
  String get tooltipSetlistShareAirQr => 'Send via AirQR';

  @override
  String get tooltipSetlistEditInfo => 'Edit setlist info';

  @override
  String get tooltipSetlistDelete => 'Delete setlist';

  @override
  String get actionSetlistPerformAll => 'Perform Setlist';

  @override
  String titleSetlistSongCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Songs',
      one: '1 Song',
    );
    return '$_temp0';
  }

  @override
  String get actionSetlistAddSongs => 'Add Songs';

  @override
  String get emptySetlistNoSongs => 'No songs in this setlist';

  @override
  String get actionSetlistAddSongsNow => 'Add Songs Now';

  @override
  String descSetlistSongDetails(String key, int bpm) {
    return 'Key: $key • $bpm BPM';
  }

  @override
  String descSetlistSongDetailsWithArtist(String artist, String key, int bpm) {
    return '$artist • Key: $key • $bpm BPM';
  }

  @override
  String get tooltipSetlistRemoveSong => 'Remove from setlist';

  @override
  String get titleSetlistDelete => 'Delete setlist?';

  @override
  String descSetlistDeleteMessage(String name) {
    return '\"$name\" will be deleted. Songs in your library will not be deleted.';
  }

  @override
  String bodySetlistDeleted(String name) {
    return 'Deleted setlist \"$name\".';
  }

  @override
  String get bodySetlistNothingToShare => 'No songs in setlist to share.';

  @override
  String titleSetlistAirQr(String name) {
    return 'Setlist: $name';
  }

  @override
  String get titleSetlistEdit => 'Edit Setlist';

  @override
  String get labelSetlistName => 'Setlist Name';

  @override
  String get descSetlistNameHint => 'e.g. Sunday Gig, Acoustic Practice';

  @override
  String get errorSetlistNameRequired => 'Please enter a setlist name';

  @override
  String get labelSetlistDescription => 'Details (optional)';

  @override
  String get descSetlistDescriptionHint => 'e.g. Venue, lineup, or notes';

  @override
  String get titleSetlistPicker => 'Add Songs to Setlist';

  @override
  String actionSetlistPickerDone(int count) {
    return 'Done ($count)';
  }

  @override
  String get descSetlistPickerSearchHint => 'Search songs...';

  @override
  String errorSetlistPickerLoad(String error) {
    return 'Error loading songs: $error';
  }

  @override
  String get emptySetlistPickerNoSongs => 'No songs found';

  @override
  String get actionDiscard => 'Discard';

  @override
  String get actionKeepEditing => 'Keep editing';

  @override
  String get actionInsert => 'Insert';

  @override
  String get actionAdd => 'Add';

  @override
  String get actionClear => 'Clear';

  @override
  String get labelTraditionWestern => 'Western';

  @override
  String get labelTraditionCarnatic => 'Carnatic';

  @override
  String get labelTraditionHindustani => 'Hindustani';

  @override
  String get descCarnaticReadingDuration => 'case means note length';

  @override
  String get descCarnaticReadingOctave => 'case means octave';

  @override
  String get titleEditorNew => 'New Song Note';

  @override
  String get titleEditorEdit => 'Edit Song Note';

  @override
  String get tooltipEditorUndo => 'Undo';

  @override
  String get tooltipEditorRedo => 'Redo';

  @override
  String get tooltipEditorMoreOptions => 'More options';

  @override
  String get actionEditorMelodyKeypad => 'Melody keypad';

  @override
  String get actionEditorPasteCarnatic => 'Paste Carnatic';

  @override
  String get actionEditorSaveAsCopy => 'Save as copy';

  @override
  String get errorEditorLoad => 'This song could not be opened.';

  @override
  String get descEditorLyricsHint =>
      'Write your lyrics here.\nTap a chord above to drop it in at the cursor.';

  @override
  String errorEditorNeedsTala(String directive) {
    return 'Add a $directive line first — the notation is checked against the tala\'s beats.';
  }

  @override
  String get titleEditorDiscard => 'Discard changes?';

  @override
  String get descEditorDiscardMessage =>
      'Your edits to this song will not be saved.';

  @override
  String get labelEditorUntitled => 'Untitled';

  @override
  String get labelUntitledSong => 'Untitled Song';

  @override
  String labelSongCopyTitle(String title) {
    return '$title (Copy)';
  }

  @override
  String labelEditorSummaryKey(String key) {
    return 'Key $key';
  }

  @override
  String labelEditorSummaryBpm(String bpm) {
    return '$bpm BPM';
  }

  @override
  String descEditorTalaWarning(String tala, String tradition) {
    return '\"$tala\" is usually a $tradition tala. You can still save it.';
  }

  @override
  String get labelSongMetaTitle => 'Title';

  @override
  String get labelSongMetaTitleHint => 'Song title';

  @override
  String get labelSongMetaArtist => 'Artist / Band';

  @override
  String get labelSongMetaArtistHint => 'Who performs it';

  @override
  String get labelSongMetaNotation => 'Notation';

  @override
  String get descSongMetaNotationHelper =>
      'Western uses chords. Indian uses swaras.';

  @override
  String get labelSongMetaRaga => 'Raga';

  @override
  String get labelSongMetaRagaHint => 'Kalyani, Yaman';

  @override
  String get labelSongMetaKey => 'Original key';

  @override
  String get labelSongMetaKeyHint => 'C, Am, F#m';

  @override
  String get labelSongMetaTempo => 'Tempo (BPM)';

  @override
  String get labelSongMetaTempoHint => '120';

  @override
  String get labelSongMetaTala => 'Tala';

  @override
  String get labelSongMetaTalaHint => 'Adi, Keherwa';

  @override
  String get labelSongMetaSetlist => 'Add to setlist';

  @override
  String get labelSongMetaSetlistNone => 'None (Do not add)';

  @override
  String tooltipChordInserterInsert(String chord) {
    return 'Insert [$chord]';
  }

  @override
  String get actionChordInserterCustom => 'Custom';

  @override
  String get tooltipChordInserterCustom => 'Add your own chord';

  @override
  String get titleChordInserterDialog => 'Custom chord';

  @override
  String get labelChordInserterChord => 'Chord';

  @override
  String get labelChordInserterChordHint => 'F#m7, Cmaj7, D/F#';

  @override
  String get titleRenameImport => 'Duplicate Song Title';

  @override
  String descRenameImportExists(String title) {
    return 'A song titled \"$title\" already exists in your songbook.';
  }

  @override
  String get descRenameImportPrompt =>
      'Enter a new title for the imported song:';

  @override
  String get labelRenameImport => 'Song Title';

  @override
  String get errorRenameImportRequired => 'Please enter a title';

  @override
  String get actionRenameImportSave => 'Save with New Title';

  @override
  String get titleMelodyKeypadDiscard => 'Discard this melody?';

  @override
  String get descMelodyKeypadDiscardMessage => 'What you tapped will be lost.';

  @override
  String get labelMelodyKeypadHold => 'Hold ,';

  @override
  String get tooltipMelodyKeypadHold => 'Hold one more beat';

  @override
  String get labelMelodyKeypadBar => 'Bar |';

  @override
  String get tooltipMelodyKeypadBar => 'Group divider';

  @override
  String get labelMelodyKeypadShare => 'Share -';

  @override
  String get tooltipMelodyKeypadShare => 'Share this beat';

  @override
  String get labelMelodyKeypadTie => 'Tie ,-';

  @override
  String get tooltipMelodyKeypadTie => 'Start mid-beat';

  @override
  String get labelMelodyKeypadSilence => 'Silence x';

  @override
  String get tooltipMelodyKeypadSilence => 'Stop the sound';

  @override
  String get labelMelodyKeypadOctaveUp => 'Octave ↑';

  @override
  String get labelMelodyKeypadOctaveDown => 'Octave ↓';

  @override
  String get labelMelodyKeypadSlide => 'Slide !';

  @override
  String get labelMelodyKeypadShake => 'Shake ~';

  @override
  String get tooltipMelodyKeypadBackspace => 'Backspace';

  @override
  String labelMelodyKeypadBeats(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count beats',
      one: '1 beat',
    );
    return '$_temp0';
  }

  @override
  String descMelodyKeypadFits(int count, String tala) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count beats — fits $tala',
      one: '1 beat — fits $tala',
    );
    return '$_temp0';
  }

  @override
  String labelMelodyKeypadOfBeats(int count, int total) {
    return '$count of $total beats';
  }

  @override
  String get descMelodyKeypadStartHint =>
      'Tap a swara to start. Hold adds a beat, Bar marks a group.';

  @override
  String descCarnaticSheetHelp(String tala) {
    return 'Tala: $tala. Paste one avarta per line, or separate them with ||. Underlined runs: write them _like_this_.';
  }

  @override
  String get labelCarnaticSheetAnyaTitle => 'Ma1 in Ga-Ma-Ri';

  @override
  String get descCarnaticSheetAnyaSubtitle =>
      'For a bhashanga raga such as Yamunakalyani. Off by default — the notation does not say which madhyamam is meant.';

  @override
  String actionCarnaticSheetInsertLines(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Insert $count lines',
      one: 'Insert 1 line',
    );
    return '$_temp0';
  }

  @override
  String descCarnaticSheetFit(int fitting, int total, String reading) {
    return '$fitting of $total cycles fit the tala — read with $reading.';
  }

  @override
  String descCarnaticSheetOtherReading(String reading, int fitting, int total) {
    return 'The other reading ($reading) fits $fitting of $total.';
  }

  @override
  String descCarnaticSheetAnyaHint(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'A Ga-Ma-Ri descent appears in $count cycles. In a bhashanga raga that madhyamam is the shuddha one.',
      one:
          'A Ga-Ma-Ri descent appears in 1 cycle. In a bhashanga raga that madhyamam is the shuddha one.',
    );
    return '$_temp0';
  }

  @override
  String get labelMelodyLineLoop => 'Loop';

  @override
  String get labelMelodyLineHalfSpeed => 'Half speed';

  @override
  String get errorMelodyLinePlayFailed => 'Could not play this melody.';

  @override
  String get tooltipMelodyLineStop => 'Stop';

  @override
  String get tooltipMelodyLinePlay => 'Hum this line';

  @override
  String tooltipMelodyLineNeedsTonic(String directive) {
    return 'Needs a $directive line';
  }

  @override
  String get actionClose => 'Close';

  @override
  String get actionExport => 'Export';

  @override
  String get tooltipPlay => 'Play';

  @override
  String get tooltipPause => 'Pause';

  @override
  String get actionReset => 'Reset';

  @override
  String labelInfoRaga(String raga) {
    return 'Raga $raga';
  }

  @override
  String labelInfoTala(String tala) {
    return 'Tala $tala';
  }

  @override
  String labelInfoKey(String key) {
    return 'Key $key';
  }

  @override
  String labelInfoKeyTransposed(String key, String semitones) {
    return 'Key $key ($semitones)';
  }

  @override
  String labelInfoBpm(int bpm) {
    return '$bpm BPM';
  }

  @override
  String labelInfoBars(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bars',
      one: '1 bar',
    );
    return '$_temp0';
  }

  @override
  String get labelInfoAutoScroll => 'Auto-scroll';

  @override
  String get titlePerfSong => 'Song';

  @override
  String get tooltipPerfPreviousSong => 'Previous song';

  @override
  String get tooltipPerfNextSong => 'Next song';

  @override
  String get tooltipPerfSetlistSongs => 'Setlist songs';

  @override
  String get tooltipPerfEditSong => 'Edit song';

  @override
  String titlePerfSetlistPosition(String name, int position, int total) {
    return '$name ($position/$total)';
  }

  @override
  String get errorPerfNotFoundTitle => 'Song not found';

  @override
  String get descPerfNotFoundMessage =>
      'It may have been deleted from your songbook.';

  @override
  String get actionPerfControls => 'Performance controls';

  @override
  String get tooltipPerfGesturesHelp => 'Gestures help';

  @override
  String get actionPerfSwaraReference => 'Swara Reference';

  @override
  String get actionPerfChordReferenceGuide => 'Chord Reference';

  @override
  String get titlePerfExportDialog => 'Export song';

  @override
  String get titlePerfShareDialog => 'Share song';

  @override
  String get labelPerfFormatAirQr => 'AirQR stream';

  @override
  String get errorPerfShareChordProFailed =>
      'Could not share the ChordPro file.';

  @override
  String get errorPerfPdfNoPages => 'Could not export the PDF (no pages).';

  @override
  String get errorPerfPdfTimeout => 'PDF export took too long and was stopped.';

  @override
  String get errorPerfSharePdfFailed => 'Could not share the PDF.';

  @override
  String get titlePerfExportPdf => 'Export as PDF';

  @override
  String get titlePerfExportChordPro => 'Export as ChordPro';

  @override
  String bodyPerfExported(String title) {
    return 'Exported \"$title\".';
  }

  @override
  String get errorPerfExportPdfFailed => 'Could not export the PDF.';

  @override
  String get errorPerfExportChordProFailed =>
      'Could not export the ChordPro file.';

  @override
  String get tooltipPerfDrone => 'Pitch pipe & drone';

  @override
  String get tooltipPerfSpeed => 'Scroll speed';

  @override
  String get tooltipPerfHideChords => 'Hide chords';

  @override
  String get tooltipPerfShowChords => 'Show chords';

  @override
  String get tooltipPerfHideMelody => 'Hide melody';

  @override
  String get tooltipPerfShowMelody => 'Show melody';

  @override
  String get tooltipAutoScrollFullScreen => 'Full screen';

  @override
  String get labelAutoScrollManual => 'Manual';

  @override
  String get labelAutoScrollTempo => 'Tempo';

  @override
  String get actionAutoScrollManualShort => 'M';

  @override
  String get actionAutoScrollTempoShort => 'T';

  @override
  String get labelTranspose => 'Transpose';

  @override
  String get tooltipTransposeDown => 'Transpose down';

  @override
  String get tooltipTransposeUp => 'Transpose up';

  @override
  String get descTransposeMelodySubtitle =>
      'Full screen never shows the melody';

  @override
  String get descTransposePinchTip =>
      'Tip: pinch the lyrics with two fingers to change the text size.';

  @override
  String get titleChordRef => 'Chord Reference';

  @override
  String get emptyChordRefNoSwaras => 'No swaras in this song';

  @override
  String get emptyChordRefNoChords => 'No chords in this song';

  @override
  String get tabChordRefGuitar => 'Guitar';

  @override
  String get tabChordRefHarmonium => 'Harmonium';

  @override
  String get tooltipStageExitFullScreen => 'Exit full screen';

  @override
  String get tooltipStageLock => 'Lock Stage View';

  @override
  String get tooltipStageQuietActive => 'Turn off Quiet Mode';

  @override
  String get tooltipStageQuietInactive => 'Turn on Quiet Mode';

  @override
  String get tooltipStageFewerBars => 'Fewer bars';

  @override
  String get tooltipStageMoreBars => 'More bars';

  @override
  String get tooltipStageSlower => 'Slower';

  @override
  String get tooltipStageFaster => 'Faster';

  @override
  String get labelStageLocked => 'Stage Locked';

  @override
  String get labelStagePlaying => 'Playing';

  @override
  String get labelStagePaused => 'Paused';

  @override
  String get descStageHelpSubtitle => 'Only the words, and these gestures.';

  @override
  String get labelStageHelpTapOnce => 'Tap once';

  @override
  String get descStageHelpTapOnceMeaning => 'Show or hide the controls';

  @override
  String get labelStageHelpDoubleTapTop => 'Double-tap up top';

  @override
  String get labelStageHelpDoubleTapBottom => 'Double-tap down low';

  @override
  String get labelStageHelpTwoFingers => 'Tap with two fingers';

  @override
  String get descStageHelpTwoFingersMeaning => 'Play or pause';

  @override
  String get labelStageHelpPinch => 'Pinch';

  @override
  String get descStageHelpPinchMeaning => 'Change the text size';

  @override
  String get labelStageHelpBack => 'Back';

  @override
  String get descStageHelpBackMeaning => 'Leave full screen';

  @override
  String get descStageHelpStart => 'Tap anywhere to start';

  @override
  String get titleGestures => 'Gestures & Shortcuts';

  @override
  String get descGesturesSubtitle =>
      'Control the sheet hands-free while playing';

  @override
  String get labelGesturesDoubleTapTop => 'Double-tap top';

  @override
  String get descGesturesDoubleTapTopMeaning =>
      'Faster in Manual mode, or adds 4 bars in Tempo mode.';

  @override
  String get labelGesturesDoubleTapBottom => 'Double-tap bottom';

  @override
  String get descGesturesDoubleTapBottomMeaning =>
      'Slower in Manual mode, or removes 4 bars in Tempo mode.';

  @override
  String get descGesturesTwoFingersMeaning =>
      'Play or pause auto-scroll without touching any button.';

  @override
  String get labelGesturesDrag => 'Drag with one finger';

  @override
  String get descGesturesDragMeaning =>
      'Move the sheet by hand; auto-scroll waits and resumes when you lift.';

  @override
  String get labelGesturesPinch => 'Two-finger pinch';

  @override
  String get descGesturesPinchMeaning =>
      'Zoom in or out to make the chord and lyric text larger or smaller.';

  @override
  String get labelGesturesFullScreen => 'Full screen';

  @override
  String get descGesturesFullScreenMeaning =>
      'Single tap toggles HUD controls; back gesture leaves full screen.';

  @override
  String get actionGesturesHelpCenter => 'Help Center';

  @override
  String get actionGesturesGotIt => 'Got it';

  @override
  String get descMetronomeTapAlong => 'Tap along with the music';

  @override
  String get descMetronomeKeepTapping => 'Keep tapping…';

  @override
  String descMetronomeTapsNeeded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Good — $count more taps to steady it',
      one: 'Good — 1 more tap to steady it',
    );
    return '$_temp0';
  }

  @override
  String get descMetronomeSteady => 'Steady';

  @override
  String get titleMetronomeTempo => 'Metronome tempo';

  @override
  String get descMetronomeSetByYou => 'Set by you for this session';

  @override
  String get descMetronomeUsingSongTempo => 'Using this song\'s saved tempo';

  @override
  String get descMetronomeNoSongTempo => 'This song has no saved tempo';

  @override
  String get tooltipMetronomeSlowerByOne => 'Slower by 1';

  @override
  String get tooltipMetronomeFasterByOne => 'Faster by 1';

  @override
  String get labelMetronomeBpmUnit => 'BPM';

  @override
  String get actionMetronomeTapTempo => 'Tap tempo';

  @override
  String get actionMetronomeUseSongTempo => 'Use song tempo';

  @override
  String get actionMetronomeNoSongTempoToRestore => 'No song tempo';

  @override
  String get tooltipMetronomeStop => 'Stop metronome';

  @override
  String get tooltipMetronomeStart => 'Start metronome';

  @override
  String get errorDroneCouldNotPlay => 'Could not play the sound.';

  @override
  String get titleDrone => 'Pitch Pipe & Drone';

  @override
  String get labelDroneModeClassical => 'Classical (Shruti)';

  @override
  String get labelDroneModeWestern => 'Western (Chords)';

  @override
  String get labelDroneSaPa => 'Sa + Pa (5th)';

  @override
  String get labelDroneSaMa => 'Sa + Ma (4th)';

  @override
  String get labelDroneMajor => 'Major (maj)';

  @override
  String get labelDroneMinor => 'Minor (min)';

  @override
  String get actionDroneChordCue => 'Chord Cue (2s)';

  @override
  String get actionDronePitchCue => 'Pitch Cue (2s)';

  @override
  String get actionDroneStop => 'Stop Drone';

  @override
  String get actionDroneChord => 'Chord Drone';

  @override
  String get actionDroneShruti => 'Shruti Drone';

  @override
  String get labelDroneTextScale => 'Stage Text Scale';

  @override
  String labelDroneYourSa(String name) {
    return 'Your Sa:  $name';
  }

  @override
  String labelDroneSongKey(String key) {
    return 'Song key:  $key';
  }

  @override
  String get labelDroneRootKey => 'Root Pitch Key';

  @override
  String get emptySheetNoLyrics => 'This song has no lyrics yet.';

  @override
  String descDiagramNoGuitar(String name) {
    return 'No guitar chord diagram for $name';
  }

  @override
  String descDiagramGuitar(String name) {
    return 'Guitar chord diagram for $name';
  }

  @override
  String get labelDiagramNone => 'No diagram';

  @override
  String descDiagramHarmonium(String name) {
    return 'Harmonium chord diagram for $name';
  }

  @override
  String descDiagramSwara(String swara) {
    return 'Swara diagram for $swara';
  }

  @override
  String get labelMelodyGridHold => 'hold';

  @override
  String get labelMelodyGridBarLine => 'bar line';

  @override
  String descMelodyGridUnreadable(String text) {
    return 'could not read $text';
  }

  @override
  String get titleSettingsGeneral => 'General';

  @override
  String get descSettingsGeneralSubtitle => 'Import and metronome';

  @override
  String get titleSettingsThemes => 'Themes';

  @override
  String get descSettingsThemesSubtitle => 'System, light, or dark look';

  @override
  String get titleSettingsChords => 'Chords';

  @override
  String get descSettingsChordsSubtitle =>
      'Your own chord notations for the editor';

  @override
  String get titleSettingsFonts => 'Fonts';

  @override
  String get descSettingsFontsSubtitle =>
      'Pick the lyric font (English and Malayalam)';

  @override
  String get titleSettingsHelp => 'Help';

  @override
  String get descSettingsHelpSubtitle =>
      'How to use setlists, metronome, export and more';

  @override
  String get descSettingsAboutSubtitle => 'App version, author, and licenses';

  @override
  String get titleGeneralImport => 'Import';

  @override
  String get descGeneralImportSubtitle => 'Bring in ChordPro files as songs';

  @override
  String get titleGeneralImportSettings => 'Import Settings';

  @override
  String get descGeneralImportSettingsSubtitle =>
      'Configure duplicate song handling for ChordPro files';

  @override
  String get descGeneralAutoScrollSubtitle =>
      'Starting speed for manual scrolling';

  @override
  String get titleGeneralMetronome => 'Metronome';

  @override
  String get descGeneralMetronomeSubtitle => 'Turn the beat on or off';

  @override
  String get descGeneralDroneSubtitle =>
      'Reference pitch tones, a steady drone, and your Sa (kattai)';

  @override
  String get labelThemeSystem => 'System theme';

  @override
  String get labelThemeLight => 'Light theme';

  @override
  String get labelThemeDark => 'Dark theme';

  @override
  String get descFontSettingsNote =>
      'Used for song lyrics on screen and in exported PDFs. Malayalam always prints in PDFs, even with an English font.';

  @override
  String get labelFontSystemDefault => 'System default';

  @override
  String get titleScrollStartingSpeed => 'Starting speed';

  @override
  String get descScrollStartingSpeedNote =>
      'Manual scrolling starts at this speed for a song you have not set a speed for yet.';

  @override
  String actionScrollResetTo(String speed) {
    return 'Reset to $speed';
  }

  @override
  String errorChordSettingsAddFailed(int max) {
    return 'Could not add that chord. Use at most $max characters and no repeats.';
  }

  @override
  String bodyChordSettingsRemoved(String chord) {
    return 'Removed \"$chord\".';
  }

  @override
  String get descChordSettingsIntro =>
      'Add your own chord notations. They always appear in the editor\'s chord bar, after the key\'s own chords.';

  @override
  String get labelChordSettings => 'Chord notation';

  @override
  String get emptyChordSettings => 'No custom chords yet.';

  @override
  String tooltipChordSettingsRemove(String chord) {
    return 'Remove $chord';
  }

  @override
  String get descImportSettingsQuestion =>
      'When importing a song whose title matches an existing song in your songbook:';

  @override
  String get labelImportStrategyOverwrite => 'Overwrite';

  @override
  String get descImportStrategyOverwrite =>
      'Replace existing song content with the imported song';

  @override
  String get labelImportStrategyRenameImported => 'Rename imported';

  @override
  String get descImportStrategyRenameImported =>
      'Automatically rename imported song by adding timestamp to the title';

  @override
  String get labelImportStrategyRenameExisting => 'Rename existing';

  @override
  String get descImportStrategyRenameExisting =>
      'Automatically rename existing song by adding timestamp to the title';

  @override
  String get labelImportStrategyUserSuggested => 'Ask for a new name';

  @override
  String get descImportStrategyUserSuggested =>
      'Prompt UI for user to type custom name for imported song';

  @override
  String get labelMetronomeEnable => 'Enable metronome';

  @override
  String get descMetronomeEnableSubtitle => 'Keep the beat at the song tempo';

  @override
  String get labelMetronomeFlash => 'Flash';

  @override
  String get descMetronomeFlashSubtitle =>
      'Blink on every beat (good when muted)';

  @override
  String get labelMetronomeClick => 'Click';

  @override
  String get descMetronomeClickSubtitle => 'Play a tick on every beat';

  @override
  String get labelMetronomeClickVolume => 'Click volume';

  @override
  String get titleMetronomeBarHeading => 'Bar';

  @override
  String get labelMetronomeBeatsInBar => 'Beats in a bar';

  @override
  String get descMetronomeBeatsInBarSubtitle =>
      'Beat 1 is the one you count on';

  @override
  String get labelMetronomeAccent => 'Accent beat 1';

  @override
  String get descMetronomeAccentSubtitle =>
      'Louder, higher click on the first beat';

  @override
  String get labelMetronomeTest => 'Test the sound';

  @override
  String descMetronomeTestSubtitle(int bpm) {
    return 'Plays one bar at $bpm BPM. If you hear nothing, raise the media volume.';
  }

  @override
  String descDroneSettingsTestWesternMajor(String key) {
    return 'Test plays: Western major chord on $key';
  }

  @override
  String descDroneSettingsTestWesternMinor(String key) {
    return 'Test plays: Western minor chord on $key';
  }

  @override
  String descDroneSettingsTestClassical(String key, String interval) {
    return 'Test plays: Classical drone on $key + $interval';
  }

  @override
  String get titleDroneSettingsNaming => 'Pitch naming';

  @override
  String get descDroneSettingsNamingCaption =>
      'Sets how pitches are named, and how a song is treated when it names no raga or tala.';

  @override
  String get descDroneSettingsUsesIndian =>
      'Songs with no raga or tala use the Indian songs settings below.';

  @override
  String get descDroneSettingsUsesWestern =>
      'Songs with no raga or tala use the Western songs settings below.';

  @override
  String get titleDroneSettingsIndianSongs => 'Indian songs';

  @override
  String get descDroneSettingsIndianCaption =>
      'Used for songs with a raga or tala. These always play the Classical shruti drone, on your Sa.';

  @override
  String get labelDroneSettingsYourSa => 'Your Sa (Shruti)';

  @override
  String descDroneSettingsSaSits(String name) {
    return 'Where your Sa sits: $name';
  }

  @override
  String get labelDroneSettingsInterval => 'Drone Interval';

  @override
  String get descDroneSettingsIntervalPa =>
      'Sa + Pa (fifth) — the usual shruti box drone';

  @override
  String get descDroneSettingsIntervalMa =>
      'Sa + Ma (fourth) — for ragas that leave out Pa';

  @override
  String get titleDroneSettingsWesternSongs => 'Western songs';

  @override
  String get descDroneSettingsWesternCaption =>
      'Used for songs with no raga or tala, when pitch naming is Western.';

  @override
  String get labelDroneSettingsDefaultKey => 'Default key';

  @override
  String descDroneSettingsDefaultKeySubtitle(String key) {
    return 'Used when a song names no key: $key';
  }

  @override
  String get labelDroneSettingsDefaultMode => 'Default drone mode';

  @override
  String get descDroneSettingsModeClassicalNote =>
      'Classical Shruti drone (Sa + Pa/Ma)';

  @override
  String get descDroneSettingsModeWesternNote =>
      'Western backing chords (Major / Minor)';

  @override
  String get labelDroneSettingsClassical => 'Classical';

  @override
  String get labelDroneSettingsDefaultQuality => 'Chord quality';

  @override
  String get descDroneSettingsMajorNote =>
      'Major triad (Root + Major 3rd + 5th)';

  @override
  String get descDroneSettingsMinorNote =>
      'Minor triad (Root + Minor 3rd + 5th)';

  @override
  String get descDroneSettingsQualityOnlyWestern =>
      'Used only when the drone mode above is Western';

  @override
  String get labelChordQualityMajor => 'Major';

  @override
  String get labelChordQualityMinor => 'Minor';

  @override
  String get titleDroneSettingsEverything => 'All songs';

  @override
  String get descDroneSettingsEverythingCaption =>
      'These affect both traditions.';

  @override
  String get labelDroneSettingsVolume => 'Volume';

  @override
  String get labelDroneSettingsFontScale => 'Stage Font Scale';

  @override
  String descDroneSettingsFontScaleSubtitle(int percent) {
    return 'Stage mode text zoom: $percent%';
  }

  @override
  String get titleDroneSettingsTryIt => 'Try it out';

  @override
  String get descDroneSettingsTryItCaption =>
      'The test uses the settings above.';

  @override
  String get actionDroneSettingsTestChordCue => 'Test Chord Cue';

  @override
  String get actionDroneSettingsTestPitchCue => 'Test Pitch Cue';

  @override
  String get actionDroneSettingsTestChordDrone => 'Test Chord Drone';

  @override
  String get actionDroneSettingsTestDrone => 'Test Drone';

  @override
  String get descDroneSettingsChordDroneNote =>
      'The chord drone holds one steady Western backing chord for as long as it is on.';

  @override
  String get descDroneSettingsDroneNote =>
      'The drone holds one steady pair of notes for as long as it is on. It does not follow the tune.';

  @override
  String labelAboutVersion(String version) {
    return 'Version $version';
  }

  @override
  String labelAboutVersionBuild(String version, String build) {
    return '$version (build $build)';
  }

  @override
  String get labelAboutBuildDate => 'Build date';

  @override
  String get labelAboutLicenses => 'Open source licenses';

  @override
  String get titleImportExport => 'Import & Export';

  @override
  String get labelImportExportPickFiles => 'Import ChordPro';

  @override
  String get descImportExportPickFilesSubtitle =>
      'Pick one or more .cho, .pro, or text files to add songs.';

  @override
  String get labelImportExportScan => 'Import via AirQR';

  @override
  String get descImportExportScanSubtitle =>
      'Scan an animated QR song stream from a bandmate\'s screen.';

  @override
  String get labelImportExportAllChordPro => 'Export all songs';

  @override
  String get descImportExportAllChordProSubtitle =>
      'Save your entire songbook as a single ChordPro file.';

  @override
  String get labelImportExportAllAirQr => 'Send all via AirQR';

  @override
  String get descImportExportAllAirQrSubtitle =>
      'Broadcast entire songbook as an animated QR stream.';

  @override
  String get errorImportExportWrongType =>
      'Only .cho, .pro, .chordpro, and .txt files can be imported.';

  @override
  String get errorImportExportNothingRead => 'Could not read any chosen files.';

  @override
  String descImportExportFilesSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count files selected',
      one: '1 file selected',
    );
    return '$_temp0';
  }

  @override
  String get errorImportExportImportFailed => 'Could not import the files.';

  @override
  String get bodyImportExportNoSongsToExport => 'No songs to export.';

  @override
  String get titleImportExportAllDialog => 'Export all songs';

  @override
  String bodyImportExportExported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Exported $count songs.',
      one: 'Exported 1 song.',
    );
    return '$_temp0';
  }

  @override
  String get errorImportExportExportFailed => 'Could not export songs.';

  @override
  String get bodyImportExportNoSongsToShare => 'No songs to share.';

  @override
  String titleImportExportFullSongbook(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Songbook ($count songs)',
      one: 'Songbook (1 song)',
    );
    return '$_temp0';
  }

  @override
  String get errorImportExportAirQrFailed => 'Could not prepare AirQR export.';

  @override
  String get titleImportPreview => 'Import Preview';

  @override
  String get actionImportPreviewSelectAll => 'Select All';

  @override
  String get actionImportPreviewDeselectAll => 'Deselect All';

  @override
  String descImportPreviewFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Found $count songs in file. Select which songs to import to your songbook.',
      one:
          'Found 1 song in file. Select which songs to import to your songbook.',
    );
    return '$_temp0';
  }

  @override
  String get emptyImportPreviewNoSongs => 'No valid songs found in this file.';

  @override
  String get labelImportPreviewInSongbook => 'In Songbook';

  @override
  String get labelImportPreviewAlreadyInSongbook => 'Already in Songbook';

  @override
  String labelImportPreviewKey(String key) {
    return 'Key: $key';
  }

  @override
  String get actionImportPreviewPreview => 'Preview';

  @override
  String get actionImportPreviewImporting => 'Importing...';

  @override
  String actionImportPreviewImportSelected(int count) {
    return 'Import ($count)';
  }

  @override
  String bodyImportPreviewImportedOne(String title) {
    return 'Imported \"$title\".';
  }

  @override
  String bodyImportPreviewImportedMany(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Imported $count songs.',
      one: 'Imported 1 song.',
    );
    return '$_temp0';
  }

  @override
  String errorImportPreviewFailed(String reason) {
    return 'Import failed: $reason';
  }

  @override
  String get titleAirQrReceiver => 'AirQR Song Receiver';

  @override
  String get tooltipAirQrReceiverGallery => 'Scan a photo';

  @override
  String get tooltipAirQrReceiverResetStream => 'Reset Stream';

  @override
  String get errorAirQrReceiverNoCode =>
      'No AirQR code detected in chosen photo.';

  @override
  String get errorAirQrReceiverPhotoFailed => 'Could not scan photo.';

  @override
  String get descAirQrReceiverStarting =>
      'Initializing AirQR Camera Receiver...';

  @override
  String get labelAirQrReceiverFileName => 'AirQR Stream Share';

  @override
  String get descAirQrHudReassembled =>
      'STREAM REASSEMBLED - OPENING PREVIEW...';

  @override
  String get descAirQrHudReceiving => 'RECEIVING AIRQR SONG STREAM...';

  @override
  String get descAirQrHudPointAt => 'POINT AT ANIMATED QR CODE STREAM';

  @override
  String descAirQrHudCaptured(int received, int total) {
    return 'Captured: $received / $total Blocks';
  }

  @override
  String labelAirQrHudMissing(int count) {
    return 'Missing: $count';
  }

  @override
  String titleAirQrTransmitter(String title) {
    return 'AirQR Share: $title';
  }

  @override
  String descAirQrTransmitterSize(int bytes, int frames) {
    return '$bytes bytes • $frames Optical Frames';
  }

  @override
  String get labelAirQrTransmitterSpeed => 'Stream Speed:';

  @override
  String get actionAirQrTransmitterPause => 'Pause stream';

  @override
  String get actionAirQrTransmitterResume => 'Resume stream';

  @override
  String get emptyAirQrTransmitterNoFrames => 'No frames generated';

  @override
  String descAirQrTransmitterParityFrame(int index, int total) {
    return 'Frame $index/$total • Fountain FEC';
  }

  @override
  String descAirQrTransmitterBlockFrame(int index, int total, int block) {
    return 'Frame $index/$total • Block $block';
  }

  @override
  String get descAirQrTransmitterHint =>
      'Point receiving phone camera at this screen.\nNo internet, Bluetooth, or Wi-Fi required.';

  @override
  String get titleHelpSongbook => 'Your songbook';

  @override
  String get helpSongbookSummary => 'Find, star, copy and remove songs';

  @override
  String get helpSongbookIntro =>
      'The home screen is your songbook. It has two tabs — Songs and Setlists. The Songs tab holds everything you have written or brought in, with the most recently changed song at the top.';

  @override
  String get helpSongbookS1Heading => 'Add a song';

  @override
  String get helpSongbookS1P1 =>
      'Tap the + button at the bottom right to write a new one.';

  @override
  String get helpSongbookS1P2 =>
      'Or bring songs in from a file — see the Import topic.';

  @override
  String get helpSongbookS1P3 =>
      'A new install already has three sample songs and one setlist, so you can try everything before typing anything.';

  @override
  String get helpSongbookS2Heading => 'Find a song';

  @override
  String get helpSongbookS2P1 =>
      'Type in the search box at the top. It looks in the title, the artist and the words, so half a remembered line is enough.';

  @override
  String get helpSongbookS2P2 => 'Tap the X in the box to clear the search.';

  @override
  String get helpSongbookS2P3 =>
      'Below it are two chips, \"All Songs\" and \"Starred\", each with a count of how many songs it holds.';

  @override
  String get helpSongbookS2P4 =>
      'Tap the star on a song to put it in Starred. Tap it again to take it out.';

  @override
  String get helpSongbookS3Heading => 'What a song card shows';

  @override
  String get helpSongbookS3P1 => 'The title and the artist.';

  @override
  String get helpSongbookS3P2 =>
      'The key, such as C or Am, and the tempo, such as 120 BPM, when the song has them.';

  @override
  String get helpSongbookS3P3 => 'A star, a copy button and a delete button.';

  @override
  String get helpSongbookS4Heading => 'Copy or delete one song';

  @override
  String get helpSongbookS4P1 =>
      'Copy makes a second, separate song named \"<Title> (Copy)\". Handy for a different arrangement of the same song.';

  @override
  String get helpSongbookS4P2 =>
      'Delete asks first, then takes the song out of your library and out of every setlist that held it.';

  @override
  String get helpSongbookS4P3 =>
      'To act on several songs at once, see the Select Songs topic.';

  @override
  String get helpSongbookS5Heading => 'On a tablet';

  @override
  String get helpSongbookS5P1 =>
      'A wide screen shows the list on the left and the song on the right, so picking a song does not hide the list.';

  @override
  String get helpSongbookS5P2 =>
      'Full screen is not offered in that right-hand half, because it would fill only that half and not the whole screen.';

  @override
  String get titleHelpEditor => 'Write a song';

  @override
  String get helpEditorSummary => 'Type the words, put chords over them, save';

  @override
  String get helpEditorIntro =>
      'The editor is one plain box for the words, with a few fields above it for the title, artist, key and tempo. Chords go inside the words in square brackets.';

  @override
  String get helpEditorS1Heading => 'Chords in the words';

  @override
  String get helpEditorS1P1 =>
      'Put the chord in square brackets right before the syllable it falls on: [G]Amazing [C]grace.';

  @override
  String get helpEditorS1P2 =>
      'On the song screen that chord is drawn floating above the syllable. The brackets are never shown.';

  @override
  String get helpEditorS1P3 =>
      'This is standard ChordPro, so a file written in another app reads the same way here.';

  @override
  String get helpEditorS2Heading => 'The chord bar above the keyboard';

  @override
  String get helpEditorS2P1 =>
      'While you are typing the words, a row of chord buttons sits just above the keyboard.';

  @override
  String get helpEditorS2P2 =>
      'The chords offered are the ones that usually belong to the key you picked — I, ii, iii, IV, V, vi and so on.';

  @override
  String get helpEditorS2P3 =>
      'Tap one and it goes in at the cursor, brackets and all.';

  @override
  String get helpEditorS2P4 =>
      'If the key is blank or cannot be read, the bar quietly falls back to the key of C rather than showing nothing.';

  @override
  String get helpEditorS2P5 =>
      'Your own chords come after those. Tap \"Custom\" to add one on the spot, or keep the whole list in Settings → Chords.';

  @override
  String get helpEditorS2P6 =>
      'A custom chord can be up to 12 characters, and the same one is never stored twice.';

  @override
  String get helpEditorS3Heading => 'The fields at the top';

  @override
  String get helpEditorS3P1 => 'Title, and Artist / Band.';

  @override
  String get helpEditorS3P2 =>
      'Notation: Western, Carnatic or Hindustani. Western shows an \"Original key\" box; either Indian choice replaces it with Raga and Tala — see the Carnatic & Hindustani topic.';

  @override
  String get helpEditorS3P3 =>
      'Tempo (BPM) drives the metronome and the Tempo auto-scroll.';

  @override
  String get helpEditorS3P4 =>
      '\"Add to setlist\" drops the song into a setlist as you save it.';

  @override
  String get helpEditorS3P5 =>
      'The fields fold into a one-line summary as soon as you tap into the words, so the words get the screen. Tap the summary to open them again.';

  @override
  String get helpEditorS4Heading => 'Undo, save and copy';

  @override
  String get helpEditorS4P1 =>
      'The undo and redo arrows in the top bar step back and forward through your typing.';

  @override
  String get helpEditorS4P2 => 'Save keeps the song and closes the editor.';

  @override
  String get helpEditorS4P3 =>
      'More options → \"Save as copy\" saves what is on screen right now, including edits you have not saved yet, as a brand-new song. The original is left as it was.';

  @override
  String get helpEditorS4P4 =>
      'Leaving with unsaved edits asks first, so a stray back gesture cannot throw your work away. With nothing changed it just closes.';

  @override
  String get helpEditorS5Heading => 'More options';

  @override
  String get helpEditorS5P1 =>
      'Melody keypad — tap out a tune instead of typing it. See the Melody Lines topic.';

  @override
  String get helpEditorS5P2 =>
      'Paste Carnatic — turn a block of published notation into melody lines. See the Indian songs topic.';

  @override
  String get titleHelpSetlists => 'Setlists';

  @override
  String get helpSetlistsSummary =>
      'Group and order songs for a gig or rehearsal';

  @override
  String get helpSetlistsIntro =>
      'A setlist is an ordered group of songs you can play through in one go, without hunting for each song. Setlists never make copies — they just point to songs already in your library.';

  @override
  String get helpSetlistsS1Heading => 'Create a setlist';

  @override
  String get helpSetlistsS1P1 =>
      'Open the \"Setlists\" tab on the home screen.';

  @override
  String get helpSetlistsS1P2 => 'Tap \"New Setlist\".';

  @override
  String get helpSetlistsS1P3 => 'Give it a name, and an optional description.';

  @override
  String get helpSetlistsS2Heading => 'Add and arrange songs';

  @override
  String get helpSetlistsS2P1 =>
      'Inside a setlist, tap \"Add Songs\" to pick from your library.';

  @override
  String get helpSetlistsS2P2 =>
      'Drag the handle on the right to change the order.';

  @override
  String get helpSetlistsS2P3 =>
      'Tap the red minus to take a song out of the setlist.';

  @override
  String get helpSetlistsS2P4 =>
      'Removing a song from a setlist does not delete it from your library.';

  @override
  String get helpSetlistsS3Heading => 'Perform a setlist';

  @override
  String get helpSetlistsS3P1 =>
      'Tap \"Perform Setlist\" to start from the first song.';

  @override
  String get helpSetlistsS3P2 =>
      'Or tap any song in the list to start from there.';

  @override
  String get helpSetlistsS3P3 =>
      'While performing, move between songs in the setlist order.';

  @override
  String get helpSetlistsS4Heading => 'Delete a setlist';

  @override
  String get helpSetlistsS4P1 =>
      'Open the setlist and use the delete (trash) icon in the top bar.';

  @override
  String get helpSetlistsS4P2 =>
      'This removes only the setlist. The songs stay in your library.';

  @override
  String get titleHelpTranspose => 'Transpose & chords';

  @override
  String get helpTransposeSummary =>
      'Change the key, hide chords, see the shapes';

  @override
  String get helpTransposeIntro =>
      'Transposing moves every chord in the song up or down by the same amount, so you can play in a key that suits the singer without rewriting anything.';

  @override
  String get helpTransposeS1Heading => 'Change the key';

  @override
  String get helpTransposeS1P1 =>
      'Open the song, then the top-bar menu (More options) → \"Performance controls\".';

  @override
  String get helpTransposeS1P2 =>
      'Use - and + to move down or up one semitone at a time.';

  @override
  String get helpTransposeS1P3 =>
      'The key the sheet now sounds in is shown between the two buttons.';

  @override
  String get helpTransposeS1P4 =>
      'The line under the controls row says how far you have moved, like \"Key A (+2)\".';

  @override
  String get helpTransposeS1P5 =>
      '\"Reset\" puts the song back to its written key.';

  @override
  String get helpTransposeS1P6 =>
      'The range is 11 semitones down to 11 semitones up. A full 12 would only land on the same key again.';

  @override
  String get helpTransposeS2Heading => 'What it changes';

  @override
  String get helpTransposeS2P1 =>
      'Slash chords move too: C/E shifted up 2 becomes D/F#.';

  @override
  String get helpTransposeS2P2 =>
      'Sharps or flats are chosen to suit the new key, so you get Bb and not A#.';

  @override
  String get helpTransposeS2P3 =>
      'The change belongs to this sheet only — it is never written back into the song.';

  @override
  String get helpTransposeS2P4 =>
      'Export and Share simply use the key you are looking at, so a transposed song goes out transposed.';

  @override
  String get helpTransposeS2P5 =>
      'A Carnatic or Hindustani song has no transpose control, because swaras are named relative to Sa and do not move.';

  @override
  String get helpTransposeS3Heading => 'Hide the chords';

  @override
  String get helpTransposeS3P1 =>
      'The same Performance controls sheet has a \"Show chords\" switch.';

  @override
  String get helpTransposeS3P2 =>
      'Turning it off leaves clean words only, which is usually what a singer wants.';

  @override
  String get helpTransposeS3P3 =>
      'The music note button in the row above the song does the same in one tap.';

  @override
  String get helpTransposeS4Heading => 'Chord Reference';

  @override
  String get helpTransposeS4P1 =>
      'Top-bar menu → \"Chord Reference\" lists every chord used in the song, already moved to the key you are playing in.';

  @override
  String get helpTransposeS4P2 =>
      'Each chord is drawn two ways: a six-string guitar fretboard with finger dots and O and X marks for open and muted strings, and a harmonium or piano keyboard with the notes lit up.';

  @override
  String get helpTransposeS4P3 =>
      'The root note is one colour; the bass note of a slash chord, such as the E in C/E, is another.';

  @override
  String get helpTransposeS4P4 =>
      'It knows the common open shapes and works out movable barre shapes for everything else.';

  @override
  String get helpTransposeS4P5 =>
      'On a Carnatic or Hindustani song this becomes \"Swara Reference\" and shows where each swara sits on the keyboard, low to high, instead of chord shapes.';

  @override
  String get titleHelpAutoScroll => 'Auto-scroll';

  @override
  String get helpAutoScrollSummary =>
      'Scroll the sheet hands-free while you play';

  @override
  String get helpAutoScrollIntro =>
      'Auto-scroll moves the chord sheet up for you while you perform, so you do not have to touch the screen. There are two modes: Manual and Tempo.';

  @override
  String get helpAutoScrollS1Heading => 'Two modes';

  @override
  String get helpAutoScrollS1P1 =>
      'Manual scrolls at a steady speed you set yourself, from 0.10x up to 2.00x. Change it by double-tapping the sheet; each tap changes it by 0.05x.';

  @override
  String get helpAutoScrollS1P2 =>
      'A song remembers the speed you set for it. A song you have never set a speed for opens at the starting speed in Settings → General → Auto-scroll.';

  @override
  String get helpAutoScrollS1P3 =>
      'Tempo works out how long the song lasts and paces the scroll to finish exactly at the end of the song.';

  @override
  String get helpAutoScrollS2Heading => 'What \"bars\" means';

  @override
  String get helpAutoScrollS2P1 =>
      'A bar (also called a measure) is a musical unit of time.';

  @override
  String get helpAutoScrollS2P2 =>
      'A song that names no tala uses common 4/4 time, so one bar is 4 beats.';

  @override
  String get helpAutoScrollS2P3 =>
      'A song with a {tala} line counts that tala\'s own beats instead, so a misra chapu song has 7 beats to the bar.';

  @override
  String get helpAutoScrollS2P4 =>
      'Songs open at 32 bars. Change the count by double-tapping the sheet — each double-tap adds or removes 4 bars.';

  @override
  String get helpAutoScrollS2P5 => 'The count can go from 1 bar up to 512.';

  @override
  String get helpAutoScrollS3Heading => 'How Tempo sets the speed';

  @override
  String get helpAutoScrollS3P1 =>
      'Song length comes from the bars and the song\'s BPM: bars x 4 beats, at the BPM you set.';

  @override
  String get helpAutoScrollS3P2 =>
      'More bars or a slower BPM makes a longer, slower scroll.';

  @override
  String get helpAutoScrollS3P3 =>
      'A higher BPM makes a shorter, faster scroll.';

  @override
  String get helpAutoScrollS3P4 =>
      'The status line shows the bars and the computed length, like \"32 bars · 1:04\".';

  @override
  String get helpAutoScrollS4Heading => 'Changing the speed by tapping';

  @override
  String get helpAutoScrollS4G1Title => 'Double-tap up top';

  @override
  String get helpAutoScrollS4G1Description => 'Faster';

  @override
  String get helpAutoScrollS4G2Title => 'Double-tap down low';

  @override
  String get helpAutoScrollS4G2Description => 'Slower';

  @override
  String get helpAutoScrollS4G3Title => 'Tap with two fingers';

  @override
  String get helpAutoScrollS4G3Description => 'Play or pause';

  @override
  String get helpAutoScrollS4P1 =>
      'The same taps work here and in full screen, so there is only one thing to remember.';

  @override
  String get helpAutoScrollS4P2 =>
      'In Tempo mode the same double-taps add or remove bars instead.';

  @override
  String get helpAutoScrollS4P3 =>
      'The new value flashes big in the middle of the screen, so you can read it from a stand.';

  @override
  String get helpAutoScrollS4P4 =>
      'This speed is only used while auto-scroll is playing. It never changes how the sheet moves when you drag it with a finger.';

  @override
  String get helpAutoScrollS4P5 =>
      'One finger still scrolls and two fingers still pinch to change the text size.';

  @override
  String get helpAutoScrollS5Heading => 'Start and stop';

  @override
  String get helpAutoScrollS5P1 =>
      'Tap the sheet with two fingers to start and stop the scroll. There is no play button on this screen any more.';

  @override
  String get helpAutoScrollS5P2 =>
      'In full screen the control bar still has a play button as well.';

  @override
  String get helpAutoScrollS5P3 =>
      'In Tempo mode the scroll stops on its own at the end of the song.';

  @override
  String get helpAutoScrollS6Heading => 'Moving the sheet by hand';

  @override
  String get helpAutoScrollS6P1 =>
      'You can drag the sheet with one finger at any time, even while auto-scroll is playing.';

  @override
  String get helpAutoScrollS6P2 =>
      'Auto-scroll waits while your finger is down and carries on from wherever you let go, so you never have to stop and start again to fix your place.';

  @override
  String get helpAutoScrollS6P3 =>
      'A fast flick stops where you lift your finger rather than coasting on, because auto-scroll takes over again straight away.';

  @override
  String get helpAutoScrollS7Heading => 'The row above the song';

  @override
  String get helpAutoScrollS7P1 =>
      'M and T pick the mode; the arrows icon goes full screen.';

  @override
  String get helpAutoScrollS7P2 =>
      'The speed, such as \"0.40x\", is shown on the right in Manual mode. It is a read-out — double-tap the sheet to change it.';

  @override
  String get helpAutoScrollS7P3 =>
      'The music note icon hides and shows the chords.';

  @override
  String get helpAutoScrollS7P4 =>
      'The piano icon hides and shows the melody rows. It is only there for a song that has a tune written in it.';

  @override
  String get titleHelpFullScreen => 'Full screen';

  @override
  String get helpFullScreenSummary => 'Just the words, controlled by taps';

  @override
  String get helpFullScreenIntro =>
      'Full screen hides the top bar and the phone\'s own bars, so the song fills the whole screen. It is made for playing live, where you look at the screen from a stand and touch it as little as possible.';

  @override
  String get helpFullScreenS1Heading => 'Going full screen';

  @override
  String get helpFullScreenS1P1 =>
      'Tap the full screen button in the auto-scroll row.';

  @override
  String get helpFullScreenS1P2 =>
      'The song, the key, the text size and the scroll position all stay as they were.';

  @override
  String get helpFullScreenS1P3 =>
      'The screen still stays awake, as it does in the normal song view.';

  @override
  String get helpFullScreenS2Heading => 'The gestures';

  @override
  String get helpFullScreenS2G1Title => 'Tap once';

  @override
  String get helpFullScreenS2G1Description => 'Show or hide the controls';

  @override
  String get helpFullScreenS2G2Title => 'Double-tap up top';

  @override
  String get helpFullScreenS2G2Description => 'Faster';

  @override
  String get helpFullScreenS2G3Title => 'Double-tap down low';

  @override
  String get helpFullScreenS2G3Description => 'Slower';

  @override
  String get helpFullScreenS2G4Title => 'Tap with two fingers';

  @override
  String get helpFullScreenS2G4Description => 'Play or pause';

  @override
  String get helpFullScreenS2G5Title => 'Pinch';

  @override
  String get helpFullScreenS2G5Description => 'Change the text size';

  @override
  String get helpFullScreenS2G6Title => 'Back';

  @override
  String get helpFullScreenS2G6Description => 'Leave full screen';

  @override
  String get helpFullScreenS2P1 =>
      'Tap once to show or hide the control bar. It slides away again after a few seconds.';

  @override
  String get helpFullScreenS2P2 =>
      'Double-tap the upper half to go faster; double-tap the lower half to go slower. The new value flashes big on the screen.';

  @override
  String get helpFullScreenS2P3 =>
      'In Tempo mode those same double-taps add or remove bars, because bars are what set the speed there.';

  @override
  String get helpFullScreenS2P4 => 'Tap with two fingers to play or pause.';

  @override
  String get helpFullScreenS2P5 =>
      'Pinch to change the text size, the same as usual.';

  @override
  String get helpFullScreenS3Heading => 'The buttons in the bar';

  @override
  String get helpFullScreenS3P1 => 'Exit (the shrink icon) leaves full screen.';

  @override
  String get helpFullScreenS3P2 => 'The padlock locks the screen — see below.';

  @override
  String get helpFullScreenS3P3 =>
      'The bell turns Stage Quiet Mode on and off — see below.';

  @override
  String get helpFullScreenS3P4 =>
      'M and T pick Manual or Tempo, and the round button plays or pauses.';

  @override
  String get helpFullScreenS3P5 =>
      'The bars icon opens the pitch pipe and shruti box.';

  @override
  String get helpFullScreenS3P6 =>
      'The - and + at the end change the speed in Manual mode and the bar count in Tempo mode, the same as the double-taps.';

  @override
  String get helpFullScreenS3P7 =>
      'The line under the buttons repeats the key, the BPM and, in Tempo mode, the length.';

  @override
  String get helpFullScreenS4Heading => 'Lock the screen';

  @override
  String get helpFullScreenS4P1 =>
      'Tap the padlock to lock Stage View. The tap controls are then switched off, so a sleeve or a stray hand cannot change your speed or pause you mid-song.';

  @override
  String get helpFullScreenS4P2 =>
      'The control bar hides and a small \"Stage Locked\" chip appears in the top right.';

  @override
  String get helpFullScreenS4P3 =>
      'Tap that chip, or press Back, to unlock. It asks for your fingerprint, or the PIN, pattern or password the phone already uses.';

  @override
  String get helpFullScreenS4P4 =>
      'On a phone with no screen lock set up there is nothing to check against, so it simply unlocks.';

  @override
  String get helpFullScreenS4P5 =>
      'If the check cannot run at all, the stage unlocks anyway and says so. The lock is there to stop stray touches, so it will never shut you out.';

  @override
  String get helpFullScreenS5Heading => 'Stage Quiet Mode';

  @override
  String get helpFullScreenS5P1 =>
      'Tap the bell to mute the ringer and notification alerts while you play, so a call cannot chime through the PA.';

  @override
  String get helpFullScreenS5P2 =>
      'The app\'s own sound is left alone — the metronome click, the pitch cue and the drone all keep working.';

  @override
  String get helpFullScreenS5P3 =>
      'The icon turns red only once the phone has really gone silent. Tap it again, leave full screen, or leave the song, and your normal ringer setting comes back — even if the app was closed.';

  @override
  String get helpFullScreenS5P4 =>
      'The first time, Android may ask you to allow \"Do Not Disturb access\" for LyricChord. Tap Open settings in the message, turn it on, then tap the bell again.';

  @override
  String get helpFullScreenS5P5 =>
      'iPhones do not let apps change the ringer, so the bell is not shown there. Use the ring/silent switch instead.';

  @override
  String get helpFullScreenS6Heading => 'Getting back';

  @override
  String get helpFullScreenS6P1 =>
      'Press Back, or tap once and use the exit button in the control bar.';

  @override
  String get helpFullScreenS6P2 =>
      'That leaves full screen only — you are still on the same song. Press Back again to return to your songbook.';

  @override
  String get helpFullScreenS6P3 =>
      'Swiping sideways does not change the song while you are full screen, so a stray touch cannot throw the wrong song up mid-song.';

  @override
  String get titleHelpMetronome => 'Metronome';

  @override
  String get helpMetronomeSummary => 'Keep the beat at the song tempo';

  @override
  String get helpMetronomeIntro =>
      'The metronome keeps time while you perform. Its speed comes from each song\'s BPM (beats per minute), which you set in the song editor.';

  @override
  String get helpMetronomeS1Heading => 'Turn it on';

  @override
  String get helpMetronomeS1P1 => 'Go to Settings > General > Metronome.';

  @override
  String get helpMetronomeS1P2 => 'Switch on \"Enable metronome\".';

  @override
  String get helpMetronomeS1P3 =>
      'The setting is saved and stays on after you restart the app.';

  @override
  String get helpMetronomeS2Heading => 'Flash and Click';

  @override
  String get helpMetronomeS2P1 =>
      'Flash blinks on every beat — handy when the sound is muted.';

  @override
  String get helpMetronomeS2P2 => 'Click plays a short tick on every beat.';

  @override
  String get helpMetronomeS2P3 => 'You can use either, both, or neither.';

  @override
  String get helpMetronomeS2P4 =>
      'Flash and Click stay greyed out until the metronome is enabled.';

  @override
  String get helpMetronomeS2P5 =>
      'Click volume sets how loud the tick is. The tick uses the media volume, so raise the volume buttons while a song is open if you cannot hear it.';

  @override
  String get helpMetronomeS2P6 =>
      'Tap \"Test the sound\" in Metronome settings to hear one bar without opening a song.';

  @override
  String get helpMetronomeS3Heading => 'Beats in a bar';

  @override
  String get helpMetronomeS3P1 =>
      'Pick 2, 3, 4 or 6 beats in a bar in Metronome settings.';

  @override
  String get helpMetronomeS3P2 =>
      'With \"Accent beat 1\" on, the first beat of every bar is louder and higher, so you can hear where the bar starts.';

  @override
  String get helpMetronomeS3P3 =>
      'While the beat runs, the button counts the beat number — 1, 2, 3, 4 — so you can see your place even with the sound off.';

  @override
  String get helpMetronomeS4Heading => 'Set the tempo';

  @override
  String get helpMetronomeS4P1 =>
      'By default the beat speed follows the song\'s BPM.';

  @override
  String get helpMetronomeS4P2 => 'Change a song\'s BPM by editing the song.';

  @override
  String get helpMetronomeS4P3 =>
      'Long press the metronome button to set the speed by hand: use - and +, drag the slider, or tap \"Tap tempo\" along with the music.';

  @override
  String get helpMetronomeS4P4 =>
      'A tempo you set by hand lasts for this session only. Tap \"Use song tempo\" to go back to the song\'s own speed.';

  @override
  String get helpMetronomeS4P5 =>
      'A song with no saved BPM still works — the metronome uses the last speed you used.';

  @override
  String get titleHelpPitchPipeDrone => 'Pitch Pipe & Drone';

  @override
  String get helpPitchPipeDroneSummary =>
      'Reference pitch cues and a steady shruti box drone';

  @override
  String get helpPitchPipeDroneIntro =>
      'A fully offline sound generator: a short reference note to start on, and a steady shruti box drone to sing against. Nothing is downloaded and no sound files ship with the app — the tones are built as you press the button.';

  @override
  String get helpPitchPipeDroneS1Heading =>
      'What the drone does — and does not do';

  @override
  String get helpPitchPipeDroneS1P1 =>
      'The drone holds ONE steady pair of notes for as long as it is on.';

  @override
  String get helpPitchPipeDroneS1P2 =>
      'It does NOT follow the tune, the words, or the chords. It never changes until you change it.';

  @override
  String get helpPitchPipeDroneS1P3 =>
      'Think of it as a tuning fork that never stops, so your ear stays anchored while you sing.';

  @override
  String get helpPitchPipeDroneS2Heading => 'Where to find it';

  @override
  String get helpPitchPipeDroneS2P1 =>
      'Open a song and tap the pitch button (the bars icon) next to the metronome.';

  @override
  String get helpPitchPipeDroneS2P2 =>
      'It is in the Stage Mode bar too, next to the play button.';

  @override
  String get helpPitchPipeDroneS2P3 =>
      'Settings → General → Pitch Pipe & Drone sets the defaults and has Test buttons.';

  @override
  String get helpPitchPipeDroneS3Heading =>
      'Pitch Cue (called Chord Cue in Western)';

  @override
  String get helpPitchPipeDroneS3P1 =>
      'Tap \"Pitch Cue\" to hear a 2-second reference note. It is a digital pitch pipe: it sounds your Sa (or the key you picked), then stops on its own.';

  @override
  String get helpPitchPipeDroneS3P2 =>
      'Use it to find your starting note before you begin singing.';

  @override
  String get helpPitchPipeDroneS3P3 =>
      'In Western mode the same button is named \"Chord Cue\" and plays the whole chord — bass, root, third and fifth — because Western players want the chord, not one note. Major or minor follows the quality you picked.';

  @override
  String get helpPitchPipeDroneS3P4 =>
      'The length is fixed at 2 seconds and there is no setting for it. That is long enough to hear the pitch clearly and short enough not to get in the way. The button says \"(2s)\" so you know what you will get before you tap it.';

  @override
  String get helpPitchPipeDroneS3P5 =>
      'If you want a tone that lasts longer, use the Shruti Drone instead. That is what it is for.';

  @override
  String get helpPitchPipeDroneS4Heading => 'Cue or drone — which one?';

  @override
  String get helpPitchPipeDroneS4P1 =>
      'Cue: one short sound that stops by itself. For finding the note before you start.';

  @override
  String get helpPitchPipeDroneS4P2 =>
      'Drone: keeps sounding until you stop it. For singing against while you practise or perform.';

  @override
  String get helpPitchPipeDroneS4P3 =>
      'Both are built inside the app the moment you press the button. Nothing is downloaded and no sound files ship with the app.';

  @override
  String get helpPitchPipeDroneS5Heading => 'Shruti box drone';

  @override
  String get helpPitchPipeDroneS5P1 =>
      'Tap \"Shruti Drone\" to start a continuous background hum.';

  @override
  String get helpPitchPipeDroneS5P2 =>
      'Choose Sa + Pa (the fifth) for most music, or Sa + Ma (the fourth) for ragas that leave out Pa, such as Malkauns or Marwa.';

  @override
  String get helpPitchPipeDroneS5P3 =>
      'The two notes are tuned in pure ratios (3:2 and 4:3), the way a real drone instrument sounds — not in equal temperament.';

  @override
  String get helpPitchPipeDroneS5P4 =>
      'The drone keeps playing until you stop it, so you can practise without it cutting out.';

  @override
  String get helpPitchPipeDroneS6Heading => 'Indian and Western naming';

  @override
  String get helpPitchPipeDroneS6P1 =>
      'Sa is movable, so the app must know which actual pitch your Sa is. Set it in Settings → \"Your Sa (Shruti)\".';

  @override
  String get helpPitchPipeDroneS6P2 =>
      'A song with a raga is named the Indian way: \"5 kattai\" for Carnatic, \"safed 5\" for Hindustani. The tala decides which. No Western letters appear on an Indian sheet.';

  @override
  String get helpPitchPipeDroneS6P3 =>
      'A song without a raga is named the Western way: just \"G\".';

  @override
  String get helpPitchPipeDroneS6P4 =>
      'A Western song opens on the song\'s own key. An Indian song opens on your Sa, because the notation is written relative to Sa.';

  @override
  String get helpPitchPipeDroneS7Heading => 'Text size for the stage';

  @override
  String get helpPitchPipeDroneS7P1 =>
      'The same sheet is read on a phone in your hand and on a stand two steps away, so the pitch sheet carries a text size setting.';

  @override
  String get helpPitchPipeDroneS7P2 =>
      'Pick one of five sizes — 85%, 95%, 100%, 115% or 130% — from the chips at the bottom of the pitch sheet.';

  @override
  String get helpPitchPipeDroneS7P3 =>
      'Settings → General → Pitch Pipe & Drone has the same chips, so you can set it before a gig.';

  @override
  String get helpPitchPipeDroneS7P4 =>
      'It multiplies the sheet text size everywhere, not only in full screen.';

  @override
  String get helpPitchPipeDroneS7P5 =>
      'Pinching the sheet with two fingers still works and is the quicker way to nudge one song.';

  @override
  String get titleHelpMelody => 'Melody Lines';

  @override
  String get helpMelodySummary =>
      'Write the tune under the words, then hear it.';

  @override
  String get helpMelodyIntro =>
      'A chord sheet tells you the words and tells the accompanist what to play. It does not tell you the tune. A melody line adds that. Write {melody} under a lyric line and the app draws the beats and hums them back, so you can learn a song you have never heard.';

  @override
  String get helpMelodyS1Heading => 'Writing one';

  @override
  String get helpMelodyS1P1 =>
      'Put a line starting with {melody} under the lyric line it belongs to.';

  @override
  String get helpMelodyS1P2 => 'Example: {melody} P ,  M2 | M2!G3~ ,  | R2 S';

  @override
  String get helpMelodyS1P3 =>
      'Beats are separated by spaces. One beat, one space.';

  @override
  String get helpMelodyS1P4 =>
      'The words and chords above it do not change at all.';

  @override
  String get helpMelodyS1P5 =>
      'You do not have to type it. In the editor, More options → \"Melody keypad\" gives you a pad of all sixteen swaras and every mark, draws the beats as you tap, and counts \"6 of 8 beats\" until the line fills the tala.';

  @override
  String get helpMelodyS1P6 =>
      'With the cursor already on a {melody} line, the keypad loads that line so you can fix it instead of deleting it first.';

  @override
  String get helpMelodyS1P7 =>
      'A block of published Carnatic notation can be turned into melody lines in one go — see the Indian songs topic.';

  @override
  String get helpMelodyS2Heading => 'The five marks';

  @override
  String get helpMelodyS2P1 =>
      'A comma ( , ) holds the note before it for one more beat.';

  @override
  String get helpMelodyS2P2 =>
      'A bar ( | ) shows where a new tala group starts. It takes no time.';

  @override
  String get helpMelodyS2P3 =>
      'A hyphen ( - ) joins notes that share one beat: G3-R2 is half a beat each.';

  @override
  String get helpMelodyS2P4 =>
      'A bang ( ! ) slides into a note. M2!G3 starts the slide at Ma. A bare !G3 is a short slide in from just under Ga.';

  @override
  String get helpMelodyS2P5 => 'A tilde ( ~ ) shakes the note.';

  @override
  String get helpMelodyS3Heading => 'Naming the notes';

  @override
  String get helpMelodyS3P1 =>
      'A bare name is the note from the plain Sa Re Ga Ma Pa Dha Ni row, so Ma on its own is Ma1.';

  @override
  String get helpMelodyS3P2 =>
      'A digit names the exact one: Ma2 is the raised Ma, R1 R2 R3 are the three Ris.';

  @override
  String get helpMelodyS3P3 =>
      'Ma2 and M2 mean the same note. Use full names in chords and short letters in melody lines, or whichever reads better.';

  @override
  String get helpMelodyS3P4 =>
      'The raga never changes what a name means, so nothing is guessed.';

  @override
  String get helpMelodyS3P5 =>
      'A dot in front drops a note an octave (.N3). An apostrophe after raises it (S\').';

  @override
  String get helpMelodyS4Heading => 'Hearing it';

  @override
  String get helpMelodyS4P1 =>
      'Add {tonic: 1 kattai} so the app knows where your Sa really is. Without it the beats still draw, but nothing can play.';

  @override
  String get helpMelodyS4P2 =>
      'Add {tala: misra chapu} so the beats are grouped correctly.';

  @override
  String get helpMelodyS4P3 => 'The song tempo sets the speed.';

  @override
  String get helpMelodyS4P4 =>
      'Tap the play button beside a melody line to hum it.';

  @override
  String get helpMelodyS4P5 =>
      'To read the words without the tune rows, open the overflow menu → Performance controls and turn Show melody off. Full screen never draws the melody rows.';

  @override
  String get helpMelodyS4P6 =>
      'Turn on Loop to repeat the line, or Half speed to learn it slowly.';

  @override
  String get helpMelodyS4P7 =>
      'Start the shruti drone first — a tune is much easier to hear against a drone than on its own.';

  @override
  String get helpMelodyS5Heading => 'What it can and cannot do';

  @override
  String get helpMelodyS5P1 =>
      'It shows you where the notes go and how long each one lasts.';

  @override
  String get helpMelodyS5P2 =>
      'It does not shape them the way a singer does. Listen to a recording for that.';

  @override
  String get helpMelodyS5P3 =>
      'Every song needs a person who knows the tune to type it in. There is no shortcut.';

  @override
  String get titleHelpIndianSongs => 'Indian songs';

  @override
  String get helpIndianSongsSummary =>
      'Swaras, raga, tala, and where your Sa is';

  @override
  String get helpIndianSongsIntro =>
      'An Indian song is written in swaras — Sa Re Ga Ma Pa Dha Ni — not in chords, and those names are relative to Sa rather than to a fixed pitch. The app treats such a song differently all the way through.';

  @override
  String get helpIndianSongsS1Heading => 'Mark the song as Indian';

  @override
  String get helpIndianSongsS1P1 =>
      'In the editor, set \"Notation\" to Carnatic or Hindustani.';

  @override
  String get helpIndianSongsS1P2 =>
      'The \"Original key\" box is replaced by Raga and Tala, because an Indian sheet has no key to transpose.';

  @override
  String get helpIndianSongsS1P3 =>
      'Switching back to Western clears the raga and tala, so an old value can never make the song look Indian again.';

  @override
  String get helpIndianSongsS2Heading => 'The note under the Tala box';

  @override
  String get helpIndianSongsS2P1 =>
      'Typing a tala that belongs to the other tradition — Keherwa on a Carnatic song, say — shows a short note under the box.';

  @override
  String get helpIndianSongsS2P2 =>
      'It is advice only. It never stops you saving. The app knows a fixed list of tala names and yours may simply not be on it.';

  @override
  String get helpIndianSongsS2P3 =>
      'The tala also decides how many beats are in a bar for Tempo auto-scroll and for the beat grid under a melody line.';

  @override
  String get helpIndianSongsS3Heading => 'What changes on the song screen';

  @override
  String get helpIndianSongsS3P1 =>
      'No Western letter is shown. The status line reads \"Auto-scroll · 120 BPM\", with the raga and tala on the line below it.';

  @override
  String get helpIndianSongsS3P2 =>
      'There is no transpose control, because a swara does not move.';

  @override
  String get helpIndianSongsS3P3 =>
      'The menu offers \"Swara Reference\" in place of Chord Reference.';

  @override
  String get helpIndianSongsS3P4 =>
      'The pitch sheet opens on your saved Sa instead of a song key, and names it the Indian way — \"5 kattai\" for Carnatic, \"safed 5\" for Hindustani.';

  @override
  String get helpIndianSongsS4Heading => 'Lines you can put in the words';

  @override
  String get helpIndianSongsS4P1 =>
      '{tonic: 1 kattai} says where your Sa really is. A melody line cannot be played without it.';

  @override
  String get helpIndianSongsS4P2 => '{tala: misra chapu} groups the beats.';

  @override
  String get helpIndianSongsS4P3 =>
      '{sruti: madhyama} marks a song sung with the drone\'s Pa string dropped to shuddha madhyamam, as Yamunakalyani usually is. The written Sa then sounds a fourth higher.';

  @override
  String get helpIndianSongsS4P4 =>
      '{melody} lines hold the tune — see the Melody Lines topic.';

  @override
  String get helpIndianSongsS4P5 =>
      'All of these live in the song text, so import and export carry them through unchanged.';

  @override
  String get helpIndianSongsS5Heading => 'Paste published notation';

  @override
  String get helpIndianSongsS5P1 =>
      'In the editor, More options → \"Paste Carnatic\" takes a block copied from a book or a page and turns it into {melody} lines.';

  @override
  String get helpIndianSongsS5P2 =>
      'Published notation has no single standard: on some pages a capital letter means a longer note, on others it means a higher octave.';

  @override
  String get helpIndianSongsS5P3 =>
      'So the app reads the block both ways, checks each against the song\'s tala, and tells you which one fitted and by how much — like \"1 of 1 cycles fit, read with case means note length\".';

  @override
  String get helpIndianSongsS5P4 =>
      'Where the two ways tie it says so instead of guessing.';

  @override
  String get helpIndianSongsS5P5 =>
      'It will not choose between the two Ma-s on its own. That is raga grammar, not arithmetic — but it points out the phrase that decides it.';

  @override
  String get titleHelpSelectSongs => 'Select Songs';

  @override
  String get helpSelectSongsSummary => 'Act on several songs at once';

  @override
  String get helpSelectSongsIntro =>
      'Selection mode lets you choose many songs together and then export or delete them in one step.';

  @override
  String get helpSelectSongsS1Heading => 'Start selecting';

  @override
  String get helpSelectSongsS1P1 =>
      'On the Songs list, long-press any song to start selection mode.';

  @override
  String get helpSelectSongsS1P2 =>
      'Tap more songs to add them to the selection.';

  @override
  String get helpSelectSongsS1P3 =>
      'The top bar shows how many songs are selected.';

  @override
  String get helpSelectSongsS2Heading => 'Select all';

  @override
  String get helpSelectSongsS2P1 =>
      'Use the \"Select all\" icon in the top bar to pick every visible song.';

  @override
  String get helpSelectSongsS2P2 =>
      'Tap it again (\"Deselect all\") to clear the selection.';

  @override
  String get helpSelectSongsS3Heading => 'What you can do';

  @override
  String get helpSelectSongsS3P1 =>
      'Export the selected songs as one ChordPro file.';

  @override
  String get helpSelectSongsS3P2 =>
      'Delete the selected songs from your library.';

  @override
  String get helpSelectSongsS3P3 =>
      'Tap the X on the top-left to leave selection mode without changes.';

  @override
  String get titleHelpImport => 'Import';

  @override
  String get helpImportSummary => 'Bring songs into the app';

  @override
  String get helpImportIntro =>
      'Import adds songs from ChordPro or plain text files into your library. Reading is defensive — broken or unreadable files are skipped safely and never break the app.';

  @override
  String get helpImportS1Heading => 'Supported file types';

  @override
  String get helpImportS1P1 =>
      'You can pick files ending in .cho, .pro, .chordpro, or .txt.';

  @override
  String get helpImportS1P2 =>
      'ChordPro files are plain text files that use simple tags for chords and headers.';

  @override
  String get helpImportS1P3 =>
      'You can pick one file or multiple files at the same time.';

  @override
  String get helpImportS2Heading => 'Multiple songs in one file';

  @override
  String get helpImportS2P1 => 'A single file can contain many songs.';

  @override
  String get helpImportS2P2 =>
      'Put {new_song} or {ns} on its own line between songs to separate them. This is the same separator used when you export your whole songbook.';

  @override
  String get helpImportS2P3 =>
      'You can also separate songs by starting a new {title: ...} or {t: ...} tag. The app automatically detects where the new song begins.';

  @override
  String get helpImportS3Heading => 'Text files without tags';

  @override
  String get helpImportS3P1 =>
      'A plain text file with no tags is imported safely as one song.';

  @override
  String get helpImportS3P2 =>
      'The app gives it the name \"Untitled Song\" and key C.';

  @override
  String get helpImportS3P3 =>
      'You can open and edit its title, chords, key, and tempo at any time.';

  @override
  String get helpImportS4Heading => 'Duplicate songs';

  @override
  String get helpImportS4P1 =>
      'If a song has the same title as one in your library, the app follows your duplicate setting.';

  @override
  String get helpImportS4P2 =>
      'You can choose to overwrite the existing song, rename the new one, rename the old one, or ask for a title each time.';

  @override
  String get helpImportS4P3 =>
      'Set this in Settings → General → Import Settings.';

  @override
  String get helpImportS5Heading => 'Check before it is saved';

  @override
  String get helpImportS5P1 => 'Every import stops at a preview screen first.';

  @override
  String get helpImportS5P2 =>
      'You can read the titles, artists, keys and words that were found, and fix a title before anything is written.';

  @override
  String get helpImportS5P3 =>
      'Nothing reaches your library until you confirm.';

  @override
  String get helpImportS6Heading => 'Other ways songs come in';

  @override
  String get helpImportS6P1 =>
      'Opening a ChordPro file from a file manager, an email or a chat app hands it to LyricChord and opens the same preview.';

  @override
  String get helpImportS6P2 =>
      'A bandmate standing next to you can send songs with no file at all — see the AirQR topic.';

  @override
  String get titleHelpExport => 'Export';

  @override
  String get helpExportSummary => 'Save your songs out of the app';

  @override
  String get helpExportIntro =>
      'Export saves songs as a file you choose the place for. Share hands the same file straight to another app. Everything stays offline — nothing is uploaded, and the system file picker or share sheet does the work.';

  @override
  String get helpExportS1Heading => 'Export all songs';

  @override
  String get helpExportS1P1 => 'Go to Settings > General > Import.';

  @override
  String get helpExportS1P2 => 'Tap \"Export all songs\".';

  @override
  String get helpExportS1P3 =>
      'Your whole songbook is saved as one ChordPro file.';

  @override
  String get helpExportS2Heading => 'Export some songs (ChordPro)';

  @override
  String get helpExportS2P1 =>
      'On the Songs list, long-press to select the songs you want.';

  @override
  String get helpExportS2P2 => 'Tap the export icon in the top bar.';

  @override
  String get helpExportS2P3 =>
      'The selected songs are saved as one ChordPro file.';

  @override
  String get helpExportS3Heading => 'Export one song';

  @override
  String get helpExportS3P1 =>
      'Open the song, then the top-bar menu (More options) → \"Export\".';

  @override
  String get helpExportS3P2 =>
      'Choose ChordPro (.chordpro) or PDF (.pdf), then tap Export.';

  @override
  String get helpExportS3P3 =>
      'The system file saver opens so you can pick where it goes.';

  @override
  String get helpExportS3P4 =>
      'Whatever you export uses the key you are looking at, so a song you have transposed is saved in that key.';

  @override
  String get helpExportS4Heading => 'What a PDF looks like';

  @override
  String get helpExportS4P1 =>
      'Title, artist, key and BPM at the top, guitar chord diagrams under that, then the words with the chords above them.';

  @override
  String get helpExportS4P2 =>
      'The words use the lyric font you picked in Settings → Fonts, so Malayalam is shaped correctly and the text stays selectable.';

  @override
  String get helpExportS4P3 =>
      'The page is only as wide as the song needs — a song with short lines gets a narrow, tall page that fills a phone screen better — up to A4 width at the most.';

  @override
  String get helpExportS4P4 =>
      'If a line is still too long, the font is stepped down (never below 9 pt) so it does not wrap in the middle.';

  @override
  String get helpExportS5Heading => 'Share instead of save';

  @override
  String get helpExportS5P1 =>
      'The top-bar menu also has \"Share\", which opens the system share sheet instead of the file saver.';

  @override
  String get helpExportS5P2 =>
      'You can share as ChordPro, as PDF, or as an AirQR stream — see the AirQR topic.';

  @override
  String get helpExportS5P3 =>
      'Selecting several songs on the Songs list gives you the same share choice for the whole set.';

  @override
  String get titleHelpAirqr => 'AirQR sharing';

  @override
  String get helpAirqrSummary => 'Pass songs to another phone with the camera';

  @override
  String get helpAirqrIntro =>
      'AirQR moves songs from one phone to another by flashing a run of QR codes on one screen while the other phone watches with its camera. No internet, no Bluetooth, no Wi-Fi, no cable and no account — just two screens facing each other.';

  @override
  String get helpAirqrS1Heading => 'Send one song';

  @override
  String get helpAirqrS1P1 =>
      'Open the song, then the top-bar menu → \"Share\".';

  @override
  String get helpAirqrS1P2 => 'Pick \"AirQR stream\" and tap Share.';

  @override
  String get helpAirqrS1P3 =>
      'The codes start flashing straight away. Hold the phone still and let the other one read it.';

  @override
  String get helpAirqrS1P4 =>
      'What goes across is the song as you are looking at it, so a key you have transposed to travels with it.';

  @override
  String get helpAirqrS2Heading => 'Send several songs';

  @override
  String get helpAirqrS2P1 =>
      'Settings → General → Import → \"Send all via AirQR\" sends the whole songbook.';

  @override
  String get helpAirqrS2P2 =>
      'Or long-press on the Songs list to select some songs and tap the QR icon in the top bar.';

  @override
  String get helpAirqrS3Heading => 'Receive';

  @override
  String get helpAirqrS3P1 =>
      'On the receiving phone, tap the scan icon in the songbook top bar, or go to Settings → General → Import → \"Import via AirQR\".';

  @override
  String get helpAirqrS3P2 =>
      'Point the camera at the sending screen and wait. The panel counts the pieces as they arrive.';

  @override
  String get helpAirqrS3P3 =>
      'When it has everything the phone buzzes and the import preview opens, so you can check the songs before they are saved.';

  @override
  String get helpAirqrS3P4 =>
      'The gallery icon reads a photo of a code instead of the live camera, for a code someone sent you as a picture.';

  @override
  String get helpAirqrS4Heading => 'Getting a clean read';

  @override
  String get helpAirqrS4P1 =>
      'The song is cut into small pieces shown one after another, with spare repair pieces mixed in, so a frame the camera misses is filled in instead of starting again.';

  @override
  String get helpAirqrS4P2 =>
      'The \"Stream Speed\" slider on the sending phone runs from 5 to 25 frames a second and starts at 10.';

  @override
  String get helpAirqrS4P3 =>
      'An older phone or a dim screen reads better slower. Turn the speed down if the count stops moving.';

  @override
  String get helpAirqrS4P4 =>
      'Keep both screens still and bright, roughly a hand-span apart.';

  @override
  String get titleHelpAppearance => 'Themes & fonts';

  @override
  String get helpAppearanceSummary => 'Make the sheet easy to read';

  @override
  String get helpAppearanceIntro =>
      'A sheet read on a dark stage and a sheet read at a desk are not the same job. Three settings cover it: the theme, the lyric font, and how big the text is.';

  @override
  String get helpAppearanceS1Heading => 'Theme';

  @override
  String get helpAppearanceS1P1 =>
      'Settings → Themes offers System theme, Light theme and Dark theme.';

  @override
  String get helpAppearanceS1P2 =>
      'System follows whatever the phone is set to.';

  @override
  String get helpAppearanceS1P3 =>
      'Dark is easier on the eyes on a stage and easier on the battery.';

  @override
  String get helpAppearanceS1P4 =>
      'The choice is saved and takes effect at once.';

  @override
  String get helpAppearanceS2Heading => 'Lyric font';

  @override
  String get helpAppearanceS2P1 =>
      'Settings → Fonts picks the font the words are drawn in: System default, Noto Sans Malayalam, Noto Serif Malayalam, Manjari or Gayathri.';

  @override
  String get helpAppearanceS2P2 =>
      'Each choice shows a live sample in English and in Malayalam, so you can see the letter shapes before you pick.';

  @override
  String get helpAppearanceS2P3 =>
      'The Malayalam fonts shape chillu, conjuncts and vowel signs properly. The system font often does not.';

  @override
  String get helpAppearanceS2P4 =>
      'One choice covers the whole app, and the exported PDF uses the same font.';

  @override
  String get helpAppearanceS2P5 =>
      'The fonts are bundled with the app under an open licence and are listed on the licences page in About.';

  @override
  String get helpAppearanceS3Heading => 'Text size';

  @override
  String get helpAppearanceS3P1 =>
      'Pinch the words with two fingers to make the text bigger or smaller, from 10 up to 32.';

  @override
  String get helpAppearanceS3P2 =>
      'It works on the ordinary song screen and in full screen, and it does not disturb the scrolling.';

  @override
  String get helpAppearanceS3P3 =>
      'The pitch sheet also has five fixed sizes — 85%, 95%, 100%, 115% and 130% — which multiply whatever the pinch has set. Use those to set a stage size once and keep it.';

  @override
  String get helpTopicNotFound => 'Help topic not found.';

  @override
  String labelAirQrFps(String fps) {
    return '$fps FPS';
  }

  @override
  String get errorStorageLoadSongs => 'Could not load songs.';

  @override
  String get errorStorageOpenSong => 'Could not open the song.';

  @override
  String get errorStorageFindSongByTitle =>
      'Could not search for song by title.';

  @override
  String get errorStorageSaveSong => 'Could not save the song.';

  @override
  String get errorStorageUpdateSong => 'Could not update the song.';

  @override
  String get errorStorageSaveScrollSpeed => 'Could not save the scroll speed.';

  @override
  String get errorStorageDeleteSong => 'Could not delete the song.';

  @override
  String get errorStorageCreateSetlist => 'Could not create setlist.';

  @override
  String get errorStorageUpdateSetlist => 'Could not update setlist.';

  @override
  String get errorStorageUpdateSetlistSongs =>
      'Could not update setlist songs.';

  @override
  String get errorStorageAddSongToSetlist => 'Could not add song to setlist.';

  @override
  String get errorStorageDeleteSetlist => 'Could not delete setlist.';

  @override
  String get errorDroneErrorChordCue => 'Could not play the chord cue.';

  @override
  String get errorDroneErrorPitchCue => 'Could not play the pitch cue.';

  @override
  String get errorDroneErrorStartDrone => 'Could not start the drone.';

  @override
  String errorMelodyProblemUnreadable(String piece, String token) {
    return 'Could not read \"$piece\" in \"$token\".';
  }

  @override
  String errorMelodyProblemNothingToPlay(String token) {
    return 'Nothing to play in \"$token\".';
  }

  @override
  String errorCarnaticProblemUnknownTala(String tala) {
    return 'Could not work out how many beats \"$tala\" has.';
  }

  @override
  String get errorCarnaticProblemNoNotation => 'No notation found to read.';

  @override
  String errorCarnaticProblemCyclesOff(int fitting, int total, String tala) {
    return '$fitting of $total cycles land on $tala. The rest are the wrong length, so some beats will be off.';
  }

  @override
  String get errorCarnaticProblemReadingsTie =>
      'Both readings of upper/lower case score the same, so the choice between them is a guess. Check it against the source page.';

  @override
  String get errorCarnaticProblemNothingReadable => 'nothing readable';

  @override
  String errorCarnaticProblemWrongLength(String got, int wanted) {
    return 'reads as $got aksharakalas, but this tala wants $wanted';
  }

  @override
  String errorCarnaticProblemUnreadableCharacter(
    String character,
    String token,
  ) {
    return 'could not read \"$character\" in \"$token\"';
  }

  @override
  String errorCarnaticProblemInCycle(int cycle, String problem) {
    return 'Cycle $cycle: $problem';
  }

  @override
  String get errorWidgetFailed => 'This part of the screen could not be shown.';

  @override
  String get titleStartupFailed => 'Could not start';

  @override
  String get descStartupFailed =>
      'LyricChord could not open its saved data. Your songs have not been changed. Try again, or copy the details to report the problem.';

  @override
  String get actionCopyDetails => 'Copy details';

  @override
  String get bodyDetailsCopied => 'Details copied';

  @override
  String get tooltipBack => 'Back';

  @override
  String get tooltipAirQrReceiverTorchOn => 'Turn on flashlight';

  @override
  String get tooltipAirQrReceiverTorchOff => 'Turn off flashlight';

  @override
  String get tooltipAirQrReceiverSwitchCamera => 'Switch camera';

  @override
  String get aboutDetailAuthor => 'Author';

  @override
  String get aboutDetailEmail => 'Email';

  @override
  String get aboutDetailLicense => 'License';

  @override
  String get aboutDetailWebsite => 'Website';

  @override
  String get aboutDetailPrivacyPolicy => 'Privacy policy';

  @override
  String get aboutDetailAiUsed => 'AI used';

  @override
  String get aboutDetailIdeUsed => 'IDE used';

  @override
  String get titleSettingsDeleteAllData => 'Delete all data';

  @override
  String get descSettingsDeleteAllDataSubtitle =>
      'Remove every song, setlist and setting';

  @override
  String get titleDeleteAllData => 'Delete all data?';

  @override
  String get descDeleteAllData =>
      'Every song, setlist, note and setting on this phone will be deleted. This cannot be undone. LyricChord then starts fresh, with its sample songs.';

  @override
  String get actionDeleteEverything => 'Delete everything';

  @override
  String get bodyAllDataDeleted => 'All data deleted';

  @override
  String get errorStorageDeleteAllData =>
      'Could not delete all data. Some of it may still be there.';

  @override
  String get helpSongbookS6Heading => 'Start fresh';

  @override
  String get helpSongbookS6P1 =>
      'Settings → Delete all data removes every song, setlist, note and setting from this phone. It cannot be undone.';

  @override
  String get helpSongbookS6P2 =>
      'LyricChord then starts as it did when first installed, with its sample songs.';

  @override
  String get helpSongbookS6P3 =>
      'Export your songs first if you may want them back (see the Export topic).';

  @override
  String get titleSettingsLanguage => 'Language';

  @override
  String get labelLanguageSystem => 'System default';

  @override
  String get tooltipHideList => 'Hide list';

  @override
  String get tooltipShowList => 'Show list';

  @override
  String get descResizeListHandle =>
      'Drag to resize the song list. Double-tap to hide or show it.';
}
