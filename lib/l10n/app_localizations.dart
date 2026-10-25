import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ml.dart';
import 'app_localizations_sa.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ml'),
    Locale('sa'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'LyricChord'**
  String get titleApp;

  /// Title of the About screen
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get titleAbout;

  /// Title of the Settings screen
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get titleSettings;

  /// Title of the songs list view
  ///
  /// In en, this message translates to:
  /// **'Songs'**
  String get titleSongs;

  /// Title of the setlists view
  ///
  /// In en, this message translates to:
  /// **'Setlists'**
  String get titleSetlists;

  /// Placeholder hint for search fields
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get labelSearch;

  /// Label for cancel actions
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// Label for save actions
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get actionSave;

  /// Label for delete actions
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get actionDelete;

  /// Label for edit actions
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get actionEdit;

  /// Reason shown in the system fingerprint / PIN prompt when unlocking Stage Lock
  ///
  /// In en, this message translates to:
  /// **'Unlock Stage Mode'**
  String get labelStageUnlockReason;

  /// SnackBar when the user cancels or fails the Stage Lock unlock prompt
  ///
  /// In en, this message translates to:
  /// **'Stage is still locked. Unlock to continue.'**
  String get bodyStageUnlockDenied;

  /// SnackBar when Stage Lock was opened without a fingerprint/PIN check because the check could not run
  ///
  /// In en, this message translates to:
  /// **'Stage unlocked. Screen lock check was not available.'**
  String get bodyStageUnlockedWithoutCheck;

  /// SnackBar after Stage Quiet Mode silenced the ringer
  ///
  /// In en, this message translates to:
  /// **'Quiet Mode on: calls and notifications are silenced.'**
  String get bodyQuietModeOn;

  /// SnackBar after Stage Quiet Mode put the ringer back
  ///
  /// In en, this message translates to:
  /// **'Quiet Mode off: ringer restored.'**
  String get bodyQuietModeOff;

  /// SnackBar when Android needs Do Not Disturb access before Quiet Mode can work
  ///
  /// In en, this message translates to:
  /// **'To silence calls, allow Do Not Disturb access for LyricChord.'**
  String get bodyQuietModeNeedsAccess;

  /// SnackBar action that opens the Do Not Disturb access system page
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get actionQuietModeOpenSettings;

  /// SnackBar when Quiet Mode could not change the ringer
  ///
  /// In en, this message translates to:
  /// **'Could not silence the phone.'**
  String get errorQuietModeFailed;

  /// SnackBar when the platform cannot change the ringer
  ///
  /// In en, this message translates to:
  /// **'Quiet Mode is not available on this device.'**
  String get bodyQuietModeUnsupported;

  /// SnackBar when an imported file is over the size limit
  ///
  /// In en, this message translates to:
  /// **'{fileName} is too large to import (limit {limitMb} MB).'**
  String errorImportFileTooLarge(String fileName, int limitMb);

  /// SnackBar when an opened file could not be read
  ///
  /// In en, this message translates to:
  /// **'Could not read {fileName}.'**
  String errorImportFileUnreadable(String fileName);

  /// SnackBar when an opened file has no song content
  ///
  /// In en, this message translates to:
  /// **'No songs found in {fileName}.'**
  String errorImportNoSongsFound(String fileName);

  /// SnackBar listing chosen files that were too large to import
  ///
  /// In en, this message translates to:
  /// **'Skipped files over {limitMb} MB: {fileNames}'**
  String errorImportFilesSkippedTooLarge(int limitMb, String fileNames);

  /// SnackBar listing chosen files that could not be read during import
  ///
  /// In en, this message translates to:
  /// **'Could not read: {fileNames}'**
  String errorImportFilesSkippedUnreadable(String fileNames);

  /// AirQR receiver message when all codes arrived but the song could not be rebuilt
  ///
  /// In en, this message translates to:
  /// **'Transfer failed. Tap Reset and scan again.'**
  String get errorAirQrTransferFailed;

  /// SnackBar action that clears a failed AirQR transfer so scanning can start again
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get actionAirQrReset;

  /// Button that creates a new item
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get actionCreate;

  /// Button that shares the chosen items
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get actionShare;

  /// Button that retries a failed load
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get actionTryAgain;

  /// Tablet right pane title when no song is open
  ///
  /// In en, this message translates to:
  /// **'Pick a song'**
  String get titleHomePickSong;

  /// Tablet right pane hint when no song is open
  ///
  /// In en, this message translates to:
  /// **'Choose a song on the left to open it here.'**
  String get descHomePickSongMessage;

  /// Subtitle under the app name on the song list
  ///
  /// In en, this message translates to:
  /// **'Lyrics & Chords Notebook'**
  String get descAppSubtitle;

  /// App bar title while songs are selected
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String titleSongListSelectedCount(int count);

  /// Tooltip: leave multi-select mode
  ///
  /// In en, this message translates to:
  /// **'Cancel selection'**
  String get tooltipSongListCancelSelection;

  /// Tooltip: export selected songs to a ChordPro file
  ///
  /// In en, this message translates to:
  /// **'Export selected'**
  String get tooltipSongListExportSelected;

  /// Tooltip: send selected songs as an AirQR stream
  ///
  /// In en, this message translates to:
  /// **'Send via AirQR'**
  String get tooltipSongListShareSelectedAirQr;

  /// Tooltip: share selected songs as a file
  ///
  /// In en, this message translates to:
  /// **'Share selected'**
  String get tooltipSongListShareSelected;

  /// Tooltip: select every song in the list
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get tooltipSongListSelectAll;

  /// Tooltip: clear the selection
  ///
  /// In en, this message translates to:
  /// **'Deselect all'**
  String get tooltipSongListDeselectAll;

  /// Tooltip: delete the selected songs
  ///
  /// In en, this message translates to:
  /// **'Delete selected'**
  String get tooltipSongListDeleteSelected;

  /// Tooltip: open the AirQR receiver
  ///
  /// In en, this message translates to:
  /// **'Scan AirQR Song'**
  String get tooltipSongListScanAirQr;

  /// Tooltip on the add-song button
  ///
  /// In en, this message translates to:
  /// **'New song'**
  String get tooltipSongListNewSong;

  /// Title of the system save dialog for exporting selected songs
  ///
  /// In en, this message translates to:
  /// **'Export selected'**
  String get titleSongListExportDialog;

  /// SnackBar after selected songs were exported
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Exported 1 song.} other{Exported {count} songs.}}'**
  String bodySongListExported(int count);

  /// SnackBar when exporting selected songs failed
  ///
  /// In en, this message translates to:
  /// **'Could not export selected songs.'**
  String get errorSongListExportFailed;

  /// Title of the dialog that asks which format to share in
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Share 1 song} other{Share {count} songs}}'**
  String titleSongListShareDialog(int count);

  /// Share format option: ChordPro file
  ///
  /// In en, this message translates to:
  /// **'ChordPro (.chordpro)'**
  String get labelSongListFormatChordPro;

  /// Share format option: PDF file
  ///
  /// In en, this message translates to:
  /// **'PDF (.pdf)'**
  String get labelSongListFormatPdf;

  /// SnackBar when sharing selected songs as ChordPro failed
  ///
  /// In en, this message translates to:
  /// **'Could not share selected songs.'**
  String get errorSongListShareFailed;

  /// SnackBar when the PDF came out empty
  ///
  /// In en, this message translates to:
  /// **'Could not generate PDF.'**
  String get errorSongListPdfFailed;

  /// SnackBar when sharing selected songs as PDF failed
  ///
  /// In en, this message translates to:
  /// **'Could not share selected songs as PDF.'**
  String get errorSongListSharePdfFailed;

  /// Title of the dialog confirming deletion of selected songs
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Delete 1 song?} other{Delete {count} songs?}}'**
  String titleSongListDeleteMany(int count);

  /// Body of the dialog confirming deletion of selected songs
  ///
  /// In en, this message translates to:
  /// **'Selected songs will be removed from your songbook.'**
  String get descSongListDeleteManyMessage;

  /// SnackBar after selected songs were deleted
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Deleted 1 song.} other{Deleted {count} songs.}}'**
  String bodySongListDeletedMany(int count);

  /// SnackBar after a song was duplicated
  ///
  /// In en, this message translates to:
  /// **'Copied \"{title}\".'**
  String bodySongListCopied(String title);

  /// Title of the dialog confirming deletion of one song
  ///
  /// In en, this message translates to:
  /// **'Delete song?'**
  String get titleSongListDeleteOne;

  /// Body of the dialog confirming deletion of one song
  ///
  /// In en, this message translates to:
  /// **'\"{title}\" will be removed from your songbook.'**
  String descSongListDeleteOneMessage(String title);

  /// SnackBar after one song was deleted
  ///
  /// In en, this message translates to:
  /// **'Deleted \"{title}\".'**
  String bodySongListDeletedOne(String title);

  /// Title shown on the AirQR transmitter for selected songs
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 Selected Song} other{{count} Selected Songs}}'**
  String titleSongListAirQr(int count);

  /// Empty list title when the search matched nothing
  ///
  /// In en, this message translates to:
  /// **'No matches'**
  String get emptySongbookNoMatchesTitle;

  /// Empty list message when the search matched nothing
  ///
  /// In en, this message translates to:
  /// **'No song matched your search. Try different words.'**
  String get emptySongbookNoMatchesMessage;

  /// Empty list title when the Starred filter has nothing
  ///
  /// In en, this message translates to:
  /// **'No starred songs'**
  String get emptySongbookNoStarredTitle;

  /// Empty list message when the Starred filter has nothing
  ///
  /// In en, this message translates to:
  /// **'Tap the star on a song to keep it here.'**
  String get emptySongbookNoStarredMessage;

  /// Empty list title when there are no songs
  ///
  /// In en, this message translates to:
  /// **'Your songbook is empty'**
  String get emptySongbookEmptyTitle;

  /// Empty list message when there are no songs
  ///
  /// In en, this message translates to:
  /// **'Tap + to write your first lyric chord sheet.'**
  String get emptySongbookEmptyMessage;

  /// Title when the song list failed to load
  ///
  /// In en, this message translates to:
  /// **'Could not open your songbook'**
  String get errorSongbookErrorTitle;

  /// Message when the song list failed to load
  ///
  /// In en, this message translates to:
  /// **'Your songs are still saved. The app could not read them just now.'**
  String get errorSongbookErrorMessage;

  /// Screen-reader label for the song key badge
  ///
  /// In en, this message translates to:
  /// **'Key {key}'**
  String labelSongCardKeySemantics(String key);

  /// Tempo badge on a song card
  ///
  /// In en, this message translates to:
  /// **'{bpm} BPM'**
  String labelSongCardBpm(int bpm);

  /// Screen-reader label for the tempo badge
  ///
  /// In en, this message translates to:
  /// **'{bpm} beats per minute'**
  String descSongCardBpmSemantics(int bpm);

  /// Tooltip: star a song
  ///
  /// In en, this message translates to:
  /// **'Add to starred'**
  String get tooltipSongCardAddStar;

  /// Tooltip: unstar a song
  ///
  /// In en, this message translates to:
  /// **'Remove from starred'**
  String get tooltipSongCardRemoveStar;

  /// Tooltip: copy a song
  ///
  /// In en, this message translates to:
  /// **'Duplicate song'**
  String get tooltipSongCardDuplicate;

  /// Tooltip: delete a song
  ///
  /// In en, this message translates to:
  /// **'Delete song'**
  String get tooltipSongCardDelete;

  /// Hint in the song search field
  ///
  /// In en, this message translates to:
  /// **'Search songs, artists, lyrics'**
  String get descSongSearchHint;

  /// Tooltip: clear the search text
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get tooltipSongSearchClear;

  /// Filter chip showing all songs with a count
  ///
  /// In en, this message translates to:
  /// **'All Songs ({count})'**
  String labelSongFilterAll(int count);

  /// Filter chip showing starred songs with a count
  ///
  /// In en, this message translates to:
  /// **'Starred ({count})'**
  String labelSongFilterStarred(int count);

  /// Shown when the setlists could not be loaded
  ///
  /// In en, this message translates to:
  /// **'Error loading setlists: {error}'**
  String errorSetlistLoad(String error);

  /// Empty setlist tab title
  ///
  /// In en, this message translates to:
  /// **'No setlists yet'**
  String get emptySetlistEmptyTitle;

  /// Empty setlist tab message
  ///
  /// In en, this message translates to:
  /// **'Create setlists to group and arrange your songs for gigs and rehearsals.'**
  String get emptySetlistEmptyMessage;

  /// Button on the empty setlist tab
  ///
  /// In en, this message translates to:
  /// **'Create Setlist'**
  String get actionSetlistCreate;

  /// Song count badge on a setlist card
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 song} other{{count} songs}}'**
  String labelSetlistSongCount(int count);

  /// Button that starts performing a setlist
  ///
  /// In en, this message translates to:
  /// **'Perform'**
  String get actionSetlistPerform;

  /// Button that opens a setlist to edit its songs
  ///
  /// In en, this message translates to:
  /// **'Edit Songs'**
  String get actionSetlistEditSongs;

  /// Button and dialog title for a new setlist
  ///
  /// In en, this message translates to:
  /// **'New Setlist'**
  String get actionSetlistNew;

  /// App bar title while a setlist loads or is missing
  ///
  /// In en, this message translates to:
  /// **'Setlist'**
  String get titleSetlist;

  /// Shown when one setlist could not be loaded
  ///
  /// In en, this message translates to:
  /// **'Error loading setlist: {error}'**
  String errorSetlistLoadOne(String error);

  /// Shown when the setlist no longer exists
  ///
  /// In en, this message translates to:
  /// **'Setlist not found.'**
  String get errorSetlistNotFound;

  /// Tooltip: send the setlist as an AirQR stream
  ///
  /// In en, this message translates to:
  /// **'Send via AirQR'**
  String get tooltipSetlistShareAirQr;

  /// Tooltip: edit the setlist name and description
  ///
  /// In en, this message translates to:
  /// **'Edit setlist info'**
  String get tooltipSetlistEditInfo;

  /// Tooltip: delete the setlist
  ///
  /// In en, this message translates to:
  /// **'Delete setlist'**
  String get tooltipSetlistDelete;

  /// Button that performs the setlist from the first song
  ///
  /// In en, this message translates to:
  /// **'Perform Setlist'**
  String get actionSetlistPerformAll;

  /// Song count heading on the setlist screen
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 Song} other{{count} Songs}}'**
  String titleSetlistSongCount(int count);

  /// Button that opens the song picker for a setlist
  ///
  /// In en, this message translates to:
  /// **'Add Songs'**
  String get actionSetlistAddSongs;

  /// Empty state on the setlist screen
  ///
  /// In en, this message translates to:
  /// **'No songs in this setlist'**
  String get emptySetlistNoSongs;

  /// Button in the empty setlist state
  ///
  /// In en, this message translates to:
  /// **'Add Songs Now'**
  String get actionSetlistAddSongsNow;

  /// Subtitle of a song row in a setlist
  ///
  /// In en, this message translates to:
  /// **'Key: {key} • {bpm} BPM'**
  String descSetlistSongDetails(String key, int bpm);

  /// Subtitle of a song row in a setlist when the song has an artist
  ///
  /// In en, this message translates to:
  /// **'{artist} • Key: {key} • {bpm} BPM'**
  String descSetlistSongDetailsWithArtist(String artist, String key, int bpm);

  /// Tooltip: take a song out of the setlist
  ///
  /// In en, this message translates to:
  /// **'Remove from setlist'**
  String get tooltipSetlistRemoveSong;

  /// Title of the dialog confirming setlist deletion
  ///
  /// In en, this message translates to:
  /// **'Delete setlist?'**
  String get titleSetlistDelete;

  /// Body of the dialog confirming setlist deletion
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" will be deleted. Songs in your library will not be deleted.'**
  String descSetlistDeleteMessage(String name);

  /// SnackBar after a setlist was deleted
  ///
  /// In en, this message translates to:
  /// **'Deleted setlist \"{name}\".'**
  String bodySetlistDeleted(String name);

  /// SnackBar when sharing an empty setlist
  ///
  /// In en, this message translates to:
  /// **'No songs in setlist to share.'**
  String get bodySetlistNothingToShare;

  /// Title shown on the AirQR transmitter for a setlist
  ///
  /// In en, this message translates to:
  /// **'Setlist: {name}'**
  String titleSetlistAirQr(String name);

  /// Title of the dialog that edits a setlist
  ///
  /// In en, this message translates to:
  /// **'Edit Setlist'**
  String get titleSetlistEdit;

  /// Label of the setlist name field
  ///
  /// In en, this message translates to:
  /// **'Setlist Name'**
  String get labelSetlistName;

  /// Hint in the setlist name field
  ///
  /// In en, this message translates to:
  /// **'e.g. Sunday Gig, Acoustic Practice'**
  String get descSetlistNameHint;

  /// Error when the setlist name is empty
  ///
  /// In en, this message translates to:
  /// **'Please enter a setlist name'**
  String get errorSetlistNameRequired;

  /// Label of the setlist description field
  ///
  /// In en, this message translates to:
  /// **'Details (optional)'**
  String get labelSetlistDescription;

  /// Hint in the setlist description field
  ///
  /// In en, this message translates to:
  /// **'e.g. Venue, lineup, or notes'**
  String get descSetlistDescriptionHint;

  /// Title of the setlist song picker
  ///
  /// In en, this message translates to:
  /// **'Add Songs to Setlist'**
  String get titleSetlistPicker;

  /// Button that closes the song picker, with the number chosen
  ///
  /// In en, this message translates to:
  /// **'Done ({count})'**
  String actionSetlistPickerDone(int count);

  /// Hint in the song picker search field
  ///
  /// In en, this message translates to:
  /// **'Search songs...'**
  String get descSetlistPickerSearchHint;

  /// Shown when the song picker could not load songs
  ///
  /// In en, this message translates to:
  /// **'Error loading songs: {error}'**
  String errorSetlistPickerLoad(String error);

  /// Shown when the song picker search matched nothing
  ///
  /// In en, this message translates to:
  /// **'No songs found'**
  String get emptySetlistPickerNoSongs;

  /// Button that throws away unsaved work
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get actionDiscard;

  /// Button that closes a discard dialog and goes back to editing
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get actionKeepEditing;

  /// Button that inserts the result into the song
  ///
  /// In en, this message translates to:
  /// **'Insert'**
  String get actionInsert;

  /// Button that adds the typed item
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get actionAdd;

  /// Button that empties the current entry
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get actionClear;

  /// Notation tradition: Western chords
  ///
  /// In en, this message translates to:
  /// **'Western'**
  String get labelTraditionWestern;

  /// Notation tradition: Carnatic (South Indian) swaras
  ///
  /// In en, this message translates to:
  /// **'Carnatic'**
  String get labelTraditionCarnatic;

  /// Notation tradition: Hindustani (North Indian) swaras
  ///
  /// In en, this message translates to:
  /// **'Hindustani'**
  String get labelTraditionHindustani;

  /// How published Carnatic notation was read: letter case gives the note length
  ///
  /// In en, this message translates to:
  /// **'case means note length'**
  String get descCarnaticReadingDuration;

  /// How published Carnatic notation was read: letter case gives the octave
  ///
  /// In en, this message translates to:
  /// **'case means octave'**
  String get descCarnaticReadingOctave;

  /// Editor title when writing a new song
  ///
  /// In en, this message translates to:
  /// **'New Song Note'**
  String get titleEditorNew;

  /// Editor title when changing an existing song
  ///
  /// In en, this message translates to:
  /// **'Edit Song Note'**
  String get titleEditorEdit;

  /// Tooltip: undo the last edit
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get tooltipEditorUndo;

  /// Tooltip: redo the last undone edit
  ///
  /// In en, this message translates to:
  /// **'Redo'**
  String get tooltipEditorRedo;

  /// Tooltip on the editor overflow menu
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get tooltipEditorMoreOptions;

  /// Menu item and sheet title for the melody keypad
  ///
  /// In en, this message translates to:
  /// **'Melody keypad'**
  String get actionEditorMelodyKeypad;

  /// Menu item and sheet title for pasting Carnatic notation
  ///
  /// In en, this message translates to:
  /// **'Paste Carnatic'**
  String get actionEditorPasteCarnatic;

  /// Menu item that saves the edits as a new song
  ///
  /// In en, this message translates to:
  /// **'Save as copy'**
  String get actionEditorSaveAsCopy;

  /// Shown when the song to edit could not be loaded
  ///
  /// In en, this message translates to:
  /// **'This song could not be opened.'**
  String get errorEditorLoad;

  /// Hint in the empty lyrics area
  ///
  /// In en, this message translates to:
  /// **'Write your lyrics here.\nTap a chord above to drop it in at the cursor.'**
  String get descEditorLyricsHint;

  /// SnackBar when Carnatic notation is pasted into a song with no tala line
  ///
  /// In en, this message translates to:
  /// **'Add a {directive} line first — the notation is checked against the tala\'\'s beats.'**
  String errorEditorNeedsTala(String directive);

  /// Title of the dialog when leaving the editor with unsaved edits
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get titleEditorDiscard;

  /// Body of the dialog when leaving the editor with unsaved edits
  ///
  /// In en, this message translates to:
  /// **'Your edits to this song will not be saved.'**
  String get descEditorDiscardMessage;

  /// Shown in the folded editor header when the song has no title
  ///
  /// In en, this message translates to:
  /// **'Untitled'**
  String get labelEditorUntitled;

  /// Title saved for a song that has none (typed, imported or received). It is stored in the songbook.
  ///
  /// In en, this message translates to:
  /// **'Untitled Song'**
  String get labelUntitledSong;

  /// Title saved for a copy of a song. It is stored in the songbook.
  ///
  /// In en, this message translates to:
  /// **'{title} (Copy)'**
  String labelSongCopyTitle(String title);

  /// Song key in the folded editor header
  ///
  /// In en, this message translates to:
  /// **'Key {key}'**
  String labelEditorSummaryKey(String key);

  /// Tempo in the folded editor header
  ///
  /// In en, this message translates to:
  /// **'{bpm} BPM'**
  String labelEditorSummaryBpm(String bpm);

  /// Warning under the Tala field when the tala belongs to the other Indian tradition
  ///
  /// In en, this message translates to:
  /// **'\"{tala}\" is usually a {tradition} tala. You can still save it.'**
  String descEditorTalaWarning(String tala, String tradition);

  /// Label of the song title field
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get labelSongMetaTitle;

  /// Hint in the song title field
  ///
  /// In en, this message translates to:
  /// **'Song title'**
  String get labelSongMetaTitleHint;

  /// Label of the artist field
  ///
  /// In en, this message translates to:
  /// **'Artist / Band'**
  String get labelSongMetaArtist;

  /// Hint in the artist field
  ///
  /// In en, this message translates to:
  /// **'Who performs it'**
  String get labelSongMetaArtistHint;

  /// Label of the notation tradition picker
  ///
  /// In en, this message translates to:
  /// **'Notation'**
  String get labelSongMetaNotation;

  /// Help under the notation tradition picker
  ///
  /// In en, this message translates to:
  /// **'Western uses chords. Indian uses swaras.'**
  String get descSongMetaNotationHelper;

  /// Label of the raga field
  ///
  /// In en, this message translates to:
  /// **'Raga'**
  String get labelSongMetaRaga;

  /// Hint in the raga field: example raga names
  ///
  /// In en, this message translates to:
  /// **'Kalyani, Yaman'**
  String get labelSongMetaRagaHint;

  /// Label of the song key field
  ///
  /// In en, this message translates to:
  /// **'Original key'**
  String get labelSongMetaKey;

  /// Hint in the song key field: example keys
  ///
  /// In en, this message translates to:
  /// **'C, Am, F#m'**
  String get labelSongMetaKeyHint;

  /// Label of the tempo field
  ///
  /// In en, this message translates to:
  /// **'Tempo (BPM)'**
  String get labelSongMetaTempo;

  /// Hint in the tempo field: an example tempo
  ///
  /// In en, this message translates to:
  /// **'120'**
  String get labelSongMetaTempoHint;

  /// Label of the tala field
  ///
  /// In en, this message translates to:
  /// **'Tala'**
  String get labelSongMetaTala;

  /// Hint in the tala field: example tala names
  ///
  /// In en, this message translates to:
  /// **'Adi, Keherwa'**
  String get labelSongMetaTalaHint;

  /// Label of the setlist picker in the editor
  ///
  /// In en, this message translates to:
  /// **'Add to setlist'**
  String get labelSongMetaSetlist;

  /// Setlist picker choice that adds the song to no setlist
  ///
  /// In en, this message translates to:
  /// **'None (Do not add)'**
  String get labelSongMetaSetlistNone;

  /// Tooltip on a chord chip; the brackets show how it is written in the song
  ///
  /// In en, this message translates to:
  /// **'Insert [{chord}]'**
  String tooltipChordInserterInsert(String chord);

  /// Chip that opens the custom chord dialog
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get actionChordInserterCustom;

  /// Tooltip on the custom chord chip
  ///
  /// In en, this message translates to:
  /// **'Add your own chord'**
  String get tooltipChordInserterCustom;

  /// Title of the custom chord dialog
  ///
  /// In en, this message translates to:
  /// **'Custom chord'**
  String get titleChordInserterDialog;

  /// Label of the custom chord field
  ///
  /// In en, this message translates to:
  /// **'Chord'**
  String get labelChordInserterChord;

  /// Hint in the custom chord field: example chords
  ///
  /// In en, this message translates to:
  /// **'F#m7, Cmaj7, D/F#'**
  String get labelChordInserterChordHint;

  /// Title of the dialog when an imported song has the same title as an existing one
  ///
  /// In en, this message translates to:
  /// **'Duplicate Song Title'**
  String get titleRenameImport;

  /// Explains the title clash on import
  ///
  /// In en, this message translates to:
  /// **'A song titled \"{title}\" already exists in your songbook.'**
  String descRenameImportExists(String title);

  /// Asks for a new title for the imported song
  ///
  /// In en, this message translates to:
  /// **'Enter a new title for the imported song:'**
  String get descRenameImportPrompt;

  /// Label of the new title field
  ///
  /// In en, this message translates to:
  /// **'Song Title'**
  String get labelRenameImport;

  /// Error when the new title is empty
  ///
  /// In en, this message translates to:
  /// **'Please enter a title'**
  String get errorRenameImportRequired;

  /// Button that imports the song under the new title
  ///
  /// In en, this message translates to:
  /// **'Save with New Title'**
  String get actionRenameImportSave;

  /// Title of the dialog when closing the keypad with unsaved notes
  ///
  /// In en, this message translates to:
  /// **'Discard this melody?'**
  String get titleMelodyKeypadDiscard;

  /// Body of the dialog when closing the keypad with unsaved notes
  ///
  /// In en, this message translates to:
  /// **'What you tapped will be lost.'**
  String get descMelodyKeypadDiscardMessage;

  /// Keypad key: hold the note one more beat. Keep the comma, it is the symbol written
  ///
  /// In en, this message translates to:
  /// **'Hold ,'**
  String get labelMelodyKeypadHold;

  /// Tooltip on the Hold key
  ///
  /// In en, this message translates to:
  /// **'Hold one more beat'**
  String get tooltipMelodyKeypadHold;

  /// Keypad key: group divider. Keep the | symbol
  ///
  /// In en, this message translates to:
  /// **'Bar |'**
  String get labelMelodyKeypadBar;

  /// Tooltip on the Bar key
  ///
  /// In en, this message translates to:
  /// **'Group divider'**
  String get tooltipMelodyKeypadBar;

  /// Keypad key: next note shares this beat. Keep the - symbol
  ///
  /// In en, this message translates to:
  /// **'Share -'**
  String get labelMelodyKeypadShare;

  /// Tooltip on the Share key
  ///
  /// In en, this message translates to:
  /// **'Share this beat'**
  String get tooltipMelodyKeypadShare;

  /// Keypad key: start the next note part-way through a beat. Keep the ,- symbol
  ///
  /// In en, this message translates to:
  /// **'Tie ,-'**
  String get labelMelodyKeypadTie;

  /// Tooltip on the Tie key
  ///
  /// In en, this message translates to:
  /// **'Start mid-beat'**
  String get tooltipMelodyKeypadTie;

  /// Keypad key: stop the sound. Keep the x symbol
  ///
  /// In en, this message translates to:
  /// **'Silence x'**
  String get labelMelodyKeypadSilence;

  /// Tooltip on the Silence key
  ///
  /// In en, this message translates to:
  /// **'Stop the sound'**
  String get tooltipMelodyKeypadSilence;

  /// Keypad toggle: move the last note up an octave
  ///
  /// In en, this message translates to:
  /// **'Octave ↑'**
  String get labelMelodyKeypadOctaveUp;

  /// Keypad toggle: move the last note down an octave
  ///
  /// In en, this message translates to:
  /// **'Octave ↓'**
  String get labelMelodyKeypadOctaveDown;

  /// Keypad toggle: slide into the last note. Keep the ! symbol
  ///
  /// In en, this message translates to:
  /// **'Slide !'**
  String get labelMelodyKeypadSlide;

  /// Keypad toggle: shake the last note. Keep the ~ symbol
  ///
  /// In en, this message translates to:
  /// **'Shake ~'**
  String get labelMelodyKeypadShake;

  /// Tooltip: remove the last entry
  ///
  /// In en, this message translates to:
  /// **'Backspace'**
  String get tooltipMelodyKeypadBackspace;

  /// Beat count when no known tala is set
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 beat} other{{count} beats}}'**
  String labelMelodyKeypadBeats(int count);

  /// Beat count when the line fills the tala
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 beat — fits {tala}} other{{count} beats — fits {tala}}}'**
  String descMelodyKeypadFits(int count, String tala);

  /// Beat count when the line does not yet fill the tala
  ///
  /// In en, this message translates to:
  /// **'{count} of {total} beats'**
  String labelMelodyKeypadOfBeats(int count, int total);

  /// Hint shown in the keypad preview before anything is entered
  ///
  /// In en, this message translates to:
  /// **'Tap a swara to start. Hold adds a beat, Bar marks a group.'**
  String get descMelodyKeypadStartHint;

  /// Help under the Carnatic paste sheet title. Keep || and _like_this_ as they are
  ///
  /// In en, this message translates to:
  /// **'Tala: {tala}. Paste one avarta per line, or separate them with ||. Underlined runs: write them _like_this_.'**
  String descCarnaticSheetHelp(String tala);

  /// Switch: read Ma as shuddha madhyamam in Ga-Ma-Ri descents
  ///
  /// In en, this message translates to:
  /// **'Ma1 in Ga-Ma-Ri'**
  String get labelCarnaticSheetAnyaTitle;

  /// Explains the shuddha madhyamam switch
  ///
  /// In en, this message translates to:
  /// **'For a bhashanga raga such as Yamunakalyani. Off by default — the notation does not say which madhyamam is meant.'**
  String get descCarnaticSheetAnyaSubtitle;

  /// Button that inserts the converted melody lines
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Insert 1 line} other{Insert {count} lines}}'**
  String actionCarnaticSheetInsertLines(int count);

  /// How many cycles matched the tala, and which reading was used
  ///
  /// In en, this message translates to:
  /// **'{fitting} of {total} cycles fit the tala — read with {reading}.'**
  String descCarnaticSheetFit(int fitting, int total, String reading);

  /// How the reading that was not used would have fitted
  ///
  /// In en, this message translates to:
  /// **'The other reading ({reading}) fits {fitting} of {total}.'**
  String descCarnaticSheetOtherReading(String reading, int fitting, int total);

  /// Hint when the notation has Ga-Ma-Ri descents
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{A Ga-Ma-Ri descent appears in 1 cycle. In a bhashanga raga that madhyamam is the shuddha one.} other{A Ga-Ma-Ri descent appears in {count} cycles. In a bhashanga raga that madhyamam is the shuddha one.}}'**
  String descCarnaticSheetAnyaHint(int count);

  /// Toggle: repeat the melody line
  ///
  /// In en, this message translates to:
  /// **'Loop'**
  String get labelMelodyLineLoop;

  /// Toggle: play the melody line at half speed
  ///
  /// In en, this message translates to:
  /// **'Half speed'**
  String get labelMelodyLineHalfSpeed;

  /// SnackBar when the melody could not start playing
  ///
  /// In en, this message translates to:
  /// **'Could not play this melody.'**
  String get errorMelodyLinePlayFailed;

  /// Tooltip: stop the melody
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get tooltipMelodyLineStop;

  /// Tooltip: play the melody line
  ///
  /// In en, this message translates to:
  /// **'Hum this line'**
  String get tooltipMelodyLinePlay;

  /// Tooltip when the melody cannot play because the song has no tonic line
  ///
  /// In en, this message translates to:
  /// **'Needs a {directive} line'**
  String tooltipMelodyLineNeedsTonic(String directive);

  /// Tooltip/button that closes a dialog or sheet
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get actionClose;

  /// Button and menu item that exports the song
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get actionExport;

  /// Tooltip: start auto-scroll
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get tooltipPlay;

  /// Tooltip: pause auto-scroll
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get tooltipPause;

  /// Button that returns a value to its default
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get actionReset;

  /// Raga part of the song info line
  ///
  /// In en, this message translates to:
  /// **'Raga {raga}'**
  String labelInfoRaga(String raga);

  /// Tala part of the song info line
  ///
  /// In en, this message translates to:
  /// **'Tala {tala}'**
  String labelInfoTala(String tala);

  /// Key part of the song info line
  ///
  /// In en, this message translates to:
  /// **'Key {key}'**
  String labelInfoKey(String key);

  /// Key part of the info line when transposed; semitones is like +2 or -3
  ///
  /// In en, this message translates to:
  /// **'Key {key} ({semitones})'**
  String labelInfoKeyTransposed(String key, String semitones);

  /// Tempo part of the song info line
  ///
  /// In en, this message translates to:
  /// **'{bpm} BPM'**
  String labelInfoBpm(int bpm);

  /// Number of bars (measures) for Tempo auto-scroll
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 bar} other{{count} bars}}'**
  String labelInfoBars(int count);

  /// First part of the status line under the performance controls
  ///
  /// In en, this message translates to:
  /// **'Auto-scroll'**
  String get labelInfoAutoScroll;

  /// App bar title while the song loads or when there is none
  ///
  /// In en, this message translates to:
  /// **'Song'**
  String get titlePerfSong;

  /// Tooltip: go to the previous song in the setlist
  ///
  /// In en, this message translates to:
  /// **'Previous song'**
  String get tooltipPerfPreviousSong;

  /// Tooltip: go to the next song in the setlist
  ///
  /// In en, this message translates to:
  /// **'Next song'**
  String get tooltipPerfNextSong;

  /// Tooltip: open the list of songs in this setlist
  ///
  /// In en, this message translates to:
  /// **'Setlist songs'**
  String get tooltipPerfSetlistSongs;

  /// Tooltip: open the editor for this song
  ///
  /// In en, this message translates to:
  /// **'Edit song'**
  String get tooltipPerfEditSong;

  /// App bar subtitle: setlist name and the song position in it
  ///
  /// In en, this message translates to:
  /// **'{name} ({position}/{total})'**
  String titlePerfSetlistPosition(String name, int position, int total);

  /// Shown when the song no longer exists
  ///
  /// In en, this message translates to:
  /// **'Song not found'**
  String get errorPerfNotFoundTitle;

  /// Explains why the song was not found
  ///
  /// In en, this message translates to:
  /// **'It may have been deleted from your songbook.'**
  String get descPerfNotFoundMessage;

  /// Menu item and sheet title for transpose and display controls
  ///
  /// In en, this message translates to:
  /// **'Performance controls'**
  String get actionPerfControls;

  /// Menu item and tooltip that open the gestures help
  ///
  /// In en, this message translates to:
  /// **'Gestures help'**
  String get tooltipPerfGesturesHelp;

  /// Menu item and dialog title for the swara keyboard reference
  ///
  /// In en, this message translates to:
  /// **'Swara Reference'**
  String get actionPerfSwaraReference;

  /// Menu item that opens the chord diagrams
  ///
  /// In en, this message translates to:
  /// **'Chord Reference'**
  String get actionPerfChordReferenceGuide;

  /// Title of the dialog that asks which format to export
  ///
  /// In en, this message translates to:
  /// **'Export song'**
  String get titlePerfExportDialog;

  /// Title of the dialog that asks how to share
  ///
  /// In en, this message translates to:
  /// **'Share song'**
  String get titlePerfShareDialog;

  /// Share option: send the song as animated QR codes
  ///
  /// In en, this message translates to:
  /// **'AirQR stream'**
  String get labelPerfFormatAirQr;

  /// SnackBar when sharing as ChordPro failed
  ///
  /// In en, this message translates to:
  /// **'Could not share the ChordPro file.'**
  String get errorPerfShareChordProFailed;

  /// SnackBar when the PDF came out empty
  ///
  /// In en, this message translates to:
  /// **'Could not export the PDF (no pages).'**
  String get errorPerfPdfNoPages;

  /// SnackBar when making the PDF timed out
  ///
  /// In en, this message translates to:
  /// **'PDF export took too long and was stopped.'**
  String get errorPerfPdfTimeout;

  /// SnackBar when sharing as PDF failed
  ///
  /// In en, this message translates to:
  /// **'Could not share the PDF.'**
  String get errorPerfSharePdfFailed;

  /// Title of the system save dialog for a PDF
  ///
  /// In en, this message translates to:
  /// **'Export as PDF'**
  String get titlePerfExportPdf;

  /// Title of the system save dialog for a ChordPro file
  ///
  /// In en, this message translates to:
  /// **'Export as ChordPro'**
  String get titlePerfExportChordPro;

  /// SnackBar after the song was exported
  ///
  /// In en, this message translates to:
  /// **'Exported \"{title}\".'**
  String bodyPerfExported(String title);

  /// SnackBar when exporting the PDF failed
  ///
  /// In en, this message translates to:
  /// **'Could not export the PDF.'**
  String get errorPerfExportPdfFailed;

  /// SnackBar when exporting the ChordPro file failed
  ///
  /// In en, this message translates to:
  /// **'Could not export the ChordPro file.'**
  String get errorPerfExportChordProFailed;

  /// Tooltip: open the pitch pipe and shruti box
  ///
  /// In en, this message translates to:
  /// **'Pitch pipe & drone'**
  String get tooltipPerfDrone;

  /// Tooltip on the manual scroll speed read-out
  ///
  /// In en, this message translates to:
  /// **'Scroll speed'**
  String get tooltipPerfSpeed;

  /// Tooltip: hide the chord line
  ///
  /// In en, this message translates to:
  /// **'Hide chords'**
  String get tooltipPerfHideChords;

  /// Tooltip and switch: show the chord line
  ///
  /// In en, this message translates to:
  /// **'Show chords'**
  String get tooltipPerfShowChords;

  /// Tooltip: hide the melody rows
  ///
  /// In en, this message translates to:
  /// **'Hide melody'**
  String get tooltipPerfHideMelody;

  /// Tooltip and switch: show the melody rows
  ///
  /// In en, this message translates to:
  /// **'Show melody'**
  String get tooltipPerfShowMelody;

  /// Tooltip and title for full screen (Stage Mode)
  ///
  /// In en, this message translates to:
  /// **'Full screen'**
  String get tooltipAutoScrollFullScreen;

  /// Auto-scroll mode with a fixed speed
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get labelAutoScrollManual;

  /// Auto-scroll mode worked out from tempo and bars
  ///
  /// In en, this message translates to:
  /// **'Tempo'**
  String get labelAutoScrollTempo;

  /// One-letter label of the Manual mode button
  ///
  /// In en, this message translates to:
  /// **'M'**
  String get actionAutoScrollManualShort;

  /// One-letter label of the Tempo mode button
  ///
  /// In en, this message translates to:
  /// **'T'**
  String get actionAutoScrollTempoShort;

  /// Label of the transpose row
  ///
  /// In en, this message translates to:
  /// **'Transpose'**
  String get labelTranspose;

  /// Tooltip: transpose one semitone down
  ///
  /// In en, this message translates to:
  /// **'Transpose down'**
  String get tooltipTransposeDown;

  /// Tooltip: transpose one semitone up
  ///
  /// In en, this message translates to:
  /// **'Transpose up'**
  String get tooltipTransposeUp;

  /// Note under the Show melody switch
  ///
  /// In en, this message translates to:
  /// **'Full screen never shows the melody'**
  String get descTransposeMelodySubtitle;

  /// Tip at the bottom of the performance controls sheet
  ///
  /// In en, this message translates to:
  /// **'Tip: pinch the lyrics with two fingers to change the text size.'**
  String get descTransposePinchTip;

  /// Title of the chord diagrams dialog
  ///
  /// In en, this message translates to:
  /// **'Chord Reference'**
  String get titleChordRef;

  /// Shown when the song has no swaras to draw
  ///
  /// In en, this message translates to:
  /// **'No swaras in this song'**
  String get emptyChordRefNoSwaras;

  /// Shown when the song has no chords to draw
  ///
  /// In en, this message translates to:
  /// **'No chords in this song'**
  String get emptyChordRefNoChords;

  /// Tab with guitar chord diagrams
  ///
  /// In en, this message translates to:
  /// **'Guitar'**
  String get tabChordRefGuitar;

  /// Tab with harmonium chord diagrams
  ///
  /// In en, this message translates to:
  /// **'Harmonium'**
  String get tabChordRefHarmonium;

  /// Tooltip: leave Stage Mode
  ///
  /// In en, this message translates to:
  /// **'Exit full screen'**
  String get tooltipStageExitFullScreen;

  /// Tooltip: lock Stage Mode against stray touches
  ///
  /// In en, this message translates to:
  /// **'Lock Stage View'**
  String get tooltipStageLock;

  /// Tooltip while Quiet Mode is on
  ///
  /// In en, this message translates to:
  /// **'Turn off Quiet Mode'**
  String get tooltipStageQuietActive;

  /// Tooltip while Quiet Mode is off
  ///
  /// In en, this message translates to:
  /// **'Turn on Quiet Mode'**
  String get tooltipStageQuietInactive;

  /// Tooltip: fewer bars in Tempo mode
  ///
  /// In en, this message translates to:
  /// **'Fewer bars'**
  String get tooltipStageFewerBars;

  /// Tooltip: more bars in Tempo mode
  ///
  /// In en, this message translates to:
  /// **'More bars'**
  String get tooltipStageMoreBars;

  /// Tooltip: slower manual scroll
  ///
  /// In en, this message translates to:
  /// **'Slower'**
  String get tooltipStageSlower;

  /// Tooltip: faster manual scroll
  ///
  /// In en, this message translates to:
  /// **'Faster'**
  String get tooltipStageFaster;

  /// Chip shown while Stage Mode is locked
  ///
  /// In en, this message translates to:
  /// **'Stage Locked'**
  String get labelStageLocked;

  /// Flash after a two-finger tap starts auto-scroll
  ///
  /// In en, this message translates to:
  /// **'Playing'**
  String get labelStagePlaying;

  /// Flash after a two-finger tap pauses auto-scroll
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get labelStagePaused;

  /// Subtitle of the first-time Stage Mode guide
  ///
  /// In en, this message translates to:
  /// **'Only the words, and these gestures.'**
  String get descStageHelpSubtitle;

  /// Gesture name in the Stage Mode guide
  ///
  /// In en, this message translates to:
  /// **'Tap once'**
  String get labelStageHelpTapOnce;

  /// What a single tap does in Stage Mode
  ///
  /// In en, this message translates to:
  /// **'Show or hide the controls'**
  String get descStageHelpTapOnceMeaning;

  /// Gesture name in the Stage Mode guide
  ///
  /// In en, this message translates to:
  /// **'Double-tap up top'**
  String get labelStageHelpDoubleTapTop;

  /// Gesture name in the Stage Mode guide
  ///
  /// In en, this message translates to:
  /// **'Double-tap down low'**
  String get labelStageHelpDoubleTapBottom;

  /// Gesture name in the Stage Mode guide and gestures help
  ///
  /// In en, this message translates to:
  /// **'Tap with two fingers'**
  String get labelStageHelpTwoFingers;

  /// What a two-finger tap does in Stage Mode
  ///
  /// In en, this message translates to:
  /// **'Play or pause'**
  String get descStageHelpTwoFingersMeaning;

  /// Gesture name in the Stage Mode guide
  ///
  /// In en, this message translates to:
  /// **'Pinch'**
  String get labelStageHelpPinch;

  /// What a pinch does in Stage Mode
  ///
  /// In en, this message translates to:
  /// **'Change the text size'**
  String get descStageHelpPinchMeaning;

  /// Gesture name in the Stage Mode guide: the system back gesture
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get labelStageHelpBack;

  /// What Back does in Stage Mode
  ///
  /// In en, this message translates to:
  /// **'Leave full screen'**
  String get descStageHelpBackMeaning;

  /// Closes the first-time Stage Mode guide
  ///
  /// In en, this message translates to:
  /// **'Tap anywhere to start'**
  String get descStageHelpStart;

  /// Title of the gestures help dialog
  ///
  /// In en, this message translates to:
  /// **'Gestures & Shortcuts'**
  String get titleGestures;

  /// Subtitle of the gestures help dialog
  ///
  /// In en, this message translates to:
  /// **'Control the sheet hands-free while playing'**
  String get descGesturesSubtitle;

  /// Gesture name in the gestures help
  ///
  /// In en, this message translates to:
  /// **'Double-tap top'**
  String get labelGesturesDoubleTapTop;

  /// What a double-tap on the top half does
  ///
  /// In en, this message translates to:
  /// **'Faster in Manual mode, or adds 4 bars in Tempo mode.'**
  String get descGesturesDoubleTapTopMeaning;

  /// Gesture name in the gestures help
  ///
  /// In en, this message translates to:
  /// **'Double-tap bottom'**
  String get labelGesturesDoubleTapBottom;

  /// What a double-tap on the bottom half does
  ///
  /// In en, this message translates to:
  /// **'Slower in Manual mode, or removes 4 bars in Tempo mode.'**
  String get descGesturesDoubleTapBottomMeaning;

  /// What a two-finger tap does
  ///
  /// In en, this message translates to:
  /// **'Play or pause auto-scroll without touching any button.'**
  String get descGesturesTwoFingersMeaning;

  /// Gesture name in the gestures help
  ///
  /// In en, this message translates to:
  /// **'Drag with one finger'**
  String get labelGesturesDrag;

  /// What a one-finger drag does
  ///
  /// In en, this message translates to:
  /// **'Move the sheet by hand; auto-scroll waits and resumes when you lift.'**
  String get descGesturesDragMeaning;

  /// Gesture name in the gestures help
  ///
  /// In en, this message translates to:
  /// **'Two-finger pinch'**
  String get labelGesturesPinch;

  /// What a pinch does
  ///
  /// In en, this message translates to:
  /// **'Zoom in or out to make the chord and lyric text larger or smaller.'**
  String get descGesturesPinchMeaning;

  /// Gesture name in the gestures help
  ///
  /// In en, this message translates to:
  /// **'Full screen'**
  String get labelGesturesFullScreen;

  /// How touches work in full screen
  ///
  /// In en, this message translates to:
  /// **'Single tap toggles HUD controls; back gesture leaves full screen.'**
  String get descGesturesFullScreenMeaning;

  /// Button that opens the in-app help
  ///
  /// In en, this message translates to:
  /// **'Help Center'**
  String get actionGesturesHelpCenter;

  /// Button that closes the gestures help
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get actionGesturesGotIt;

  /// Tap tempo hint before any tap
  ///
  /// In en, this message translates to:
  /// **'Tap along with the music'**
  String get descMetronomeTapAlong;

  /// Tap tempo hint after the first tap
  ///
  /// In en, this message translates to:
  /// **'Keep tapping…'**
  String get descMetronomeKeepTapping;

  /// Tap tempo hint: taps still needed for a steady tempo
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Good — 1 more tap to steady it} other{Good — {count} more taps to steady it}}'**
  String descMetronomeTapsNeeded(int count);

  /// Tap tempo hint once enough taps were made
  ///
  /// In en, this message translates to:
  /// **'Steady'**
  String get descMetronomeSteady;

  /// Title of the metronome tempo sheet
  ///
  /// In en, this message translates to:
  /// **'Metronome tempo'**
  String get titleMetronomeTempo;

  /// Tempo source: changed by the user
  ///
  /// In en, this message translates to:
  /// **'Set by you for this session'**
  String get descMetronomeSetByYou;

  /// Tempo source: the song tempo
  ///
  /// In en, this message translates to:
  /// **'Using this song\'\'s saved tempo'**
  String get descMetronomeUsingSongTempo;

  /// Tempo source: the song has no tempo
  ///
  /// In en, this message translates to:
  /// **'This song has no saved tempo'**
  String get descMetronomeNoSongTempo;

  /// Tooltip: lower the tempo by 1 BPM
  ///
  /// In en, this message translates to:
  /// **'Slower by 1'**
  String get tooltipMetronomeSlowerByOne;

  /// Tooltip: raise the tempo by 1 BPM
  ///
  /// In en, this message translates to:
  /// **'Faster by 1'**
  String get tooltipMetronomeFasterByOne;

  /// Unit under the big tempo number (beats per minute)
  ///
  /// In en, this message translates to:
  /// **'BPM'**
  String get labelMetronomeBpmUnit;

  /// Button: set the tempo by tapping
  ///
  /// In en, this message translates to:
  /// **'Tap tempo'**
  String get actionMetronomeTapTempo;

  /// Button: go back to the song tempo
  ///
  /// In en, this message translates to:
  /// **'Use song tempo'**
  String get actionMetronomeUseSongTempo;

  /// Disabled button when the song has no tempo
  ///
  /// In en, this message translates to:
  /// **'No song tempo'**
  String get actionMetronomeNoSongTempoToRestore;

  /// Tooltip on the running metronome button
  ///
  /// In en, this message translates to:
  /// **'Stop metronome'**
  String get tooltipMetronomeStop;

  /// Tooltip on the stopped metronome button
  ///
  /// In en, this message translates to:
  /// **'Start metronome'**
  String get tooltipMetronomeStart;

  /// SnackBar when a pitch sound could not play and no reason is known
  ///
  /// In en, this message translates to:
  /// **'Could not play the sound.'**
  String get errorDroneCouldNotPlay;

  /// Title of the pitch pipe sheet
  ///
  /// In en, this message translates to:
  /// **'Pitch Pipe & Drone'**
  String get titleDrone;

  /// Drone mode: Indian classical shruti
  ///
  /// In en, this message translates to:
  /// **'Classical (Shruti)'**
  String get labelDroneModeClassical;

  /// Drone mode: Western chords
  ///
  /// In en, this message translates to:
  /// **'Western (Chords)'**
  String get labelDroneModeWestern;

  /// Drone interval: Sa with Pa
  ///
  /// In en, this message translates to:
  /// **'Sa + Pa (5th)'**
  String get labelDroneSaPa;

  /// Drone interval: Sa with Ma
  ///
  /// In en, this message translates to:
  /// **'Sa + Ma (4th)'**
  String get labelDroneSaMa;

  /// Chord quality: major
  ///
  /// In en, this message translates to:
  /// **'Major (maj)'**
  String get labelDroneMajor;

  /// Chord quality: minor
  ///
  /// In en, this message translates to:
  /// **'Minor (min)'**
  String get labelDroneMinor;

  /// Button: play the chord for two seconds
  ///
  /// In en, this message translates to:
  /// **'Chord Cue (2s)'**
  String get actionDroneChordCue;

  /// Button: play the pitch for two seconds
  ///
  /// In en, this message translates to:
  /// **'Pitch Cue (2s)'**
  String get actionDronePitchCue;

  /// Button: stop the drone
  ///
  /// In en, this message translates to:
  /// **'Stop Drone'**
  String get actionDroneStop;

  /// Button: start a chord drone
  ///
  /// In en, this message translates to:
  /// **'Chord Drone'**
  String get actionDroneChord;

  /// Button: start a shruti drone
  ///
  /// In en, this message translates to:
  /// **'Shruti Drone'**
  String get actionDroneShruti;

  /// Label of the Stage Mode text size choices
  ///
  /// In en, this message translates to:
  /// **'Stage Text Scale'**
  String get labelDroneTextScale;

  /// Where the pitch came from: the singer Sa
  ///
  /// In en, this message translates to:
  /// **'Your Sa:  {name}'**
  String labelDroneYourSa(String name);

  /// Where the pitch came from: the song key
  ///
  /// In en, this message translates to:
  /// **'Song key:  {key}'**
  String labelDroneSongKey(String key);

  /// Prompt to pick a root pitch
  ///
  /// In en, this message translates to:
  /// **'Root Pitch Key'**
  String get labelDroneRootKey;

  /// Shown when the song has no lyrics
  ///
  /// In en, this message translates to:
  /// **'This song has no lyrics yet.'**
  String get emptySheetNoLyrics;

  /// Screen-reader label when a chord cannot be drawn on guitar
  ///
  /// In en, this message translates to:
  /// **'No guitar chord diagram for {name}'**
  String descDiagramNoGuitar(String name);

  /// Screen-reader label of a guitar chord diagram
  ///
  /// In en, this message translates to:
  /// **'Guitar chord diagram for {name}'**
  String descDiagramGuitar(String name);

  /// Shown in place of a guitar diagram that cannot be drawn
  ///
  /// In en, this message translates to:
  /// **'No diagram'**
  String get labelDiagramNone;

  /// Screen-reader label of a harmonium chord diagram
  ///
  /// In en, this message translates to:
  /// **'Harmonium chord diagram for {name}'**
  String descDiagramHarmonium(String name);

  /// Screen-reader label of a swara keyboard diagram
  ///
  /// In en, this message translates to:
  /// **'Swara diagram for {swara}'**
  String descDiagramSwara(String swara);

  /// Screen-reader word for a held beat in the melody grid
  ///
  /// In en, this message translates to:
  /// **'hold'**
  String get labelMelodyGridHold;

  /// Screen-reader word for a group divider in the melody grid
  ///
  /// In en, this message translates to:
  /// **'bar line'**
  String get labelMelodyGridBarLine;

  /// Screen-reader words for a melody token that could not be read
  ///
  /// In en, this message translates to:
  /// **'could not read {text}'**
  String descMelodyGridUnreadable(String text);

  /// Settings card and screen title: general settings
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get titleSettingsGeneral;

  /// Settings card subtitle for General
  ///
  /// In en, this message translates to:
  /// **'Import and metronome'**
  String get descSettingsGeneralSubtitle;

  /// Settings card and screen title: theme choice
  ///
  /// In en, this message translates to:
  /// **'Themes'**
  String get titleSettingsThemes;

  /// Settings card subtitle for Themes
  ///
  /// In en, this message translates to:
  /// **'System, light, or dark look'**
  String get descSettingsThemesSubtitle;

  /// Settings card and screen title: custom chords
  ///
  /// In en, this message translates to:
  /// **'Chords'**
  String get titleSettingsChords;

  /// Settings card subtitle for Chords
  ///
  /// In en, this message translates to:
  /// **'Your own chord notations for the editor'**
  String get descSettingsChordsSubtitle;

  /// Settings card and screen title: lyric font
  ///
  /// In en, this message translates to:
  /// **'Fonts'**
  String get titleSettingsFonts;

  /// Settings card subtitle for Fonts
  ///
  /// In en, this message translates to:
  /// **'Pick the lyric font (English and Malayalam)'**
  String get descSettingsFontsSubtitle;

  /// Settings card: in-app help
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get titleSettingsHelp;

  /// Settings card subtitle for Help
  ///
  /// In en, this message translates to:
  /// **'How to use setlists, metronome, export and more'**
  String get descSettingsHelpSubtitle;

  /// Settings card subtitle for About
  ///
  /// In en, this message translates to:
  /// **'App version, author, and licenses'**
  String get descSettingsAboutSubtitle;

  /// General settings card: import ChordPro files
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get titleGeneralImport;

  /// Subtitle of the Import card
  ///
  /// In en, this message translates to:
  /// **'Bring in ChordPro files as songs'**
  String get descGeneralImportSubtitle;

  /// General settings card and screen title: duplicate handling on import
  ///
  /// In en, this message translates to:
  /// **'Import Settings'**
  String get titleGeneralImportSettings;

  /// Subtitle of the Import Settings card
  ///
  /// In en, this message translates to:
  /// **'Configure duplicate song handling for ChordPro files'**
  String get descGeneralImportSettingsSubtitle;

  /// Subtitle of the Auto-scroll card
  ///
  /// In en, this message translates to:
  /// **'Starting speed for manual scrolling'**
  String get descGeneralAutoScrollSubtitle;

  /// General settings card and screen title: metronome
  ///
  /// In en, this message translates to:
  /// **'Metronome'**
  String get titleGeneralMetronome;

  /// Subtitle of the Metronome card
  ///
  /// In en, this message translates to:
  /// **'Turn the beat on or off'**
  String get descGeneralMetronomeSubtitle;

  /// Subtitle of the Pitch Pipe & Drone card
  ///
  /// In en, this message translates to:
  /// **'Reference pitch tones, a steady drone, and your Sa (kattai)'**
  String get descGeneralDroneSubtitle;

  /// Theme choice: follow the device
  ///
  /// In en, this message translates to:
  /// **'System theme'**
  String get labelThemeSystem;

  /// Theme choice: light
  ///
  /// In en, this message translates to:
  /// **'Light theme'**
  String get labelThemeLight;

  /// Theme choice: dark
  ///
  /// In en, this message translates to:
  /// **'Dark theme'**
  String get labelThemeDark;

  /// Note at the top of the font settings
  ///
  /// In en, this message translates to:
  /// **'Used for song lyrics on screen and in exported PDFs. Malayalam always prints in PDFs, even with an English font.'**
  String get descFontSettingsNote;

  /// Font choice: the app default font
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get labelFontSystemDefault;

  /// Heading of the default scroll speed setting
  ///
  /// In en, this message translates to:
  /// **'Starting speed'**
  String get titleScrollStartingSpeed;

  /// Explains the default scroll speed
  ///
  /// In en, this message translates to:
  /// **'Manual scrolling starts at this speed for a song you have not set a speed for yet.'**
  String get descScrollStartingSpeedNote;

  /// Button that resets the default scroll speed; speed is like 1.00x
  ///
  /// In en, this message translates to:
  /// **'Reset to {speed}'**
  String actionScrollResetTo(String speed);

  /// SnackBar when a custom chord is too long or already there
  ///
  /// In en, this message translates to:
  /// **'Could not add that chord. Use at most {max} characters and no repeats.'**
  String errorChordSettingsAddFailed(int max);

  /// SnackBar after a custom chord was removed
  ///
  /// In en, this message translates to:
  /// **'Removed \"{chord}\".'**
  String bodyChordSettingsRemoved(String chord);

  /// Intro text on the custom chords screen
  ///
  /// In en, this message translates to:
  /// **'Add your own chord notations. They always appear in the editor\'\'s chord bar, after the key\'\'s own chords.'**
  String get descChordSettingsIntro;

  /// Label of the custom chord field
  ///
  /// In en, this message translates to:
  /// **'Chord notation'**
  String get labelChordSettings;

  /// Shown when there are no custom chords
  ///
  /// In en, this message translates to:
  /// **'No custom chords yet.'**
  String get emptyChordSettings;

  /// Tooltip: remove a custom chord
  ///
  /// In en, this message translates to:
  /// **'Remove {chord}'**
  String tooltipChordSettingsRemove(String chord);

  /// Question above the duplicate handling choices
  ///
  /// In en, this message translates to:
  /// **'When importing a song whose title matches an existing song in your songbook:'**
  String get descImportSettingsQuestion;

  /// Duplicate handling choice: replace the existing song
  ///
  /// In en, this message translates to:
  /// **'Overwrite'**
  String get labelImportStrategyOverwrite;

  /// Explains the Overwrite choice
  ///
  /// In en, this message translates to:
  /// **'Replace existing song content with the imported song'**
  String get descImportStrategyOverwrite;

  /// Duplicate handling choice: rename the new song
  ///
  /// In en, this message translates to:
  /// **'Rename imported'**
  String get labelImportStrategyRenameImported;

  /// Explains the Rename imported choice
  ///
  /// In en, this message translates to:
  /// **'Automatically rename imported song by adding timestamp to the title'**
  String get descImportStrategyRenameImported;

  /// Duplicate handling choice: rename the old song
  ///
  /// In en, this message translates to:
  /// **'Rename existing'**
  String get labelImportStrategyRenameExisting;

  /// Explains the Rename existing choice
  ///
  /// In en, this message translates to:
  /// **'Automatically rename existing song by adding timestamp to the title'**
  String get descImportStrategyRenameExisting;

  /// Duplicate handling choice: ask for a new name
  ///
  /// In en, this message translates to:
  /// **'Ask for a new name'**
  String get labelImportStrategyUserSuggested;

  /// Explains the user suggested name choice
  ///
  /// In en, this message translates to:
  /// **'Prompt UI for user to type custom name for imported song'**
  String get descImportStrategyUserSuggested;

  /// Switch: turn the metronome on
  ///
  /// In en, this message translates to:
  /// **'Enable metronome'**
  String get labelMetronomeEnable;

  /// Subtitle of the metronome switch
  ///
  /// In en, this message translates to:
  /// **'Keep the beat at the song tempo'**
  String get descMetronomeEnableSubtitle;

  /// Switch: flash on every beat
  ///
  /// In en, this message translates to:
  /// **'Flash'**
  String get labelMetronomeFlash;

  /// Subtitle of the Flash switch
  ///
  /// In en, this message translates to:
  /// **'Blink on every beat (good when muted)'**
  String get descMetronomeFlashSubtitle;

  /// Switch: click sound on every beat
  ///
  /// In en, this message translates to:
  /// **'Click'**
  String get labelMetronomeClick;

  /// Subtitle of the Click switch
  ///
  /// In en, this message translates to:
  /// **'Play a tick on every beat'**
  String get descMetronomeClickSubtitle;

  /// Label of the click volume slider
  ///
  /// In en, this message translates to:
  /// **'Click volume'**
  String get labelMetronomeClickVolume;

  /// Section heading for bar settings (a bar is a measure)
  ///
  /// In en, this message translates to:
  /// **'Bar'**
  String get titleMetronomeBarHeading;

  /// Setting: number of beats in a bar
  ///
  /// In en, this message translates to:
  /// **'Beats in a bar'**
  String get labelMetronomeBeatsInBar;

  /// Subtitle of the Beats in a bar setting
  ///
  /// In en, this message translates to:
  /// **'Beat 1 is the one you count on'**
  String get descMetronomeBeatsInBarSubtitle;

  /// Switch: make the first beat louder
  ///
  /// In en, this message translates to:
  /// **'Accent beat 1'**
  String get labelMetronomeAccent;

  /// Subtitle of the accent switch
  ///
  /// In en, this message translates to:
  /// **'Louder, higher click on the first beat'**
  String get descMetronomeAccentSubtitle;

  /// Row that plays a test bar
  ///
  /// In en, this message translates to:
  /// **'Test the sound'**
  String get labelMetronomeTest;

  /// Subtitle of the test row
  ///
  /// In en, this message translates to:
  /// **'Plays one bar at {bpm} BPM. If you hear nothing, raise the media volume.'**
  String descMetronomeTestSubtitle(int bpm);

  /// What the test buttons play: a major chord
  ///
  /// In en, this message translates to:
  /// **'Test plays: Western major chord on {key}'**
  String descDroneSettingsTestWesternMajor(String key);

  /// What the test buttons play: a minor chord
  ///
  /// In en, this message translates to:
  /// **'Test plays: Western minor chord on {key}'**
  String descDroneSettingsTestWesternMinor(String key);

  /// What the test buttons play: a shruti drone; interval is Pa or Ma
  ///
  /// In en, this message translates to:
  /// **'Test plays: Classical drone on {key} + {interval}'**
  String descDroneSettingsTestClassical(String key, String interval);

  /// Section title: how pitches are named
  ///
  /// In en, this message translates to:
  /// **'Pitch naming'**
  String get titleDroneSettingsNaming;

  /// Caption of the Pitch naming section
  ///
  /// In en, this message translates to:
  /// **'Sets how pitches are named, and how a song is treated when it names no raga or tala.'**
  String get descDroneSettingsNamingCaption;

  /// Note when pitch naming is Indian
  ///
  /// In en, this message translates to:
  /// **'Songs with no raga or tala use the Indian songs settings below.'**
  String get descDroneSettingsUsesIndian;

  /// Note when pitch naming is Western
  ///
  /// In en, this message translates to:
  /// **'Songs with no raga or tala use the Western songs settings below.'**
  String get descDroneSettingsUsesWestern;

  /// Section title: settings for Indian songs
  ///
  /// In en, this message translates to:
  /// **'Indian songs'**
  String get titleDroneSettingsIndianSongs;

  /// Caption of the Indian songs section
  ///
  /// In en, this message translates to:
  /// **'Used for songs with a raga or tala. These always play the Classical shruti drone, on your Sa.'**
  String get descDroneSettingsIndianCaption;

  /// Setting: the singer Sa
  ///
  /// In en, this message translates to:
  /// **'Your Sa (Shruti)'**
  String get labelDroneSettingsYourSa;

  /// Subtitle of the Sa setting
  ///
  /// In en, this message translates to:
  /// **'Where your Sa sits: {name}'**
  String descDroneSettingsSaSits(String name);

  /// Setting: the second drone note
  ///
  /// In en, this message translates to:
  /// **'Drone Interval'**
  String get labelDroneSettingsInterval;

  /// Explains the Pa interval
  ///
  /// In en, this message translates to:
  /// **'Sa + Pa (fifth) — the usual shruti box drone'**
  String get descDroneSettingsIntervalPa;

  /// Explains the Ma interval
  ///
  /// In en, this message translates to:
  /// **'Sa + Ma (fourth) — for ragas that leave out Pa'**
  String get descDroneSettingsIntervalMa;

  /// Section title: settings for Western songs
  ///
  /// In en, this message translates to:
  /// **'Western songs'**
  String get titleDroneSettingsWesternSongs;

  /// Caption of the Western songs section
  ///
  /// In en, this message translates to:
  /// **'Used for songs with no raga or tala, when pitch naming is Western.'**
  String get descDroneSettingsWesternCaption;

  /// Setting: key used when a song names none
  ///
  /// In en, this message translates to:
  /// **'Default key'**
  String get labelDroneSettingsDefaultKey;

  /// Subtitle of the Default key setting
  ///
  /// In en, this message translates to:
  /// **'Used when a song names no key: {key}'**
  String descDroneSettingsDefaultKeySubtitle(String key);

  /// Setting: Classical or Western drone
  ///
  /// In en, this message translates to:
  /// **'Default drone mode'**
  String get labelDroneSettingsDefaultMode;

  /// Explains the Classical drone mode
  ///
  /// In en, this message translates to:
  /// **'Classical Shruti drone (Sa + Pa/Ma)'**
  String get descDroneSettingsModeClassicalNote;

  /// Explains the Western drone mode
  ///
  /// In en, this message translates to:
  /// **'Western backing chords (Major / Minor)'**
  String get descDroneSettingsModeWesternNote;

  /// Drone mode choice: Classical
  ///
  /// In en, this message translates to:
  /// **'Classical'**
  String get labelDroneSettingsClassical;

  /// Setting: major or minor chord
  ///
  /// In en, this message translates to:
  /// **'Chord quality'**
  String get labelDroneSettingsDefaultQuality;

  /// Explains the major chord
  ///
  /// In en, this message translates to:
  /// **'Major triad (Root + Major 3rd + 5th)'**
  String get descDroneSettingsMajorNote;

  /// Explains the minor chord
  ///
  /// In en, this message translates to:
  /// **'Minor triad (Root + Minor 3rd + 5th)'**
  String get descDroneSettingsMinorNote;

  /// Why the chord quality setting is greyed out
  ///
  /// In en, this message translates to:
  /// **'Used only when the drone mode above is Western'**
  String get descDroneSettingsQualityOnlyWestern;

  /// Chord quality: major
  ///
  /// In en, this message translates to:
  /// **'Major'**
  String get labelChordQualityMajor;

  /// Chord quality: minor
  ///
  /// In en, this message translates to:
  /// **'Minor'**
  String get labelChordQualityMinor;

  /// Section title: settings for both traditions
  ///
  /// In en, this message translates to:
  /// **'All songs'**
  String get titleDroneSettingsEverything;

  /// Caption of the All songs section
  ///
  /// In en, this message translates to:
  /// **'These affect both traditions.'**
  String get descDroneSettingsEverythingCaption;

  /// Setting: drone volume
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get labelDroneSettingsVolume;

  /// Setting: Stage Mode text size
  ///
  /// In en, this message translates to:
  /// **'Stage Font Scale'**
  String get labelDroneSettingsFontScale;

  /// Subtitle of the Stage Font Scale setting
  ///
  /// In en, this message translates to:
  /// **'Stage mode text zoom: {percent}%'**
  String descDroneSettingsFontScaleSubtitle(int percent);

  /// Section title: test buttons
  ///
  /// In en, this message translates to:
  /// **'Try it out'**
  String get titleDroneSettingsTryIt;

  /// Caption of the Try it out section
  ///
  /// In en, this message translates to:
  /// **'The test uses the settings above.'**
  String get descDroneSettingsTryItCaption;

  /// Button: play a test chord cue
  ///
  /// In en, this message translates to:
  /// **'Test Chord Cue'**
  String get actionDroneSettingsTestChordCue;

  /// Button: play a test pitch cue
  ///
  /// In en, this message translates to:
  /// **'Test Pitch Cue'**
  String get actionDroneSettingsTestPitchCue;

  /// Button: start a test chord drone
  ///
  /// In en, this message translates to:
  /// **'Test Chord Drone'**
  String get actionDroneSettingsTestChordDrone;

  /// Button: start a test drone
  ///
  /// In en, this message translates to:
  /// **'Test Drone'**
  String get actionDroneSettingsTestDrone;

  /// Explains the chord drone
  ///
  /// In en, this message translates to:
  /// **'The chord drone holds one steady Western backing chord for as long as it is on.'**
  String get descDroneSettingsChordDroneNote;

  /// Explains the shruti drone
  ///
  /// In en, this message translates to:
  /// **'The drone holds one steady pair of notes for as long as it is on. It does not follow the tune.'**
  String get descDroneSettingsDroneNote;

  /// App version line on the About screen
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String labelAboutVersion(String version);

  /// Version with build number
  ///
  /// In en, this message translates to:
  /// **'{version} (build {build})'**
  String labelAboutVersionBuild(String version, String build);

  /// Row title: when this build was made
  ///
  /// In en, this message translates to:
  /// **'Build date'**
  String get labelAboutBuildDate;

  /// Row that opens the open source licenses
  ///
  /// In en, this message translates to:
  /// **'Open source licenses'**
  String get labelAboutLicenses;

  /// Title of the Import & Export screen
  ///
  /// In en, this message translates to:
  /// **'Import & Export'**
  String get titleImportExport;

  /// Row: pick ChordPro files to import
  ///
  /// In en, this message translates to:
  /// **'Import ChordPro'**
  String get labelImportExportPickFiles;

  /// Subtitle of the file import row
  ///
  /// In en, this message translates to:
  /// **'Pick one or more .cho, .pro, or text files to add songs.'**
  String get descImportExportPickFilesSubtitle;

  /// Row: receive songs by scanning AirQR codes
  ///
  /// In en, this message translates to:
  /// **'Import via AirQR'**
  String get labelImportExportScan;

  /// Subtitle of the AirQR scan row
  ///
  /// In en, this message translates to:
  /// **'Scan an animated QR song stream from a bandmate\'\'s screen.'**
  String get descImportExportScanSubtitle;

  /// Row: export every song to one ChordPro file
  ///
  /// In en, this message translates to:
  /// **'Export all songs'**
  String get labelImportExportAllChordPro;

  /// Subtitle of the export-all row
  ///
  /// In en, this message translates to:
  /// **'Save your entire songbook as a single ChordPro file.'**
  String get descImportExportAllChordProSubtitle;

  /// Row: send every song as an AirQR stream
  ///
  /// In en, this message translates to:
  /// **'Send all via AirQR'**
  String get labelImportExportAllAirQr;

  /// Subtitle of the AirQR export-all row
  ///
  /// In en, this message translates to:
  /// **'Broadcast entire songbook as an animated QR stream.'**
  String get descImportExportAllAirQrSubtitle;

  /// SnackBar when none of the chosen files has a supported type
  ///
  /// In en, this message translates to:
  /// **'Only .cho, .pro, .chordpro, and .txt files can be imported.'**
  String get errorImportExportWrongType;

  /// SnackBar when no chosen file could be read
  ///
  /// In en, this message translates to:
  /// **'Could not read any chosen files.'**
  String get errorImportExportNothingRead;

  /// Import preview subtitle when several files were chosen
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 file selected} other{{count} files selected}}'**
  String descImportExportFilesSelected(int count);

  /// SnackBar when importing files failed
  ///
  /// In en, this message translates to:
  /// **'Could not import the files.'**
  String get errorImportExportImportFailed;

  /// SnackBar when the songbook is empty on export
  ///
  /// In en, this message translates to:
  /// **'No songs to export.'**
  String get bodyImportExportNoSongsToExport;

  /// Title of the system save dialog for exporting all songs
  ///
  /// In en, this message translates to:
  /// **'Export all songs'**
  String get titleImportExportAllDialog;

  /// SnackBar after all songs were exported
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Exported 1 song.} other{Exported {count} songs.}}'**
  String bodyImportExportExported(int count);

  /// SnackBar when exporting all songs failed
  ///
  /// In en, this message translates to:
  /// **'Could not export songs.'**
  String get errorImportExportExportFailed;

  /// SnackBar when the songbook is empty on AirQR share
  ///
  /// In en, this message translates to:
  /// **'No songs to share.'**
  String get bodyImportExportNoSongsToShare;

  /// AirQR transmitter title when sending the whole songbook
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Songbook (1 song)} other{Songbook ({count} songs)}}'**
  String titleImportExportFullSongbook(int count);

  /// SnackBar when the AirQR export could not start
  ///
  /// In en, this message translates to:
  /// **'Could not prepare AirQR export.'**
  String get errorImportExportAirQrFailed;

  /// Title of the import preview screen
  ///
  /// In en, this message translates to:
  /// **'Import Preview'**
  String get titleImportPreview;

  /// Button: select every song in the file
  ///
  /// In en, this message translates to:
  /// **'Select All'**
  String get actionImportPreviewSelectAll;

  /// Button: clear the selection
  ///
  /// In en, this message translates to:
  /// **'Deselect All'**
  String get actionImportPreviewDeselectAll;

  /// Banner at the top of the import preview
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Found 1 song in file. Select which songs to import to your songbook.} other{Found {count} songs in file. Select which songs to import to your songbook.}}'**
  String descImportPreviewFound(int count);

  /// Shown when the file has no songs
  ///
  /// In en, this message translates to:
  /// **'No valid songs found in this file.'**
  String get emptyImportPreviewNoSongs;

  /// Badge on a song whose title is already in the songbook
  ///
  /// In en, this message translates to:
  /// **'In Songbook'**
  String get labelImportPreviewInSongbook;

  /// Chip in the song preview when the title is already in the songbook
  ///
  /// In en, this message translates to:
  /// **'Already in Songbook'**
  String get labelImportPreviewAlreadyInSongbook;

  /// Key chip in the song preview
  ///
  /// In en, this message translates to:
  /// **'Key: {key}'**
  String labelImportPreviewKey(String key);

  /// Button that opens a song preview
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get actionImportPreviewPreview;

  /// Import button text while importing
  ///
  /// In en, this message translates to:
  /// **'Importing...'**
  String get actionImportPreviewImporting;

  /// Import button with the number of chosen songs
  ///
  /// In en, this message translates to:
  /// **'Import ({count})'**
  String actionImportPreviewImportSelected(int count);

  /// SnackBar after one song was imported
  ///
  /// In en, this message translates to:
  /// **'Imported \"{title}\".'**
  String bodyImportPreviewImportedOne(String title);

  /// SnackBar after several songs were imported
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Imported 1 song.} other{Imported {count} songs.}}'**
  String bodyImportPreviewImportedMany(int count);

  /// SnackBar when import failed; reason is technical detail
  ///
  /// In en, this message translates to:
  /// **'Import failed: {reason}'**
  String errorImportPreviewFailed(String reason);

  /// Title of the AirQR receiver screen
  ///
  /// In en, this message translates to:
  /// **'AirQR Song Receiver'**
  String get titleAirQrReceiver;

  /// Tooltip: scan an AirQR code from a photo
  ///
  /// In en, this message translates to:
  /// **'Scan a photo'**
  String get tooltipAirQrReceiverGallery;

  /// Tooltip: clear the received blocks
  ///
  /// In en, this message translates to:
  /// **'Reset Stream'**
  String get tooltipAirQrReceiverResetStream;

  /// SnackBar when a photo has no AirQR code
  ///
  /// In en, this message translates to:
  /// **'No AirQR code detected in chosen photo.'**
  String get errorAirQrReceiverNoCode;

  /// SnackBar when a photo could not be scanned
  ///
  /// In en, this message translates to:
  /// **'Could not scan photo.'**
  String get errorAirQrReceiverPhotoFailed;

  /// Shown while the camera starts or cannot start
  ///
  /// In en, this message translates to:
  /// **'Initializing AirQR Camera Receiver...'**
  String get descAirQrReceiverStarting;

  /// Name shown in the import preview for songs received by AirQR
  ///
  /// In en, this message translates to:
  /// **'AirQR Stream Share'**
  String get labelAirQrReceiverFileName;

  /// AirQR status when every block arrived
  ///
  /// In en, this message translates to:
  /// **'STREAM REASSEMBLED - OPENING PREVIEW...'**
  String get descAirQrHudReassembled;

  /// AirQR status while blocks arrive
  ///
  /// In en, this message translates to:
  /// **'RECEIVING AIRQR SONG STREAM...'**
  String get descAirQrHudReceiving;

  /// AirQR status before any block arrived
  ///
  /// In en, this message translates to:
  /// **'POINT AT ANIMATED QR CODE STREAM'**
  String get descAirQrHudPointAt;

  /// How many AirQR blocks arrived
  ///
  /// In en, this message translates to:
  /// **'Captured: {received} / {total} Blocks'**
  String descAirQrHudCaptured(int received, int total);

  /// How many AirQR blocks are still missing
  ///
  /// In en, this message translates to:
  /// **'Missing: {count}'**
  String labelAirQrHudMissing(int count);

  /// Title of the AirQR sending screen
  ///
  /// In en, this message translates to:
  /// **'AirQR Share: {title}'**
  String titleAirQrTransmitter(String title);

  /// Size of the AirQR stream
  ///
  /// In en, this message translates to:
  /// **'{bytes} bytes • {frames} Optical Frames'**
  String descAirQrTransmitterSize(int bytes, int frames);

  /// Label of the frames-per-second slider
  ///
  /// In en, this message translates to:
  /// **'Stream Speed:'**
  String get labelAirQrTransmitterSpeed;

  /// Button: pause the QR animation
  ///
  /// In en, this message translates to:
  /// **'Pause stream'**
  String get actionAirQrTransmitterPause;

  /// Button: resume the QR animation
  ///
  /// In en, this message translates to:
  /// **'Resume stream'**
  String get actionAirQrTransmitterResume;

  /// Shown when there is nothing to send
  ///
  /// In en, this message translates to:
  /// **'No frames generated'**
  String get emptyAirQrTransmitterNoFrames;

  /// Label of a repair (parity) frame
  ///
  /// In en, this message translates to:
  /// **'Frame {index}/{total} • Fountain FEC'**
  String descAirQrTransmitterParityFrame(int index, int total);

  /// Label of a data frame
  ///
  /// In en, this message translates to:
  /// **'Frame {index}/{total} • Block {block}'**
  String descAirQrTransmitterBlockFrame(int index, int total, int block);

  /// Hint under the AirQR code
  ///
  /// In en, this message translates to:
  /// **'Point receiving phone camera at this screen.\nNo internet, Bluetooth, or Wi-Fi required.'**
  String get descAirQrTransmitterHint;

  /// Help › topic title (songbook)
  ///
  /// In en, this message translates to:
  /// **'Your songbook'**
  String get titleHelpSongbook;

  /// Help › Your songbook › one-line summary on the hub card
  ///
  /// In en, this message translates to:
  /// **'Find, star, copy and remove songs'**
  String get helpSongbookSummary;

  /// Help › Your songbook › opening paragraph
  ///
  /// In en, this message translates to:
  /// **'The home screen is your songbook. It has two tabs — Songs and Setlists. The Songs tab holds everything you have written or brought in, with the most recently changed song at the top.'**
  String get helpSongbookIntro;

  /// Help › Your songbook › section heading
  ///
  /// In en, this message translates to:
  /// **'Add a song'**
  String get helpSongbookS1Heading;

  /// Help › Your songbook › Add a song — point 1
  ///
  /// In en, this message translates to:
  /// **'Tap the + button at the bottom right to write a new one.'**
  String get helpSongbookS1P1;

  /// Help › Your songbook › Add a song — point 2
  ///
  /// In en, this message translates to:
  /// **'Or bring songs in from a file — see the Import topic.'**
  String get helpSongbookS1P2;

  /// Help › Your songbook › Add a song — point 3
  ///
  /// In en, this message translates to:
  /// **'A new install already has three sample songs and one setlist, so you can try everything before typing anything.'**
  String get helpSongbookS1P3;

  /// Help › Your songbook › section heading
  ///
  /// In en, this message translates to:
  /// **'Find a song'**
  String get helpSongbookS2Heading;

  /// Help › Your songbook › Find a song — point 1
  ///
  /// In en, this message translates to:
  /// **'Type in the search box at the top. It looks in the title, the artist and the words, so half a remembered line is enough.'**
  String get helpSongbookS2P1;

  /// Help › Your songbook › Find a song — point 2
  ///
  /// In en, this message translates to:
  /// **'Tap the X in the box to clear the search.'**
  String get helpSongbookS2P2;

  /// Help › Your songbook › Find a song — point 3
  ///
  /// In en, this message translates to:
  /// **'Below it are two chips, \"All Songs\" and \"Starred\", each with a count of how many songs it holds.'**
  String get helpSongbookS2P3;

  /// Help › Your songbook › Find a song — point 4
  ///
  /// In en, this message translates to:
  /// **'Tap the star on a song to put it in Starred. Tap it again to take it out.'**
  String get helpSongbookS2P4;

  /// Help › Your songbook › section heading
  ///
  /// In en, this message translates to:
  /// **'What a song card shows'**
  String get helpSongbookS3Heading;

  /// Help › Your songbook › What a song card shows — point 1
  ///
  /// In en, this message translates to:
  /// **'The title and the artist.'**
  String get helpSongbookS3P1;

  /// Help › Your songbook › What a song card shows — point 2
  ///
  /// In en, this message translates to:
  /// **'The key, such as C or Am, and the tempo, such as 120 BPM, when the song has them.'**
  String get helpSongbookS3P2;

  /// Help › Your songbook › What a song card shows — point 3
  ///
  /// In en, this message translates to:
  /// **'A star, a copy button and a delete button.'**
  String get helpSongbookS3P3;

  /// Help › Your songbook › section heading
  ///
  /// In en, this message translates to:
  /// **'Copy or delete one song'**
  String get helpSongbookS4Heading;

  /// Help › Your songbook › Copy or delete one song — point 1
  ///
  /// In en, this message translates to:
  /// **'Copy makes a second, separate song named \"<Title> (Copy)\". Handy for a different arrangement of the same song.'**
  String get helpSongbookS4P1;

  /// Help › Your songbook › Copy or delete one song — point 2
  ///
  /// In en, this message translates to:
  /// **'Delete asks first, then takes the song out of your library and out of every setlist that held it.'**
  String get helpSongbookS4P2;

  /// Help › Your songbook › Copy or delete one song — point 3
  ///
  /// In en, this message translates to:
  /// **'To act on several songs at once, see the Select Songs topic.'**
  String get helpSongbookS4P3;

  /// Help › Your songbook › section heading
  ///
  /// In en, this message translates to:
  /// **'On a tablet'**
  String get helpSongbookS5Heading;

  /// Help › Your songbook › On a tablet — point 1
  ///
  /// In en, this message translates to:
  /// **'A wide screen shows the list on the left and the song on the right, so picking a song does not hide the list.'**
  String get helpSongbookS5P1;

  /// Help › Your songbook › On a tablet — point 2
  ///
  /// In en, this message translates to:
  /// **'Full screen is not offered in that right-hand half, because it would fill only that half and not the whole screen.'**
  String get helpSongbookS5P2;

  /// Help › topic title (editor)
  ///
  /// In en, this message translates to:
  /// **'Write a song'**
  String get titleHelpEditor;

  /// Help › Write a song › one-line summary on the hub card
  ///
  /// In en, this message translates to:
  /// **'Type the words, put chords over them, save'**
  String get helpEditorSummary;

  /// Help › Write a song › opening paragraph
  ///
  /// In en, this message translates to:
  /// **'The editor is one plain box for the words, with a few fields above it for the title, artist, key and tempo. Chords go inside the words in square brackets.'**
  String get helpEditorIntro;

  /// Help › Write a song › section heading
  ///
  /// In en, this message translates to:
  /// **'Chords in the words'**
  String get helpEditorS1Heading;

  /// Help › Write a song › Chords in the words — point 1
  ///
  /// In en, this message translates to:
  /// **'Put the chord in square brackets right before the syllable it falls on: [G]Amazing [C]grace.'**
  String get helpEditorS1P1;

  /// Help › Write a song › Chords in the words — point 2
  ///
  /// In en, this message translates to:
  /// **'On the song screen that chord is drawn floating above the syllable. The brackets are never shown.'**
  String get helpEditorS1P2;

  /// Help › Write a song › Chords in the words — point 3
  ///
  /// In en, this message translates to:
  /// **'This is standard ChordPro, so a file written in another app reads the same way here.'**
  String get helpEditorS1P3;

  /// Help › Write a song › section heading
  ///
  /// In en, this message translates to:
  /// **'The chord bar above the keyboard'**
  String get helpEditorS2Heading;

  /// Help › Write a song › The chord bar above the keyboard — point 1
  ///
  /// In en, this message translates to:
  /// **'While you are typing the words, a row of chord buttons sits just above the keyboard.'**
  String get helpEditorS2P1;

  /// Help › Write a song › The chord bar above the keyboard — point 2
  ///
  /// In en, this message translates to:
  /// **'The chords offered are the ones that usually belong to the key you picked — I, ii, iii, IV, V, vi and so on.'**
  String get helpEditorS2P2;

  /// Help › Write a song › The chord bar above the keyboard — point 3
  ///
  /// In en, this message translates to:
  /// **'Tap one and it goes in at the cursor, brackets and all.'**
  String get helpEditorS2P3;

  /// Help › Write a song › The chord bar above the keyboard — point 4
  ///
  /// In en, this message translates to:
  /// **'If the key is blank or cannot be read, the bar quietly falls back to the key of C rather than showing nothing.'**
  String get helpEditorS2P4;

  /// Help › Write a song › The chord bar above the keyboard — point 5
  ///
  /// In en, this message translates to:
  /// **'Your own chords come after those. Tap \"Custom\" to add one on the spot, or keep the whole list in Settings → Chords.'**
  String get helpEditorS2P5;

  /// Help › Write a song › The chord bar above the keyboard — point 6
  ///
  /// In en, this message translates to:
  /// **'A custom chord can be up to 12 characters, and the same one is never stored twice.'**
  String get helpEditorS2P6;

  /// Help › Write a song › section heading
  ///
  /// In en, this message translates to:
  /// **'The fields at the top'**
  String get helpEditorS3Heading;

  /// Help › Write a song › The fields at the top — point 1
  ///
  /// In en, this message translates to:
  /// **'Title, and Artist / Band.'**
  String get helpEditorS3P1;

  /// Help › Write a song › The fields at the top — point 2
  ///
  /// In en, this message translates to:
  /// **'Notation: Western, Carnatic or Hindustani. Western shows an \"Original key\" box; either Indian choice replaces it with Raga and Tala — see the Carnatic & Hindustani topic.'**
  String get helpEditorS3P2;

  /// Help › Write a song › The fields at the top — point 3
  ///
  /// In en, this message translates to:
  /// **'Tempo (BPM) drives the metronome and the Tempo auto-scroll.'**
  String get helpEditorS3P3;

  /// Help › Write a song › The fields at the top — point 4
  ///
  /// In en, this message translates to:
  /// **'\"Add to setlist\" drops the song into a setlist as you save it.'**
  String get helpEditorS3P4;

  /// Help › Write a song › The fields at the top — point 5
  ///
  /// In en, this message translates to:
  /// **'The fields fold into a one-line summary as soon as you tap into the words, so the words get the screen. Tap the summary to open them again.'**
  String get helpEditorS3P5;

  /// Help › Write a song › section heading
  ///
  /// In en, this message translates to:
  /// **'Undo, save and copy'**
  String get helpEditorS4Heading;

  /// Help › Write a song › Undo, save and copy — point 1
  ///
  /// In en, this message translates to:
  /// **'The undo and redo arrows in the top bar step back and forward through your typing.'**
  String get helpEditorS4P1;

  /// Help › Write a song › Undo, save and copy — point 2
  ///
  /// In en, this message translates to:
  /// **'Save keeps the song and closes the editor.'**
  String get helpEditorS4P2;

  /// Help › Write a song › Undo, save and copy — point 3
  ///
  /// In en, this message translates to:
  /// **'More options → \"Save as copy\" saves what is on screen right now, including edits you have not saved yet, as a brand-new song. The original is left as it was.'**
  String get helpEditorS4P3;

  /// Help › Write a song › Undo, save and copy — point 4
  ///
  /// In en, this message translates to:
  /// **'Leaving with unsaved edits asks first, so a stray back gesture cannot throw your work away. With nothing changed it just closes.'**
  String get helpEditorS4P4;

  /// Help › Write a song › section heading
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get helpEditorS5Heading;

  /// Help › Write a song › More options — point 1
  ///
  /// In en, this message translates to:
  /// **'Melody keypad — tap out a tune instead of typing it. See the Melody Lines topic.'**
  String get helpEditorS5P1;

  /// Help › Write a song › More options — point 2
  ///
  /// In en, this message translates to:
  /// **'Paste Carnatic — turn a block of published notation into melody lines. See the Indian songs topic.'**
  String get helpEditorS5P2;

  /// Help › topic title (setlists)
  ///
  /// In en, this message translates to:
  /// **'Setlists'**
  String get titleHelpSetlists;

  /// Help › Setlists › one-line summary on the hub card
  ///
  /// In en, this message translates to:
  /// **'Group and order songs for a gig or rehearsal'**
  String get helpSetlistsSummary;

  /// Help › Setlists › opening paragraph
  ///
  /// In en, this message translates to:
  /// **'A setlist is an ordered group of songs you can play through in one go, without hunting for each song. Setlists never make copies — they just point to songs already in your library.'**
  String get helpSetlistsIntro;

  /// Help › Setlists › section heading
  ///
  /// In en, this message translates to:
  /// **'Create a setlist'**
  String get helpSetlistsS1Heading;

  /// Help › Setlists › Create a setlist — point 1
  ///
  /// In en, this message translates to:
  /// **'Open the \"Setlists\" tab on the home screen.'**
  String get helpSetlistsS1P1;

  /// Help › Setlists › Create a setlist — point 2
  ///
  /// In en, this message translates to:
  /// **'Tap \"New Setlist\".'**
  String get helpSetlistsS1P2;

  /// Help › Setlists › Create a setlist — point 3
  ///
  /// In en, this message translates to:
  /// **'Give it a name, and an optional description.'**
  String get helpSetlistsS1P3;

  /// Help › Setlists › section heading
  ///
  /// In en, this message translates to:
  /// **'Add and arrange songs'**
  String get helpSetlistsS2Heading;

  /// Help › Setlists › Add and arrange songs — point 1
  ///
  /// In en, this message translates to:
  /// **'Inside a setlist, tap \"Add Songs\" to pick from your library.'**
  String get helpSetlistsS2P1;

  /// Help › Setlists › Add and arrange songs — point 2
  ///
  /// In en, this message translates to:
  /// **'Drag the handle on the right to change the order.'**
  String get helpSetlistsS2P2;

  /// Help › Setlists › Add and arrange songs — point 3
  ///
  /// In en, this message translates to:
  /// **'Tap the red minus to take a song out of the setlist.'**
  String get helpSetlistsS2P3;

  /// Help › Setlists › Add and arrange songs — point 4
  ///
  /// In en, this message translates to:
  /// **'Removing a song from a setlist does not delete it from your library.'**
  String get helpSetlistsS2P4;

  /// Help › Setlists › section heading
  ///
  /// In en, this message translates to:
  /// **'Perform a setlist'**
  String get helpSetlistsS3Heading;

  /// Help › Setlists › Perform a setlist — point 1
  ///
  /// In en, this message translates to:
  /// **'Tap \"Perform Setlist\" to start from the first song.'**
  String get helpSetlistsS3P1;

  /// Help › Setlists › Perform a setlist — point 2
  ///
  /// In en, this message translates to:
  /// **'Or tap any song in the list to start from there.'**
  String get helpSetlistsS3P2;

  /// Help › Setlists › Perform a setlist — point 3
  ///
  /// In en, this message translates to:
  /// **'While performing, move between songs in the setlist order.'**
  String get helpSetlistsS3P3;

  /// Help › Setlists › section heading
  ///
  /// In en, this message translates to:
  /// **'Delete a setlist'**
  String get helpSetlistsS4Heading;

  /// Help › Setlists › Delete a setlist — point 1
  ///
  /// In en, this message translates to:
  /// **'Open the setlist and use the delete (trash) icon in the top bar.'**
  String get helpSetlistsS4P1;

  /// Help › Setlists › Delete a setlist — point 2
  ///
  /// In en, this message translates to:
  /// **'This removes only the setlist. The songs stay in your library.'**
  String get helpSetlistsS4P2;

  /// Help › topic title (transpose)
  ///
  /// In en, this message translates to:
  /// **'Transpose & chords'**
  String get titleHelpTranspose;

  /// Help › Transpose & chords › one-line summary on the hub card
  ///
  /// In en, this message translates to:
  /// **'Change the key, hide chords, see the shapes'**
  String get helpTransposeSummary;

  /// Help › Transpose & chords › opening paragraph
  ///
  /// In en, this message translates to:
  /// **'Transposing moves every chord in the song up or down by the same amount, so you can play in a key that suits the singer without rewriting anything.'**
  String get helpTransposeIntro;

  /// Help › Transpose & chords › section heading
  ///
  /// In en, this message translates to:
  /// **'Change the key'**
  String get helpTransposeS1Heading;

  /// Help › Transpose & chords › Change the key — point 1
  ///
  /// In en, this message translates to:
  /// **'Open the song, then the top-bar menu (More options) → \"Performance controls\".'**
  String get helpTransposeS1P1;

  /// Help › Transpose & chords › Change the key — point 2
  ///
  /// In en, this message translates to:
  /// **'Use - and + to move down or up one semitone at a time.'**
  String get helpTransposeS1P2;

  /// Help › Transpose & chords › Change the key — point 3
  ///
  /// In en, this message translates to:
  /// **'The key the sheet now sounds in is shown between the two buttons.'**
  String get helpTransposeS1P3;

  /// Help › Transpose & chords › Change the key — point 4
  ///
  /// In en, this message translates to:
  /// **'The line under the controls row says how far you have moved, like \"Key A (+2)\".'**
  String get helpTransposeS1P4;

  /// Help › Transpose & chords › Change the key — point 5
  ///
  /// In en, this message translates to:
  /// **'\"Reset\" puts the song back to its written key.'**
  String get helpTransposeS1P5;

  /// Help › Transpose & chords › Change the key — point 6
  ///
  /// In en, this message translates to:
  /// **'The range is 11 semitones down to 11 semitones up. A full 12 would only land on the same key again.'**
  String get helpTransposeS1P6;

  /// Help › Transpose & chords › section heading
  ///
  /// In en, this message translates to:
  /// **'What it changes'**
  String get helpTransposeS2Heading;

  /// Help › Transpose & chords › What it changes — point 1
  ///
  /// In en, this message translates to:
  /// **'Slash chords move too: C/E shifted up 2 becomes D/F#.'**
  String get helpTransposeS2P1;

  /// Help › Transpose & chords › What it changes — point 2
  ///
  /// In en, this message translates to:
  /// **'Sharps or flats are chosen to suit the new key, so you get Bb and not A#.'**
  String get helpTransposeS2P2;

  /// Help › Transpose & chords › What it changes — point 3
  ///
  /// In en, this message translates to:
  /// **'The change belongs to this sheet only — it is never written back into the song.'**
  String get helpTransposeS2P3;

  /// Help › Transpose & chords › What it changes — point 4
  ///
  /// In en, this message translates to:
  /// **'Export and Share simply use the key you are looking at, so a transposed song goes out transposed.'**
  String get helpTransposeS2P4;

  /// Help › Transpose & chords › What it changes — point 5
  ///
  /// In en, this message translates to:
  /// **'A Carnatic or Hindustani song has no transpose control, because swaras are named relative to Sa and do not move.'**
  String get helpTransposeS2P5;

  /// Help › Transpose & chords › section heading
  ///
  /// In en, this message translates to:
  /// **'Hide the chords'**
  String get helpTransposeS3Heading;

  /// Help › Transpose & chords › Hide the chords — point 1
  ///
  /// In en, this message translates to:
  /// **'The same Performance controls sheet has a \"Show chords\" switch.'**
  String get helpTransposeS3P1;

  /// Help › Transpose & chords › Hide the chords — point 2
  ///
  /// In en, this message translates to:
  /// **'Turning it off leaves clean words only, which is usually what a singer wants.'**
  String get helpTransposeS3P2;

  /// Help › Transpose & chords › Hide the chords — point 3
  ///
  /// In en, this message translates to:
  /// **'The music note button in the row above the song does the same in one tap.'**
  String get helpTransposeS3P3;

  /// Help › Transpose & chords › section heading
  ///
  /// In en, this message translates to:
  /// **'Chord Reference'**
  String get helpTransposeS4Heading;

  /// Help › Transpose & chords › Chord Reference — point 1
  ///
  /// In en, this message translates to:
  /// **'Top-bar menu → \"Chord Reference\" lists every chord used in the song, already moved to the key you are playing in.'**
  String get helpTransposeS4P1;

  /// Help › Transpose & chords › Chord Reference — point 2
  ///
  /// In en, this message translates to:
  /// **'Each chord is drawn two ways: a six-string guitar fretboard with finger dots and O and X marks for open and muted strings, and a harmonium or piano keyboard with the notes lit up.'**
  String get helpTransposeS4P2;

  /// Help › Transpose & chords › Chord Reference — point 3
  ///
  /// In en, this message translates to:
  /// **'The root note is one colour; the bass note of a slash chord, such as the E in C/E, is another.'**
  String get helpTransposeS4P3;

  /// Help › Transpose & chords › Chord Reference — point 4
  ///
  /// In en, this message translates to:
  /// **'It knows the common open shapes and works out movable barre shapes for everything else.'**
  String get helpTransposeS4P4;

  /// Help › Transpose & chords › Chord Reference — point 5
  ///
  /// In en, this message translates to:
  /// **'On a Carnatic or Hindustani song this becomes \"Swara Reference\" and shows where each swara sits on the keyboard, low to high, instead of chord shapes.'**
  String get helpTransposeS4P5;

  /// Help › topic title (auto-scroll)
  ///
  /// In en, this message translates to:
  /// **'Auto-scroll'**
  String get titleHelpAutoScroll;

  /// Help › Auto-scroll › one-line summary on the hub card
  ///
  /// In en, this message translates to:
  /// **'Scroll the sheet hands-free while you play'**
  String get helpAutoScrollSummary;

  /// Help › Auto-scroll › opening paragraph
  ///
  /// In en, this message translates to:
  /// **'Auto-scroll moves the chord sheet up for you while you perform, so you do not have to touch the screen. There are two modes: Manual and Tempo.'**
  String get helpAutoScrollIntro;

  /// Help › Auto-scroll › section heading
  ///
  /// In en, this message translates to:
  /// **'Two modes'**
  String get helpAutoScrollS1Heading;

  /// Help › Auto-scroll › Two modes — point 1
  ///
  /// In en, this message translates to:
  /// **'Manual scrolls at a steady speed you set yourself, from 0.10x up to 2.00x. Change it by double-tapping the sheet; each tap changes it by 0.05x.'**
  String get helpAutoScrollS1P1;

  /// Help › Auto-scroll › Two modes — point 2
  ///
  /// In en, this message translates to:
  /// **'A song remembers the speed you set for it. A song you have never set a speed for opens at the starting speed in Settings → General → Auto-scroll.'**
  String get helpAutoScrollS1P2;

  /// Help › Auto-scroll › Two modes — point 3
  ///
  /// In en, this message translates to:
  /// **'Tempo works out how long the song lasts and paces the scroll to finish exactly at the end of the song.'**
  String get helpAutoScrollS1P3;

  /// Help › Auto-scroll › section heading
  ///
  /// In en, this message translates to:
  /// **'What \"bars\" means'**
  String get helpAutoScrollS2Heading;

  /// Help › Auto-scroll › What "bars" means — point 1
  ///
  /// In en, this message translates to:
  /// **'A bar (also called a measure) is a musical unit of time.'**
  String get helpAutoScrollS2P1;

  /// Help › Auto-scroll › What "bars" means — point 2
  ///
  /// In en, this message translates to:
  /// **'A song that names no tala uses common 4/4 time, so one bar is 4 beats.'**
  String get helpAutoScrollS2P2;

  /// Help › Auto-scroll › What "bars" means — point 3
  ///
  /// In en, this message translates to:
  /// **'A song with a \'{tala}\' line counts that tala\'\'s own beats instead, so a misra chapu song has 7 beats to the bar.'**
  String get helpAutoScrollS2P3;

  /// Help › Auto-scroll › What "bars" means — point 4
  ///
  /// In en, this message translates to:
  /// **'Songs open at 32 bars. Change the count by double-tapping the sheet — each double-tap adds or removes 4 bars.'**
  String get helpAutoScrollS2P4;

  /// Help › Auto-scroll › What "bars" means — point 5
  ///
  /// In en, this message translates to:
  /// **'The count can go from 1 bar up to 512.'**
  String get helpAutoScrollS2P5;

  /// Help › Auto-scroll › section heading
  ///
  /// In en, this message translates to:
  /// **'How Tempo sets the speed'**
  String get helpAutoScrollS3Heading;

  /// Help › Auto-scroll › How Tempo sets the speed — point 1
  ///
  /// In en, this message translates to:
  /// **'Song length comes from the bars and the song\'\'s BPM: bars x 4 beats, at the BPM you set.'**
  String get helpAutoScrollS3P1;

  /// Help › Auto-scroll › How Tempo sets the speed — point 2
  ///
  /// In en, this message translates to:
  /// **'More bars or a slower BPM makes a longer, slower scroll.'**
  String get helpAutoScrollS3P2;

  /// Help › Auto-scroll › How Tempo sets the speed — point 3
  ///
  /// In en, this message translates to:
  /// **'A higher BPM makes a shorter, faster scroll.'**
  String get helpAutoScrollS3P3;

  /// Help › Auto-scroll › How Tempo sets the speed — point 4
  ///
  /// In en, this message translates to:
  /// **'The status line shows the bars and the computed length, like \"32 bars · 1:04\".'**
  String get helpAutoScrollS3P4;

  /// Help › Auto-scroll › section heading
  ///
  /// In en, this message translates to:
  /// **'Changing the speed by tapping'**
  String get helpAutoScrollS4Heading;

  /// Help › Auto-scroll › Changing the speed by tapping — gesture 1 name
  ///
  /// In en, this message translates to:
  /// **'Double-tap up top'**
  String get helpAutoScrollS4G1Title;

  /// Help › Auto-scroll › Changing the speed by tapping — what gesture 1 does
  ///
  /// In en, this message translates to:
  /// **'Faster'**
  String get helpAutoScrollS4G1Description;

  /// Help › Auto-scroll › Changing the speed by tapping — gesture 2 name
  ///
  /// In en, this message translates to:
  /// **'Double-tap down low'**
  String get helpAutoScrollS4G2Title;

  /// Help › Auto-scroll › Changing the speed by tapping — what gesture 2 does
  ///
  /// In en, this message translates to:
  /// **'Slower'**
  String get helpAutoScrollS4G2Description;

  /// Help › Auto-scroll › Changing the speed by tapping — gesture 3 name
  ///
  /// In en, this message translates to:
  /// **'Tap with two fingers'**
  String get helpAutoScrollS4G3Title;

  /// Help › Auto-scroll › Changing the speed by tapping — what gesture 3 does
  ///
  /// In en, this message translates to:
  /// **'Play or pause'**
  String get helpAutoScrollS4G3Description;

  /// Help › Auto-scroll › Changing the speed by tapping — point 1
  ///
  /// In en, this message translates to:
  /// **'The same taps work here and in full screen, so there is only one thing to remember.'**
  String get helpAutoScrollS4P1;

  /// Help › Auto-scroll › Changing the speed by tapping — point 2
  ///
  /// In en, this message translates to:
  /// **'In Tempo mode the same double-taps add or remove bars instead.'**
  String get helpAutoScrollS4P2;

  /// Help › Auto-scroll › Changing the speed by tapping — point 3
  ///
  /// In en, this message translates to:
  /// **'The new value flashes big in the middle of the screen, so you can read it from a stand.'**
  String get helpAutoScrollS4P3;

  /// Help › Auto-scroll › Changing the speed by tapping — point 4
  ///
  /// In en, this message translates to:
  /// **'This speed is only used while auto-scroll is playing. It never changes how the sheet moves when you drag it with a finger.'**
  String get helpAutoScrollS4P4;

  /// Help › Auto-scroll › Changing the speed by tapping — point 5
  ///
  /// In en, this message translates to:
  /// **'One finger still scrolls and two fingers still pinch to change the text size.'**
  String get helpAutoScrollS4P5;

  /// Help › Auto-scroll › section heading
  ///
  /// In en, this message translates to:
  /// **'Start and stop'**
  String get helpAutoScrollS5Heading;

  /// Help › Auto-scroll › Start and stop — point 1
  ///
  /// In en, this message translates to:
  /// **'Tap the sheet with two fingers to start and stop the scroll. There is no play button on this screen any more.'**
  String get helpAutoScrollS5P1;

  /// Help › Auto-scroll › Start and stop — point 2
  ///
  /// In en, this message translates to:
  /// **'In full screen the control bar still has a play button as well.'**
  String get helpAutoScrollS5P2;

  /// Help › Auto-scroll › Start and stop — point 3
  ///
  /// In en, this message translates to:
  /// **'In Tempo mode the scroll stops on its own at the end of the song.'**
  String get helpAutoScrollS5P3;

  /// Help › Auto-scroll › section heading
  ///
  /// In en, this message translates to:
  /// **'Moving the sheet by hand'**
  String get helpAutoScrollS6Heading;

  /// Help › Auto-scroll › Moving the sheet by hand — point 1
  ///
  /// In en, this message translates to:
  /// **'You can drag the sheet with one finger at any time, even while auto-scroll is playing.'**
  String get helpAutoScrollS6P1;

  /// Help › Auto-scroll › Moving the sheet by hand — point 2
  ///
  /// In en, this message translates to:
  /// **'Auto-scroll waits while your finger is down and carries on from wherever you let go, so you never have to stop and start again to fix your place.'**
  String get helpAutoScrollS6P2;

  /// Help › Auto-scroll › Moving the sheet by hand — point 3
  ///
  /// In en, this message translates to:
  /// **'A fast flick stops where you lift your finger rather than coasting on, because auto-scroll takes over again straight away.'**
  String get helpAutoScrollS6P3;

  /// Help › Auto-scroll › section heading
  ///
  /// In en, this message translates to:
  /// **'The row above the song'**
  String get helpAutoScrollS7Heading;

  /// Help › Auto-scroll › The row above the song — point 1
  ///
  /// In en, this message translates to:
  /// **'M and T pick the mode; the arrows icon goes full screen.'**
  String get helpAutoScrollS7P1;

  /// Help › Auto-scroll › The row above the song — point 2
  ///
  /// In en, this message translates to:
  /// **'The speed, such as \"0.40x\", is shown on the right in Manual mode. It is a read-out — double-tap the sheet to change it.'**
  String get helpAutoScrollS7P2;

  /// Help › Auto-scroll › The row above the song — point 3
  ///
  /// In en, this message translates to:
  /// **'The music note icon hides and shows the chords.'**
  String get helpAutoScrollS7P3;

  /// Help › Auto-scroll › The row above the song — point 4
  ///
  /// In en, this message translates to:
  /// **'The piano icon hides and shows the melody rows. It is only there for a song that has a tune written in it.'**
  String get helpAutoScrollS7P4;

  /// Help › topic title (full-screen)
  ///
  /// In en, this message translates to:
  /// **'Full screen'**
  String get titleHelpFullScreen;

  /// Help › Full screen › one-line summary on the hub card
  ///
  /// In en, this message translates to:
  /// **'Just the words, controlled by taps'**
  String get helpFullScreenSummary;

  /// Help › Full screen › opening paragraph
  ///
  /// In en, this message translates to:
  /// **'Full screen hides the top bar and the phone\'\'s own bars, so the song fills the whole screen. It is made for playing live, where you look at the screen from a stand and touch it as little as possible.'**
  String get helpFullScreenIntro;

  /// Help › Full screen › section heading
  ///
  /// In en, this message translates to:
  /// **'Going full screen'**
  String get helpFullScreenS1Heading;

  /// Help › Full screen › Going full screen — point 1
  ///
  /// In en, this message translates to:
  /// **'Tap the full screen button in the auto-scroll row.'**
  String get helpFullScreenS1P1;

  /// Help › Full screen › Going full screen — point 2
  ///
  /// In en, this message translates to:
  /// **'The song, the key, the text size and the scroll position all stay as they were.'**
  String get helpFullScreenS1P2;

  /// Help › Full screen › Going full screen — point 3
  ///
  /// In en, this message translates to:
  /// **'The screen still stays awake, as it does in the normal song view.'**
  String get helpFullScreenS1P3;

  /// Help › Full screen › section heading
  ///
  /// In en, this message translates to:
  /// **'The gestures'**
  String get helpFullScreenS2Heading;

  /// Help › Full screen › The gestures — gesture 1 name
  ///
  /// In en, this message translates to:
  /// **'Tap once'**
  String get helpFullScreenS2G1Title;

  /// Help › Full screen › The gestures — what gesture 1 does
  ///
  /// In en, this message translates to:
  /// **'Show or hide the controls'**
  String get helpFullScreenS2G1Description;

  /// Help › Full screen › The gestures — gesture 2 name
  ///
  /// In en, this message translates to:
  /// **'Double-tap up top'**
  String get helpFullScreenS2G2Title;

  /// Help › Full screen › The gestures — what gesture 2 does
  ///
  /// In en, this message translates to:
  /// **'Faster'**
  String get helpFullScreenS2G2Description;

  /// Help › Full screen › The gestures — gesture 3 name
  ///
  /// In en, this message translates to:
  /// **'Double-tap down low'**
  String get helpFullScreenS2G3Title;

  /// Help › Full screen › The gestures — what gesture 3 does
  ///
  /// In en, this message translates to:
  /// **'Slower'**
  String get helpFullScreenS2G3Description;

  /// Help › Full screen › The gestures — gesture 4 name
  ///
  /// In en, this message translates to:
  /// **'Tap with two fingers'**
  String get helpFullScreenS2G4Title;

  /// Help › Full screen › The gestures — what gesture 4 does
  ///
  /// In en, this message translates to:
  /// **'Play or pause'**
  String get helpFullScreenS2G4Description;

  /// Help › Full screen › The gestures — gesture 5 name
  ///
  /// In en, this message translates to:
  /// **'Pinch'**
  String get helpFullScreenS2G5Title;

  /// Help › Full screen › The gestures — what gesture 5 does
  ///
  /// In en, this message translates to:
  /// **'Change the text size'**
  String get helpFullScreenS2G5Description;

  /// Help › Full screen › The gestures — gesture 6 name
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get helpFullScreenS2G6Title;

  /// Help › Full screen › The gestures — what gesture 6 does
  ///
  /// In en, this message translates to:
  /// **'Leave full screen'**
  String get helpFullScreenS2G6Description;

  /// Help › Full screen › The gestures — point 1
  ///
  /// In en, this message translates to:
  /// **'Tap once to show or hide the control bar. It slides away again after a few seconds.'**
  String get helpFullScreenS2P1;

  /// Help › Full screen › The gestures — point 2
  ///
  /// In en, this message translates to:
  /// **'Double-tap the upper half to go faster; double-tap the lower half to go slower. The new value flashes big on the screen.'**
  String get helpFullScreenS2P2;

  /// Help › Full screen › The gestures — point 3
  ///
  /// In en, this message translates to:
  /// **'In Tempo mode those same double-taps add or remove bars, because bars are what set the speed there.'**
  String get helpFullScreenS2P3;

  /// Help › Full screen › The gestures — point 4
  ///
  /// In en, this message translates to:
  /// **'Tap with two fingers to play or pause.'**
  String get helpFullScreenS2P4;

  /// Help › Full screen › The gestures — point 5
  ///
  /// In en, this message translates to:
  /// **'Pinch to change the text size, the same as usual.'**
  String get helpFullScreenS2P5;

  /// Help › Full screen › section heading
  ///
  /// In en, this message translates to:
  /// **'The buttons in the bar'**
  String get helpFullScreenS3Heading;

  /// Help › Full screen › The buttons in the bar — point 1
  ///
  /// In en, this message translates to:
  /// **'Exit (the shrink icon) leaves full screen.'**
  String get helpFullScreenS3P1;

  /// Help › Full screen › The buttons in the bar — point 2
  ///
  /// In en, this message translates to:
  /// **'The padlock locks the screen — see below.'**
  String get helpFullScreenS3P2;

  /// Help › Full screen › The buttons in the bar — point 3
  ///
  /// In en, this message translates to:
  /// **'The bell turns Stage Quiet Mode on and off — see below.'**
  String get helpFullScreenS3P3;

  /// Help › Full screen › The buttons in the bar — point 4
  ///
  /// In en, this message translates to:
  /// **'M and T pick Manual or Tempo, and the round button plays or pauses.'**
  String get helpFullScreenS3P4;

  /// Help › Full screen › The buttons in the bar — point 5
  ///
  /// In en, this message translates to:
  /// **'The bars icon opens the pitch pipe and shruti box.'**
  String get helpFullScreenS3P5;

  /// Help › Full screen › The buttons in the bar — point 6
  ///
  /// In en, this message translates to:
  /// **'The - and + at the end change the speed in Manual mode and the bar count in Tempo mode, the same as the double-taps.'**
  String get helpFullScreenS3P6;

  /// Help › Full screen › The buttons in the bar — point 7
  ///
  /// In en, this message translates to:
  /// **'The line under the buttons repeats the key, the BPM and, in Tempo mode, the length.'**
  String get helpFullScreenS3P7;

  /// Help › Full screen › section heading
  ///
  /// In en, this message translates to:
  /// **'Lock the screen'**
  String get helpFullScreenS4Heading;

  /// Help › Full screen › Lock the screen — point 1
  ///
  /// In en, this message translates to:
  /// **'Tap the padlock to lock Stage View. The tap controls are then switched off, so a sleeve or a stray hand cannot change your speed or pause you mid-song.'**
  String get helpFullScreenS4P1;

  /// Help › Full screen › Lock the screen — point 2
  ///
  /// In en, this message translates to:
  /// **'The control bar hides and a small \"Stage Locked\" chip appears in the top right.'**
  String get helpFullScreenS4P2;

  /// Help › Full screen › Lock the screen — point 3
  ///
  /// In en, this message translates to:
  /// **'Tap that chip, or press Back, to unlock. It asks for your fingerprint, or the PIN, pattern or password the phone already uses.'**
  String get helpFullScreenS4P3;

  /// Help › Full screen › Lock the screen — point 4
  ///
  /// In en, this message translates to:
  /// **'On a phone with no screen lock set up there is nothing to check against, so it simply unlocks.'**
  String get helpFullScreenS4P4;

  /// Help › Full screen › Lock the screen — point 5
  ///
  /// In en, this message translates to:
  /// **'If the check cannot run at all, the stage unlocks anyway and says so. The lock is there to stop stray touches, so it will never shut you out.'**
  String get helpFullScreenS4P5;

  /// Help › Full screen › section heading
  ///
  /// In en, this message translates to:
  /// **'Stage Quiet Mode'**
  String get helpFullScreenS5Heading;

  /// Help › Full screen › Stage Quiet Mode — point 1
  ///
  /// In en, this message translates to:
  /// **'Tap the bell to mute the ringer and notification alerts while you play, so a call cannot chime through the PA.'**
  String get helpFullScreenS5P1;

  /// Help › Full screen › Stage Quiet Mode — point 2
  ///
  /// In en, this message translates to:
  /// **'The app\'\'s own sound is left alone — the metronome click, the pitch cue and the drone all keep working.'**
  String get helpFullScreenS5P2;

  /// Help › Full screen › Stage Quiet Mode — point 3
  ///
  /// In en, this message translates to:
  /// **'The icon turns red only once the phone has really gone silent. Tap it again, leave full screen, or leave the song, and your normal ringer setting comes back — even if the app was closed.'**
  String get helpFullScreenS5P3;

  /// Help › Full screen › Stage Quiet Mode — point 4
  ///
  /// In en, this message translates to:
  /// **'The first time, Android may ask you to allow \"Do Not Disturb access\" for LyricChord. Tap Open settings in the message, turn it on, then tap the bell again.'**
  String get helpFullScreenS5P4;

  /// Help › Full screen › Stage Quiet Mode — point 5
  ///
  /// In en, this message translates to:
  /// **'iPhones do not let apps change the ringer, so the bell is not shown there. Use the ring/silent switch instead.'**
  String get helpFullScreenS5P5;

  /// Help › Full screen › section heading
  ///
  /// In en, this message translates to:
  /// **'Getting back'**
  String get helpFullScreenS6Heading;

  /// Help › Full screen › Getting back — point 1
  ///
  /// In en, this message translates to:
  /// **'Press Back, or tap once and use the exit button in the control bar.'**
  String get helpFullScreenS6P1;

  /// Help › Full screen › Getting back — point 2
  ///
  /// In en, this message translates to:
  /// **'That leaves full screen only — you are still on the same song. Press Back again to return to your songbook.'**
  String get helpFullScreenS6P2;

  /// Help › Full screen › Getting back — point 3
  ///
  /// In en, this message translates to:
  /// **'Swiping sideways does not change the song while you are full screen, so a stray touch cannot throw the wrong song up mid-song.'**
  String get helpFullScreenS6P3;

  /// Help › topic title (metronome)
  ///
  /// In en, this message translates to:
  /// **'Metronome'**
  String get titleHelpMetronome;

  /// Help › Metronome › one-line summary on the hub card
  ///
  /// In en, this message translates to:
  /// **'Keep the beat at the song tempo'**
  String get helpMetronomeSummary;

  /// Help › Metronome › opening paragraph
  ///
  /// In en, this message translates to:
  /// **'The metronome keeps time while you perform. Its speed comes from each song\'\'s BPM (beats per minute), which you set in the song editor.'**
  String get helpMetronomeIntro;

  /// Help › Metronome › section heading
  ///
  /// In en, this message translates to:
  /// **'Turn it on'**
  String get helpMetronomeS1Heading;

  /// Help › Metronome › Turn it on — point 1
  ///
  /// In en, this message translates to:
  /// **'Go to Settings > General > Metronome.'**
  String get helpMetronomeS1P1;

  /// Help › Metronome › Turn it on — point 2
  ///
  /// In en, this message translates to:
  /// **'Switch on \"Enable metronome\".'**
  String get helpMetronomeS1P2;

  /// Help › Metronome › Turn it on — point 3
  ///
  /// In en, this message translates to:
  /// **'The setting is saved and stays on after you restart the app.'**
  String get helpMetronomeS1P3;

  /// Help › Metronome › section heading
  ///
  /// In en, this message translates to:
  /// **'Flash and Click'**
  String get helpMetronomeS2Heading;

  /// Help › Metronome › Flash and Click — point 1
  ///
  /// In en, this message translates to:
  /// **'Flash blinks on every beat — handy when the sound is muted.'**
  String get helpMetronomeS2P1;

  /// Help › Metronome › Flash and Click — point 2
  ///
  /// In en, this message translates to:
  /// **'Click plays a short tick on every beat.'**
  String get helpMetronomeS2P2;

  /// Help › Metronome › Flash and Click — point 3
  ///
  /// In en, this message translates to:
  /// **'You can use either, both, or neither.'**
  String get helpMetronomeS2P3;

  /// Help › Metronome › Flash and Click — point 4
  ///
  /// In en, this message translates to:
  /// **'Flash and Click stay greyed out until the metronome is enabled.'**
  String get helpMetronomeS2P4;

  /// Help › Metronome › Flash and Click — point 5
  ///
  /// In en, this message translates to:
  /// **'Click volume sets how loud the tick is. The tick uses the media volume, so raise the volume buttons while a song is open if you cannot hear it.'**
  String get helpMetronomeS2P5;

  /// Help › Metronome › Flash and Click — point 6
  ///
  /// In en, this message translates to:
  /// **'Tap \"Test the sound\" in Metronome settings to hear one bar without opening a song.'**
  String get helpMetronomeS2P6;

  /// Help › Metronome › section heading
  ///
  /// In en, this message translates to:
  /// **'Beats in a bar'**
  String get helpMetronomeS3Heading;

  /// Help › Metronome › Beats in a bar — point 1
  ///
  /// In en, this message translates to:
  /// **'Pick 2, 3, 4 or 6 beats in a bar in Metronome settings.'**
  String get helpMetronomeS3P1;

  /// Help › Metronome › Beats in a bar — point 2
  ///
  /// In en, this message translates to:
  /// **'With \"Accent beat 1\" on, the first beat of every bar is louder and higher, so you can hear where the bar starts.'**
  String get helpMetronomeS3P2;

  /// Help › Metronome › Beats in a bar — point 3
  ///
  /// In en, this message translates to:
  /// **'While the beat runs, the button counts the beat number — 1, 2, 3, 4 — so you can see your place even with the sound off.'**
  String get helpMetronomeS3P3;

  /// Help › Metronome › section heading
  ///
  /// In en, this message translates to:
  /// **'Set the tempo'**
  String get helpMetronomeS4Heading;

  /// Help › Metronome › Set the tempo — point 1
  ///
  /// In en, this message translates to:
  /// **'By default the beat speed follows the song\'\'s BPM.'**
  String get helpMetronomeS4P1;

  /// Help › Metronome › Set the tempo — point 2
  ///
  /// In en, this message translates to:
  /// **'Change a song\'\'s BPM by editing the song.'**
  String get helpMetronomeS4P2;

  /// Help › Metronome › Set the tempo — point 3
  ///
  /// In en, this message translates to:
  /// **'Long press the metronome button to set the speed by hand: use - and +, drag the slider, or tap \"Tap tempo\" along with the music.'**
  String get helpMetronomeS4P3;

  /// Help › Metronome › Set the tempo — point 4
  ///
  /// In en, this message translates to:
  /// **'A tempo you set by hand lasts for this session only. Tap \"Use song tempo\" to go back to the song\'\'s own speed.'**
  String get helpMetronomeS4P4;

  /// Help › Metronome › Set the tempo — point 5
  ///
  /// In en, this message translates to:
  /// **'A song with no saved BPM still works — the metronome uses the last speed you used.'**
  String get helpMetronomeS4P5;

  /// Help › topic title (pitch-pipe-drone)
  ///
  /// In en, this message translates to:
  /// **'Pitch Pipe & Drone'**
  String get titleHelpPitchPipeDrone;

  /// Help › Pitch Pipe & Drone › one-line summary on the hub card
  ///
  /// In en, this message translates to:
  /// **'Reference pitch cues and a steady shruti box drone'**
  String get helpPitchPipeDroneSummary;

  /// Help › Pitch Pipe & Drone › opening paragraph
  ///
  /// In en, this message translates to:
  /// **'A fully offline sound generator: a short reference note to start on, and a steady shruti box drone to sing against. Nothing is downloaded and no sound files ship with the app — the tones are built as you press the button.'**
  String get helpPitchPipeDroneIntro;

  /// Help › Pitch Pipe & Drone › section heading
  ///
  /// In en, this message translates to:
  /// **'What the drone does — and does not do'**
  String get helpPitchPipeDroneS1Heading;

  /// Help › Pitch Pipe & Drone › What the drone does — and does not do — point 1
  ///
  /// In en, this message translates to:
  /// **'The drone holds ONE steady pair of notes for as long as it is on.'**
  String get helpPitchPipeDroneS1P1;

  /// Help › Pitch Pipe & Drone › What the drone does — and does not do — point 2
  ///
  /// In en, this message translates to:
  /// **'It does NOT follow the tune, the words, or the chords. It never changes until you change it.'**
  String get helpPitchPipeDroneS1P2;

  /// Help › Pitch Pipe & Drone › What the drone does — and does not do — point 3
  ///
  /// In en, this message translates to:
  /// **'Think of it as a tuning fork that never stops, so your ear stays anchored while you sing.'**
  String get helpPitchPipeDroneS1P3;

  /// Help › Pitch Pipe & Drone › section heading
  ///
  /// In en, this message translates to:
  /// **'Where to find it'**
  String get helpPitchPipeDroneS2Heading;

  /// Help › Pitch Pipe & Drone › Where to find it — point 1
  ///
  /// In en, this message translates to:
  /// **'Open a song and tap the pitch button (the bars icon) next to the metronome.'**
  String get helpPitchPipeDroneS2P1;

  /// Help › Pitch Pipe & Drone › Where to find it — point 2
  ///
  /// In en, this message translates to:
  /// **'It is in the Stage Mode bar too, next to the play button.'**
  String get helpPitchPipeDroneS2P2;

  /// Help › Pitch Pipe & Drone › Where to find it — point 3
  ///
  /// In en, this message translates to:
  /// **'Settings → General → Pitch Pipe & Drone sets the defaults and has Test buttons.'**
  String get helpPitchPipeDroneS2P3;

  /// Help › Pitch Pipe & Drone › section heading
  ///
  /// In en, this message translates to:
  /// **'Pitch Cue (called Chord Cue in Western)'**
  String get helpPitchPipeDroneS3Heading;

  /// Help › Pitch Pipe & Drone › Pitch Cue (called Chord Cue in Western) — point 1
  ///
  /// In en, this message translates to:
  /// **'Tap \"Pitch Cue\" to hear a 2-second reference note. It is a digital pitch pipe: it sounds your Sa (or the key you picked), then stops on its own.'**
  String get helpPitchPipeDroneS3P1;

  /// Help › Pitch Pipe & Drone › Pitch Cue (called Chord Cue in Western) — point 2
  ///
  /// In en, this message translates to:
  /// **'Use it to find your starting note before you begin singing.'**
  String get helpPitchPipeDroneS3P2;

  /// Help › Pitch Pipe & Drone › Pitch Cue (called Chord Cue in Western) — point 3
  ///
  /// In en, this message translates to:
  /// **'In Western mode the same button is named \"Chord Cue\" and plays the whole chord — bass, root, third and fifth — because Western players want the chord, not one note. Major or minor follows the quality you picked.'**
  String get helpPitchPipeDroneS3P3;

  /// Help › Pitch Pipe & Drone › Pitch Cue (called Chord Cue in Western) — point 4
  ///
  /// In en, this message translates to:
  /// **'The length is fixed at 2 seconds and there is no setting for it. That is long enough to hear the pitch clearly and short enough not to get in the way. The button says \"(2s)\" so you know what you will get before you tap it.'**
  String get helpPitchPipeDroneS3P4;

  /// Help › Pitch Pipe & Drone › Pitch Cue (called Chord Cue in Western) — point 5
  ///
  /// In en, this message translates to:
  /// **'If you want a tone that lasts longer, use the Shruti Drone instead. That is what it is for.'**
  String get helpPitchPipeDroneS3P5;

  /// Help › Pitch Pipe & Drone › section heading
  ///
  /// In en, this message translates to:
  /// **'Cue or drone — which one?'**
  String get helpPitchPipeDroneS4Heading;

  /// Help › Pitch Pipe & Drone › Cue or drone — which one? — point 1
  ///
  /// In en, this message translates to:
  /// **'Cue: one short sound that stops by itself. For finding the note before you start.'**
  String get helpPitchPipeDroneS4P1;

  /// Help › Pitch Pipe & Drone › Cue or drone — which one? — point 2
  ///
  /// In en, this message translates to:
  /// **'Drone: keeps sounding until you stop it. For singing against while you practise or perform.'**
  String get helpPitchPipeDroneS4P2;

  /// Help › Pitch Pipe & Drone › Cue or drone — which one? — point 3
  ///
  /// In en, this message translates to:
  /// **'Both are built inside the app the moment you press the button. Nothing is downloaded and no sound files ship with the app.'**
  String get helpPitchPipeDroneS4P3;

  /// Help › Pitch Pipe & Drone › section heading
  ///
  /// In en, this message translates to:
  /// **'Shruti box drone'**
  String get helpPitchPipeDroneS5Heading;

  /// Help › Pitch Pipe & Drone › Shruti box drone — point 1
  ///
  /// In en, this message translates to:
  /// **'Tap \"Shruti Drone\" to start a continuous background hum.'**
  String get helpPitchPipeDroneS5P1;

  /// Help › Pitch Pipe & Drone › Shruti box drone — point 2
  ///
  /// In en, this message translates to:
  /// **'Choose Sa + Pa (the fifth) for most music, or Sa + Ma (the fourth) for ragas that leave out Pa, such as Malkauns or Marwa.'**
  String get helpPitchPipeDroneS5P2;

  /// Help › Pitch Pipe & Drone › Shruti box drone — point 3
  ///
  /// In en, this message translates to:
  /// **'The two notes are tuned in pure ratios (3:2 and 4:3), the way a real drone instrument sounds — not in equal temperament.'**
  String get helpPitchPipeDroneS5P3;

  /// Help › Pitch Pipe & Drone › Shruti box drone — point 4
  ///
  /// In en, this message translates to:
  /// **'The drone keeps playing until you stop it, so you can practise without it cutting out.'**
  String get helpPitchPipeDroneS5P4;

  /// Help › Pitch Pipe & Drone › section heading
  ///
  /// In en, this message translates to:
  /// **'Indian and Western naming'**
  String get helpPitchPipeDroneS6Heading;

  /// Help › Pitch Pipe & Drone › Indian and Western naming — point 1
  ///
  /// In en, this message translates to:
  /// **'Sa is movable, so the app must know which actual pitch your Sa is. Set it in Settings → \"Your Sa (Shruti)\".'**
  String get helpPitchPipeDroneS6P1;

  /// Help › Pitch Pipe & Drone › Indian and Western naming — point 2
  ///
  /// In en, this message translates to:
  /// **'A song with a raga is named the Indian way: \"5 kattai\" for Carnatic, \"safed 5\" for Hindustani. The tala decides which. No Western letters appear on an Indian sheet.'**
  String get helpPitchPipeDroneS6P2;

  /// Help › Pitch Pipe & Drone › Indian and Western naming — point 3
  ///
  /// In en, this message translates to:
  /// **'A song without a raga is named the Western way: just \"G\".'**
  String get helpPitchPipeDroneS6P3;

  /// Help › Pitch Pipe & Drone › Indian and Western naming — point 4
  ///
  /// In en, this message translates to:
  /// **'A Western song opens on the song\'\'s own key. An Indian song opens on your Sa, because the notation is written relative to Sa.'**
  String get helpPitchPipeDroneS6P4;

  /// Help › Pitch Pipe & Drone › section heading
  ///
  /// In en, this message translates to:
  /// **'Text size for the stage'**
  String get helpPitchPipeDroneS7Heading;

  /// Help › Pitch Pipe & Drone › Text size for the stage — point 1
  ///
  /// In en, this message translates to:
  /// **'The same sheet is read on a phone in your hand and on a stand two steps away, so the pitch sheet carries a text size setting.'**
  String get helpPitchPipeDroneS7P1;

  /// Help › Pitch Pipe & Drone › Text size for the stage — point 2
  ///
  /// In en, this message translates to:
  /// **'Pick one of five sizes — 85%, 95%, 100%, 115% or 130% — from the chips at the bottom of the pitch sheet.'**
  String get helpPitchPipeDroneS7P2;

  /// Help › Pitch Pipe & Drone › Text size for the stage — point 3
  ///
  /// In en, this message translates to:
  /// **'Settings → General → Pitch Pipe & Drone has the same chips, so you can set it before a gig.'**
  String get helpPitchPipeDroneS7P3;

  /// Help › Pitch Pipe & Drone › Text size for the stage — point 4
  ///
  /// In en, this message translates to:
  /// **'It multiplies the sheet text size everywhere, not only in full screen.'**
  String get helpPitchPipeDroneS7P4;

  /// Help › Pitch Pipe & Drone › Text size for the stage — point 5
  ///
  /// In en, this message translates to:
  /// **'Pinching the sheet with two fingers still works and is the quicker way to nudge one song.'**
  String get helpPitchPipeDroneS7P5;

  /// Help › topic title (melody)
  ///
  /// In en, this message translates to:
  /// **'Melody Lines'**
  String get titleHelpMelody;

  /// Help › Melody Lines › one-line summary on the hub card
  ///
  /// In en, this message translates to:
  /// **'Write the tune under the words, then hear it.'**
  String get helpMelodySummary;

  /// Help › Melody Lines › opening paragraph
  ///
  /// In en, this message translates to:
  /// **'A chord sheet tells you the words and tells the accompanist what to play. It does not tell you the tune. A melody line adds that. Write \'{melody}\' under a lyric line and the app draws the beats and hums them back, so you can learn a song you have never heard.'**
  String get helpMelodyIntro;

  /// Help › Melody Lines › section heading
  ///
  /// In en, this message translates to:
  /// **'Writing one'**
  String get helpMelodyS1Heading;

  /// Help › Melody Lines › Writing one — point 1
  ///
  /// In en, this message translates to:
  /// **'Put a line starting with \'{melody}\' under the lyric line it belongs to.'**
  String get helpMelodyS1P1;

  /// Help › Melody Lines › Writing one — point 2
  ///
  /// In en, this message translates to:
  /// **'Example: \'{melody}\' P ,  M2 | M2!G3~ ,  | R2 S'**
  String get helpMelodyS1P2;

  /// Help › Melody Lines › Writing one — point 3
  ///
  /// In en, this message translates to:
  /// **'Beats are separated by spaces. One beat, one space.'**
  String get helpMelodyS1P3;

  /// Help › Melody Lines › Writing one — point 4
  ///
  /// In en, this message translates to:
  /// **'The words and chords above it do not change at all.'**
  String get helpMelodyS1P4;

  /// Help › Melody Lines › Writing one — point 5
  ///
  /// In en, this message translates to:
  /// **'You do not have to type it. In the editor, More options → \"Melody keypad\" gives you a pad of all sixteen swaras and every mark, draws the beats as you tap, and counts \"6 of 8 beats\" until the line fills the tala.'**
  String get helpMelodyS1P5;

  /// Help › Melody Lines › Writing one — point 6
  ///
  /// In en, this message translates to:
  /// **'With the cursor already on a \'{melody}\' line, the keypad loads that line so you can fix it instead of deleting it first.'**
  String get helpMelodyS1P6;

  /// Help › Melody Lines › Writing one — point 7
  ///
  /// In en, this message translates to:
  /// **'A block of published Carnatic notation can be turned into melody lines in one go — see the Indian songs topic.'**
  String get helpMelodyS1P7;

  /// Help › Melody Lines › section heading
  ///
  /// In en, this message translates to:
  /// **'The five marks'**
  String get helpMelodyS2Heading;

  /// Help › Melody Lines › The five marks — point 1
  ///
  /// In en, this message translates to:
  /// **'A comma ( , ) holds the note before it for one more beat.'**
  String get helpMelodyS2P1;

  /// Help › Melody Lines › The five marks — point 2
  ///
  /// In en, this message translates to:
  /// **'A bar ( | ) shows where a new tala group starts. It takes no time.'**
  String get helpMelodyS2P2;

  /// Help › Melody Lines › The five marks — point 3
  ///
  /// In en, this message translates to:
  /// **'A hyphen ( - ) joins notes that share one beat: G3-R2 is half a beat each.'**
  String get helpMelodyS2P3;

  /// Help › Melody Lines › The five marks — point 4
  ///
  /// In en, this message translates to:
  /// **'A bang ( ! ) slides into a note. M2!G3 starts the slide at Ma. A bare !G3 is a short slide in from just under Ga.'**
  String get helpMelodyS2P4;

  /// Help › Melody Lines › The five marks — point 5
  ///
  /// In en, this message translates to:
  /// **'A tilde ( ~ ) shakes the note.'**
  String get helpMelodyS2P5;

  /// Help › Melody Lines › section heading
  ///
  /// In en, this message translates to:
  /// **'Naming the notes'**
  String get helpMelodyS3Heading;

  /// Help › Melody Lines › Naming the notes — point 1
  ///
  /// In en, this message translates to:
  /// **'A bare name is the note from the plain Sa Re Ga Ma Pa Dha Ni row, so Ma on its own is Ma1.'**
  String get helpMelodyS3P1;

  /// Help › Melody Lines › Naming the notes — point 2
  ///
  /// In en, this message translates to:
  /// **'A digit names the exact one: Ma2 is the raised Ma, R1 R2 R3 are the three Ris.'**
  String get helpMelodyS3P2;

  /// Help › Melody Lines › Naming the notes — point 3
  ///
  /// In en, this message translates to:
  /// **'Ma2 and M2 mean the same note. Use full names in chords and short letters in melody lines, or whichever reads better.'**
  String get helpMelodyS3P3;

  /// Help › Melody Lines › Naming the notes — point 4
  ///
  /// In en, this message translates to:
  /// **'The raga never changes what a name means, so nothing is guessed.'**
  String get helpMelodyS3P4;

  /// Help › Melody Lines › Naming the notes — point 5
  ///
  /// In en, this message translates to:
  /// **'A dot in front drops a note an octave (.N3). An apostrophe after raises it (S\'\').'**
  String get helpMelodyS3P5;

  /// Help › Melody Lines › section heading
  ///
  /// In en, this message translates to:
  /// **'Hearing it'**
  String get helpMelodyS4Heading;

  /// Help › Melody Lines › Hearing it — point 1
  ///
  /// In en, this message translates to:
  /// **'Add \'{tonic: 1 kattai}\' so the app knows where your Sa really is. Without it the beats still draw, but nothing can play.'**
  String get helpMelodyS4P1;

  /// Help › Melody Lines › Hearing it — point 2
  ///
  /// In en, this message translates to:
  /// **'Add \'{tala: misra chapu}\' so the beats are grouped correctly.'**
  String get helpMelodyS4P2;

  /// Help › Melody Lines › Hearing it — point 3
  ///
  /// In en, this message translates to:
  /// **'The song tempo sets the speed.'**
  String get helpMelodyS4P3;

  /// Help › Melody Lines › Hearing it — point 4
  ///
  /// In en, this message translates to:
  /// **'Tap the play button beside a melody line to hum it.'**
  String get helpMelodyS4P4;

  /// Help › Melody Lines › Hearing it — point 5
  ///
  /// In en, this message translates to:
  /// **'To read the words without the tune rows, open the overflow menu → Performance controls and turn Show melody off. Full screen never draws the melody rows.'**
  String get helpMelodyS4P5;

  /// Help › Melody Lines › Hearing it — point 6
  ///
  /// In en, this message translates to:
  /// **'Turn on Loop to repeat the line, or Half speed to learn it slowly.'**
  String get helpMelodyS4P6;

  /// Help › Melody Lines › Hearing it — point 7
  ///
  /// In en, this message translates to:
  /// **'Start the shruti drone first — a tune is much easier to hear against a drone than on its own.'**
  String get helpMelodyS4P7;

  /// Help › Melody Lines › section heading
  ///
  /// In en, this message translates to:
  /// **'What it can and cannot do'**
  String get helpMelodyS5Heading;

  /// Help › Melody Lines › What it can and cannot do — point 1
  ///
  /// In en, this message translates to:
  /// **'It shows you where the notes go and how long each one lasts.'**
  String get helpMelodyS5P1;

  /// Help › Melody Lines › What it can and cannot do — point 2
  ///
  /// In en, this message translates to:
  /// **'It does not shape them the way a singer does. Listen to a recording for that.'**
  String get helpMelodyS5P2;

  /// Help › Melody Lines › What it can and cannot do — point 3
  ///
  /// In en, this message translates to:
  /// **'Every song needs a person who knows the tune to type it in. There is no shortcut.'**
  String get helpMelodyS5P3;

  /// Help › topic title (indian-songs)
  ///
  /// In en, this message translates to:
  /// **'Indian songs'**
  String get titleHelpIndianSongs;

  /// Help › Indian songs › one-line summary on the hub card
  ///
  /// In en, this message translates to:
  /// **'Swaras, raga, tala, and where your Sa is'**
  String get helpIndianSongsSummary;

  /// Help › Indian songs › opening paragraph
  ///
  /// In en, this message translates to:
  /// **'An Indian song is written in swaras — Sa Re Ga Ma Pa Dha Ni — not in chords, and those names are relative to Sa rather than to a fixed pitch. The app treats such a song differently all the way through.'**
  String get helpIndianSongsIntro;

  /// Help › Indian songs › section heading
  ///
  /// In en, this message translates to:
  /// **'Mark the song as Indian'**
  String get helpIndianSongsS1Heading;

  /// Help › Indian songs › Mark the song as Indian — point 1
  ///
  /// In en, this message translates to:
  /// **'In the editor, set \"Notation\" to Carnatic or Hindustani.'**
  String get helpIndianSongsS1P1;

  /// Help › Indian songs › Mark the song as Indian — point 2
  ///
  /// In en, this message translates to:
  /// **'The \"Original key\" box is replaced by Raga and Tala, because an Indian sheet has no key to transpose.'**
  String get helpIndianSongsS1P2;

  /// Help › Indian songs › Mark the song as Indian — point 3
  ///
  /// In en, this message translates to:
  /// **'Switching back to Western clears the raga and tala, so an old value can never make the song look Indian again.'**
  String get helpIndianSongsS1P3;

  /// Help › Indian songs › section heading
  ///
  /// In en, this message translates to:
  /// **'The note under the Tala box'**
  String get helpIndianSongsS2Heading;

  /// Help › Indian songs › The note under the Tala box — point 1
  ///
  /// In en, this message translates to:
  /// **'Typing a tala that belongs to the other tradition — Keherwa on a Carnatic song, say — shows a short note under the box.'**
  String get helpIndianSongsS2P1;

  /// Help › Indian songs › The note under the Tala box — point 2
  ///
  /// In en, this message translates to:
  /// **'It is advice only. It never stops you saving. The app knows a fixed list of tala names and yours may simply not be on it.'**
  String get helpIndianSongsS2P2;

  /// Help › Indian songs › The note under the Tala box — point 3
  ///
  /// In en, this message translates to:
  /// **'The tala also decides how many beats are in a bar for Tempo auto-scroll and for the beat grid under a melody line.'**
  String get helpIndianSongsS2P3;

  /// Help › Indian songs › section heading
  ///
  /// In en, this message translates to:
  /// **'What changes on the song screen'**
  String get helpIndianSongsS3Heading;

  /// Help › Indian songs › What changes on the song screen — point 1
  ///
  /// In en, this message translates to:
  /// **'No Western letter is shown. The status line reads \"Auto-scroll · 120 BPM\", with the raga and tala on the line below it.'**
  String get helpIndianSongsS3P1;

  /// Help › Indian songs › What changes on the song screen — point 2
  ///
  /// In en, this message translates to:
  /// **'There is no transpose control, because a swara does not move.'**
  String get helpIndianSongsS3P2;

  /// Help › Indian songs › What changes on the song screen — point 3
  ///
  /// In en, this message translates to:
  /// **'The menu offers \"Swara Reference\" in place of Chord Reference.'**
  String get helpIndianSongsS3P3;

  /// Help › Indian songs › What changes on the song screen — point 4
  ///
  /// In en, this message translates to:
  /// **'The pitch sheet opens on your saved Sa instead of a song key, and names it the Indian way — \"5 kattai\" for Carnatic, \"safed 5\" for Hindustani.'**
  String get helpIndianSongsS3P4;

  /// Help › Indian songs › section heading
  ///
  /// In en, this message translates to:
  /// **'Lines you can put in the words'**
  String get helpIndianSongsS4Heading;

  /// Help › Indian songs › Lines you can put in the words — point 1
  ///
  /// In en, this message translates to:
  /// **'\'{tonic: 1 kattai}\' says where your Sa really is. A melody line cannot be played without it.'**
  String get helpIndianSongsS4P1;

  /// Help › Indian songs › Lines you can put in the words — point 2
  ///
  /// In en, this message translates to:
  /// **'\'{tala: misra chapu}\' groups the beats.'**
  String get helpIndianSongsS4P2;

  /// Help › Indian songs › Lines you can put in the words — point 3
  ///
  /// In en, this message translates to:
  /// **'\'{sruti: madhyama}\' marks a song sung with the drone\'\'s Pa string dropped to shuddha madhyamam, as Yamunakalyani usually is. The written Sa then sounds a fourth higher.'**
  String get helpIndianSongsS4P3;

  /// Help › Indian songs › Lines you can put in the words — point 4
  ///
  /// In en, this message translates to:
  /// **'\'{melody}\' lines hold the tune — see the Melody Lines topic.'**
  String get helpIndianSongsS4P4;

  /// Help › Indian songs › Lines you can put in the words — point 5
  ///
  /// In en, this message translates to:
  /// **'All of these live in the song text, so import and export carry them through unchanged.'**
  String get helpIndianSongsS4P5;

  /// Help › Indian songs › section heading
  ///
  /// In en, this message translates to:
  /// **'Paste published notation'**
  String get helpIndianSongsS5Heading;

  /// Help › Indian songs › Paste published notation — point 1
  ///
  /// In en, this message translates to:
  /// **'In the editor, More options → \"Paste Carnatic\" takes a block copied from a book or a page and turns it into \'{melody}\' lines.'**
  String get helpIndianSongsS5P1;

  /// Help › Indian songs › Paste published notation — point 2
  ///
  /// In en, this message translates to:
  /// **'Published notation has no single standard: on some pages a capital letter means a longer note, on others it means a higher octave.'**
  String get helpIndianSongsS5P2;

  /// Help › Indian songs › Paste published notation — point 3
  ///
  /// In en, this message translates to:
  /// **'So the app reads the block both ways, checks each against the song\'\'s tala, and tells you which one fitted and by how much — like \"1 of 1 cycles fit, read with case means note length\".'**
  String get helpIndianSongsS5P3;

  /// Help › Indian songs › Paste published notation — point 4
  ///
  /// In en, this message translates to:
  /// **'Where the two ways tie it says so instead of guessing.'**
  String get helpIndianSongsS5P4;

  /// Help › Indian songs › Paste published notation — point 5
  ///
  /// In en, this message translates to:
  /// **'It will not choose between the two Ma-s on its own. That is raga grammar, not arithmetic — but it points out the phrase that decides it.'**
  String get helpIndianSongsS5P5;

  /// Help › topic title (select-songs)
  ///
  /// In en, this message translates to:
  /// **'Select Songs'**
  String get titleHelpSelectSongs;

  /// Help › Select Songs › one-line summary on the hub card
  ///
  /// In en, this message translates to:
  /// **'Act on several songs at once'**
  String get helpSelectSongsSummary;

  /// Help › Select Songs › opening paragraph
  ///
  /// In en, this message translates to:
  /// **'Selection mode lets you choose many songs together and then export or delete them in one step.'**
  String get helpSelectSongsIntro;

  /// Help › Select Songs › section heading
  ///
  /// In en, this message translates to:
  /// **'Start selecting'**
  String get helpSelectSongsS1Heading;

  /// Help › Select Songs › Start selecting — point 1
  ///
  /// In en, this message translates to:
  /// **'On the Songs list, long-press any song to start selection mode.'**
  String get helpSelectSongsS1P1;

  /// Help › Select Songs › Start selecting — point 2
  ///
  /// In en, this message translates to:
  /// **'Tap more songs to add them to the selection.'**
  String get helpSelectSongsS1P2;

  /// Help › Select Songs › Start selecting — point 3
  ///
  /// In en, this message translates to:
  /// **'The top bar shows how many songs are selected.'**
  String get helpSelectSongsS1P3;

  /// Help › Select Songs › section heading
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get helpSelectSongsS2Heading;

  /// Help › Select Songs › Select all — point 1
  ///
  /// In en, this message translates to:
  /// **'Use the \"Select all\" icon in the top bar to pick every visible song.'**
  String get helpSelectSongsS2P1;

  /// Help › Select Songs › Select all — point 2
  ///
  /// In en, this message translates to:
  /// **'Tap it again (\"Deselect all\") to clear the selection.'**
  String get helpSelectSongsS2P2;

  /// Help › Select Songs › section heading
  ///
  /// In en, this message translates to:
  /// **'What you can do'**
  String get helpSelectSongsS3Heading;

  /// Help › Select Songs › What you can do — point 1
  ///
  /// In en, this message translates to:
  /// **'Export the selected songs as one ChordPro file.'**
  String get helpSelectSongsS3P1;

  /// Help › Select Songs › What you can do — point 2
  ///
  /// In en, this message translates to:
  /// **'Delete the selected songs from your library.'**
  String get helpSelectSongsS3P2;

  /// Help › Select Songs › What you can do — point 3
  ///
  /// In en, this message translates to:
  /// **'Tap the X on the top-left to leave selection mode without changes.'**
  String get helpSelectSongsS3P3;

  /// Help › topic title (import)
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get titleHelpImport;

  /// Help › Import › one-line summary on the hub card
  ///
  /// In en, this message translates to:
  /// **'Bring songs into the app'**
  String get helpImportSummary;

  /// Help › Import › opening paragraph
  ///
  /// In en, this message translates to:
  /// **'Import adds songs from ChordPro or plain text files into your library. Reading is defensive — broken or unreadable files are skipped safely and never break the app.'**
  String get helpImportIntro;

  /// Help › Import › section heading
  ///
  /// In en, this message translates to:
  /// **'Supported file types'**
  String get helpImportS1Heading;

  /// Help › Import › Supported file types — point 1
  ///
  /// In en, this message translates to:
  /// **'You can pick files ending in .cho, .pro, .chordpro, or .txt.'**
  String get helpImportS1P1;

  /// Help › Import › Supported file types — point 2
  ///
  /// In en, this message translates to:
  /// **'ChordPro files are plain text files that use simple tags for chords and headers.'**
  String get helpImportS1P2;

  /// Help › Import › Supported file types — point 3
  ///
  /// In en, this message translates to:
  /// **'You can pick one file or multiple files at the same time.'**
  String get helpImportS1P3;

  /// Help › Import › section heading
  ///
  /// In en, this message translates to:
  /// **'Multiple songs in one file'**
  String get helpImportS2Heading;

  /// Help › Import › Multiple songs in one file — point 1
  ///
  /// In en, this message translates to:
  /// **'A single file can contain many songs.'**
  String get helpImportS2P1;

  /// Help › Import › Multiple songs in one file — point 2
  ///
  /// In en, this message translates to:
  /// **'Put \'{new_song}\' or \'{ns}\' on its own line between songs to separate them. This is the same separator used when you export your whole songbook.'**
  String get helpImportS2P2;

  /// Help › Import › Multiple songs in one file — point 3
  ///
  /// In en, this message translates to:
  /// **'You can also separate songs by starting a new \'{title: ...}\' or \'{t: ...}\' tag. The app automatically detects where the new song begins.'**
  String get helpImportS2P3;

  /// Help › Import › section heading
  ///
  /// In en, this message translates to:
  /// **'Text files without tags'**
  String get helpImportS3Heading;

  /// Help › Import › Text files without tags — point 1
  ///
  /// In en, this message translates to:
  /// **'A plain text file with no tags is imported safely as one song.'**
  String get helpImportS3P1;

  /// Help › Import › Text files without tags — point 2
  ///
  /// In en, this message translates to:
  /// **'The app gives it the name \"Untitled Song\" and key C.'**
  String get helpImportS3P2;

  /// Help › Import › Text files without tags — point 3
  ///
  /// In en, this message translates to:
  /// **'You can open and edit its title, chords, key, and tempo at any time.'**
  String get helpImportS3P3;

  /// Help › Import › section heading
  ///
  /// In en, this message translates to:
  /// **'Duplicate songs'**
  String get helpImportS4Heading;

  /// Help › Import › Duplicate songs — point 1
  ///
  /// In en, this message translates to:
  /// **'If a song has the same title as one in your library, the app follows your duplicate setting.'**
  String get helpImportS4P1;

  /// Help › Import › Duplicate songs — point 2
  ///
  /// In en, this message translates to:
  /// **'You can choose to overwrite the existing song, rename the new one, rename the old one, or ask for a title each time.'**
  String get helpImportS4P2;

  /// Help › Import › Duplicate songs — point 3
  ///
  /// In en, this message translates to:
  /// **'Set this in Settings → General → Import Settings.'**
  String get helpImportS4P3;

  /// Help › Import › section heading
  ///
  /// In en, this message translates to:
  /// **'Check before it is saved'**
  String get helpImportS5Heading;

  /// Help › Import › Check before it is saved — point 1
  ///
  /// In en, this message translates to:
  /// **'Every import stops at a preview screen first.'**
  String get helpImportS5P1;

  /// Help › Import › Check before it is saved — point 2
  ///
  /// In en, this message translates to:
  /// **'You can read the titles, artists, keys and words that were found, and fix a title before anything is written.'**
  String get helpImportS5P2;

  /// Help › Import › Check before it is saved — point 3
  ///
  /// In en, this message translates to:
  /// **'Nothing reaches your library until you confirm.'**
  String get helpImportS5P3;

  /// Help › Import › section heading
  ///
  /// In en, this message translates to:
  /// **'Other ways songs come in'**
  String get helpImportS6Heading;

  /// Help › Import › Other ways songs come in — point 1
  ///
  /// In en, this message translates to:
  /// **'Opening a ChordPro file from a file manager, an email or a chat app hands it to LyricChord and opens the same preview.'**
  String get helpImportS6P1;

  /// Help › Import › Other ways songs come in — point 2
  ///
  /// In en, this message translates to:
  /// **'A bandmate standing next to you can send songs with no file at all — see the AirQR topic.'**
  String get helpImportS6P2;

  /// Help › topic title (export)
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get titleHelpExport;

  /// Help › Export › one-line summary on the hub card
  ///
  /// In en, this message translates to:
  /// **'Save your songs out of the app'**
  String get helpExportSummary;

  /// Help › Export › opening paragraph
  ///
  /// In en, this message translates to:
  /// **'Export saves songs as a file you choose the place for. Share hands the same file straight to another app. Everything stays offline — nothing is uploaded, and the system file picker or share sheet does the work.'**
  String get helpExportIntro;

  /// Help › Export › section heading
  ///
  /// In en, this message translates to:
  /// **'Export all songs'**
  String get helpExportS1Heading;

  /// Help › Export › Export all songs — point 1
  ///
  /// In en, this message translates to:
  /// **'Go to Settings > General > Import.'**
  String get helpExportS1P1;

  /// Help › Export › Export all songs — point 2
  ///
  /// In en, this message translates to:
  /// **'Tap \"Export all songs\".'**
  String get helpExportS1P2;

  /// Help › Export › Export all songs — point 3
  ///
  /// In en, this message translates to:
  /// **'Your whole songbook is saved as one ChordPro file.'**
  String get helpExportS1P3;

  /// Help › Export › section heading
  ///
  /// In en, this message translates to:
  /// **'Export some songs (ChordPro)'**
  String get helpExportS2Heading;

  /// Help › Export › Export some songs (ChordPro) — point 1
  ///
  /// In en, this message translates to:
  /// **'On the Songs list, long-press to select the songs you want.'**
  String get helpExportS2P1;

  /// Help › Export › Export some songs (ChordPro) — point 2
  ///
  /// In en, this message translates to:
  /// **'Tap the export icon in the top bar.'**
  String get helpExportS2P2;

  /// Help › Export › Export some songs (ChordPro) — point 3
  ///
  /// In en, this message translates to:
  /// **'The selected songs are saved as one ChordPro file.'**
  String get helpExportS2P3;

  /// Help › Export › section heading
  ///
  /// In en, this message translates to:
  /// **'Export one song'**
  String get helpExportS3Heading;

  /// Help › Export › Export one song — point 1
  ///
  /// In en, this message translates to:
  /// **'Open the song, then the top-bar menu (More options) → \"Export\".'**
  String get helpExportS3P1;

  /// Help › Export › Export one song — point 2
  ///
  /// In en, this message translates to:
  /// **'Choose ChordPro (.chordpro) or PDF (.pdf), then tap Export.'**
  String get helpExportS3P2;

  /// Help › Export › Export one song — point 3
  ///
  /// In en, this message translates to:
  /// **'The system file saver opens so you can pick where it goes.'**
  String get helpExportS3P3;

  /// Help › Export › Export one song — point 4
  ///
  /// In en, this message translates to:
  /// **'Whatever you export uses the key you are looking at, so a song you have transposed is saved in that key.'**
  String get helpExportS3P4;

  /// Help › Export › section heading
  ///
  /// In en, this message translates to:
  /// **'What a PDF looks like'**
  String get helpExportS4Heading;

  /// Help › Export › What a PDF looks like — point 1
  ///
  /// In en, this message translates to:
  /// **'Title, artist, key and BPM at the top, guitar chord diagrams under that, then the words with the chords above them.'**
  String get helpExportS4P1;

  /// Help › Export › What a PDF looks like — point 2
  ///
  /// In en, this message translates to:
  /// **'The words use the lyric font you picked in Settings → Fonts, so Malayalam is shaped correctly and the text stays selectable.'**
  String get helpExportS4P2;

  /// Help › Export › What a PDF looks like — point 3
  ///
  /// In en, this message translates to:
  /// **'The page is only as wide as the song needs — a song with short lines gets a narrow, tall page that fills a phone screen better — up to A4 width at the most.'**
  String get helpExportS4P3;

  /// Help › Export › What a PDF looks like — point 4
  ///
  /// In en, this message translates to:
  /// **'If a line is still too long, the font is stepped down (never below 9 pt) so it does not wrap in the middle.'**
  String get helpExportS4P4;

  /// Help › Export › section heading
  ///
  /// In en, this message translates to:
  /// **'Share instead of save'**
  String get helpExportS5Heading;

  /// Help › Export › Share instead of save — point 1
  ///
  /// In en, this message translates to:
  /// **'The top-bar menu also has \"Share\", which opens the system share sheet instead of the file saver.'**
  String get helpExportS5P1;

  /// Help › Export › Share instead of save — point 2
  ///
  /// In en, this message translates to:
  /// **'You can share as ChordPro, as PDF, or as an AirQR stream — see the AirQR topic.'**
  String get helpExportS5P2;

  /// Help › Export › Share instead of save — point 3
  ///
  /// In en, this message translates to:
  /// **'Selecting several songs on the Songs list gives you the same share choice for the whole set.'**
  String get helpExportS5P3;

  /// Help › topic title (airqr)
  ///
  /// In en, this message translates to:
  /// **'AirQR sharing'**
  String get titleHelpAirqr;

  /// Help › AirQR sharing › one-line summary on the hub card
  ///
  /// In en, this message translates to:
  /// **'Pass songs to another phone with the camera'**
  String get helpAirqrSummary;

  /// Help › AirQR sharing › opening paragraph
  ///
  /// In en, this message translates to:
  /// **'AirQR moves songs from one phone to another by flashing a run of QR codes on one screen while the other phone watches with its camera. No internet, no Bluetooth, no Wi-Fi, no cable and no account — just two screens facing each other.'**
  String get helpAirqrIntro;

  /// Help › AirQR sharing › section heading
  ///
  /// In en, this message translates to:
  /// **'Send one song'**
  String get helpAirqrS1Heading;

  /// Help › AirQR sharing › Send one song — point 1
  ///
  /// In en, this message translates to:
  /// **'Open the song, then the top-bar menu → \"Share\".'**
  String get helpAirqrS1P1;

  /// Help › AirQR sharing › Send one song — point 2
  ///
  /// In en, this message translates to:
  /// **'Pick \"AirQR stream\" and tap Share.'**
  String get helpAirqrS1P2;

  /// Help › AirQR sharing › Send one song — point 3
  ///
  /// In en, this message translates to:
  /// **'The codes start flashing straight away. Hold the phone still and let the other one read it.'**
  String get helpAirqrS1P3;

  /// Help › AirQR sharing › Send one song — point 4
  ///
  /// In en, this message translates to:
  /// **'What goes across is the song as you are looking at it, so a key you have transposed to travels with it.'**
  String get helpAirqrS1P4;

  /// Help › AirQR sharing › section heading
  ///
  /// In en, this message translates to:
  /// **'Send several songs'**
  String get helpAirqrS2Heading;

  /// Help › AirQR sharing › Send several songs — point 1
  ///
  /// In en, this message translates to:
  /// **'Settings → General → Import → \"Send all via AirQR\" sends the whole songbook.'**
  String get helpAirqrS2P1;

  /// Help › AirQR sharing › Send several songs — point 2
  ///
  /// In en, this message translates to:
  /// **'Or long-press on the Songs list to select some songs and tap the QR icon in the top bar.'**
  String get helpAirqrS2P2;

  /// Help › AirQR sharing › section heading
  ///
  /// In en, this message translates to:
  /// **'Receive'**
  String get helpAirqrS3Heading;

  /// Help › AirQR sharing › Receive — point 1
  ///
  /// In en, this message translates to:
  /// **'On the receiving phone, tap the scan icon in the songbook top bar, or go to Settings → General → Import → \"Import via AirQR\".'**
  String get helpAirqrS3P1;

  /// Help › AirQR sharing › Receive — point 2
  ///
  /// In en, this message translates to:
  /// **'Point the camera at the sending screen and wait. The panel counts the pieces as they arrive.'**
  String get helpAirqrS3P2;

  /// Help › AirQR sharing › Receive — point 3
  ///
  /// In en, this message translates to:
  /// **'When it has everything the phone buzzes and the import preview opens, so you can check the songs before they are saved.'**
  String get helpAirqrS3P3;

  /// Help › AirQR sharing › Receive — point 4
  ///
  /// In en, this message translates to:
  /// **'The gallery icon reads a photo of a code instead of the live camera, for a code someone sent you as a picture.'**
  String get helpAirqrS3P4;

  /// Help › AirQR sharing › section heading
  ///
  /// In en, this message translates to:
  /// **'Getting a clean read'**
  String get helpAirqrS4Heading;

  /// Help › AirQR sharing › Getting a clean read — point 1
  ///
  /// In en, this message translates to:
  /// **'The song is cut into small pieces shown one after another, with spare repair pieces mixed in, so a frame the camera misses is filled in instead of starting again.'**
  String get helpAirqrS4P1;

  /// Help › AirQR sharing › Getting a clean read — point 2
  ///
  /// In en, this message translates to:
  /// **'The \"Stream Speed\" slider on the sending phone runs from 5 to 25 frames a second and starts at 10.'**
  String get helpAirqrS4P2;

  /// Help › AirQR sharing › Getting a clean read — point 3
  ///
  /// In en, this message translates to:
  /// **'An older phone or a dim screen reads better slower. Turn the speed down if the count stops moving.'**
  String get helpAirqrS4P3;

  /// Help › AirQR sharing › Getting a clean read — point 4
  ///
  /// In en, this message translates to:
  /// **'Keep both screens still and bright, roughly a hand-span apart.'**
  String get helpAirqrS4P4;

  /// Help › topic title (appearance)
  ///
  /// In en, this message translates to:
  /// **'Themes & fonts'**
  String get titleHelpAppearance;

  /// Help › Themes & fonts › one-line summary on the hub card
  ///
  /// In en, this message translates to:
  /// **'Make the sheet easy to read'**
  String get helpAppearanceSummary;

  /// Help › Themes & fonts › opening paragraph
  ///
  /// In en, this message translates to:
  /// **'A sheet read on a dark stage and a sheet read at a desk are not the same job. Three settings cover it: the theme, the lyric font, and how big the text is.'**
  String get helpAppearanceIntro;

  /// Help › Themes & fonts › section heading
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get helpAppearanceS1Heading;

  /// Help › Themes & fonts › Theme — point 1
  ///
  /// In en, this message translates to:
  /// **'Settings → Themes offers System theme, Light theme and Dark theme.'**
  String get helpAppearanceS1P1;

  /// Help › Themes & fonts › Theme — point 2
  ///
  /// In en, this message translates to:
  /// **'System follows whatever the phone is set to.'**
  String get helpAppearanceS1P2;

  /// Help › Themes & fonts › Theme — point 3
  ///
  /// In en, this message translates to:
  /// **'Dark is easier on the eyes on a stage and easier on the battery.'**
  String get helpAppearanceS1P3;

  /// Help › Themes & fonts › Theme — point 4
  ///
  /// In en, this message translates to:
  /// **'The choice is saved and takes effect at once.'**
  String get helpAppearanceS1P4;

  /// Help › Themes & fonts › section heading
  ///
  /// In en, this message translates to:
  /// **'Lyric font'**
  String get helpAppearanceS2Heading;

  /// Help › Themes & fonts › Lyric font — point 1
  ///
  /// In en, this message translates to:
  /// **'Settings → Fonts picks the font the words are drawn in: System default, Noto Sans Malayalam, Noto Serif Malayalam, Manjari or Gayathri.'**
  String get helpAppearanceS2P1;

  /// Help › Themes & fonts › Lyric font — point 2
  ///
  /// In en, this message translates to:
  /// **'Each choice shows a live sample in English and in Malayalam, so you can see the letter shapes before you pick.'**
  String get helpAppearanceS2P2;

  /// Help › Themes & fonts › Lyric font — point 3
  ///
  /// In en, this message translates to:
  /// **'The Malayalam fonts shape chillu, conjuncts and vowel signs properly. The system font often does not.'**
  String get helpAppearanceS2P3;

  /// Help › Themes & fonts › Lyric font — point 4
  ///
  /// In en, this message translates to:
  /// **'One choice covers the whole app, and the exported PDF uses the same font.'**
  String get helpAppearanceS2P4;

  /// Help › Themes & fonts › Lyric font — point 5
  ///
  /// In en, this message translates to:
  /// **'The fonts are bundled with the app under an open licence and are listed on the licences page in About.'**
  String get helpAppearanceS2P5;

  /// Help › Themes & fonts › section heading
  ///
  /// In en, this message translates to:
  /// **'Text size'**
  String get helpAppearanceS3Heading;

  /// Help › Themes & fonts › Text size — point 1
  ///
  /// In en, this message translates to:
  /// **'Pinch the words with two fingers to make the text bigger or smaller, from 10 up to 32.'**
  String get helpAppearanceS3P1;

  /// Help › Themes & fonts › Text size — point 2
  ///
  /// In en, this message translates to:
  /// **'It works on the ordinary song screen and in full screen, and it does not disturb the scrolling.'**
  String get helpAppearanceS3P2;

  /// Help › Themes & fonts › Text size — point 3
  ///
  /// In en, this message translates to:
  /// **'The pitch sheet also has five fixed sizes — 85%, 95%, 100%, 115% and 130% — which multiply whatever the pinch has set. Use those to set a stage size once and keep it.'**
  String get helpAppearanceS3P3;

  /// Shown when a help link points to a topic that does not exist
  ///
  /// In en, this message translates to:
  /// **'Help topic not found.'**
  String get helpTopicNotFound;

  /// AirQR frame rate, in frames per second
  ///
  /// In en, this message translates to:
  /// **'{fps} FPS'**
  String labelAirQrFps(String fps);

  /// Error: the song list could not be read
  ///
  /// In en, this message translates to:
  /// **'Could not load songs.'**
  String get errorStorageLoadSongs;

  /// Error: one song could not be read
  ///
  /// In en, this message translates to:
  /// **'Could not open the song.'**
  String get errorStorageOpenSong;

  /// Error: looking up a song by title failed
  ///
  /// In en, this message translates to:
  /// **'Could not search for song by title.'**
  String get errorStorageFindSongByTitle;

  /// Error: a new song could not be saved
  ///
  /// In en, this message translates to:
  /// **'Could not save the song.'**
  String get errorStorageSaveSong;

  /// Error: changes to a song could not be saved
  ///
  /// In en, this message translates to:
  /// **'Could not update the song.'**
  String get errorStorageUpdateSong;

  /// Error: the song scroll speed could not be saved
  ///
  /// In en, this message translates to:
  /// **'Could not save the scroll speed.'**
  String get errorStorageSaveScrollSpeed;

  /// Error: a song could not be deleted
  ///
  /// In en, this message translates to:
  /// **'Could not delete the song.'**
  String get errorStorageDeleteSong;

  /// Error: a new setlist could not be saved
  ///
  /// In en, this message translates to:
  /// **'Could not create setlist.'**
  String get errorStorageCreateSetlist;

  /// Error: setlist name or description could not be saved
  ///
  /// In en, this message translates to:
  /// **'Could not update setlist.'**
  String get errorStorageUpdateSetlist;

  /// Error: the songs in a setlist could not be saved
  ///
  /// In en, this message translates to:
  /// **'Could not update setlist songs.'**
  String get errorStorageUpdateSetlistSongs;

  /// Error: a song could not be added to a setlist
  ///
  /// In en, this message translates to:
  /// **'Could not add song to setlist.'**
  String get errorStorageAddSongToSetlist;

  /// Error: a setlist could not be deleted
  ///
  /// In en, this message translates to:
  /// **'Could not delete setlist.'**
  String get errorStorageDeleteSetlist;

  /// Error: the two-second chord sound did not play
  ///
  /// In en, this message translates to:
  /// **'Could not play the chord cue.'**
  String get errorDroneErrorChordCue;

  /// Error: the two-second pitch sound did not play
  ///
  /// In en, this message translates to:
  /// **'Could not play the pitch cue.'**
  String get errorDroneErrorPitchCue;

  /// Error: the continuous drone did not start
  ///
  /// In en, this message translates to:
  /// **'Could not start the drone.'**
  String get errorDroneErrorStartDrone;

  /// Melody line problem: part of a beat is not a swara or mark
  ///
  /// In en, this message translates to:
  /// **'Could not read \"{piece}\" in \"{token}\".'**
  String errorMelodyProblemUnreadable(String piece, String token);

  /// Melody line problem: a beat holds nothing to sound
  ///
  /// In en, this message translates to:
  /// **'Nothing to play in \"{token}\".'**
  String errorMelodyProblemNothingToPlay(String token);

  /// Carnatic import problem: the tala name is unknown
  ///
  /// In en, this message translates to:
  /// **'Could not work out how many beats \"{tala}\" has.'**
  String errorCarnaticProblemUnknownTala(String tala);

  /// Carnatic import problem: nothing was pasted
  ///
  /// In en, this message translates to:
  /// **'No notation found to read.'**
  String get errorCarnaticProblemNoNotation;

  /// Carnatic import problem: some cycles do not match the tala
  ///
  /// In en, this message translates to:
  /// **'{fitting} of {total} cycles land on {tala}. The rest are the wrong length, so some beats will be off.'**
  String errorCarnaticProblemCyclesOff(int fitting, int total, String tala);

  /// Carnatic import problem: both case readings fit equally
  ///
  /// In en, this message translates to:
  /// **'Both readings of upper/lower case score the same, so the choice between them is a guess. Check it against the source page.'**
  String get errorCarnaticProblemReadingsTie;

  /// Carnatic import problem for one cycle (shown after "Cycle N: "): nothing could be read
  ///
  /// In en, this message translates to:
  /// **'nothing readable'**
  String get errorCarnaticProblemNothingReadable;

  /// Carnatic import problem for one cycle (shown after "Cycle N: "): wrong length
  ///
  /// In en, this message translates to:
  /// **'reads as {got} aksharakalas, but this tala wants {wanted}'**
  String errorCarnaticProblemWrongLength(String got, int wanted);

  /// Carnatic import problem for one cycle (shown after "Cycle N: "): unknown character
  ///
  /// In en, this message translates to:
  /// **'could not read \"{character}\" in \"{token}\"'**
  String errorCarnaticProblemUnreadableCharacter(
    String character,
    String token,
  );

  /// Puts the cycle (avarta) number in front of a Carnatic import problem
  ///
  /// In en, this message translates to:
  /// **'Cycle {cycle}: {problem}'**
  String errorCarnaticProblemInCycle(int cycle, String problem);

  /// Shown in release builds in place of a widget that failed to build. Keep it calm and short; no technical detail.
  ///
  /// In en, this message translates to:
  /// **'This part of the screen could not be shown.'**
  String get errorWidgetFailed;

  /// Title of the screen shown when the app fails to start. Short label.
  ///
  /// In en, this message translates to:
  /// **'Could not start'**
  String get titleStartupFailed;

  /// Body text of the start-up failure screen. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'LyricChord could not open its saved data. Your songs have not been changed. Try again, or copy the details to report the problem.'**
  String get descStartupFailed;

  /// Button on the start-up failure screen that copies technical details for a bug report. Keep to one or two words.
  ///
  /// In en, this message translates to:
  /// **'Copy details'**
  String get actionCopyDetails;

  /// SnackBar after the start-up failure details were copied.
  ///
  /// In en, this message translates to:
  /// **'Details copied'**
  String get bodyDetailsCopied;

  /// Tooltip on a custom back button in a screen's top bar. One word.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get tooltipBack;

  /// Tooltip on the AirQR scanner's flashlight button while the light is off. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Turn on flashlight'**
  String get tooltipAirQrReceiverTorchOn;

  /// Tooltip on the AirQR scanner's flashlight button while the light is on. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Turn off flashlight'**
  String get tooltipAirQrReceiverTorchOff;

  /// Tooltip on the AirQR scanner button that swaps front and back cameras. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Switch camera'**
  String get tooltipAirQrReceiverSwitchCamera;

  /// About-screen row label for the author detail (details key 'author').
  ///
  /// In en, this message translates to:
  /// **'Author'**
  String get aboutDetailAuthor;

  /// About-screen row label for the support email (details key 'email').
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get aboutDetailEmail;

  /// About-screen row label for the license note (details key 'license').
  ///
  /// In en, this message translates to:
  /// **'License'**
  String get aboutDetailLicense;

  /// About-screen row label for the website (details key 'website').
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get aboutDetailWebsite;

  /// About-screen row label for the privacy policy link (details key 'privacyPolicy').
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get aboutDetailPrivacyPolicy;

  /// About-screen row label: the AI tool used to build the app (details key 'aiUsed').
  ///
  /// In en, this message translates to:
  /// **'AI used'**
  String get aboutDetailAiUsed;

  /// About-screen row label: the code editor used to build the app (details key 'ideUsed').
  ///
  /// In en, this message translates to:
  /// **'IDE used'**
  String get aboutDetailIdeUsed;

  /// Settings card title: delete every song, setlist and setting. Short label.
  ///
  /// In en, this message translates to:
  /// **'Delete all data'**
  String get titleSettingsDeleteAllData;

  /// Settings card subtitle for Delete all data.
  ///
  /// In en, this message translates to:
  /// **'Remove every song, setlist and setting'**
  String get descSettingsDeleteAllDataSubtitle;

  /// Title of the dialog that confirms deleting all app data. Short title.
  ///
  /// In en, this message translates to:
  /// **'Delete all data?'**
  String get titleDeleteAllData;

  /// Body of the dialog that confirms deleting all app data.
  ///
  /// In en, this message translates to:
  /// **'Every song, setlist, note and setting on this phone will be deleted. This cannot be undone. LyricChord then starts fresh, with its sample songs.'**
  String get descDeleteAllData;

  /// Destructive confirm button in the Delete all data dialog. Keep to one or two words.
  ///
  /// In en, this message translates to:
  /// **'Delete everything'**
  String get actionDeleteEverything;

  /// SnackBar after all app data was deleted and the app started fresh.
  ///
  /// In en, this message translates to:
  /// **'All data deleted'**
  String get bodyAllDataDeleted;

  /// Error: deleting all app data did not fully work.
  ///
  /// In en, this message translates to:
  /// **'Could not delete all data. Some of it may still be there.'**
  String get errorStorageDeleteAllData;

  /// Help › Your songbook › section heading
  ///
  /// In en, this message translates to:
  /// **'Start fresh'**
  String get helpSongbookS6Heading;

  /// Help › Your songbook › Start fresh — point 1
  ///
  /// In en, this message translates to:
  /// **'Settings → Delete all data removes every song, setlist, note and setting from this phone. It cannot be undone.'**
  String get helpSongbookS6P1;

  /// Help › Your songbook › Start fresh — point 2
  ///
  /// In en, this message translates to:
  /// **'LyricChord then starts as it did when first installed, with its sample songs.'**
  String get helpSongbookS6P2;

  /// Help › Your songbook › Start fresh — point 3
  ///
  /// In en, this message translates to:
  /// **'Export your songs first if you may want them back (see the Export topic).'**
  String get helpSongbookS6P3;

  /// Settings card and screen title: the app language. Short title.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get titleSettingsLanguage;

  /// Language choice: follow the phone's language. Short label.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get labelLanguageSystem;

  /// Tablet split view: button on the divider that hides the song list. Short tooltip.
  ///
  /// In en, this message translates to:
  /// **'Hide list'**
  String get tooltipHideList;

  /// Tablet split view: button on the divider that shows the hidden song list again. Short tooltip.
  ///
  /// In en, this message translates to:
  /// **'Show list'**
  String get tooltipShowList;

  /// Screen-reader label for the tablet divider between the song list and the song.
  ///
  /// In en, this message translates to:
  /// **'Drag to resize the song list. Double-tap to hide or show it.'**
  String get descResizeListHandle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ml', 'sa'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ml':
      return AppLocalizationsMl();
    case 'sa':
      return AppLocalizationsSa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
