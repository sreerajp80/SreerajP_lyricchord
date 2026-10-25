# Change log: Guideline compliance — Phase 5 (ARB key prefixes)

Implements Phase 5 of plan:
[../plans/20261023_073607_guideline-compliance-audit.md](../plans/20261023_073607_guideline-compliance-audit.md)
(gap E3, answer Q7 "rename all keys now").

## What changed

- Every key in `lib/l10n/app_en.arb` now starts with its category, as engineering standard
  §8.6 asks, so the length budget can be checked by key name in Phase 6:
  - short UI text: `action…`, `label…`, `title…`, `tab…`, `tooltip…`;
  - long text: `desc…`, `help…`, `empty…`, `error…`, `body…`.
- **539 keys renamed.** 407 keys kept their names: 402 help-text keys already
  started with `help`, and the 5 keys added in Phase 4 already used the prefixes.
- Key count by category: action 59, body 20, desc 119, empty 16, error 65, help 402, label 129, tab 2, title 71, tooltip 63.
- Only key **names** changed. No English text changed, so the app looks and reads the same.
- A category suffix is dropped when the prefix says the same thing
  (`songListExportDialogTitle` → `titleSongListExportDialog`,
  `melodyKeypadHoldTooltip` → `tooltipMelodyKeypadHold`,
  `songMetaTitleLabel` → `labelSongMetaTitle`).
- Help topic titles (`helpXxxTitle`, shown as screen titles) became `titleHelpXxx`. The
  gesture names inside help topics (`help…S#G#Title`) stay `help…`, because they are help
  content.
- `l10n.yaml`, the ARB descriptions and placeholders are unchanged. `flutter gen-l10n`
  re-created `lib/l10n/app_localizations*.dart`.

### How the call sites were renamed

Many old key names are also ordinary method names (`add`, `clear`, `close`, `play`,
`insert`, `share`, `delete`), so a text search-and-replace was not safe: it matched 985
lines, against 705 real uses. The rename used the Dart analyzer instead: a one-off tool
(kept outside the repository, so no new dependency) renamed only identifiers that resolve
to a member of `AppLocalizations` — 629 references in 58 files in `lib/` and `test/`. The
76 remaining references in `test/l10n/app_localizations_plural_test.dart` call the concrete
`AppLocalizationsEn` class; they were renamed at the exact positions the analyzer reported.
Afterwards no old key name is referenced anywhere (route names, table names and help-topic
ids that share a word, such as `'setlists'`, are not key references and were left alone).

The plan named a `tool/rename_arb_keys.dart` script in the repository. It was kept outside
the repository instead, because it is a one-off and would have needed the `analyzer`
package as a new dev dependency.

### Small follow-on edits

- `lib/screens/import_export_screen.dart`, `lib/widgets/stage_hud.dart` — two one-line `if`
  statements got braces: the longer names made `dart format` split them over two lines,
  which the brace lint does not allow.
- `CLAUDE.md` / `AGENTS.md` — new localization rule: every ARB key starts with its category.

### Found for Phase 6

- The key `actionEdit` (was `edit`) is not used anywhere in the code.
- **55 short-category strings are longer than 20 characters in English** (the §8.6 hard
  limit). The Phase 6 length test will fail on them until the English text is shortened or
  the string is re-categorised. Shortening changes UI text, so it needs the user's approval:

  - `tooltipSongListExportSelected`
  - `tooltipSongListShareSelectedAirQr`
  - `titleSongListExportDialog`
  - `titleSongListShareDialog`
  - `titleSongListDeleteMany`
  - `titleSongListAirQr`
  - `labelSetlistSongCount`
  - `tooltipSetlistShareAirQr`
  - `titleSetlistSongCount`
  - `labelSetlistDescription`
  - `actionEditorPasteCarnatic`
  - `labelSongMetaSetlist`
  - `tooltipMelodyKeypadHold`
  - `tooltipMelodyKeypadBar`
  - `tooltipMelodyKeypadShare`
  - `tooltipMelodyKeypadTie`
  - `labelMelodyKeypadBeats`
  - `labelCarnaticSheetAnyaTitle`
  - `actionCarnaticSheetInsertLines`
  - `tooltipMelodyLineNeedsTonic`
  - `labelInfoBars`
  - `actionPerfChordReferenceGuide`
  - `labelPerfFormatAirQr`
  - `tooltipPerfDrone`
  - `tooltipPerfSpeed`
  - `tooltipStageQuietActive`
  - `tooltipStageQuietInactive`
  - `labelGesturesDoubleTapBottom`
  - `labelGesturesPinch`
  - `labelGesturesFullScreen`
  - `actionMetronomeUseSongTempo`
  - `actionMetronomeNoSongTempoToRestore`
  - `tooltipMetronomeStop`
  - `tooltipMetronomeStart`
  - `titleDrone`
  - `labelImportStrategyRenameImported`
  - `labelImportStrategyRenameExisting`
  - `labelImportStrategyUserSuggested`
  - `titleDroneSettingsIndianSongs`
  - `labelDroneSettingsDefaultQuality`
  - `titleDroneSettingsEverything`
  - `labelImportExportPickFiles`
  - `labelImportExportScan`
  - `labelImportExportAllChordPro`
  - `labelImportExportAllAirQr`
  - `titleImportExportAllDialog`
  - `titleImportExportFullSongbook`
  - `actionImportPreviewImportSelected`
  - `tooltipAirQrReceiverGallery`
  - `actionAirQrTransmitterResume`
  - `titleHelpTranspose`
  - `titleHelpPitchPipeDrone`
  - `titleHelpIndianSongs`
  - `titleHelpAirqr`
  - `titleHelpAppearance`

## Checks

- `dart format --output=none --set-exit-if-changed .` — no changes.
- `flutter analyze` — no issues.
- `flutter test` — all 1009 tests passed.
- No build was run: only Dart names changed, and the analyzer and the full test run cover
  them.

## Appendix — full rename table

| Old key | New key |
|---|---|
| `appTitle` | `titleApp` |
| `about` | `titleAbout` |
| `settings` | `titleSettings` |
| `songs` | `titleSongs` |
| `setlists` | `titleSetlists` |
| `search` | `labelSearch` |
| `cancel` | `actionCancel` |
| `save` | `actionSave` |
| `delete` | `actionDelete` |
| `edit` | `actionEdit` |
| `stageUnlockReason` | `labelStageUnlockReason` |
| `stageUnlockDenied` | `bodyStageUnlockDenied` |
| `stageUnlockedWithoutCheck` | `bodyStageUnlockedWithoutCheck` |
| `quietModeOn` | `bodyQuietModeOn` |
| `quietModeOff` | `bodyQuietModeOff` |
| `quietModeNeedsAccess` | `bodyQuietModeNeedsAccess` |
| `quietModeOpenSettings` | `actionQuietModeOpenSettings` |
| `quietModeFailed` | `errorQuietModeFailed` |
| `quietModeUnsupported` | `bodyQuietModeUnsupported` |
| `importFileTooLarge` | `errorImportFileTooLarge` |
| `importFileUnreadable` | `errorImportFileUnreadable` |
| `importNoSongsFound` | `errorImportNoSongsFound` |
| `importFilesSkippedTooLarge` | `errorImportFilesSkippedTooLarge` |
| `importFilesSkippedUnreadable` | `errorImportFilesSkippedUnreadable` |
| `airQrTransferFailed` | `errorAirQrTransferFailed` |
| `airQrReset` | `actionAirQrReset` |
| `create` | `actionCreate` |
| `share` | `actionShare` |
| `tryAgain` | `actionTryAgain` |
| `homePickSongTitle` | `titleHomePickSong` |
| `homePickSongMessage` | `descHomePickSongMessage` |
| `appSubtitle` | `descAppSubtitle` |
| `songListSelectedCount` | `titleSongListSelectedCount` |
| `songListCancelSelection` | `tooltipSongListCancelSelection` |
| `songListExportSelected` | `tooltipSongListExportSelected` |
| `songListShareSelectedAirQr` | `tooltipSongListShareSelectedAirQr` |
| `songListShareSelected` | `tooltipSongListShareSelected` |
| `songListSelectAll` | `tooltipSongListSelectAll` |
| `songListDeselectAll` | `tooltipSongListDeselectAll` |
| `songListDeleteSelected` | `tooltipSongListDeleteSelected` |
| `songListScanAirQr` | `tooltipSongListScanAirQr` |
| `songListNewSong` | `tooltipSongListNewSong` |
| `songListExportDialogTitle` | `titleSongListExportDialog` |
| `songListExported` | `bodySongListExported` |
| `songListExportFailed` | `errorSongListExportFailed` |
| `songListShareDialogTitle` | `titleSongListShareDialog` |
| `songListFormatChordPro` | `labelSongListFormatChordPro` |
| `songListFormatPdf` | `labelSongListFormatPdf` |
| `songListShareFailed` | `errorSongListShareFailed` |
| `songListPdfFailed` | `errorSongListPdfFailed` |
| `songListSharePdfFailed` | `errorSongListSharePdfFailed` |
| `songListDeleteManyTitle` | `titleSongListDeleteMany` |
| `songListDeleteManyMessage` | `descSongListDeleteManyMessage` |
| `songListDeletedMany` | `bodySongListDeletedMany` |
| `songListCopied` | `bodySongListCopied` |
| `songListDeleteOneTitle` | `titleSongListDeleteOne` |
| `songListDeleteOneMessage` | `descSongListDeleteOneMessage` |
| `songListDeletedOne` | `bodySongListDeletedOne` |
| `songListAirQrTitle` | `titleSongListAirQr` |
| `songbookNoMatchesTitle` | `emptySongbookNoMatchesTitle` |
| `songbookNoMatchesMessage` | `emptySongbookNoMatchesMessage` |
| `songbookNoStarredTitle` | `emptySongbookNoStarredTitle` |
| `songbookNoStarredMessage` | `emptySongbookNoStarredMessage` |
| `songbookEmptyTitle` | `emptySongbookEmptyTitle` |
| `songbookEmptyMessage` | `emptySongbookEmptyMessage` |
| `songbookErrorTitle` | `errorSongbookErrorTitle` |
| `songbookErrorMessage` | `errorSongbookErrorMessage` |
| `songCardKeySemantics` | `labelSongCardKeySemantics` |
| `songCardBpm` | `labelSongCardBpm` |
| `songCardBpmSemantics` | `descSongCardBpmSemantics` |
| `songCardAddStar` | `tooltipSongCardAddStar` |
| `songCardRemoveStar` | `tooltipSongCardRemoveStar` |
| `songCardDuplicate` | `tooltipSongCardDuplicate` |
| `songCardDelete` | `tooltipSongCardDelete` |
| `songSearchHint` | `descSongSearchHint` |
| `songSearchClear` | `tooltipSongSearchClear` |
| `songFilterAll` | `labelSongFilterAll` |
| `songFilterStarred` | `labelSongFilterStarred` |
| `setlistLoadError` | `errorSetlistLoad` |
| `setlistEmptyTitle` | `emptySetlistEmptyTitle` |
| `setlistEmptyMessage` | `emptySetlistEmptyMessage` |
| `setlistCreate` | `actionSetlistCreate` |
| `setlistSongCount` | `labelSetlistSongCount` |
| `setlistPerform` | `actionSetlistPerform` |
| `setlistEditSongs` | `actionSetlistEditSongs` |
| `setlistNew` | `actionSetlistNew` |
| `setlistTitle` | `titleSetlist` |
| `setlistLoadOneError` | `errorSetlistLoadOne` |
| `setlistNotFound` | `errorSetlistNotFound` |
| `setlistShareAirQr` | `tooltipSetlistShareAirQr` |
| `setlistEditInfo` | `tooltipSetlistEditInfo` |
| `setlistDelete` | `tooltipSetlistDelete` |
| `setlistPerformAll` | `actionSetlistPerformAll` |
| `setlistSongCountTitle` | `titleSetlistSongCount` |
| `setlistAddSongs` | `actionSetlistAddSongs` |
| `setlistNoSongs` | `emptySetlistNoSongs` |
| `setlistAddSongsNow` | `actionSetlistAddSongsNow` |
| `setlistSongDetails` | `descSetlistSongDetails` |
| `setlistSongDetailsWithArtist` | `descSetlistSongDetailsWithArtist` |
| `setlistRemoveSong` | `tooltipSetlistRemoveSong` |
| `setlistDeleteTitle` | `titleSetlistDelete` |
| `setlistDeleteMessage` | `descSetlistDeleteMessage` |
| `setlistDeleted` | `bodySetlistDeleted` |
| `setlistNothingToShare` | `bodySetlistNothingToShare` |
| `setlistAirQrTitle` | `titleSetlistAirQr` |
| `setlistEdit` | `titleSetlistEdit` |
| `setlistNameLabel` | `labelSetlistName` |
| `setlistNameHint` | `descSetlistNameHint` |
| `setlistNameRequired` | `errorSetlistNameRequired` |
| `setlistDescriptionLabel` | `labelSetlistDescription` |
| `setlistDescriptionHint` | `descSetlistDescriptionHint` |
| `setlistPickerTitle` | `titleSetlistPicker` |
| `setlistPickerDone` | `actionSetlistPickerDone` |
| `setlistPickerSearchHint` | `descSetlistPickerSearchHint` |
| `setlistPickerLoadError` | `errorSetlistPickerLoad` |
| `setlistPickerNoSongs` | `emptySetlistPickerNoSongs` |
| `discard` | `actionDiscard` |
| `keepEditing` | `actionKeepEditing` |
| `insert` | `actionInsert` |
| `add` | `actionAdd` |
| `clear` | `actionClear` |
| `traditionWestern` | `labelTraditionWestern` |
| `traditionCarnatic` | `labelTraditionCarnatic` |
| `traditionHindustani` | `labelTraditionHindustani` |
| `carnaticReadingDuration` | `descCarnaticReadingDuration` |
| `carnaticReadingOctave` | `descCarnaticReadingOctave` |
| `editorNewTitle` | `titleEditorNew` |
| `editorEditTitle` | `titleEditorEdit` |
| `editorUndo` | `tooltipEditorUndo` |
| `editorRedo` | `tooltipEditorRedo` |
| `editorMoreOptions` | `tooltipEditorMoreOptions` |
| `editorMelodyKeypad` | `actionEditorMelodyKeypad` |
| `editorPasteCarnatic` | `actionEditorPasteCarnatic` |
| `editorSaveAsCopy` | `actionEditorSaveAsCopy` |
| `editorLoadError` | `errorEditorLoad` |
| `editorLyricsHint` | `descEditorLyricsHint` |
| `editorNeedsTala` | `errorEditorNeedsTala` |
| `editorDiscardTitle` | `titleEditorDiscard` |
| `editorDiscardMessage` | `descEditorDiscardMessage` |
| `editorUntitled` | `labelEditorUntitled` |
| `editorSummaryKey` | `labelEditorSummaryKey` |
| `editorSummaryBpm` | `labelEditorSummaryBpm` |
| `editorTalaWarning` | `descEditorTalaWarning` |
| `songMetaTitleLabel` | `labelSongMetaTitle` |
| `songMetaTitleHint` | `labelSongMetaTitleHint` |
| `songMetaArtistLabel` | `labelSongMetaArtist` |
| `songMetaArtistHint` | `labelSongMetaArtistHint` |
| `songMetaNotationLabel` | `labelSongMetaNotation` |
| `songMetaNotationHelper` | `descSongMetaNotationHelper` |
| `songMetaRagaLabel` | `labelSongMetaRaga` |
| `songMetaRagaHint` | `labelSongMetaRagaHint` |
| `songMetaKeyLabel` | `labelSongMetaKey` |
| `songMetaKeyHint` | `labelSongMetaKeyHint` |
| `songMetaTempoLabel` | `labelSongMetaTempo` |
| `songMetaTempoHint` | `labelSongMetaTempoHint` |
| `songMetaTalaLabel` | `labelSongMetaTala` |
| `songMetaTalaHint` | `labelSongMetaTalaHint` |
| `songMetaSetlistLabel` | `labelSongMetaSetlist` |
| `songMetaSetlistNone` | `labelSongMetaSetlistNone` |
| `chordInserterInsert` | `tooltipChordInserterInsert` |
| `chordInserterCustom` | `actionChordInserterCustom` |
| `chordInserterCustomTooltip` | `tooltipChordInserterCustom` |
| `chordInserterDialogTitle` | `titleChordInserterDialog` |
| `chordInserterChordLabel` | `labelChordInserterChord` |
| `chordInserterChordHint` | `labelChordInserterChordHint` |
| `renameImportTitle` | `titleRenameImport` |
| `renameImportExists` | `descRenameImportExists` |
| `renameImportPrompt` | `descRenameImportPrompt` |
| `renameImportLabel` | `labelRenameImport` |
| `renameImportRequired` | `errorRenameImportRequired` |
| `renameImportSave` | `actionRenameImportSave` |
| `melodyKeypadDiscardTitle` | `titleMelodyKeypadDiscard` |
| `melodyKeypadDiscardMessage` | `descMelodyKeypadDiscardMessage` |
| `melodyKeypadHold` | `labelMelodyKeypadHold` |
| `melodyKeypadHoldTooltip` | `tooltipMelodyKeypadHold` |
| `melodyKeypadBar` | `labelMelodyKeypadBar` |
| `melodyKeypadBarTooltip` | `tooltipMelodyKeypadBar` |
| `melodyKeypadShare` | `labelMelodyKeypadShare` |
| `melodyKeypadShareTooltip` | `tooltipMelodyKeypadShare` |
| `melodyKeypadTie` | `labelMelodyKeypadTie` |
| `melodyKeypadTieTooltip` | `tooltipMelodyKeypadTie` |
| `melodyKeypadSilence` | `labelMelodyKeypadSilence` |
| `melodyKeypadSilenceTooltip` | `tooltipMelodyKeypadSilence` |
| `melodyKeypadOctaveUp` | `labelMelodyKeypadOctaveUp` |
| `melodyKeypadOctaveDown` | `labelMelodyKeypadOctaveDown` |
| `melodyKeypadSlide` | `labelMelodyKeypadSlide` |
| `melodyKeypadShake` | `labelMelodyKeypadShake` |
| `melodyKeypadBackspace` | `tooltipMelodyKeypadBackspace` |
| `melodyKeypadBeats` | `labelMelodyKeypadBeats` |
| `melodyKeypadFits` | `descMelodyKeypadFits` |
| `melodyKeypadOfBeats` | `labelMelodyKeypadOfBeats` |
| `melodyKeypadStartHint` | `descMelodyKeypadStartHint` |
| `carnaticSheetHelp` | `descCarnaticSheetHelp` |
| `carnaticSheetAnyaTitle` | `labelCarnaticSheetAnyaTitle` |
| `carnaticSheetAnyaSubtitle` | `descCarnaticSheetAnyaSubtitle` |
| `carnaticSheetInsertLines` | `actionCarnaticSheetInsertLines` |
| `carnaticSheetFit` | `descCarnaticSheetFit` |
| `carnaticSheetOtherReading` | `descCarnaticSheetOtherReading` |
| `carnaticSheetAnyaHint` | `descCarnaticSheetAnyaHint` |
| `melodyLineLoop` | `labelMelodyLineLoop` |
| `melodyLineHalfSpeed` | `labelMelodyLineHalfSpeed` |
| `melodyLinePlayFailed` | `errorMelodyLinePlayFailed` |
| `melodyLineStop` | `tooltipMelodyLineStop` |
| `melodyLinePlay` | `tooltipMelodyLinePlay` |
| `melodyLineNeedsTonic` | `tooltipMelodyLineNeedsTonic` |
| `close` | `actionClose` |
| `export` | `actionExport` |
| `play` | `tooltipPlay` |
| `pause` | `tooltipPause` |
| `reset` | `actionReset` |
| `infoRaga` | `labelInfoRaga` |
| `infoTala` | `labelInfoTala` |
| `infoKey` | `labelInfoKey` |
| `infoKeyTransposed` | `labelInfoKeyTransposed` |
| `infoBpm` | `labelInfoBpm` |
| `infoBars` | `labelInfoBars` |
| `infoAutoScroll` | `labelInfoAutoScroll` |
| `perfSong` | `titlePerfSong` |
| `perfPreviousSong` | `tooltipPerfPreviousSong` |
| `perfNextSong` | `tooltipPerfNextSong` |
| `perfSetlistSongs` | `tooltipPerfSetlistSongs` |
| `perfEditSong` | `tooltipPerfEditSong` |
| `perfSetlistPosition` | `titlePerfSetlistPosition` |
| `perfNotFoundTitle` | `errorPerfNotFoundTitle` |
| `perfNotFoundMessage` | `descPerfNotFoundMessage` |
| `perfControls` | `actionPerfControls` |
| `perfGesturesHelp` | `tooltipPerfGesturesHelp` |
| `perfSwaraReference` | `actionPerfSwaraReference` |
| `perfChordReferenceGuide` | `actionPerfChordReferenceGuide` |
| `perfExportDialogTitle` | `titlePerfExportDialog` |
| `perfShareDialogTitle` | `titlePerfShareDialog` |
| `perfFormatAirQr` | `labelPerfFormatAirQr` |
| `perfShareChordProFailed` | `errorPerfShareChordProFailed` |
| `perfPdfNoPages` | `errorPerfPdfNoPages` |
| `perfPdfTimeout` | `errorPerfPdfTimeout` |
| `perfSharePdfFailed` | `errorPerfSharePdfFailed` |
| `perfExportPdfTitle` | `titlePerfExportPdf` |
| `perfExportChordProTitle` | `titlePerfExportChordPro` |
| `perfExported` | `bodyPerfExported` |
| `perfExportPdfFailed` | `errorPerfExportPdfFailed` |
| `perfExportChordProFailed` | `errorPerfExportChordProFailed` |
| `perfDroneTooltip` | `tooltipPerfDrone` |
| `perfSpeedTooltip` | `tooltipPerfSpeed` |
| `perfHideChords` | `tooltipPerfHideChords` |
| `perfShowChords` | `tooltipPerfShowChords` |
| `perfHideMelody` | `tooltipPerfHideMelody` |
| `perfShowMelody` | `tooltipPerfShowMelody` |
| `autoScrollFullScreen` | `tooltipAutoScrollFullScreen` |
| `autoScrollManual` | `labelAutoScrollManual` |
| `autoScrollTempo` | `labelAutoScrollTempo` |
| `autoScrollManualShort` | `actionAutoScrollManualShort` |
| `autoScrollTempoShort` | `actionAutoScrollTempoShort` |
| `transposeLabel` | `labelTranspose` |
| `transposeDown` | `tooltipTransposeDown` |
| `transposeUp` | `tooltipTransposeUp` |
| `transposeMelodySubtitle` | `descTransposeMelodySubtitle` |
| `transposePinchTip` | `descTransposePinchTip` |
| `chordRefTitle` | `titleChordRef` |
| `chordRefNoSwaras` | `emptyChordRefNoSwaras` |
| `chordRefNoChords` | `emptyChordRefNoChords` |
| `chordRefGuitar` | `tabChordRefGuitar` |
| `chordRefHarmonium` | `tabChordRefHarmonium` |
| `stageExitFullScreen` | `tooltipStageExitFullScreen` |
| `stageLock` | `tooltipStageLock` |
| `stageQuietActive` | `tooltipStageQuietActive` |
| `stageQuietInactive` | `tooltipStageQuietInactive` |
| `stageFewerBars` | `tooltipStageFewerBars` |
| `stageMoreBars` | `tooltipStageMoreBars` |
| `stageSlower` | `tooltipStageSlower` |
| `stageFaster` | `tooltipStageFaster` |
| `stageLocked` | `labelStageLocked` |
| `stagePlaying` | `labelStagePlaying` |
| `stagePaused` | `labelStagePaused` |
| `stageHelpSubtitle` | `descStageHelpSubtitle` |
| `stageHelpTapOnce` | `labelStageHelpTapOnce` |
| `stageHelpTapOnceMeaning` | `descStageHelpTapOnceMeaning` |
| `stageHelpDoubleTapTop` | `labelStageHelpDoubleTapTop` |
| `stageHelpDoubleTapBottom` | `labelStageHelpDoubleTapBottom` |
| `stageHelpTwoFingers` | `labelStageHelpTwoFingers` |
| `stageHelpTwoFingersMeaning` | `descStageHelpTwoFingersMeaning` |
| `stageHelpPinch` | `labelStageHelpPinch` |
| `stageHelpPinchMeaning` | `descStageHelpPinchMeaning` |
| `stageHelpBack` | `labelStageHelpBack` |
| `stageHelpBackMeaning` | `descStageHelpBackMeaning` |
| `stageHelpStart` | `descStageHelpStart` |
| `gesturesTitle` | `titleGestures` |
| `gesturesSubtitle` | `descGesturesSubtitle` |
| `gesturesDoubleTapTop` | `labelGesturesDoubleTapTop` |
| `gesturesDoubleTapTopMeaning` | `descGesturesDoubleTapTopMeaning` |
| `gesturesDoubleTapBottom` | `labelGesturesDoubleTapBottom` |
| `gesturesDoubleTapBottomMeaning` | `descGesturesDoubleTapBottomMeaning` |
| `gesturesTwoFingersMeaning` | `descGesturesTwoFingersMeaning` |
| `gesturesDrag` | `labelGesturesDrag` |
| `gesturesDragMeaning` | `descGesturesDragMeaning` |
| `gesturesPinch` | `labelGesturesPinch` |
| `gesturesPinchMeaning` | `descGesturesPinchMeaning` |
| `gesturesFullScreen` | `labelGesturesFullScreen` |
| `gesturesFullScreenMeaning` | `descGesturesFullScreenMeaning` |
| `gesturesHelpCenter` | `actionGesturesHelpCenter` |
| `gesturesGotIt` | `actionGesturesGotIt` |
| `metronomeTapAlong` | `descMetronomeTapAlong` |
| `metronomeKeepTapping` | `descMetronomeKeepTapping` |
| `metronomeTapsNeeded` | `descMetronomeTapsNeeded` |
| `metronomeSteady` | `descMetronomeSteady` |
| `metronomeTempoTitle` | `titleMetronomeTempo` |
| `metronomeSetByYou` | `descMetronomeSetByYou` |
| `metronomeUsingSongTempo` | `descMetronomeUsingSongTempo` |
| `metronomeNoSongTempo` | `descMetronomeNoSongTempo` |
| `metronomeSlowerByOne` | `tooltipMetronomeSlowerByOne` |
| `metronomeFasterByOne` | `tooltipMetronomeFasterByOne` |
| `metronomeBpmUnit` | `labelMetronomeBpmUnit` |
| `metronomeTapTempo` | `actionMetronomeTapTempo` |
| `metronomeUseSongTempo` | `actionMetronomeUseSongTempo` |
| `metronomeNoSongTempoToRestore` | `actionMetronomeNoSongTempoToRestore` |
| `metronomeStop` | `tooltipMetronomeStop` |
| `metronomeStart` | `tooltipMetronomeStart` |
| `droneCouldNotPlay` | `errorDroneCouldNotPlay` |
| `droneTitle` | `titleDrone` |
| `droneModeClassical` | `labelDroneModeClassical` |
| `droneModeWestern` | `labelDroneModeWestern` |
| `droneSaPa` | `labelDroneSaPa` |
| `droneSaMa` | `labelDroneSaMa` |
| `droneMajor` | `labelDroneMajor` |
| `droneMinor` | `labelDroneMinor` |
| `droneChordCue` | `actionDroneChordCue` |
| `dronePitchCue` | `actionDronePitchCue` |
| `droneStop` | `actionDroneStop` |
| `droneChord` | `actionDroneChord` |
| `droneShruti` | `actionDroneShruti` |
| `droneTextScale` | `labelDroneTextScale` |
| `droneYourSa` | `labelDroneYourSa` |
| `droneSongKey` | `labelDroneSongKey` |
| `droneRootKey` | `labelDroneRootKey` |
| `sheetNoLyrics` | `emptySheetNoLyrics` |
| `diagramNoGuitar` | `descDiagramNoGuitar` |
| `diagramGuitar` | `descDiagramGuitar` |
| `diagramNone` | `labelDiagramNone` |
| `diagramHarmonium` | `descDiagramHarmonium` |
| `diagramSwara` | `descDiagramSwara` |
| `melodyGridHold` | `labelMelodyGridHold` |
| `melodyGridBarLine` | `labelMelodyGridBarLine` |
| `melodyGridUnreadable` | `descMelodyGridUnreadable` |
| `settingsGeneral` | `titleSettingsGeneral` |
| `settingsGeneralSubtitle` | `descSettingsGeneralSubtitle` |
| `settingsThemes` | `titleSettingsThemes` |
| `settingsThemesSubtitle` | `descSettingsThemesSubtitle` |
| `settingsChords` | `titleSettingsChords` |
| `settingsChordsSubtitle` | `descSettingsChordsSubtitle` |
| `settingsFonts` | `titleSettingsFonts` |
| `settingsFontsSubtitle` | `descSettingsFontsSubtitle` |
| `settingsHelp` | `titleSettingsHelp` |
| `settingsHelpSubtitle` | `descSettingsHelpSubtitle` |
| `settingsAboutSubtitle` | `descSettingsAboutSubtitle` |
| `generalImport` | `titleGeneralImport` |
| `generalImportSubtitle` | `descGeneralImportSubtitle` |
| `generalImportSettings` | `titleGeneralImportSettings` |
| `generalImportSettingsSubtitle` | `descGeneralImportSettingsSubtitle` |
| `generalAutoScrollSubtitle` | `descGeneralAutoScrollSubtitle` |
| `generalMetronome` | `titleGeneralMetronome` |
| `generalMetronomeSubtitle` | `descGeneralMetronomeSubtitle` |
| `generalDroneSubtitle` | `descGeneralDroneSubtitle` |
| `themeSystem` | `labelThemeSystem` |
| `themeLight` | `labelThemeLight` |
| `themeDark` | `labelThemeDark` |
| `fontSettingsNote` | `descFontSettingsNote` |
| `fontSystemDefault` | `labelFontSystemDefault` |
| `scrollStartingSpeed` | `titleScrollStartingSpeed` |
| `scrollStartingSpeedNote` | `descScrollStartingSpeedNote` |
| `scrollResetTo` | `actionScrollResetTo` |
| `chordSettingsAddFailed` | `errorChordSettingsAddFailed` |
| `chordSettingsRemoved` | `bodyChordSettingsRemoved` |
| `chordSettingsIntro` | `descChordSettingsIntro` |
| `chordSettingsLabel` | `labelChordSettings` |
| `chordSettingsEmpty` | `emptyChordSettings` |
| `chordSettingsRemove` | `tooltipChordSettingsRemove` |
| `importSettingsQuestion` | `descImportSettingsQuestion` |
| `importStrategyOverwrite` | `labelImportStrategyOverwrite` |
| `importStrategyOverwriteDescription` | `descImportStrategyOverwrite` |
| `importStrategyRenameImported` | `labelImportStrategyRenameImported` |
| `importStrategyRenameImportedDescription` | `descImportStrategyRenameImported` |
| `importStrategyRenameExisting` | `labelImportStrategyRenameExisting` |
| `importStrategyRenameExistingDescription` | `descImportStrategyRenameExisting` |
| `importStrategyUserSuggested` | `labelImportStrategyUserSuggested` |
| `importStrategyUserSuggestedDescription` | `descImportStrategyUserSuggested` |
| `metronomeEnable` | `labelMetronomeEnable` |
| `metronomeEnableSubtitle` | `descMetronomeEnableSubtitle` |
| `metronomeFlash` | `labelMetronomeFlash` |
| `metronomeFlashSubtitle` | `descMetronomeFlashSubtitle` |
| `metronomeClick` | `labelMetronomeClick` |
| `metronomeClickSubtitle` | `descMetronomeClickSubtitle` |
| `metronomeClickVolume` | `labelMetronomeClickVolume` |
| `metronomeBarHeading` | `titleMetronomeBarHeading` |
| `metronomeBeatsInBar` | `labelMetronomeBeatsInBar` |
| `metronomeBeatsInBarSubtitle` | `descMetronomeBeatsInBarSubtitle` |
| `metronomeAccent` | `labelMetronomeAccent` |
| `metronomeAccentSubtitle` | `descMetronomeAccentSubtitle` |
| `metronomeTest` | `labelMetronomeTest` |
| `metronomeTestSubtitle` | `descMetronomeTestSubtitle` |
| `droneSettingsTestWesternMajor` | `descDroneSettingsTestWesternMajor` |
| `droneSettingsTestWesternMinor` | `descDroneSettingsTestWesternMinor` |
| `droneSettingsTestClassical` | `descDroneSettingsTestClassical` |
| `droneSettingsNaming` | `titleDroneSettingsNaming` |
| `droneSettingsNamingCaption` | `descDroneSettingsNamingCaption` |
| `droneSettingsUsesIndian` | `descDroneSettingsUsesIndian` |
| `droneSettingsUsesWestern` | `descDroneSettingsUsesWestern` |
| `droneSettingsIndianSongs` | `titleDroneSettingsIndianSongs` |
| `droneSettingsIndianCaption` | `descDroneSettingsIndianCaption` |
| `droneSettingsYourSa` | `labelDroneSettingsYourSa` |
| `droneSettingsSaSits` | `descDroneSettingsSaSits` |
| `droneSettingsInterval` | `labelDroneSettingsInterval` |
| `droneSettingsIntervalPa` | `descDroneSettingsIntervalPa` |
| `droneSettingsIntervalMa` | `descDroneSettingsIntervalMa` |
| `droneSettingsWesternSongs` | `titleDroneSettingsWesternSongs` |
| `droneSettingsWesternCaption` | `descDroneSettingsWesternCaption` |
| `droneSettingsDefaultKey` | `labelDroneSettingsDefaultKey` |
| `droneSettingsDefaultKeySubtitle` | `descDroneSettingsDefaultKeySubtitle` |
| `droneSettingsDefaultMode` | `labelDroneSettingsDefaultMode` |
| `droneSettingsModeClassicalNote` | `descDroneSettingsModeClassicalNote` |
| `droneSettingsModeWesternNote` | `descDroneSettingsModeWesternNote` |
| `droneSettingsClassical` | `labelDroneSettingsClassical` |
| `droneSettingsDefaultQuality` | `labelDroneSettingsDefaultQuality` |
| `droneSettingsMajorNote` | `descDroneSettingsMajorNote` |
| `droneSettingsMinorNote` | `descDroneSettingsMinorNote` |
| `droneSettingsQualityOnlyWestern` | `descDroneSettingsQualityOnlyWestern` |
| `chordQualityMajor` | `labelChordQualityMajor` |
| `chordQualityMinor` | `labelChordQualityMinor` |
| `droneSettingsEverything` | `titleDroneSettingsEverything` |
| `droneSettingsEverythingCaption` | `descDroneSettingsEverythingCaption` |
| `droneSettingsVolume` | `labelDroneSettingsVolume` |
| `droneSettingsFontScale` | `labelDroneSettingsFontScale` |
| `droneSettingsFontScaleSubtitle` | `descDroneSettingsFontScaleSubtitle` |
| `droneSettingsTryIt` | `titleDroneSettingsTryIt` |
| `droneSettingsTryItCaption` | `descDroneSettingsTryItCaption` |
| `droneSettingsTestChordCue` | `actionDroneSettingsTestChordCue` |
| `droneSettingsTestPitchCue` | `actionDroneSettingsTestPitchCue` |
| `droneSettingsTestChordDrone` | `actionDroneSettingsTestChordDrone` |
| `droneSettingsTestDrone` | `actionDroneSettingsTestDrone` |
| `droneSettingsChordDroneNote` | `descDroneSettingsChordDroneNote` |
| `droneSettingsDroneNote` | `descDroneSettingsDroneNote` |
| `aboutVersion` | `labelAboutVersion` |
| `aboutVersionBuild` | `labelAboutVersionBuild` |
| `aboutBuildDate` | `labelAboutBuildDate` |
| `aboutLicenses` | `labelAboutLicenses` |
| `importExportTitle` | `titleImportExport` |
| `importExportPickFiles` | `labelImportExportPickFiles` |
| `importExportPickFilesSubtitle` | `descImportExportPickFilesSubtitle` |
| `importExportScan` | `labelImportExportScan` |
| `importExportScanSubtitle` | `descImportExportScanSubtitle` |
| `importExportAllChordPro` | `labelImportExportAllChordPro` |
| `importExportAllChordProSubtitle` | `descImportExportAllChordProSubtitle` |
| `importExportAllAirQr` | `labelImportExportAllAirQr` |
| `importExportAllAirQrSubtitle` | `descImportExportAllAirQrSubtitle` |
| `importExportWrongType` | `errorImportExportWrongType` |
| `importExportNothingRead` | `errorImportExportNothingRead` |
| `importExportFilesSelected` | `descImportExportFilesSelected` |
| `importExportImportFailed` | `errorImportExportImportFailed` |
| `importExportNoSongsToExport` | `bodyImportExportNoSongsToExport` |
| `importExportAllDialogTitle` | `titleImportExportAllDialog` |
| `importExportExported` | `bodyImportExportExported` |
| `importExportExportFailed` | `errorImportExportExportFailed` |
| `importExportNoSongsToShare` | `bodyImportExportNoSongsToShare` |
| `importExportFullSongbook` | `titleImportExportFullSongbook` |
| `importExportAirQrFailed` | `errorImportExportAirQrFailed` |
| `importPreviewTitle` | `titleImportPreview` |
| `importPreviewSelectAll` | `actionImportPreviewSelectAll` |
| `importPreviewDeselectAll` | `actionImportPreviewDeselectAll` |
| `importPreviewFound` | `descImportPreviewFound` |
| `importPreviewNoSongs` | `emptyImportPreviewNoSongs` |
| `importPreviewInSongbook` | `labelImportPreviewInSongbook` |
| `importPreviewAlreadyInSongbook` | `labelImportPreviewAlreadyInSongbook` |
| `importPreviewKey` | `labelImportPreviewKey` |
| `importPreviewPreview` | `actionImportPreviewPreview` |
| `importPreviewImporting` | `actionImportPreviewImporting` |
| `importPreviewImportSelected` | `actionImportPreviewImportSelected` |
| `importPreviewImportedOne` | `bodyImportPreviewImportedOne` |
| `importPreviewImportedMany` | `bodyImportPreviewImportedMany` |
| `importPreviewFailed` | `errorImportPreviewFailed` |
| `airQrReceiverTitle` | `titleAirQrReceiver` |
| `airQrReceiverGallery` | `tooltipAirQrReceiverGallery` |
| `airQrReceiverResetStream` | `tooltipAirQrReceiverResetStream` |
| `airQrReceiverNoCode` | `errorAirQrReceiverNoCode` |
| `airQrReceiverPhotoFailed` | `errorAirQrReceiverPhotoFailed` |
| `airQrReceiverStarting` | `descAirQrReceiverStarting` |
| `airQrReceiverFileName` | `labelAirQrReceiverFileName` |
| `airQrHudReassembled` | `descAirQrHudReassembled` |
| `airQrHudReceiving` | `descAirQrHudReceiving` |
| `airQrHudPointAt` | `descAirQrHudPointAt` |
| `airQrHudCaptured` | `descAirQrHudCaptured` |
| `airQrHudMissing` | `labelAirQrHudMissing` |
| `airQrTransmitterTitle` | `titleAirQrTransmitter` |
| `airQrTransmitterSize` | `descAirQrTransmitterSize` |
| `airQrTransmitterSpeed` | `labelAirQrTransmitterSpeed` |
| `airQrTransmitterPause` | `actionAirQrTransmitterPause` |
| `airQrTransmitterResume` | `actionAirQrTransmitterResume` |
| `airQrTransmitterNoFrames` | `emptyAirQrTransmitterNoFrames` |
| `airQrTransmitterParityFrame` | `descAirQrTransmitterParityFrame` |
| `airQrTransmitterBlockFrame` | `descAirQrTransmitterBlockFrame` |
| `airQrTransmitterHint` | `descAirQrTransmitterHint` |
| `helpSongbookTitle` | `titleHelpSongbook` |
| `helpEditorTitle` | `titleHelpEditor` |
| `helpSetlistsTitle` | `titleHelpSetlists` |
| `helpTransposeTitle` | `titleHelpTranspose` |
| `helpAutoScrollTitle` | `titleHelpAutoScroll` |
| `helpFullScreenTitle` | `titleHelpFullScreen` |
| `helpMetronomeTitle` | `titleHelpMetronome` |
| `helpPitchPipeDroneTitle` | `titleHelpPitchPipeDrone` |
| `helpMelodyTitle` | `titleHelpMelody` |
| `helpIndianSongsTitle` | `titleHelpIndianSongs` |
| `helpSelectSongsTitle` | `titleHelpSelectSongs` |
| `helpImportTitle` | `titleHelpImport` |
| `helpExportTitle` | `titleHelpExport` |
| `helpAirqrTitle` | `titleHelpAirqr` |
| `helpAppearanceTitle` | `titleHelpAppearance` |
| `airQrFps` | `labelAirQrFps` |
| `storageLoadSongs` | `errorStorageLoadSongs` |
| `storageOpenSong` | `errorStorageOpenSong` |
| `storageFindSongByTitle` | `errorStorageFindSongByTitle` |
| `storageSaveSong` | `errorStorageSaveSong` |
| `storageUpdateSong` | `errorStorageUpdateSong` |
| `storageSaveScrollSpeed` | `errorStorageSaveScrollSpeed` |
| `storageDeleteSong` | `errorStorageDeleteSong` |
| `storageCreateSetlist` | `errorStorageCreateSetlist` |
| `storageUpdateSetlist` | `errorStorageUpdateSetlist` |
| `storageUpdateSetlistSongs` | `errorStorageUpdateSetlistSongs` |
| `storageAddSongToSetlist` | `errorStorageAddSongToSetlist` |
| `storageDeleteSetlist` | `errorStorageDeleteSetlist` |
| `droneErrorChordCue` | `errorDroneErrorChordCue` |
| `droneErrorPitchCue` | `errorDroneErrorPitchCue` |
| `droneErrorStartDrone` | `errorDroneErrorStartDrone` |
| `melodyProblemUnreadable` | `errorMelodyProblemUnreadable` |
| `melodyProblemNothingToPlay` | `errorMelodyProblemNothingToPlay` |
| `carnaticProblemUnknownTala` | `errorCarnaticProblemUnknownTala` |
| `carnaticProblemNoNotation` | `errorCarnaticProblemNoNotation` |
| `carnaticProblemCyclesOff` | `errorCarnaticProblemCyclesOff` |
| `carnaticProblemReadingsTie` | `errorCarnaticProblemReadingsTie` |
| `carnaticProblemNothingReadable` | `errorCarnaticProblemNothingReadable` |
| `carnaticProblemWrongLength` | `errorCarnaticProblemWrongLength` |
| `carnaticProblemUnreadableCharacter` | `errorCarnaticProblemUnreadableCharacter` |
| `carnaticProblemInCycle` | `errorCarnaticProblemInCycle` |
