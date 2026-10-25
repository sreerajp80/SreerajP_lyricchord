// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Malayalam (`ml`).
class AppLocalizationsMl extends AppLocalizations {
  AppLocalizationsMl([String locale = 'ml']) : super(locale);

  @override
  String get titleApp => 'LyricChord';

  @override
  String get titleAbout => 'ആപ്പിനെക്കുറിച്ച്';

  @override
  String get titleSettings => 'ക്രമീകരണങ്ങൾ';

  @override
  String get titleSongs => 'പാട്ടുകൾ';

  @override
  String get titleSetlists => 'പാട്ടുപട്ടികകൾ';

  @override
  String get labelSearch => 'തിരയുക';

  @override
  String get actionCancel => 'റദ്ദാക്കുക';

  @override
  String get actionSave => 'സൂക്ഷിക്കുക';

  @override
  String get actionDelete => 'ഇല്ലാതാക്കുക';

  @override
  String get actionEdit => 'തിരുത്തുക';

  @override
  String get labelStageUnlockReason => 'വേദി രീതി തുറക്കുക';

  @override
  String get bodyStageUnlockDenied =>
      'വേദി ഇപ്പോഴും പൂട്ടിയിരിക്കുന്നു. തുടരാൻ തുറക്കുക.';

  @override
  String get bodyStageUnlockedWithoutCheck =>
      'വേദി തുറന്നു. സ്ക്രീൻ പൂട്ടിന്റെ പരിശോധന ലഭ്യമായിരുന്നില്ല.';

  @override
  String get bodyQuietModeOn =>
      'നിശ്ശബ്ദ രീതി സജീവം: വിളികളും അറിയിപ്പുകളും നിശ്ശബ്ദമാക്കി.';

  @override
  String get bodyQuietModeOff =>
      'നിശ്ശബ്ദ രീതി അവസാനിച്ചു: ഫോണിന്റെ ശബ്ദം തിരികെയെത്തി.';

  @override
  String get bodyQuietModeNeedsAccess =>
      'വിളികൾ നിശ്ശബ്ദമാക്കാൻ LyricChord-ന് “ശല്യപ്പെടുത്തരുത്” അനുമതി നൽകുക.';

  @override
  String get actionQuietModeOpenSettings => 'ക്രമീകരണം തുറക്കുക';

  @override
  String get errorQuietModeFailed => 'ഫോൺ നിശ്ശബ്ദമാക്കാൻ കഴിഞ്ഞില്ല.';

  @override
  String get bodyQuietModeUnsupported => 'ഈ ഉപകരണത്തിൽ നിശ്ശബ്ദ രീതി ലഭ്യമല്ല.';

  @override
  String errorImportFileTooLarge(String fileName, int limitMb) {
    return '$fileName ഇറക്കുമതി ചെയ്യാൻ വളരെ വലുതാണ് (പരിധി $limitMb MB).';
  }

  @override
  String errorImportFileUnreadable(String fileName) {
    return '$fileName വായിക്കാൻ കഴിഞ്ഞില്ല.';
  }

  @override
  String errorImportNoSongsFound(String fileName) {
    return '$fileName-ൽ പാട്ടുകളൊന്നും കണ്ടെത്തിയില്ല.';
  }

  @override
  String errorImportFilesSkippedTooLarge(int limitMb, String fileNames) {
    return '$limitMb MB-യിൽ കൂടിയ ഫയലുകൾ ഒഴിവാക്കി: $fileNames';
  }

  @override
  String errorImportFilesSkippedUnreadable(String fileNames) {
    return 'വായിക്കാൻ കഴിഞ്ഞില്ല: $fileNames';
  }

  @override
  String get errorAirQrTransferFailed =>
      'കൈമാറ്റം പരാജയപ്പെട്ടു. “പുനഃസജ്ജമാക്കുക” അമർത്തി വീണ്ടും സ്കാൻ ചെയ്യുക.';

  @override
  String get actionAirQrReset => 'പുനഃസജ്ജമാക്കുക';

  @override
  String get actionCreate => 'സൃഷ്ടിക്കുക';

  @override
  String get actionShare => 'പങ്കിടുക';

  @override
  String get actionTryAgain => 'വീണ്ടും ശ്രമിക്കുക';

  @override
  String get titleHomePickSong => 'പാട്ട് തിരഞ്ഞെടുക്കൂ';

  @override
  String get descHomePickSongMessage =>
      'ഇവിടെ തുറക്കാൻ ഇടതുവശത്തുനിന്ന് ഒരു പാട്ട് തിരഞ്ഞെടുക്കുക.';

  @override
  String get descAppSubtitle => 'വരികളുടെയും കോർഡുകളുടെയും പുസ്തകം';

  @override
  String titleSongListSelectedCount(int count) {
    return '$count തിരഞ്ഞെടുത്തു';
  }

  @override
  String get tooltipSongListCancelSelection => 'തിരഞ്ഞെടുപ്പ് റദ്ദാക്കുക';

  @override
  String get tooltipSongListExportSelected => 'കയറ്റുമതി ചെയ്യുക';

  @override
  String get tooltipSongListShareSelectedAirQr => 'AirQR വഴി അയയ്ക്കുക';

  @override
  String get tooltipSongListShareSelected => 'തിരഞ്ഞെടുത്തവ പങ്കിടുക';

  @override
  String get tooltipSongListSelectAll => 'എല്ലാം തിരഞ്ഞെടുക്കുക';

  @override
  String get tooltipSongListDeselectAll => 'എല്ലാം ഒഴിവാക്കുക';

  @override
  String get tooltipSongListDeleteSelected => 'തിരഞ്ഞെടുത്തവ നീക്കുക';

  @override
  String get tooltipSongListScanAirQr => 'AirQR പാട്ട് സ്വീകരിക്കുക';

  @override
  String get tooltipSongListNewSong => 'പുതിയ പാട്ട്';

  @override
  String get titleSongListExportDialog => 'തിരഞ്ഞെടുത്തവ കയറ്റുമതി';

  @override
  String bodySongListExported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count പാട്ടുകൾ കയറ്റുമതി ചെയ്തു.',
      one: '1 പാട്ട് കയറ്റുമതി ചെയ്തു.',
    );
    return '$_temp0';
  }

  @override
  String get errorSongListExportFailed =>
      'തിരഞ്ഞെടുത്ത പാട്ടുകൾ കയറ്റുമതി ചെയ്യാൻ കഴിഞ്ഞില്ല.';

  @override
  String titleSongListShareDialog(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count പാട്ടുകൾ പങ്കിടുക',
      one: '1 പാട്ട് പങ്കിടുക',
    );
    return '$_temp0';
  }

  @override
  String get labelSongListFormatChordPro => 'ChordPro (.chordpro)';

  @override
  String get labelSongListFormatPdf => 'PDF (.pdf)';

  @override
  String get errorSongListShareFailed =>
      'തിരഞ്ഞെടുത്ത പാട്ടുകൾ പങ്കിടാൻ കഴിഞ്ഞില്ല.';

  @override
  String get errorSongListPdfFailed => 'PDF ഉണ്ടാക്കാൻ കഴിഞ്ഞില്ല.';

  @override
  String get errorSongListSharePdfFailed =>
      'തിരഞ്ഞെടുത്ത പാട്ടുകൾ PDF ആയി പങ്കിടാൻ കഴിഞ്ഞില്ല.';

  @override
  String titleSongListDeleteMany(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count പാട്ടുകൾ ഇല്ലാതാക്കണോ?',
      one: '1 പാട്ട് ഇല്ലാതാക്കണോ?',
    );
    return '$_temp0';
  }

  @override
  String get descSongListDeleteManyMessage =>
      'തിരഞ്ഞെടുത്ത പാട്ടുകൾ നിങ്ങളുടെ പാട്ടുപുസ്തകത്തിൽനിന്ന് നീക്കും.';

  @override
  String bodySongListDeletedMany(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count പാട്ടുകൾ ഇല്ലാതാക്കി.',
      one: '1 പാട്ട് ഇല്ലാതാക്കി.',
    );
    return '$_temp0';
  }

  @override
  String bodySongListCopied(String title) {
    return '\"$title\" പകർത്തി.';
  }

  @override
  String get titleSongListDeleteOne => 'പാട്ട് ഇല്ലാതാക്കണോ?';

  @override
  String descSongListDeleteOneMessage(String title) {
    return '\"$title\" നിങ്ങളുടെ പാട്ടുപുസ്തകത്തിൽനിന്ന് നീക്കും.';
  }

  @override
  String bodySongListDeletedOne(String title) {
    return '\"$title\" ഇല്ലാതാക്കി.';
  }

  @override
  String titleSongListAirQr(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'തിരഞ്ഞെടുത്ത $count പാട്ടുകൾ',
      one: 'തിരഞ്ഞെടുത്ത 1 പാട്ട്',
    );
    return '$_temp0';
  }

  @override
  String get emptySongbookNoMatchesTitle => 'പൊരുത്തങ്ങളില്ല';

  @override
  String get emptySongbookNoMatchesMessage =>
      'തിരച്ചിലിന് പൊരുത്തപ്പെടുന്ന പാട്ടൊന്നുമില്ല. മറ്റു വാക്കുകൾ ശ്രമിക്കുക.';

  @override
  String get emptySongbookNoStarredTitle => 'നക്ഷത്രമിട്ട പാട്ടുകളില്ല';

  @override
  String get emptySongbookNoStarredMessage =>
      'ഒരു പാട്ട് ഇവിടെ സൂക്ഷിക്കാൻ അതിലെ നക്ഷത്രം അമർത്തുക.';

  @override
  String get emptySongbookEmptyTitle => 'നിങ്ങളുടെ പാട്ടുപുസ്തകം ശൂന്യമാണ്';

  @override
  String get emptySongbookEmptyMessage =>
      'ആദ്യത്തെ കോർഡ് ഷീറ്റ് എഴുതാൻ + അമർത്തുക.';

  @override
  String get errorSongbookErrorTitle => 'പാട്ടുപുസ്തകം തുറക്കാൻ കഴിഞ്ഞില്ല';

  @override
  String get errorSongbookErrorMessage =>
      'നിങ്ങളുടെ പാട്ടുകൾ ഇപ്പോഴും സുരക്ഷിതമാണ്. ആപ്പിന് ഇപ്പോൾ അവ വായിക്കാൻ കഴിഞ്ഞില്ല.';

  @override
  String labelSongCardKeySemantics(String key) {
    return 'ശ്രുതി $key';
  }

  @override
  String labelSongCardBpm(int bpm) {
    return '$bpm BPM';
  }

  @override
  String descSongCardBpmSemantics(int bpm) {
    return 'മിനിറ്റിൽ $bpm താളം';
  }

  @override
  String get tooltipSongCardAddStar => 'നക്ഷത്രമിടുക';

  @override
  String get tooltipSongCardRemoveStar => 'നക്ഷത്രം നീക്കുക';

  @override
  String get tooltipSongCardDuplicate => 'പാട്ട് പകർത്തുക';

  @override
  String get tooltipSongCardDelete => 'പാട്ട് ഇല്ലാതാക്കുക';

  @override
  String get descSongSearchHint => 'പാട്ട്, കലാകാരൻ, വരികൾ തിരയുക';

  @override
  String get tooltipSongSearchClear => 'തിരച്ചിൽ മായ്ക്കുക';

  @override
  String labelSongFilterAll(int count) {
    return 'എല്ലാം ($count)';
  }

  @override
  String labelSongFilterStarred(int count) {
    return 'നക്ഷത്രമിട്ടവ ($count)';
  }

  @override
  String errorSetlistLoad(String error) {
    return 'പാട്ടുപട്ടികകൾ ലോഡ് ചെയ്യുന്നതിൽ പിശക്: $error';
  }

  @override
  String get emptySetlistEmptyTitle => 'ഇതുവരെ പാട്ടുപട്ടികകളില്ല';

  @override
  String get emptySetlistEmptyMessage =>
      'പരിപാടികൾക്കും പരിശീലനത്തിനുമായി പാട്ടുകൾ കൂട്ടിവെച്ച് ക്രമീകരിക്കാൻ പാട്ടുപട്ടികകൾ സൃഷ്ടിക്കുക.';

  @override
  String get actionSetlistCreate => 'പട്ടിക സൃഷ്ടിക്കുക';

  @override
  String labelSetlistSongCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count പാട്ടുകൾ',
      one: '1 പാട്ട്',
    );
    return '$_temp0';
  }

  @override
  String get actionSetlistPerform => 'അവതരിപ്പിക്കുക';

  @override
  String get actionSetlistEditSongs => 'പാട്ടുകൾ തിരുത്തുക';

  @override
  String get actionSetlistNew => 'പുതിയ പട്ടിക';

  @override
  String get titleSetlist => 'പാട്ടുപട്ടിക';

  @override
  String errorSetlistLoadOne(String error) {
    return 'പാട്ടുപട്ടിക ലോഡ് ചെയ്യുന്നതിൽ പിശക്: $error';
  }

  @override
  String get errorSetlistNotFound => 'പാട്ടുപട്ടിക കണ്ടെത്തിയില്ല.';

  @override
  String get tooltipSetlistShareAirQr => 'AirQR വഴി അയയ്ക്കുക';

  @override
  String get tooltipSetlistEditInfo => 'പട്ടിക വിവരം തിരുത്തുക';

  @override
  String get tooltipSetlistDelete => 'പട്ടിക ഇല്ലാതാക്കുക';

  @override
  String get actionSetlistPerformAll => 'പട്ടിക അവതരിപ്പിക്കുക';

  @override
  String titleSetlistSongCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count പാട്ടുകൾ',
      one: '1 പാട്ട്',
    );
    return '$_temp0';
  }

  @override
  String get actionSetlistAddSongs => 'പാട്ടുകൾ ചേർക്കുക';

  @override
  String get emptySetlistNoSongs => 'ഈ പട്ടികയിൽ പാട്ടുകളില്ല';

  @override
  String get actionSetlistAddSongsNow => 'പാട്ടുകൾ ചേർക്കൂ';

  @override
  String descSetlistSongDetails(String key, int bpm) {
    return 'ശ്രുതി: $key • $bpm BPM';
  }

  @override
  String descSetlistSongDetailsWithArtist(String artist, String key, int bpm) {
    return '$artist • ശ്രുതി: $key • $bpm BPM';
  }

  @override
  String get tooltipSetlistRemoveSong => 'പട്ടികയിൽനിന്ന് നീക്കുക';

  @override
  String get titleSetlistDelete => 'പട്ടിക ഇല്ലാതാക്കണോ?';

  @override
  String descSetlistDeleteMessage(String name) {
    return '\"$name\" ഇല്ലാതാക്കും. നിങ്ങളുടെ പാട്ടുപുസ്തകത്തിലെ പാട്ടുകൾ ഇല്ലാതാകില്ല.';
  }

  @override
  String bodySetlistDeleted(String name) {
    return '\"$name\" പട്ടിക ഇല്ലാതാക്കി.';
  }

  @override
  String get bodySetlistNothingToShare => 'പങ്കിടാൻ പട്ടികയിൽ പാട്ടുകളില്ല.';

  @override
  String titleSetlistAirQr(String name) {
    return 'പട്ടിക: $name';
  }

  @override
  String get titleSetlistEdit => 'പട്ടിക തിരുത്തുക';

  @override
  String get labelSetlistName => 'പട്ടികയുടെ പേര്';

  @override
  String get descSetlistNameHint => 'ഉദാ. ഞായറാഴ്ച പരിപാടി, പരിശീലനം';

  @override
  String get errorSetlistNameRequired => 'പട്ടികയ്ക്ക് ഒരു പേര് നൽകുക';

  @override
  String get labelSetlistDescription => 'വിവരങ്ങൾ (ഐച്ഛികം)';

  @override
  String get descSetlistDescriptionHint => 'ഉദാ. വേദി, ഗായകർ, കുറിപ്പുകൾ';

  @override
  String get titleSetlistPicker => 'പട്ടികയിൽ പാട്ടുകൾ ചേർക്കുക';

  @override
  String actionSetlistPickerDone(int count) {
    return 'പൂർത്തിയായി ($count)';
  }

  @override
  String get descSetlistPickerSearchHint => 'പാട്ടുകൾ തിരയുക...';

  @override
  String errorSetlistPickerLoad(String error) {
    return 'പാട്ടുകൾ ലോഡ് ചെയ്യുന്നതിൽ പിശക്: $error';
  }

  @override
  String get emptySetlistPickerNoSongs => 'പാട്ടുകളൊന്നും കണ്ടെത്തിയില്ല';

  @override
  String get actionDiscard => 'ഉപേക്ഷിക്കുക';

  @override
  String get actionKeepEditing => 'തിരുത്തൽ തുടരുക';

  @override
  String get actionInsert => 'ഉൾപ്പെടുത്തുക';

  @override
  String get actionAdd => 'ചേർക്കുക';

  @override
  String get actionClear => 'മായ്ക്കുക';

  @override
  String get labelTraditionWestern => 'പാശ്ചാത്യം';

  @override
  String get labelTraditionCarnatic => 'കർണാടക';

  @override
  String get labelTraditionHindustani => 'ഹിന്ദുസ്ഥാനി';

  @override
  String get descCarnaticReadingDuration =>
      'അക്ഷരവലുപ്പം സ്വരദൈർഘ്യം കാണിക്കുന്നു';

  @override
  String get descCarnaticReadingOctave => 'അക്ഷരവലുപ്പം സ്ഥായി കാണിക്കുന്നു';

  @override
  String get titleEditorNew => 'പുതിയ പാട്ട്';

  @override
  String get titleEditorEdit => 'പാട്ട് തിരുത്തുക';

  @override
  String get tooltipEditorUndo => 'പഴയപടിയാക്കുക';

  @override
  String get tooltipEditorRedo => 'വീണ്ടും ചെയ്യുക';

  @override
  String get tooltipEditorMoreOptions => 'കൂടുതൽ';

  @override
  String get actionEditorMelodyKeypad => 'ഈണ കീപാഡ്';

  @override
  String get actionEditorPasteCarnatic => 'കർണാടക ഒട്ടിക്കുക';

  @override
  String get actionEditorSaveAsCopy => 'പകർപ്പായി സൂക്ഷിക്കുക';

  @override
  String get errorEditorLoad => 'ഈ പാട്ട് തുറക്കാൻ കഴിഞ്ഞില്ല.';

  @override
  String get descEditorLyricsHint =>
      'വരികൾ ഇവിടെ എഴുതുക.\nകഴ്സറിൽ ചേർക്കാൻ മുകളിലെ ഒരു കോർഡ് അമർത്തുക.';

  @override
  String errorEditorNeedsTala(String directive) {
    return 'ആദ്യം ഒരു $directive വരി ചേർക്കുക — താളത്തിന്റെ മാത്രകളുമായി ഒത്തുനോക്കിയാണ് സ്വരലിപി പരിശോധിക്കുന്നത്.';
  }

  @override
  String get titleEditorDiscard => 'മാറ്റങ്ങൾ ഉപേക്ഷിക്കണോ?';

  @override
  String get descEditorDiscardMessage =>
      'ഈ പാട്ടിൽ വരുത്തിയ മാറ്റങ്ങൾ സൂക്ഷിക്കില്ല.';

  @override
  String get labelEditorUntitled => 'പേരില്ലാത്തത്';

  @override
  String get labelUntitledSong => 'പേരില്ലാത്ത പാട്ട്';

  @override
  String labelSongCopyTitle(String title) {
    return '$title (പകർപ്പ്)';
  }

  @override
  String labelEditorSummaryKey(String key) {
    return 'ശ്രുതി $key';
  }

  @override
  String labelEditorSummaryBpm(String bpm) {
    return '$bpm BPM';
  }

  @override
  String descEditorTalaWarning(String tala, String tradition) {
    return '\"$tala\" സാധാരണയായി ഒരു $tradition താളമാണ്. എങ്കിലും സൂക്ഷിക്കാം.';
  }

  @override
  String get labelSongMetaTitle => 'ശീർഷകം';

  @override
  String get labelSongMetaTitleHint => 'പാട്ടിന്റെ ശീർഷകം';

  @override
  String get labelSongMetaArtist => 'കലാകാരൻ / സംഘം';

  @override
  String get labelSongMetaArtistHint => 'ആരാണ് പാടുന്നത്';

  @override
  String get labelSongMetaNotation => 'സ്വരലിപി';

  @override
  String get descSongMetaNotationHelper =>
      'പാശ്ചാത്യം കോർഡുകൾ ഉപയോഗിക്കുന്നു. ഭാരതീയം സ്വരങ്ങൾ ഉപയോഗിക്കുന്നു.';

  @override
  String get labelSongMetaRaga => 'രാഗം';

  @override
  String get labelSongMetaRagaHint => 'കല്യാണി, യമൻ';

  @override
  String get labelSongMetaKey => 'മൂല ശ്രുതി';

  @override
  String get labelSongMetaKeyHint => 'C, Am, F#m';

  @override
  String get labelSongMetaTempo => 'വേഗം (BPM)';

  @override
  String get labelSongMetaTempoHint => '120';

  @override
  String get labelSongMetaTala => 'താളം';

  @override
  String get labelSongMetaTalaHint => 'ആദി, കഹർവ';

  @override
  String get labelSongMetaSetlist => 'പട്ടികയിൽ ചേർക്കുക';

  @override
  String get labelSongMetaSetlistNone => 'ഒന്നുമില്ല (ചേർക്കേണ്ട)';

  @override
  String tooltipChordInserterInsert(String chord) {
    return '[$chord] ചേർക്കുക';
  }

  @override
  String get actionChordInserterCustom => 'സ്വന്തം';

  @override
  String get tooltipChordInserterCustom => 'സ്വന്തം കോർഡ് ചേർക്കുക';

  @override
  String get titleChordInserterDialog => 'സ്വന്തം കോർഡ്';

  @override
  String get labelChordInserterChord => 'കോർഡ്';

  @override
  String get labelChordInserterChordHint => 'F#m7, Cmaj7, D/F#';

  @override
  String get titleRenameImport => 'ഒരേ ശീർഷകമുള്ള പാട്ട്';

  @override
  String descRenameImportExists(String title) {
    return '\"$title\" എന്ന ശീർഷകമുള്ള ഒരു പാട്ട് നിങ്ങളുടെ പാട്ടുപുസ്തകത്തിൽ ഇതിനകം ഉണ്ട്.';
  }

  @override
  String get descRenameImportPrompt =>
      'ഇറക്കുമതി ചെയ്യുന്ന പാട്ടിന് പുതിയ ശീർഷകം നൽകുക:';

  @override
  String get labelRenameImport => 'പാട്ടിന്റെ ശീർഷകം';

  @override
  String get errorRenameImportRequired => 'ഒരു ശീർഷകം നൽകുക';

  @override
  String get actionRenameImportSave => 'പുതിയ പേരിൽ സൂക്ഷിക്കുക';

  @override
  String get titleMelodyKeypadDiscard => 'ഈ ഈണം ഉപേക്ഷിക്കണോ?';

  @override
  String get descMelodyKeypadDiscardMessage => 'നിങ്ങൾ അമർത്തിയത് നഷ്ടമാകും.';

  @override
  String get labelMelodyKeypadHold => 'നീട്ട് ,';

  @override
  String get tooltipMelodyKeypadHold => 'ഒരു മാത്ര കൂടി നീട്ടുക';

  @override
  String get labelMelodyKeypadBar => 'വിഭാഗം |';

  @override
  String get tooltipMelodyKeypadBar => 'വിഭാഗ രേഖ';

  @override
  String get labelMelodyKeypadShare => 'പങ്ക് -';

  @override
  String get tooltipMelodyKeypadShare => 'ഈ മാത്ര പങ്കിടുക';

  @override
  String get labelMelodyKeypadTie => 'ബന്ധം ,-';

  @override
  String get tooltipMelodyKeypadTie => 'മാത്രയുടെ നടുവിൽ തുടങ്ങുക';

  @override
  String get labelMelodyKeypadSilence => 'നിശ്ശബ്ദം x';

  @override
  String get tooltipMelodyKeypadSilence => 'ശബ്ദം നിർത്തുക';

  @override
  String get labelMelodyKeypadOctaveUp => 'സ്ഥായി ↑';

  @override
  String get labelMelodyKeypadOctaveDown => 'സ്ഥായി ↓';

  @override
  String get labelMelodyKeypadSlide => 'ജാരു !';

  @override
  String get labelMelodyKeypadShake => 'കമ്പിതം ~';

  @override
  String get tooltipMelodyKeypadBackspace => 'അവസാനത്തേത് മായ്ക്കുക';

  @override
  String labelMelodyKeypadBeats(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count മാത്രകൾ',
      one: '1 മാത്ര',
    );
    return '$_temp0';
  }

  @override
  String descMelodyKeypadFits(int count, String tala) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count മാത്രകൾ — $tala-ന് ചേരുന്നു',
      one: '1 മാത്ര — $tala-ന് ചേരുന്നു',
    );
    return '$_temp0';
  }

  @override
  String labelMelodyKeypadOfBeats(int count, int total) {
    return '$total-ൽ $count മാത്ര';
  }

  @override
  String get descMelodyKeypadStartHint =>
      'തുടങ്ങാൻ ഒരു സ്വരം അമർത്തുക. “നീട്ട്” ഒരു മാത്ര കൂട്ടുന്നു, “വിഭാഗം” ഒരു കൂട്ടം അടയാളപ്പെടുത്തുന്നു.';

  @override
  String descCarnaticSheetHelp(String tala) {
    return 'താളം: $tala. ഓരോ വരിയിലും ഒരു ആവർത്തം ഒട്ടിക്കുക, അല്ലെങ്കിൽ || കൊണ്ട് വേർതിരിക്കുക. അടിവരയിട്ട ഭാഗങ്ങൾ _like_this_ എന്ന് എഴുതുക.';
  }

  @override
  String get labelCarnaticSheetAnyaTitle => 'Ga-Ma-Ri-യിൽ Ma1';

  @override
  String get descCarnaticSheetAnyaSubtitle =>
      'യമുനാകല്യാണി പോലെയുള്ള ഭാഷാംഗ രാഗത്തിന്. സ്വതവേ ഇത് പ്രവർത്തനരഹിതമാണ് — ഏത് മധ്യമമാണെന്ന് സ്വരലിപി പറയുന്നില്ല.';

  @override
  String actionCarnaticSheetInsertLines(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count വരികൾ ചേർക്കുക',
      one: '1 വരി ചേർക്കുക',
    );
    return '$_temp0';
  }

  @override
  String descCarnaticSheetFit(int fitting, int total, String reading) {
    return '$total-ൽ $fitting ആവർത്തങ്ങൾ താളത്തിന് ചേരുന്നു — $reading എന്ന് വായിച്ചു.';
  }

  @override
  String descCarnaticSheetOtherReading(String reading, int fitting, int total) {
    return 'മറ്റേ വായന ($reading) $total-ൽ $fitting എണ്ണത്തിന് ചേരുന്നു.';
  }

  @override
  String descCarnaticSheetAnyaHint(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count ആവർത്തങ്ങളിൽ Ga-Ma-Ri ഇറക്കം കാണുന്നു. ഭാഷാംഗ രാഗത്തിൽ ആ മധ്യമം ശുദ്ധ മധ്യമമാണ്.',
      one:
          '1 ആവർത്തത്തിൽ Ga-Ma-Ri ഇറക്കം കാണുന്നു. ഭാഷാംഗ രാഗത്തിൽ ആ മധ്യമം ശുദ്ധ മധ്യമമാണ്.',
    );
    return '$_temp0';
  }

  @override
  String get labelMelodyLineLoop => 'ആവർത്തിക്കുക';

  @override
  String get labelMelodyLineHalfSpeed => 'പകുതി വേഗം';

  @override
  String get errorMelodyLinePlayFailed => 'ഈ ഈണം വായിക്കാൻ കഴിഞ്ഞില്ല.';

  @override
  String get tooltipMelodyLineStop => 'നിർത്തുക';

  @override
  String get tooltipMelodyLinePlay => 'ഈ വരി മൂളുക';

  @override
  String tooltipMelodyLineNeedsTonic(String directive) {
    return 'ഒരു $directive വരി വേണം';
  }

  @override
  String get actionClose => 'അടയ്ക്കുക';

  @override
  String get actionExport => 'കയറ്റുമതി ചെയ്യുക';

  @override
  String get tooltipPlay => 'തുടങ്ങുക';

  @override
  String get tooltipPause => 'നിർത്തിവയ്ക്കുക';

  @override
  String get actionReset => 'പുനഃസജ്ജമാക്കുക';

  @override
  String labelInfoRaga(String raga) {
    return 'രാഗം $raga';
  }

  @override
  String labelInfoTala(String tala) {
    return 'താളം $tala';
  }

  @override
  String labelInfoKey(String key) {
    return 'ശ്രുതി $key';
  }

  @override
  String labelInfoKeyTransposed(String key, String semitones) {
    return 'ശ്രുതി $key ($semitones)';
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
      other: '$count ബാറുകൾ',
      one: '1 ബാർ',
    );
    return '$_temp0';
  }

  @override
  String get labelInfoAutoScroll => 'സ്വയം നീങ്ങൽ';

  @override
  String get titlePerfSong => 'പാട്ട്';

  @override
  String get tooltipPerfPreviousSong => 'മുമ്പത്തെ പാട്ട്';

  @override
  String get tooltipPerfNextSong => 'അടുത്ത പാട്ട്';

  @override
  String get tooltipPerfSetlistSongs => 'പട്ടികയിലെ പാട്ടുകൾ';

  @override
  String get tooltipPerfEditSong => 'പാട്ട് തിരുത്തുക';

  @override
  String titlePerfSetlistPosition(String name, int position, int total) {
    return '$name ($position/$total)';
  }

  @override
  String get errorPerfNotFoundTitle => 'പാട്ട് കണ്ടെത്തിയില്ല';

  @override
  String get descPerfNotFoundMessage =>
      'ഇത് നിങ്ങളുടെ പാട്ടുപുസ്തകത്തിൽനിന്ന് ഇല്ലാതാക്കിയിരിക്കാം.';

  @override
  String get actionPerfControls => 'അവതരണ നിയന്ത്രണം';

  @override
  String get tooltipPerfGesturesHelp => 'ആംഗ്യ സഹായം';

  @override
  String get actionPerfSwaraReference => 'സ്വര സൂചിക';

  @override
  String get actionPerfChordReferenceGuide => 'കോർഡ് സൂചിക';

  @override
  String get titlePerfExportDialog => 'പാട്ട് കയറ്റുമതി';

  @override
  String get titlePerfShareDialog => 'പാട്ട് പങ്കിടൽ';

  @override
  String get labelPerfFormatAirQr => 'AirQR ധാര';

  @override
  String get errorPerfShareChordProFailed =>
      'ChordPro ഫയൽ പങ്കിടാൻ കഴിഞ്ഞില്ല.';

  @override
  String get errorPerfPdfNoPages =>
      'PDF കയറ്റുമതി ചെയ്യാൻ കഴിഞ്ഞില്ല (താളുകളില്ല).';

  @override
  String get errorPerfPdfTimeout =>
      'PDF കയറ്റുമതിക്ക് വളരെ സമയമെടുത്തു, അതിനാൽ നിർത്തി.';

  @override
  String get errorPerfSharePdfFailed => 'PDF പങ്കിടാൻ കഴിഞ്ഞില്ല.';

  @override
  String get titlePerfExportPdf => 'PDF ആയി കയറ്റുമതി';

  @override
  String get titlePerfExportChordPro => 'ChordPro ആയി കയറ്റുമതി';

  @override
  String bodyPerfExported(String title) {
    return '\"$title\" കയറ്റുമതി ചെയ്തു.';
  }

  @override
  String get errorPerfExportPdfFailed => 'PDF കയറ്റുമതി ചെയ്യാൻ കഴിഞ്ഞില്ല.';

  @override
  String get errorPerfExportChordProFailed =>
      'ChordPro ഫയൽ കയറ്റുമതി ചെയ്യാൻ കഴിഞ്ഞില്ല.';

  @override
  String get tooltipPerfDrone => 'ശ്രുതിക്കുഴലും ശ്രുതിയും';

  @override
  String get tooltipPerfSpeed => 'നീങ്ങൽ വേഗം';

  @override
  String get tooltipPerfHideChords => 'കോർഡുകൾ മറയ്ക്കുക';

  @override
  String get tooltipPerfShowChords => 'കോർഡുകൾ കാണിക്കുക';

  @override
  String get tooltipPerfHideMelody => 'ഈണം മറയ്ക്കുക';

  @override
  String get tooltipPerfShowMelody => 'ഈണം കാണിക്കുക';

  @override
  String get tooltipAutoScrollFullScreen => 'പൂർണ്ണ സ്ക്രീൻ';

  @override
  String get labelAutoScrollManual => 'സ്വമേധയാ';

  @override
  String get labelAutoScrollTempo => 'വേഗം';

  @override
  String get actionAutoScrollManualShort => 'സ്വ';

  @override
  String get actionAutoScrollTempoShort => 'വേ';

  @override
  String get labelTranspose => 'ശ്രുതി മാറ്റം';

  @override
  String get tooltipTransposeDown => 'ശ്രുതി താഴ്ത്തുക';

  @override
  String get tooltipTransposeUp => 'ശ്രുതി ഉയർത്തുക';

  @override
  String get descTransposeMelodySubtitle =>
      'പൂർണ്ണ സ്ക്രീനിൽ ഈണം ഒരിക്കലും കാണിക്കില്ല';

  @override
  String get descTransposePinchTip =>
      'സൂചന: അക്ഷരവലുപ്പം മാറ്റാൻ രണ്ടു വിരലുകൾകൊണ്ട് വരികൾ നുള്ളുക.';

  @override
  String get titleChordRef => 'കോർഡ് സൂചിക';

  @override
  String get emptyChordRefNoSwaras => 'ഈ പാട്ടിൽ സ്വരങ്ങളില്ല';

  @override
  String get emptyChordRefNoChords => 'ഈ പാട്ടിൽ കോർഡുകളില്ല';

  @override
  String get tabChordRefGuitar => 'ഗിറ്റാർ';

  @override
  String get tabChordRefHarmonium => 'ഹാർമോണിയം';

  @override
  String get tooltipStageExitFullScreen => 'പൂർണ്ണ സ്ക്രീൻ വിടുക';

  @override
  String get tooltipStageLock => 'വേദി പൂട്ടുക';

  @override
  String get tooltipStageQuietActive => 'നിശ്ശബ്ദ രീതി നിർത്തുക';

  @override
  String get tooltipStageQuietInactive => 'നിശ്ശബ്ദ രീതി തുടങ്ങുക';

  @override
  String get tooltipStageFewerBars => 'ബാറുകൾ കുറയ്ക്കുക';

  @override
  String get tooltipStageMoreBars => 'ബാറുകൾ കൂട്ടുക';

  @override
  String get tooltipStageSlower => 'പതുക്കെ';

  @override
  String get tooltipStageFaster => 'വേഗത്തിൽ';

  @override
  String get labelStageLocked => 'വേദി പൂട്ടി';

  @override
  String get labelStagePlaying => 'നീങ്ങുന്നു';

  @override
  String get labelStagePaused => 'നിർത്തിവച്ചു';

  @override
  String get descStageHelpSubtitle => 'വാക്കുകൾ മാത്രം, പിന്നെ ഈ ആംഗ്യങ്ങളും.';

  @override
  String get labelStageHelpTapOnce => 'ഒരിക്കൽ തട്ടുക';

  @override
  String get descStageHelpTapOnceMeaning =>
      'നിയന്ത്രണങ്ങൾ കാണിക്കുക അല്ലെങ്കിൽ മറയ്ക്കുക';

  @override
  String get labelStageHelpDoubleTapTop => 'മുകളിൽ രണ്ടുതവണ';

  @override
  String get labelStageHelpDoubleTapBottom => 'താഴെ രണ്ടുതവണ';

  @override
  String get labelStageHelpTwoFingers => 'രണ്ടു വിരൽ തട്ടൽ';

  @override
  String get descStageHelpTwoFingersMeaning =>
      'തുടങ്ങുക അല്ലെങ്കിൽ നിർത്തിവയ്ക്കുക';

  @override
  String get labelStageHelpPinch => 'നുള്ളൽ';

  @override
  String get descStageHelpPinchMeaning => 'അക്ഷരവലുപ്പം മാറ്റുക';

  @override
  String get labelStageHelpBack => 'പിന്നോട്ട്';

  @override
  String get descStageHelpBackMeaning => 'പൂർണ്ണ സ്ക്രീൻ വിടുക';

  @override
  String get descStageHelpStart => 'തുടങ്ങാൻ എവിടെയെങ്കിലും തട്ടുക';

  @override
  String get titleGestures => 'ആംഗ്യങ്ങളും കുറുക്കുവഴികളും';

  @override
  String get descGesturesSubtitle =>
      'വായിക്കുമ്പോൾ കൈ ഉപയോഗിക്കാതെ ഷീറ്റ് നിയന്ത്രിക്കുക';

  @override
  String get labelGesturesDoubleTapTop => 'മുകളിൽ രണ്ടുതവണ';

  @override
  String get descGesturesDoubleTapTopMeaning =>
      'സ്വമേധയാ രീതിയിൽ വേഗം കൂട്ടുന്നു, അല്ലെങ്കിൽ വേഗ രീതിയിൽ 4 ബാറുകൾ ചേർക്കുന്നു.';

  @override
  String get labelGesturesDoubleTapBottom => 'താഴെ രണ്ടുതവണ';

  @override
  String get descGesturesDoubleTapBottomMeaning =>
      'സ്വമേധയാ രീതിയിൽ വേഗം കുറയ്ക്കുന്നു, അല്ലെങ്കിൽ വേഗ രീതിയിൽ 4 ബാറുകൾ കുറയ്ക്കുന്നു.';

  @override
  String get descGesturesTwoFingersMeaning =>
      'ഒരു ബട്ടണും തൊടാതെ സ്വയം നീങ്ങൽ തുടങ്ങുക അല്ലെങ്കിൽ നിർത്തിവയ്ക്കുക.';

  @override
  String get labelGesturesDrag => 'ഒരു വിരൽ വലിക്കൽ';

  @override
  String get descGesturesDragMeaning =>
      'ഷീറ്റ് കൈകൊണ്ട് നീക്കുക; സ്വയം നീങ്ങൽ കാത്തുനിന്ന് വിരൽ എടുക്കുമ്പോൾ തുടരും.';

  @override
  String get labelGesturesPinch => 'രണ്ടു വിരൽ നുള്ളൽ';

  @override
  String get descGesturesPinchMeaning =>
      'കോർഡും വരികളും വലുതോ ചെറുതോ ആക്കാൻ വലുതാക്കുക അല്ലെങ്കിൽ ചെറുതാക്കുക.';

  @override
  String get labelGesturesFullScreen => 'പൂർണ്ണ സ്ക്രീൻ';

  @override
  String get descGesturesFullScreenMeaning =>
      'ഒരു തട്ട് നിയന്ത്രണങ്ങൾ കാണിക്കുകയോ മറയ്ക്കുകയോ ചെയ്യുന്നു; പിന്നോട്ട് ആംഗ്യം പൂർണ്ണ സ്ക്രീൻ വിടുന്നു.';

  @override
  String get actionGesturesHelpCenter => 'സഹായ കേന്ദ്രം';

  @override
  String get actionGesturesGotIt => 'മനസ്സിലായി';

  @override
  String get descMetronomeTapAlong => 'സംഗീതത്തിനൊപ്പം തട്ടുക';

  @override
  String get descMetronomeKeepTapping => 'തട്ടിക്കൊണ്ടിരിക്കുക…';

  @override
  String descMetronomeTapsNeeded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'നല്ലത് — സ്ഥിരമാക്കാൻ $count തട്ടുകൾ കൂടി',
      one: 'നല്ലത് — സ്ഥിരമാക്കാൻ 1 തട്ട് കൂടി',
    );
    return '$_temp0';
  }

  @override
  String get descMetronomeSteady => 'സ്ഥിരം';

  @override
  String get titleMetronomeTempo => 'മെട്രോനോം വേഗം';

  @override
  String get descMetronomeSetByYou => 'ഈ സെഷനിലേക്ക് നിങ്ങൾ സജ്ജമാക്കിയത്';

  @override
  String get descMetronomeUsingSongTempo =>
      'ഈ പാട്ടിൽ സൂക്ഷിച്ച വേഗം ഉപയോഗിക്കുന്നു';

  @override
  String get descMetronomeNoSongTempo => 'ഈ പാട്ടിൽ വേഗം സൂക്ഷിച്ചിട്ടില്ല';

  @override
  String get tooltipMetronomeSlowerByOne => '1 കുറയ്ക്കുക';

  @override
  String get tooltipMetronomeFasterByOne => '1 കൂട്ടുക';

  @override
  String get labelMetronomeBpmUnit => 'BPM';

  @override
  String get actionMetronomeTapTempo => 'തട്ടി വേഗം';

  @override
  String get actionMetronomeUseSongTempo => 'പാട്ടിന്റെ വേഗം';

  @override
  String get actionMetronomeNoSongTempoToRestore => 'പാട്ടിന് വേഗമില്ല';

  @override
  String get tooltipMetronomeStop => 'മെട്രോനോം നിർത്തുക';

  @override
  String get tooltipMetronomeStart => 'മെട്രോനോം തുടങ്ങുക';

  @override
  String get errorDroneCouldNotPlay => 'ശബ്ദം വായിക്കാൻ കഴിഞ്ഞില്ല.';

  @override
  String get titleDrone => 'ശ്രുതിക്കുഴലും ശ്രുതിയും';

  @override
  String get labelDroneModeClassical => 'ശാസ്ത്രീയം (ശ്രുതി)';

  @override
  String get labelDroneModeWestern => 'പാശ്ചാത്യം (കോർഡ്)';

  @override
  String get labelDroneSaPa => 'Sa + Pa (പഞ്ചമം)';

  @override
  String get labelDroneSaMa => 'Sa + Ma (മധ്യമം)';

  @override
  String get labelDroneMajor => 'മേജർ (maj)';

  @override
  String get labelDroneMinor => 'മൈനർ (min)';

  @override
  String get actionDroneChordCue => 'കോർഡ് സൂചന (2 സെ.)';

  @override
  String get actionDronePitchCue => 'ശ്രുതി സൂചന (2 സെ.)';

  @override
  String get actionDroneStop => 'ശ്രുതി നിർത്തുക';

  @override
  String get actionDroneChord => 'കോർഡ് ശ്രുതി';

  @override
  String get actionDroneShruti => 'ശ്രുതിപ്പെട്ടി';

  @override
  String get labelDroneTextScale => 'വേദി അക്ഷരവലുപ്പം';

  @override
  String labelDroneYourSa(String name) {
    return 'നിങ്ങളുടെ Sa:  $name';
  }

  @override
  String labelDroneSongKey(String key) {
    return 'പാട്ടിന്റെ ശ്രുതി:  $key';
  }

  @override
  String get labelDroneRootKey => 'ആധാര ശ്രുതി';

  @override
  String get emptySheetNoLyrics => 'ഈ പാട്ടിന് ഇതുവരെ വരികളില്ല.';

  @override
  String descDiagramNoGuitar(String name) {
    return '$name-ന് ഗിറ്റാർ കോർഡ് ചിത്രമില്ല';
  }

  @override
  String descDiagramGuitar(String name) {
    return '$name-ന്റെ ഗിറ്റാർ കോർഡ് ചിത്രം';
  }

  @override
  String get labelDiagramNone => 'ചിത്രമില്ല';

  @override
  String descDiagramHarmonium(String name) {
    return '$name-ന്റെ ഹാർമോണിയം കോർഡ് ചിത്രം';
  }

  @override
  String descDiagramSwara(String swara) {
    return '$swara-ന്റെ സ്വര ചിത്രം';
  }

  @override
  String get labelMelodyGridHold => 'നീട്ട്';

  @override
  String get labelMelodyGridBarLine => 'വിഭാഗ രേഖ';

  @override
  String descMelodyGridUnreadable(String text) {
    return '$text വായിക്കാൻ കഴിഞ്ഞില്ല';
  }

  @override
  String get titleSettingsGeneral => 'പൊതുവായവ';

  @override
  String get descSettingsGeneralSubtitle => 'ഇറക്കുമതിയും മെട്രോനോമും';

  @override
  String get titleSettingsThemes => 'തീമുകൾ';

  @override
  String get descSettingsThemesSubtitle =>
      'സിസ്റ്റം, തെളിഞ്ഞ, അല്ലെങ്കിൽ ഇരുണ്ട രൂപം';

  @override
  String get titleSettingsChords => 'കോർഡുകൾ';

  @override
  String get descSettingsChordsSubtitle =>
      'എഡിറ്ററിനായി നിങ്ങളുടെ സ്വന്തം കോർഡുകൾ';

  @override
  String get titleSettingsFonts => 'അക്ഷരരൂപങ്ങൾ';

  @override
  String get descSettingsFontsSubtitle =>
      'വരികളുടെ അക്ഷരരൂപം തിരഞ്ഞെടുക്കുക (ഇംഗ്ലീഷും മലയാളവും)';

  @override
  String get titleSettingsHelp => 'സഹായം';

  @override
  String get descSettingsHelpSubtitle =>
      'പട്ടികകൾ, മെട്രോനോം, കയറ്റുമതി തുടങ്ങിയവ എങ്ങനെ ഉപയോഗിക്കാം';

  @override
  String get descSettingsAboutSubtitle => 'ആപ്പ് പതിപ്പ്, രചയിതാവ്, ലൈസൻസുകൾ';

  @override
  String get titleGeneralImport => 'ഇറക്കുമതി';

  @override
  String get descGeneralImportSubtitle =>
      'ChordPro ഫയലുകൾ പാട്ടുകളായി കൊണ്ടുവരിക';

  @override
  String get titleGeneralImportSettings => 'ഇറക്കുമതി ക്രമീകരണം';

  @override
  String get descGeneralImportSettingsSubtitle =>
      'ChordPro ഫയലുകളിലെ ഒരേ പേരുള്ള പാട്ടുകൾ എന്തുചെയ്യണമെന്ന് തീരുമാനിക്കുക';

  @override
  String get descGeneralAutoScrollSubtitle =>
      'സ്വമേധയാ നീങ്ങലിന്റെ തുടക്ക വേഗം';

  @override
  String get titleGeneralMetronome => 'മെട്രോനോം';

  @override
  String get descGeneralMetronomeSubtitle =>
      'താളം ഓണാക്കുക അല്ലെങ്കിൽ ഓഫാക്കുക';

  @override
  String get descGeneralDroneSubtitle =>
      'ശ്രുതി ശബ്ദങ്ങൾ, സ്ഥിരമായ ശ്രുതി, നിങ്ങളുടെ Sa (കട്ട)';

  @override
  String get labelThemeSystem => 'സിസ്റ്റം തീം';

  @override
  String get labelThemeLight => 'തെളിഞ്ഞ രൂപം';

  @override
  String get labelThemeDark => 'ഇരുണ്ട രൂപം';

  @override
  String get descFontSettingsNote =>
      'സ്ക്രീനിലെയും കയറ്റുമതി ചെയ്ത PDF-കളിലെയും വരികൾക്ക് ഉപയോഗിക്കുന്നു. ഇംഗ്ലീഷ് അക്ഷരരൂപം തിരഞ്ഞെടുത്താലും PDF-ൽ മലയാളം അച്ചടിക്കും.';

  @override
  String get labelFontSystemDefault => 'സിസ്റ്റം സ്വതവേ';

  @override
  String get titleScrollStartingSpeed => 'തുടക്ക വേഗം';

  @override
  String get descScrollStartingSpeedNote =>
      'വേഗം ഇതുവരെ നിശ്ചയിക്കാത്ത പാട്ടിൽ സ്വമേധയാ നീങ്ങൽ ഈ വേഗത്തിൽ തുടങ്ങും.';

  @override
  String actionScrollResetTo(String speed) {
    return '$speed ആക്കുക';
  }

  @override
  String errorChordSettingsAddFailed(int max) {
    return 'ആ കോർഡ് ചേർക്കാൻ കഴിഞ്ഞില്ല. പരമാവധി $max അക്ഷരങ്ങൾ ഉപയോഗിക്കുക, ആവർത്തിക്കരുത്.';
  }

  @override
  String bodyChordSettingsRemoved(String chord) {
    return '\"$chord\" നീക്കി.';
  }

  @override
  String get descChordSettingsIntro =>
      'നിങ്ങളുടെ സ്വന്തം കോർഡുകൾ ചേർക്കുക. എഡിറ്ററിലെ കോർഡ് നിരയിൽ, ശ്രുതിയുടെ സ്വന്തം കോർഡുകൾക്കുശേഷം, ഇവ എപ്പോഴും കാണും.';

  @override
  String get labelChordSettings => 'കോർഡ് എഴുത്ത്';

  @override
  String get emptyChordSettings => 'ഇതുവരെ സ്വന്തം കോർഡുകളില്ല.';

  @override
  String tooltipChordSettingsRemove(String chord) {
    return '$chord നീക്കുക';
  }

  @override
  String get descImportSettingsQuestion =>
      'നിങ്ങളുടെ പാട്ടുപുസ്തകത്തിലെ ഒരു പാട്ടിന്റെ അതേ ശീർഷകമുള്ള പാട്ട് ഇറക്കുമതി ചെയ്യുമ്പോൾ:';

  @override
  String get labelImportStrategyOverwrite => 'മാറ്റിയെഴുതുക';

  @override
  String get descImportStrategyOverwrite =>
      'നിലവിലുള്ള പാട്ടിന്റെ ഉള്ളടക്കം ഇറക്കുമതി ചെയ്ത പാട്ടുകൊണ്ട് മാറ്റുക';

  @override
  String get labelImportStrategyRenameImported => 'പുതിയതിന് പേരുമാറ്റുക';

  @override
  String get descImportStrategyRenameImported =>
      'ശീർഷകത്തിൽ സമയമുദ്ര ചേർത്ത് ഇറക്കുമതി ചെയ്ത പാട്ടിന് സ്വയം പേരുമാറ്റുക';

  @override
  String get labelImportStrategyRenameExisting => 'പഴയതിന് പേരുമാറ്റുക';

  @override
  String get descImportStrategyRenameExisting =>
      'ശീർഷകത്തിൽ സമയമുദ്ര ചേർത്ത് നിലവിലുള്ള പാട്ടിന് സ്വയം പേരുമാറ്റുക';

  @override
  String get labelImportStrategyUserSuggested => 'പുതിയ പേര് ചോദിക്കുക';

  @override
  String get descImportStrategyUserSuggested =>
      'ഇറക്കുമതി ചെയ്യുന്ന പാട്ടിന് ഒരു പേര് എഴുതാൻ നിങ്ങളോട് ചോദിക്കും';

  @override
  String get labelMetronomeEnable => 'മെട്രോനോം ഓണാക്കുക';

  @override
  String get descMetronomeEnableSubtitle =>
      'പാട്ടിന്റെ വേഗത്തിൽ താളം നിലനിർത്തുക';

  @override
  String get labelMetronomeFlash => 'മിന്നൽ';

  @override
  String get descMetronomeFlashSubtitle =>
      'ഓരോ മാത്രയിലും മിന്നുക (ശബ്ദമില്ലാത്തപ്പോൾ നല്ലത്)';

  @override
  String get labelMetronomeClick => 'ടിക്ക് ശബ്ദം';

  @override
  String get descMetronomeClickSubtitle => 'ഓരോ മാത്രയിലും ഒരു ടിക്ക് ശബ്ദം';

  @override
  String get labelMetronomeClickVolume => 'ടിക്ക് ശബ്ദനില';

  @override
  String get titleMetronomeBarHeading => 'ബാർ';

  @override
  String get labelMetronomeBeatsInBar => 'ഒരു ബാറിലെ മാത്രകൾ';

  @override
  String get descMetronomeBeatsInBarSubtitle =>
      'മാത്ര 1 ആണ് നിങ്ങൾ എണ്ണിത്തുടങ്ങുന്നത്';

  @override
  String get labelMetronomeAccent => 'മാത്ര 1-ന് ഊന്നൽ';

  @override
  String get descMetronomeAccentSubtitle =>
      'ആദ്യ മാത്രയിൽ ഉച്ചത്തിലുള്ള, ഉയർന്ന ടിക്ക്';

  @override
  String get labelMetronomeTest => 'ശബ്ദം പരീക്ഷിക്കുക';

  @override
  String descMetronomeTestSubtitle(int bpm) {
    return '$bpm BPM-ൽ ഒരു ബാർ വായിക്കുന്നു. ഒന്നും കേൾക്കുന്നില്ലെങ്കിൽ മീഡിയ ശബ്ദം കൂട്ടുക.';
  }

  @override
  String descDroneSettingsTestWesternMajor(String key) {
    return 'പരീക്ഷണം: $key-ൽ പാശ്ചാത്യ മേജർ കോർഡ്';
  }

  @override
  String descDroneSettingsTestWesternMinor(String key) {
    return 'പരീക്ഷണം: $key-ൽ പാശ്ചാത്യ മൈനർ കോർഡ്';
  }

  @override
  String descDroneSettingsTestClassical(String key, String interval) {
    return 'പരീക്ഷണം: $key + $interval-ൽ ശാസ്ത്രീയ ശ്രുതി';
  }

  @override
  String get titleDroneSettingsNaming => 'സ്വര നാമകരണം';

  @override
  String get descDroneSettingsNamingCaption =>
      'സ്വരങ്ങൾക്ക് എങ്ങനെ പേരിടുന്നു എന്നും രാഗമോ താളമോ ഇല്ലാത്ത പാട്ട് എങ്ങനെ കാണുന്നു എന്നും നിശ്ചയിക്കുന്നു.';

  @override
  String get descDroneSettingsUsesIndian =>
      'രാഗമോ താളമോ ഇല്ലാത്ത പാട്ടുകൾ താഴെയുള്ള ഭാരതീയ ക്രമീകരണങ്ങൾ ഉപയോഗിക്കുന്നു.';

  @override
  String get descDroneSettingsUsesWestern =>
      'രാഗമോ താളമോ ഇല്ലാത്ത പാട്ടുകൾ താഴെയുള്ള പാശ്ചാത്യ ക്രമീകരണങ്ങൾ ഉപയോഗിക്കുന്നു.';

  @override
  String get titleDroneSettingsIndianSongs => 'ഭാരതീയ പാട്ടുകൾ';

  @override
  String get descDroneSettingsIndianCaption =>
      'രാഗമോ താളമോ ഉള്ള പാട്ടുകൾക്ക്. ഇവ എപ്പോഴും നിങ്ങളുടെ Sa-യിൽ ശാസ്ത്രീയ ശ്രുതി വായിക്കുന്നു.';

  @override
  String get labelDroneSettingsYourSa => 'നിങ്ങളുടെ Sa (ശ്രുതി)';

  @override
  String descDroneSettingsSaSits(String name) {
    return 'നിങ്ങളുടെ Sa ഇവിടെ: $name';
  }

  @override
  String get labelDroneSettingsInterval => 'ശ്രുതി ഇടവേള';

  @override
  String get descDroneSettingsIntervalPa =>
      'Sa + Pa (പഞ്ചമം) — സാധാരണ ശ്രുതിപ്പെട്ടി ശബ്ദം';

  @override
  String get descDroneSettingsIntervalMa =>
      'Sa + Ma (മധ്യമം) — Pa ഒഴിവാക്കുന്ന രാഗങ്ങൾക്ക്';

  @override
  String get titleDroneSettingsWesternSongs => 'പാശ്ചാത്യ പാട്ടുകൾ';

  @override
  String get descDroneSettingsWesternCaption =>
      'സ്വര നാമകരണം പാശ്ചാത്യമായിരിക്കുമ്പോൾ, രാഗമോ താളമോ ഇല്ലാത്ത പാട്ടുകൾക്ക്.';

  @override
  String get labelDroneSettingsDefaultKey => 'സ്വതവേയുള്ള ശ്രുതി';

  @override
  String descDroneSettingsDefaultKeySubtitle(String key) {
    return 'പാട്ടിന് ശ്രുതി ഇല്ലാത്തപ്പോൾ ഉപയോഗിക്കുന്നു: $key';
  }

  @override
  String get labelDroneSettingsDefaultMode => 'സ്വതവേയുള്ള ശ്രുതി രീതി';

  @override
  String get descDroneSettingsModeClassicalNote =>
      'ശാസ്ത്രീയ ശ്രുതി (Sa + Pa/Ma)';

  @override
  String get descDroneSettingsModeWesternNote =>
      'പാശ്ചാത്യ പിന്നണി കോർഡുകൾ (മേജർ / മൈനർ)';

  @override
  String get labelDroneSettingsClassical => 'ശാസ്ത്രീയം';

  @override
  String get labelDroneSettingsDefaultQuality => 'കോർഡ് തരം';

  @override
  String get descDroneSettingsMajorNote => 'മേജർ ത്രിസ്വരം (മൂലം + മേജർ 3 + 5)';

  @override
  String get descDroneSettingsMinorNote => 'മൈനർ ത്രിസ്വരം (മൂലം + മൈനർ 3 + 5)';

  @override
  String get descDroneSettingsQualityOnlyWestern =>
      'മുകളിലെ ശ്രുതി രീതി പാശ്ചാത്യമായിരിക്കുമ്പോൾ മാത്രം ഉപയോഗിക്കുന്നു';

  @override
  String get labelChordQualityMajor => 'മേജർ';

  @override
  String get labelChordQualityMinor => 'മൈനർ';

  @override
  String get titleDroneSettingsEverything => 'എല്ലാ പാട്ടുകളും';

  @override
  String get descDroneSettingsEverythingCaption =>
      'ഇവ രണ്ടു പാരമ്പര്യങ്ങളെയും ബാധിക്കുന്നു.';

  @override
  String get labelDroneSettingsVolume => 'ശബ്ദനില';

  @override
  String get labelDroneSettingsFontScale => 'വേദി അക്ഷരവലുപ്പം';

  @override
  String descDroneSettingsFontScaleSubtitle(int percent) {
    return 'വേദി രീതിയിലെ അക്ഷരവലുപ്പം: $percent%';
  }

  @override
  String get titleDroneSettingsTryIt => 'പരീക്ഷിച്ചുനോക്കുക';

  @override
  String get descDroneSettingsTryItCaption =>
      'പരീക്ഷണം മുകളിലെ ക്രമീകരണങ്ങൾ ഉപയോഗിക്കുന്നു.';

  @override
  String get actionDroneSettingsTestChordCue => 'കോർഡ് സൂചന പരീക്ഷണം';

  @override
  String get actionDroneSettingsTestPitchCue => 'ശ്രുതി സൂചന പരീക്ഷണം';

  @override
  String get actionDroneSettingsTestChordDrone => 'കോർഡ് ശ്രുതി പരീക്ഷണം';

  @override
  String get actionDroneSettingsTestDrone => 'ശ്രുതി പരീക്ഷണം';

  @override
  String get descDroneSettingsChordDroneNote =>
      'കോർഡ് ശ്രുതി ഓണായിരിക്കുന്നിടത്തോളം ഒരു സ്ഥിരമായ പാശ്ചാത്യ പിന്നണി കോർഡ് നിലനിർത്തുന്നു.';

  @override
  String get descDroneSettingsDroneNote =>
      'ശ്രുതി ഓണായിരിക്കുന്നിടത്തോളം ഒരു സ്ഥിരമായ സ്വരജോടി നിലനിർത്തുന്നു. ഇത് ഈണം പിന്തുടരുന്നില്ല.';

  @override
  String labelAboutVersion(String version) {
    return 'പതിപ്പ് $version';
  }

  @override
  String labelAboutVersionBuild(String version, String build) {
    return '$version (നിർമ്മിതി $build)';
  }

  @override
  String get labelAboutBuildDate => 'നിർമ്മിച്ച തീയതി';

  @override
  String get labelAboutLicenses => 'ഓപ്പൺ സോഴ്സ് ലൈസൻസുകൾ';

  @override
  String get titleImportExport => 'ഇറക്കുമതിയും കയറ്റുമതിയും';

  @override
  String get labelImportExportPickFiles => 'ChordPro ഇറക്കുമതി';

  @override
  String get descImportExportPickFilesSubtitle =>
      'പാട്ടുകൾ ചേർക്കാൻ ഒന്നോ അതിലധികമോ .cho, .pro, അല്ലെങ്കിൽ ടെക്സ്റ്റ് ഫയലുകൾ തിരഞ്ഞെടുക്കുക.';

  @override
  String get labelImportExportScan => 'AirQR വഴി ഇറക്കുമതി';

  @override
  String get descImportExportScanSubtitle =>
      'കൂട്ടുകാരന്റെ സ്ക്രീനിൽനിന്ന് ചലിക്കുന്ന QR പാട്ട് ധാര സ്കാൻ ചെയ്യുക.';

  @override
  String get labelImportExportAllChordPro => 'എല്ലാം കയറ്റുമതി';

  @override
  String get descImportExportAllChordProSubtitle =>
      'നിങ്ങളുടെ മുഴുവൻ പാട്ടുപുസ്തകവും ഒരൊറ്റ ChordPro ഫയലായി സൂക്ഷിക്കുക.';

  @override
  String get labelImportExportAllAirQr => 'എല്ലാം AirQR വഴി';

  @override
  String get descImportExportAllAirQrSubtitle =>
      'മുഴുവൻ പാട്ടുപുസ്തകവും ചലിക്കുന്ന QR ധാരയായി അയയ്ക്കുക.';

  @override
  String get errorImportExportWrongType =>
      '.cho, .pro, .chordpro, .txt ഫയലുകൾ മാത്രമേ ഇറക്കുമതി ചെയ്യാനാകൂ.';

  @override
  String get errorImportExportNothingRead =>
      'തിരഞ്ഞെടുത്ത ഫയലുകളൊന്നും വായിക്കാൻ കഴിഞ്ഞില്ല.';

  @override
  String descImportExportFilesSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ഫയലുകൾ തിരഞ്ഞെടുത്തു',
      one: '1 ഫയൽ തിരഞ്ഞെടുത്തു',
    );
    return '$_temp0';
  }

  @override
  String get errorImportExportImportFailed =>
      'ഫയലുകൾ ഇറക്കുമതി ചെയ്യാൻ കഴിഞ്ഞില്ല.';

  @override
  String get bodyImportExportNoSongsToExport =>
      'കയറ്റുമതി ചെയ്യാൻ പാട്ടുകളില്ല.';

  @override
  String get titleImportExportAllDialog => 'എല്ലാം കയറ്റുമതി';

  @override
  String bodyImportExportExported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count പാട്ടുകൾ കയറ്റുമതി ചെയ്തു.',
      one: '1 പാട്ട് കയറ്റുമതി ചെയ്തു.',
    );
    return '$_temp0';
  }

  @override
  String get errorImportExportExportFailed =>
      'പാട്ടുകൾ കയറ്റുമതി ചെയ്യാൻ കഴിഞ്ഞില്ല.';

  @override
  String get bodyImportExportNoSongsToShare => 'പങ്കിടാൻ പാട്ടുകളില്ല.';

  @override
  String titleImportExportFullSongbook(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'പാട്ടുപുസ്തകം ($count പാട്ടുകൾ)',
      one: 'പാട്ടുപുസ്തകം (1 പാട്ട്)',
    );
    return '$_temp0';
  }

  @override
  String get errorImportExportAirQrFailed =>
      'AirQR കയറ്റുമതി ഒരുക്കാൻ കഴിഞ്ഞില്ല.';

  @override
  String get titleImportPreview => 'ഇറക്കുമതി മുൻകാഴ്ച';

  @override
  String get actionImportPreviewSelectAll => 'എല്ലാം തിരഞ്ഞെടുക്കുക';

  @override
  String get actionImportPreviewDeselectAll => 'എല്ലാം ഒഴിവാക്കുക';

  @override
  String descImportPreviewFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'ഫയലിൽ $count പാട്ടുകൾ കണ്ടെത്തി. പാട്ടുപുസ്തകത്തിലേക്ക് ഇറക്കുമതി ചെയ്യേണ്ട പാട്ടുകൾ തിരഞ്ഞെടുക്കുക.',
      one:
          'ഫയലിൽ 1 പാട്ട് കണ്ടെത്തി. പാട്ടുപുസ്തകത്തിലേക്ക് ഇറക്കുമതി ചെയ്യേണ്ട പാട്ടുകൾ തിരഞ്ഞെടുക്കുക.',
    );
    return '$_temp0';
  }

  @override
  String get emptyImportPreviewNoSongs =>
      'ഈ ഫയലിൽ ശരിയായ പാട്ടുകളൊന്നും കണ്ടെത്തിയില്ല.';

  @override
  String get labelImportPreviewInSongbook => 'പാട്ടുപുസ്തകത്തിൽ';

  @override
  String get labelImportPreviewAlreadyInSongbook => 'ഇതിനകം പുസ്തകത്തിൽ';

  @override
  String labelImportPreviewKey(String key) {
    return 'ശ്രുതി: $key';
  }

  @override
  String get actionImportPreviewPreview => 'മുൻകാഴ്ച';

  @override
  String get actionImportPreviewImporting => 'ഇറക്കുമതി ചെയ്യുന്നു...';

  @override
  String actionImportPreviewImportSelected(int count) {
    return 'ഇറക്കുമതി ($count)';
  }

  @override
  String bodyImportPreviewImportedOne(String title) {
    return '\"$title\" ഇറക്കുമതി ചെയ്തു.';
  }

  @override
  String bodyImportPreviewImportedMany(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count പാട്ടുകൾ ഇറക്കുമതി ചെയ്തു.',
      one: '1 പാട്ട് ഇറക്കുമതി ചെയ്തു.',
    );
    return '$_temp0';
  }

  @override
  String errorImportPreviewFailed(String reason) {
    return 'ഇറക്കുമതി പരാജയപ്പെട്ടു: $reason';
  }

  @override
  String get titleAirQrReceiver => 'AirQR പാട്ട് സ്വീകരണി';

  @override
  String get tooltipAirQrReceiverGallery => 'ഒരു ചിത്രം സ്കാൻ ചെയ്യുക';

  @override
  String get tooltipAirQrReceiverResetStream => 'ധാര പുനഃസജ്ജമാക്കുക';

  @override
  String get errorAirQrReceiverNoCode =>
      'തിരഞ്ഞെടുത്ത ചിത്രത്തിൽ AirQR കോഡ് കണ്ടെത്തിയില്ല.';

  @override
  String get errorAirQrReceiverPhotoFailed =>
      'ചിത്രം സ്കാൻ ചെയ്യാൻ കഴിഞ്ഞില്ല.';

  @override
  String get descAirQrReceiverStarting =>
      'AirQR ക്യാമറ സ്വീകരണി തുടങ്ങുന്നു...';

  @override
  String get labelAirQrReceiverFileName => 'AirQR ധാര പങ്കിടൽ';

  @override
  String get descAirQrHudReassembled =>
      'ധാര പൂർത്തിയായി - മുൻകാഴ്ച തുറക്കുന്നു...';

  @override
  String get descAirQrHudReceiving => 'AirQR പാട്ട് ധാര സ്വീകരിക്കുന്നു...';

  @override
  String get descAirQrHudPointAt =>
      'ചലിക്കുന്ന QR കോഡ് ധാരയിലേക്ക് ക്യാമറ തിരിക്കുക';

  @override
  String descAirQrHudCaptured(int received, int total) {
    return 'ലഭിച്ചത്: $received / $total ഖണ്ഡങ്ങൾ';
  }

  @override
  String labelAirQrHudMissing(int count) {
    return 'കിട്ടാനുള്ളത്: $count';
  }

  @override
  String titleAirQrTransmitter(String title) {
    return 'AirQR പങ്കിടൽ: $title';
  }

  @override
  String descAirQrTransmitterSize(int bytes, int frames) {
    return '$bytes ബൈറ്റ് • $frames ചിത്രഖണ്ഡങ്ങൾ';
  }

  @override
  String get labelAirQrTransmitterSpeed => 'ധാര വേഗം:';

  @override
  String get actionAirQrTransmitterPause => 'ധാര നിർത്തിവയ്ക്കുക';

  @override
  String get actionAirQrTransmitterResume => 'ധാര തുടരുക';

  @override
  String get emptyAirQrTransmitterNoFrames =>
      'ചിത്രഖണ്ഡങ്ങളൊന്നും ഉണ്ടാക്കിയില്ല';

  @override
  String descAirQrTransmitterParityFrame(int index, int total) {
    return 'ചിത്രം $index/$total • Fountain FEC';
  }

  @override
  String descAirQrTransmitterBlockFrame(int index, int total, int block) {
    return 'ചിത്രം $index/$total • ഖണ്ഡം $block';
  }

  @override
  String get descAirQrTransmitterHint =>
      'സ്വീകരിക്കുന്ന ഫോണിന്റെ ക്യാമറ ഈ സ്ക്രീനിലേക്ക് തിരിക്കുക.\nഇന്റർനെറ്റ്, ബ്ലൂടൂത്ത്, വൈ-ഫൈ ഒന്നും വേണ്ട.';

  @override
  String get titleHelpSongbook => 'നിങ്ങളുടെ പാട്ടുപുസ്തകം';

  @override
  String get helpSongbookSummary =>
      'പാട്ടുകൾ കണ്ടെത്തുക, നക്ഷത്രമിടുക, പകർത്തുക, നീക്കുക';

  @override
  String get helpSongbookIntro =>
      'ഹോം സ്ക്രീനാണ് നിങ്ങളുടെ പാട്ടുപുസ്തകം. അതിൽ രണ്ട് ടാബുകളുണ്ട് — പാട്ടുകൾ, പാട്ടുപട്ടികകൾ. നിങ്ങൾ എഴുതിയതും കൊണ്ടുവന്നതുമായ എല്ലാം പാട്ടുകൾ ടാബിലുണ്ട്; ഏറ്റവും ഒടുവിൽ മാറ്റിയ പാട്ട് ഏറ്റവും മുകളിൽ.';

  @override
  String get helpSongbookS1Heading => 'പാട്ട് ചേർക്കുക';

  @override
  String get helpSongbookS1P1 =>
      'പുതിയ ഒന്ന് എഴുതാൻ താഴെ വലതുവശത്തുള്ള + ബട്ടൺ തൊടുക.';

  @override
  String get helpSongbookS1P2 =>
      'അല്ലെങ്കിൽ ഒരു ഫയലിൽനിന്ന് പാട്ടുകൾ കൊണ്ടുവരിക — ഇറക്കുമതി വിഷയം കാണുക.';

  @override
  String get helpSongbookS1P3 =>
      'പുതുതായി ഇൻസ്റ്റാൾ ചെയ്യുമ്പോൾ മൂന്ന് മാതൃകാ പാട്ടുകളും ഒരു പാട്ടുപട്ടികയും ഉണ്ടാകും; ഒന്നും ടൈപ്പ് ചെയ്യാതെതന്നെ എല്ലാം പരീക്ഷിക്കാം.';

  @override
  String get helpSongbookS2Heading => 'പാട്ട് കണ്ടെത്തുക';

  @override
  String get helpSongbookS2P1 =>
      'മുകളിലെ തിരയൽ പെട്ടിയിൽ ടൈപ്പ് ചെയ്യുക. ശീർഷകത്തിലും കലാകാരനിലും വരികളിലും അത് തിരയും; ഓർമ്മയിലുള്ള പാതി വരി മതി.';

  @override
  String get helpSongbookS2P2 => 'തിരയൽ മായ്ക്കാൻ പെട്ടിയിലെ X തൊടുക.';

  @override
  String get helpSongbookS2P3 =>
      'അതിനു താഴെ \"എല്ലാം\", \"നക്ഷത്രമിട്ടവ\" എന്നീ രണ്ട് ചിപ്പുകൾ; ഓരോന്നിലും എത്ര പാട്ടുകളുണ്ടെന്ന എണ്ണവും കാണാം.';

  @override
  String get helpSongbookS2P4 =>
      'ഒരു പാട്ടിനെ നക്ഷത്രമിട്ടവയിൽ ചേർക്കാൻ അതിലെ നക്ഷത്രം തൊടുക. എടുത്തുമാറ്റാൻ വീണ്ടും തൊടുക.';

  @override
  String get helpSongbookS3Heading => 'പാട്ട് കാർഡിൽ എന്തെല്ലാം';

  @override
  String get helpSongbookS3P1 => 'ശീർഷകവും കലാകാരനും.';

  @override
  String get helpSongbookS3P2 =>
      'പാട്ടിനുണ്ടെങ്കിൽ, C അല്ലെങ്കിൽ Am പോലെയുള്ള ശ്രുതിയും 120 BPM പോലെയുള്ള വേഗവും.';

  @override
  String get helpSongbookS3P3 =>
      'ഒരു നക്ഷത്രം, ഒരു പകർത്തൽ ബട്ടൺ, ഒരു ഇല്ലാതാക്കൽ ബട്ടൺ.';

  @override
  String get helpSongbookS4Heading => 'ഒരു പാട്ട് പകർത്തുക, ഇല്ലാതാക്കുക';

  @override
  String get helpSongbookS4P1 =>
      'പകർത്തൽ \"<പേര്> (പകർപ്പ്)\" എന്ന പേരിൽ വേറിട്ട രണ്ടാമതൊരു പാട്ട് ഉണ്ടാക്കും. ഒരേ പാട്ടിന്റെ മറ്റൊരു ക്രമീകരണത്തിന് ഉപകാരപ്രദം.';

  @override
  String get helpSongbookS4P2 =>
      'ഇല്ലാതാക്കൽ ആദ്യം ചോദിക്കും; പിന്നെ പാട്ട് നിങ്ങളുടെ ശേഖരത്തിൽനിന്നും അതുള്ള എല്ലാ പട്ടികകളിൽനിന്നും നീക്കും.';

  @override
  String get helpSongbookS4P3 =>
      'ഒരേസമയം പല പാട്ടുകളിൽ പ്രവർത്തിക്കാൻ, പാട്ടുകൾ തിരഞ്ഞെടുക്കൽ വിഷയം കാണുക.';

  @override
  String get helpSongbookS5Heading => 'ടാബ്‌ലെറ്റിൽ';

  @override
  String get helpSongbookS5P1 =>
      'വീതിയുള്ള സ്ക്രീനിൽ ഇടതുവശത്ത് പട്ടികയും വലതുവശത്ത് പാട്ടും കാണിക്കും; അതിനാൽ ഒരു പാട്ട് തിരഞ്ഞെടുത്താലും പട്ടിക മറയില്ല.';

  @override
  String get helpSongbookS5P2 =>
      'ആ വലതുപകുതിയിൽ പൂർണ്ണ സ്ക്രീൻ ലഭ്യമല്ല; അത് മുഴുവൻ സ്ക്രീനല്ല, ആ പകുതി മാത്രമേ നിറയ്ക്കൂ.';

  @override
  String get titleHelpEditor => 'പാട്ട് എഴുതുക';

  @override
  String get helpEditorSummary =>
      'വരികൾ ടൈപ്പ് ചെയ്യുക, മുകളിൽ കോർഡുകൾ ഇടുക, സൂക്ഷിക്കുക';

  @override
  String get helpEditorIntro =>
      'വരികൾക്കായി ഒരൊറ്റ ലളിതമായ പെട്ടിയാണ് എഡിറ്റർ; അതിനു മുകളിൽ ശീർഷകം, കലാകാരൻ, ശ്രുതി, വേഗം എന്നിവയ്ക്ക് കുറച്ച് ഇടങ്ങൾ. കോർഡുകൾ ചതുര ബ്രാക്കറ്റിൽ വരികൾക്കുള്ളിൽ ഇടുന്നു.';

  @override
  String get helpEditorS1Heading => 'വരികളിലെ കോർഡുകൾ';

  @override
  String get helpEditorS1P1 =>
      'കോർഡ് വീഴുന്ന അക്ഷരത്തിന് തൊട്ടുമുമ്പ് ചതുര ബ്രാക്കറ്റിൽ ഇടുക: [G]Amazing [C]grace.';

  @override
  String get helpEditorS1P2 =>
      'പാട്ട് സ്ക്രീനിൽ ആ കോർഡ് അക്ഷരത്തിനു മുകളിൽ പൊങ്ങിനിൽക്കുന്നതായി കാണിക്കും. ബ്രാക്കറ്റുകൾ ഒരിക്കലും കാണിക്കില്ല.';

  @override
  String get helpEditorS1P3 =>
      'ഇത് സാധാരണ ChordPro ആണ്; അതിനാൽ മറ്റൊരു ആപ്പിൽ എഴുതിയ ഫയലും ഇവിടെ അതുപോലെ വായിക്കാം.';

  @override
  String get helpEditorS2Heading => 'കീബോർഡിനു മുകളിലെ കോർഡ് നിര';

  @override
  String get helpEditorS2P1 =>
      'വരികൾ ടൈപ്പ് ചെയ്യുമ്പോൾ കീബോർഡിനു തൊട്ടുമുകളിൽ കോർഡ് ബട്ടണുകളുടെ ഒരു നിരയുണ്ടാകും.';

  @override
  String get helpEditorS2P2 =>
      'നിങ്ങൾ തിരഞ്ഞെടുത്ത ശ്രുതിക്ക് സാധാരണ ചേരുന്ന കോർഡുകളാണ് കാണിക്കുക — I, ii, iii, IV, V, vi എന്നിങ്ങനെ.';

  @override
  String get helpEditorS2P3 =>
      'ഒന്ന് തൊട്ടാൽ അത് ബ്രാക്കറ്റുകളോടെ കഴ്സറിൽ ചേരും.';

  @override
  String get helpEditorS2P4 =>
      'ശ്രുതി ശൂന്യമാണെങ്കിലോ വായിക്കാനാവുന്നില്ലെങ്കിലോ, ഒന്നും കാണിക്കാതിരിക്കുന്നതിനു പകരം നിര നിശ്ശബ്ദമായി C ശ്രുതിയിലേക്ക് മാറും.';

  @override
  String get helpEditorS2P5 =>
      'നിങ്ങളുടെ സ്വന്തം കോർഡുകൾ അവയ്ക്കു ശേഷം വരും. അപ്പോൾതന്നെ ഒന്ന് ചേർക്കാൻ \"സ്വന്തം\" തൊടുക, അല്ലെങ്കിൽ മുഴുവൻ പട്ടികയും ക്രമീകരണങ്ങൾ → കോർഡുകൾ എന്നതിൽ സൂക്ഷിക്കുക.';

  @override
  String get helpEditorS2P6 =>
      'ഒരു സ്വന്തം കോർഡിന് 12 അക്ഷരങ്ങൾ വരെയാകാം; ഒരേ കോർഡ് രണ്ടുതവണ സൂക്ഷിക്കില്ല.';

  @override
  String get helpEditorS3Heading => 'മുകളിലെ ഇടങ്ങൾ';

  @override
  String get helpEditorS3P1 => 'ശീർഷകം, കലാകാരൻ / സംഘം.';

  @override
  String get helpEditorS3P2 =>
      'സ്വരലിപി: പാശ്ചാത്യം, കർണാടക, ഹിന്ദുസ്ഥാനി. പാശ്ചാത്യം \"മൂല ശ്രുതി\" പെട്ടി കാണിക്കും; ഇന്ത്യൻ രീതികളിൽ ഏതെങ്കിലുമൊന്ന് അതിനു പകരം രാഗവും താളവും കാണിക്കും — കർണാടക & ഹിന്ദുസ്ഥാനി വിഷയം കാണുക.';

  @override
  String get helpEditorS3P3 =>
      'വേഗം (BPM) ആണ് മെട്രോനോമിനെയും വേഗം സ്വയംനീക്കത്തെയും നയിക്കുന്നത്.';

  @override
  String get helpEditorS3P4 =>
      '\"പട്ടികയിൽ ചേർക്കുക\" സൂക്ഷിക്കുമ്പോൾതന്നെ പാട്ടിനെ ഒരു പട്ടികയിൽ ഇടും.';

  @override
  String get helpEditorS3P5 =>
      'വരികളിൽ തൊട്ടാലുടൻ ഈ ഇടങ്ങൾ ഒറ്റവരി സംഗ്രഹമായി ചുരുങ്ങും, അങ്ങനെ സ്ക്രീൻ വരികൾക്ക് ലഭിക്കും. വീണ്ടും തുറക്കാൻ സംഗ്രഹം തൊടുക.';

  @override
  String get helpEditorS4Heading => 'പഴയപടി, സൂക്ഷിക്കൽ, പകർപ്പ്';

  @override
  String get helpEditorS4P1 =>
      'മുകളിലെ ബാറിലെ പഴയപടി / വീണ്ടും ചെയ്യുക അമ്പുകൾ നിങ്ങളുടെ ടൈപ്പിങ്ങിലൂടെ പിന്നോട്ടും മുന്നോട്ടും നീങ്ങും.';

  @override
  String get helpEditorS4P2 =>
      'സൂക്ഷിക്കുക പാട്ട് സൂക്ഷിച്ച് എഡിറ്റർ അടയ്ക്കും.';

  @override
  String get helpEditorS4P3 =>
      'കൂടുതൽ → \"പകർപ്പായി സൂക്ഷിക്കുക\" ഇപ്പോൾ സ്ക്രീനിലുള്ളത്, സൂക്ഷിക്കാത്ത മാറ്റങ്ങളടക്കം, പുതിയൊരു പാട്ടായി സൂക്ഷിക്കും. മൂലപ്പാട്ട് അതുപോലെ തുടരും.';

  @override
  String get helpEditorS4P4 =>
      'സൂക്ഷിക്കാത്ത മാറ്റങ്ങളോടെ പുറത്തുകടക്കുമ്പോൾ ആദ്യം ചോദിക്കും; അതിനാൽ അബദ്ധത്തിലുള്ള ഒരു പിന്നോട്ട് നീക്കം നിങ്ങളുടെ ജോലി കളയില്ല. ഒന്നും മാറ്റിയിട്ടില്ലെങ്കിൽ നേരെ അടയും.';

  @override
  String get helpEditorS5Heading => 'കൂടുതൽ ഓപ്ഷനുകൾ';

  @override
  String get helpEditorS5P1 =>
      'ഈണ കീപാഡ് — ടൈപ്പ് ചെയ്യുന്നതിനു പകരം ഒരു ഈണം തൊട്ട് ചേർക്കുക. ഈണവരികൾ വിഷയം കാണുക.';

  @override
  String get helpEditorS5P2 =>
      'കർണാടക ഒട്ടിക്കുക — പ്രസിദ്ധീകരിച്ച സ്വരലിപിയുടെ ഒരു ഭാഗം ഈണവരികളാക്കുക. ഇന്ത്യൻ പാട്ടുകൾ വിഷയം കാണുക.';

  @override
  String get titleHelpSetlists => 'പാട്ടുപട്ടികകൾ';

  @override
  String get helpSetlistsSummary =>
      'പരിപാടിക്കോ പരിശീലനത്തിനോ പാട്ടുകൾ കൂട്ടി ക്രമപ്പെടുത്തുക';

  @override
  String get helpSetlistsIntro =>
      'ഓരോ പാട്ടും തിരഞ്ഞുനടക്കാതെ ഒറ്റയടിക്ക് വായിച്ചുപോകാവുന്ന, ക്രമത്തിലുള്ള പാട്ടുകളുടെ കൂട്ടമാണ് പാട്ടുപട്ടിക. പട്ടികകൾ ഒരിക്കലും പകർപ്പുകൾ ഉണ്ടാക്കില്ല — നിങ്ങളുടെ ശേഖരത്തിൽ ഇതിനകമുള്ള പാട്ടുകളിലേക്ക് ചൂണ്ടുക മാത്രം ചെയ്യും.';

  @override
  String get helpSetlistsS1Heading => 'പാട്ടുപട്ടിക സൃഷ്ടിക്കുക';

  @override
  String get helpSetlistsS1P1 =>
      'ഹോം സ്ക്രീനിലെ \"പാട്ടുപട്ടികകൾ\" ടാബ് തുറക്കുക.';

  @override
  String get helpSetlistsS1P2 => '\"പുതിയ പട്ടിക\" തൊടുക.';

  @override
  String get helpSetlistsS1P3 =>
      'അതിനൊരു പേരും, വേണമെങ്കിൽ ഒരു വിവരണവും നൽകുക.';

  @override
  String get helpSetlistsS2Heading => 'പാട്ടുകൾ ചേർക്കുക, ക്രമപ്പെടുത്തുക';

  @override
  String get helpSetlistsS2P1 =>
      'ഒരു പട്ടികയ്ക്കുള്ളിൽ, നിങ്ങളുടെ ശേഖരത്തിൽനിന്ന് തിരഞ്ഞെടുക്കാൻ \"പാട്ടുകൾ ചേർക്കുക\" തൊടുക.';

  @override
  String get helpSetlistsS2P2 => 'ക്രമം മാറ്റാൻ വലതുവശത്തെ പിടി വലിക്കുക.';

  @override
  String get helpSetlistsS2P3 =>
      'ഒരു പാട്ട് പട്ടികയിൽനിന്ന് എടുത്തുമാറ്റാൻ ചുവന്ന മൈനസ് തൊടുക.';

  @override
  String get helpSetlistsS2P4 =>
      'പട്ടികയിൽനിന്ന് ഒരു പാട്ട് നീക്കിയാൽ അത് നിങ്ങളുടെ ശേഖരത്തിൽനിന്ന് ഇല്ലാതാകില്ല.';

  @override
  String get helpSetlistsS3Heading => 'പാട്ടുപട്ടിക അവതരിപ്പിക്കുക';

  @override
  String get helpSetlistsS3P1 =>
      'ആദ്യ പാട്ടിൽനിന്ന് തുടങ്ങാൻ \"പട്ടിക അവതരിപ്പിക്കുക\" തൊടുക.';

  @override
  String get helpSetlistsS3P2 =>
      'അല്ലെങ്കിൽ അവിടെനിന്ന് തുടങ്ങാൻ പട്ടികയിലെ ഏതെങ്കിലും പാട്ട് തൊടുക.';

  @override
  String get helpSetlistsS3P3 =>
      'അവതരിപ്പിക്കുമ്പോൾ പട്ടികയിലെ ക്രമത്തിൽ പാട്ടുകൾക്കിടയിൽ നീങ്ങുക.';

  @override
  String get helpSetlistsS4Heading => 'പാട്ടുപട്ടിക ഇല്ലാതാക്കുക';

  @override
  String get helpSetlistsS4P1 =>
      'പട്ടിക തുറന്ന്, മുകളിലെ ബാറിലെ ഇല്ലാതാക്കൽ (ചവറ്റുകുട്ട) ചിഹ്നം ഉപയോഗിക്കുക.';

  @override
  String get helpSetlistsS4P2 =>
      'ഇത് പട്ടിക മാത്രമേ നീക്കൂ. പാട്ടുകൾ നിങ്ങളുടെ ശേഖരത്തിൽ തുടരും.';

  @override
  String get titleHelpTranspose => 'ശ്രുതിമാറ്റവും കോർഡുകളും';

  @override
  String get helpTransposeSummary =>
      'ശ്രുതി മാറ്റുക, കോർഡുകൾ മറയ്ക്കുക, രൂപങ്ങൾ കാണുക';

  @override
  String get helpTransposeIntro =>
      'ശ്രുതിമാറ്റം പാട്ടിലെ എല്ലാ കോർഡുകളെയും ഒരേ അളവിൽ മുകളിലേക്കോ താഴേക്കോ നീക്കുന്നു; അതിനാൽ ഒന്നും മാറ്റിയെഴുതാതെ ഗായകന് ചേരുന്ന ശ്രുതിയിൽ വായിക്കാം.';

  @override
  String get helpTransposeS1Heading => 'ശ്രുതി മാറ്റുക';

  @override
  String get helpTransposeS1P1 =>
      'പാട്ട് തുറക്കുക, പിന്നെ മുകളിലെ ബാറിലെ മെനു (കൂടുതൽ) → \"അവതരണ നിയന്ത്രണം\".';

  @override
  String get helpTransposeS1P2 =>
      'ഒരു സമയം ഒരു അർദ്ധസ്വരം താഴേക്കോ മുകളിലേക്കോ നീങ്ങാൻ - ഉം + ഉം ഉപയോഗിക്കുക.';

  @override
  String get helpTransposeS1P3 =>
      'ഷീറ്റ് ഇപ്പോൾ മുഴങ്ങുന്ന ശ്രുതി രണ്ട് ബട്ടണുകൾക്കിടയിൽ കാണിക്കും.';

  @override
  String get helpTransposeS1P4 =>
      'നിയന്ത്രണ നിരയ്ക്കു താഴെയുള്ള വരി നിങ്ങൾ എത്ര നീങ്ങിയെന്ന് പറയും, \"ശ്രുതി A (+2)\" എന്നതുപോലെ.';

  @override
  String get helpTransposeS1P5 =>
      '\"പുനഃസജ്ജമാക്കുക\" പാട്ടിനെ എഴുതിയ ശ്രുതിയിലേക്ക് തിരികെ കൊണ്ടുവരും.';

  @override
  String get helpTransposeS1P6 =>
      'പരിധി 11 അർദ്ധസ്വരം താഴെ മുതൽ 11 അർദ്ധസ്വരം മുകളിൽ വരെ. മുഴുവൻ 12 ആയാൽ അതേ ശ്രുതിയിൽതന്നെ തിരിച്ചെത്തും.';

  @override
  String get helpTransposeS2Heading => 'ഇത് എന്തെല്ലാം മാറ്റുന്നു';

  @override
  String get helpTransposeS2P1 =>
      'സ്ലാഷ് കോർഡുകളും നീങ്ങും: C/E 2 മുകളിലേക്ക് നീക്കിയാൽ D/F# ആകും.';

  @override
  String get helpTransposeS2P2 =>
      'പുതിയ ശ്രുതിക്ക് ചേരുന്ന ഷാർപ്പുകളോ ഫ്ലാറ്റുകളോ തിരഞ്ഞെടുക്കും; അതിനാൽ A# അല്ല, Bb ലഭിക്കും.';

  @override
  String get helpTransposeS2P3 =>
      'മാറ്റം ഈ ഷീറ്റിനു മാത്രം — അത് ഒരിക്കലും പാട്ടിലേക്ക് തിരികെ എഴുതില്ല.';

  @override
  String get helpTransposeS2P4 =>
      'കയറ്റുമതിയും പങ്കിടലും നിങ്ങൾ കാണുന്ന ശ്രുതിതന്നെ ഉപയോഗിക്കും; അതിനാൽ ശ്രുതി മാറ്റിയ പാട്ട് അങ്ങനെതന്നെ പുറത്തുപോകും.';

  @override
  String get helpTransposeS2P5 =>
      'കർണാടക, ഹിന്ദുസ്ഥാനി പാട്ടുകൾക്ക് ശ്രുതിമാറ്റ നിയന്ത്രണമില്ല; സ്വരങ്ങൾക്ക് സ-യെ ആശ്രയിച്ചാണ് പേര്, അവ നീങ്ങില്ല.';

  @override
  String get helpTransposeS3Heading => 'കോർഡുകൾ മറയ്ക്കുക';

  @override
  String get helpTransposeS3P1 =>
      'അതേ അവതരണ നിയന്ത്രണ ഷീറ്റിൽ \"കോർഡുകൾ കാണിക്കുക\" എന്ന സ്വിച്ചുണ്ട്.';

  @override
  String get helpTransposeS3P2 =>
      'അത് ഓഫാക്കിയാൽ വെറും വരികൾ മാത്രം ബാക്കിയാകും; സാധാരണ ഗായകന് വേണ്ടത് അതാണ്.';

  @override
  String get helpTransposeS3P3 =>
      'പാട്ടിനു മുകളിലെ നിരയിലെ സംഗീതചിഹ്ന ബട്ടൺ ഒറ്റ തൊടലിൽ ഇതുതന്നെ ചെയ്യും.';

  @override
  String get helpTransposeS4Heading => 'കോർഡ് സൂചിക';

  @override
  String get helpTransposeS4P1 =>
      'മുകളിലെ ബാറിലെ മെനു → \"കോർഡ് സൂചിക\" പാട്ടിൽ ഉപയോഗിച്ച എല്ലാ കോർഡുകളും, നിങ്ങൾ വായിക്കുന്ന ശ്രുതിയിലേക്ക് ഇതിനകം നീക്കിയ നിലയിൽ, കാണിക്കും.';

  @override
  String get helpTransposeS4P2 =>
      'ഓരോ കോർഡും രണ്ടു വിധത്തിൽ വരയ്ക്കും: വിരൽപ്പുള്ളികളും, തുറന്നതും നിശ്ശബ്ദമാക്കിയതുമായ കമ്പികൾക്ക് O, X അടയാളങ്ങളുമുള്ള ആറുകമ്പി ഗിറ്റാർ ഫ്രെറ്റ്ബോർഡ്; സ്വരങ്ങൾ തെളിഞ്ഞ ഹാർമോണിയം അഥവാ പിയാനോ കീബോർഡ്.';

  @override
  String get helpTransposeS4P3 =>
      'മൂലസ്വരം ഒരു നിറം; C/E-യിലെ E പോലെ, സ്ലാഷ് കോർഡിന്റെ ബാസ് സ്വരം മറ്റൊരു നിറം.';

  @override
  String get helpTransposeS4P4 =>
      'സാധാരണ തുറന്ന രൂപങ്ങൾ ഇതിനറിയാം; ബാക്കിയെല്ലാത്തിനും നീക്കാവുന്ന ബാരെ രൂപങ്ങൾ കണ്ടെത്തും.';

  @override
  String get helpTransposeS4P5 =>
      'കർണാടക, ഹിന്ദുസ്ഥാനി പാട്ടിൽ ഇത് \"സ്വര സൂചിക\" ആകും; കോർഡ് രൂപങ്ങൾക്കു പകരം ഓരോ സ്വരവും കീബോർഡിൽ എവിടെയെന്ന്, താഴെ മുതൽ മുകളിൽ വരെ, കാണിക്കും.';

  @override
  String get titleHelpAutoScroll => 'സ്വയം നീങ്ങൽ';

  @override
  String get helpAutoScrollSummary => 'വായിക്കുമ്പോൾ കൈ തൊടാതെ ഷീറ്റ് നീക്കുക';

  @override
  String get helpAutoScrollIntro =>
      'അവതരിപ്പിക്കുമ്പോൾ സ്വയം നീങ്ങൽ കോർഡ് ഷീറ്റ് മുകളിലേക്ക് നീക്കിത്തരും, അതിനാൽ സ്ക്രീൻ തൊടേണ്ടതില്ല. രണ്ട് രീതികളുണ്ട്: സ്വമേധയാ, വേഗം.';

  @override
  String get helpAutoScrollS1Heading => 'രണ്ട് രീതികൾ';

  @override
  String get helpAutoScrollS1P1 =>
      'സ്വമേധയാ രീതി നിങ്ങൾ നിശ്ചയിക്കുന്ന സ്ഥിരവേഗത്തിൽ നീങ്ങും, 0.10x മുതൽ 2.00x വരെ. ഷീറ്റിൽ രണ്ടുതവണ തൊട്ട് മാറ്റുക; ഓരോ തൊടലും 0.05x മാറ്റും.';

  @override
  String get helpAutoScrollS1P2 =>
      'നിങ്ങൾ ഒരു പാട്ടിന് നിശ്ചയിച്ച വേഗം ആ പാട്ട് ഓർക്കും. വേഗം നിശ്ചയിച്ചിട്ടില്ലാത്ത പാട്ട് ക്രമീകരണങ്ങൾ → പൊതുവായവ → സ്വയം നീങ്ങൽ എന്നതിലെ തുടക്കവേഗത്തിൽ തുറക്കും.';

  @override
  String get helpAutoScrollS1P3 =>
      'വേഗം രീതി പാട്ടിന്റെ ദൈർഘ്യം കണക്കാക്കി, പാട്ടിന്റെ അവസാനത്തിൽതന്നെ തീരുംവിധം നീക്കത്തിന്റെ വേഗം ക്രമീകരിക്കും.';

  @override
  String get helpAutoScrollS2Heading => '\"ബാർ\" എന്നാൽ എന്ത്';

  @override
  String get helpAutoScrollS2P1 =>
      'ബാർ (മെഷർ എന്നും പറയും) സംഗീതത്തിലെ ഒരു കാലയളവാണ്.';

  @override
  String get helpAutoScrollS2P2 =>
      'താളം പറയാത്ത പാട്ട് സാധാരണ 4/4 കാലം ഉപയോഗിക്കും, അതായത് ഒരു ബാറിൽ 4 മാത്ര.';

  @override
  String get helpAutoScrollS2P3 =>
      '{tala} വരിയുള്ള പാട്ട് പകരം ആ താളത്തിന്റെ സ്വന്തം മാത്രകൾ എണ്ണും; അതിനാൽ മിശ്ര ചാപ്പ് പാട്ടിൽ ഒരു ബാറിൽ 7 മാത്ര.';

  @override
  String get helpAutoScrollS2P4 =>
      'പാട്ടുകൾ 32 ബാറിൽ തുറക്കും. ഷീറ്റിൽ രണ്ടുതവണ തൊട്ട് എണ്ണം മാറ്റുക — ഓരോ ഇരട്ടത്തൊടലും 4 ബാർ കൂട്ടുകയോ കുറയ്ക്കുകയോ ചെയ്യും.';

  @override
  String get helpAutoScrollS2P5 => 'എണ്ണം 1 ബാർ മുതൽ 512 വരെയാകാം.';

  @override
  String get helpAutoScrollS3Heading => 'വേഗം രീതി വേഗം നിശ്ചയിക്കുന്നത്';

  @override
  String get helpAutoScrollS3P1 =>
      'പാട്ടിന്റെ ദൈർഘ്യം ബാറുകളിൽനിന്നും പാട്ടിന്റെ BPM-ൽനിന്നും: ബാറുകൾ x 4 മാത്ര, നിങ്ങൾ നിശ്ചയിച്ച BPM-ൽ.';

  @override
  String get helpAutoScrollS3P2 =>
      'കൂടുതൽ ബാറുകളോ കുറഞ്ഞ BPM-ഓ ആയാൽ നീളമുള്ള, പതുക്കെയുള്ള നീക്കം.';

  @override
  String get helpAutoScrollS3P3 =>
      'കൂടിയ BPM ചെറുതും വേഗമേറിയതുമായ നീക്കം നൽകും.';

  @override
  String get helpAutoScrollS3P4 =>
      'നില വരി ബാറുകളും കണക്കാക്കിയ ദൈർഘ്യവും കാണിക്കും, \"32 ബാറുകൾ · 1:04\" എന്നതുപോലെ.';

  @override
  String get helpAutoScrollS4Heading => 'തൊട്ട് വേഗം മാറ്റുക';

  @override
  String get helpAutoScrollS4G1Title => 'മുകളിൽ ഇരട്ടത്തൊടൽ';

  @override
  String get helpAutoScrollS4G1Description => 'വേഗം കൂട്ടുക';

  @override
  String get helpAutoScrollS4G2Title => 'താഴെ ഇരട്ടത്തൊടൽ';

  @override
  String get helpAutoScrollS4G2Description => 'വേഗം കുറയ്ക്കുക';

  @override
  String get helpAutoScrollS4G3Title => 'രണ്ടു വിരൽകൊണ്ട് തൊടുക';

  @override
  String get helpAutoScrollS4G3Description => 'തുടങ്ങുക / നിർത്തുക';

  @override
  String get helpAutoScrollS4P1 =>
      'ഇതേ തൊടലുകൾ ഇവിടെയും പൂർണ്ണ സ്ക്രീനിലും പ്രവർത്തിക്കും, അതിനാൽ ഓർക്കാൻ ഒന്നേയുള്ളൂ.';

  @override
  String get helpAutoScrollS4P2 =>
      'വേഗം രീതിയിൽ ഇതേ ഇരട്ടത്തൊടലുകൾ പകരം ബാറുകൾ കൂട്ടുകയോ കുറയ്ക്കുകയോ ചെയ്യും.';

  @override
  String get helpAutoScrollS4P3 =>
      'പുതിയ മൂല്യം സ്ക്രീനിന്റെ നടുവിൽ വലുതായി മിന്നും, അതിനാൽ സ്റ്റാൻഡിൽനിന്നും വായിക്കാം.';

  @override
  String get helpAutoScrollS4P4 =>
      'ഈ വേഗം സ്വയം നീങ്ങൽ പ്രവർത്തിക്കുമ്പോൾ മാത്രമേ ഉപയോഗിക്കൂ. വിരൽകൊണ്ട് വലിക്കുമ്പോൾ ഷീറ്റ് നീങ്ങുന്ന രീതിയെ ഇത് ഒരിക്കലും മാറ്റില്ല.';

  @override
  String get helpAutoScrollS4P5 =>
      'ഒരു വിരൽ ഇപ്പോഴും നീക്കും, രണ്ടു വിരൽ നുള്ളി അക്ഷരവലുപ്പം മാറ്റാം.';

  @override
  String get helpAutoScrollS5Heading => 'തുടങ്ങുക, നിർത്തുക';

  @override
  String get helpAutoScrollS5P1 =>
      'നീക്കം തുടങ്ങാനും നിർത്താനും ഷീറ്റിൽ രണ്ടു വിരൽകൊണ്ട് തൊടുക. ഈ സ്ക്രീനിൽ ഇനി പ്ലേ ബട്ടണില്ല.';

  @override
  String get helpAutoScrollS5P2 =>
      'പൂർണ്ണ സ്ക്രീനിൽ നിയന്ത്രണ ബാറിൽ ഒരു പ്ലേ ബട്ടണും ഇപ്പോഴുമുണ്ട്.';

  @override
  String get helpAutoScrollS5P3 =>
      'വേഗം രീതിയിൽ പാട്ടിന്റെ അവസാനത്തിൽ നീക്കം സ്വയം നിൽക്കും.';

  @override
  String get helpAutoScrollS6Heading => 'ഷീറ്റ് കൈകൊണ്ട് നീക്കുക';

  @override
  String get helpAutoScrollS6P1 =>
      'സ്വയം നീങ്ങൽ പ്രവർത്തിക്കുമ്പോഴും, എപ്പോൾ വേണമെങ്കിലും ഒരു വിരൽകൊണ്ട് ഷീറ്റ് വലിക്കാം.';

  @override
  String get helpAutoScrollS6P2 =>
      'വിരൽ അമർത്തിയിരിക്കുമ്പോൾ സ്വയം നീങ്ങൽ കാത്തുനിൽക്കും, വിട്ടിടത്തുനിന്ന് തുടരും; അതിനാൽ സ്ഥാനം ശരിയാക്കാൻ നിർത്തി വീണ്ടും തുടങ്ങേണ്ടതില്ല.';

  @override
  String get helpAutoScrollS6P3 =>
      'വേഗത്തിലുള്ള ഒരു തട്ട് ഒഴുകിനീങ്ങാതെ വിരൽ ഉയർത്തുന്നിടത്ത് നിൽക്കും, കാരണം സ്വയം നീങ്ങൽ ഉടനെ വീണ്ടും ചുമതലയേൽക്കും.';

  @override
  String get helpAutoScrollS7Heading => 'പാട്ടിനു മുകളിലെ നിര';

  @override
  String get helpAutoScrollS7P1 =>
      'M, T എന്നിവ രീതി തിരഞ്ഞെടുക്കും; അമ്പുകളുടെ ചിഹ്നം പൂർണ്ണ സ്ക്രീനിലേക്ക് പോകും.';

  @override
  String get helpAutoScrollS7P2 =>
      'സ്വമേധയാ രീതിയിൽ \"0.40x\" പോലെയുള്ള വേഗം വലതുവശത്ത് കാണിക്കും. അത് വായിക്കാൻ മാത്രം — മാറ്റാൻ ഷീറ്റിൽ രണ്ടുതവണ തൊടുക.';

  @override
  String get helpAutoScrollS7P3 =>
      'സംഗീതചിഹ്നം കോർഡുകൾ മറയ്ക്കുകയും കാണിക്കുകയും ചെയ്യും.';

  @override
  String get helpAutoScrollS7P4 =>
      'പിയാനോ ചിഹ്നം ഈണവരികൾ മറയ്ക്കുകയും കാണിക്കുകയും ചെയ്യും. ഈണം എഴുതിയ പാട്ടിൽ മാത്രമേ അതുണ്ടാകൂ.';

  @override
  String get titleHelpFullScreen => 'പൂർണ്ണ സ്ക്രീൻ';

  @override
  String get helpFullScreenSummary => 'വരികൾ മാത്രം, തൊടലുകളാൽ നിയന്ത്രണം';

  @override
  String get helpFullScreenIntro =>
      'പൂർണ്ണ സ്ക്രീൻ മുകളിലെ ബാറും ഫോണിന്റെ സ്വന്തം ബാറുകളും മറയ്ക്കും, അങ്ങനെ പാട്ട് സ്ക്രീൻ മുഴുവൻ നിറയും. തത്സമയ അവതരണത്തിനുവേണ്ടി ഉണ്ടാക്കിയതാണ് ഇത്; അവിടെ സ്റ്റാൻഡിൽനിന്ന് സ്ക്രീൻ നോക്കുകയും കഴിയുന്നത്ര കുറച്ചുമാത്രം തൊടുകയും ചെയ്യുന്നു.';

  @override
  String get helpFullScreenS1Heading => 'പൂർണ്ണ സ്ക്രീനിലേക്ക്';

  @override
  String get helpFullScreenS1P1 =>
      'സ്വയം നീങ്ങൽ നിരയിലെ പൂർണ്ണ സ്ക്രീൻ ബട്ടൺ തൊടുക.';

  @override
  String get helpFullScreenS1P2 =>
      'പാട്ടും ശ്രുതിയും അക്ഷരവലുപ്പവും നീക്കസ്ഥാനവും എല്ലാം അതുപോലെ തുടരും.';

  @override
  String get helpFullScreenS1P3 =>
      'സാധാരണ പാട്ട് കാഴ്ചയിലെന്നപോലെ സ്ക്രീൻ ഉണർന്നുതന്നെയിരിക്കും.';

  @override
  String get helpFullScreenS2Heading => 'ആംഗ്യങ്ങൾ';

  @override
  String get helpFullScreenS2G1Title => 'ഒരുതവണ തൊടുക';

  @override
  String get helpFullScreenS2G1Description =>
      'നിയന്ത്രണങ്ങൾ കാണിക്കുക / മറയ്ക്കുക';

  @override
  String get helpFullScreenS2G2Title => 'മുകളിൽ ഇരട്ടത്തൊടൽ';

  @override
  String get helpFullScreenS2G2Description => 'വേഗം കൂട്ടുക';

  @override
  String get helpFullScreenS2G3Title => 'താഴെ ഇരട്ടത്തൊടൽ';

  @override
  String get helpFullScreenS2G3Description => 'വേഗം കുറയ്ക്കുക';

  @override
  String get helpFullScreenS2G4Title => 'രണ്ടു വിരൽകൊണ്ട് തൊടുക';

  @override
  String get helpFullScreenS2G4Description => 'തുടങ്ങുക / നിർത്തുക';

  @override
  String get helpFullScreenS2G5Title => 'നുള്ളുക';

  @override
  String get helpFullScreenS2G5Description => 'അക്ഷരവലുപ്പം മാറ്റുക';

  @override
  String get helpFullScreenS2G6Title => 'പിന്നോട്ട്';

  @override
  String get helpFullScreenS2G6Description =>
      'പൂർണ്ണ സ്ക്രീനിൽനിന്ന് പുറത്തുകടക്കുക';

  @override
  String get helpFullScreenS2P1 =>
      'നിയന്ത്രണ ബാർ കാണിക്കാനോ മറയ്ക്കാനോ ഒരുതവണ തൊടുക. ഏതാനും നിമിഷങ്ങൾക്കു ശേഷം അത് വീണ്ടും മറയും.';

  @override
  String get helpFullScreenS2P2 =>
      'വേഗം കൂട്ടാൻ മുകൾപകുതിയിൽ ഇരട്ടത്തൊടൽ; കുറയ്ക്കാൻ താഴ്പകുതിയിൽ ഇരട്ടത്തൊടൽ. പുതിയ മൂല്യം സ്ക്രീനിൽ വലുതായി മിന്നും.';

  @override
  String get helpFullScreenS2P3 =>
      'വേഗം രീതിയിൽ ഇതേ ഇരട്ടത്തൊടലുകൾ ബാറുകൾ കൂട്ടുകയോ കുറയ്ക്കുകയോ ചെയ്യും, കാരണം അവിടെ വേഗം നിശ്ചയിക്കുന്നത് ബാറുകളാണ്.';

  @override
  String get helpFullScreenS2P4 =>
      'തുടങ്ങാനോ നിർത്താനോ രണ്ടു വിരൽകൊണ്ട് തൊടുക.';

  @override
  String get helpFullScreenS2P5 => 'സാധാരണപോലെ, അക്ഷരവലുപ്പം മാറ്റാൻ നുള്ളുക.';

  @override
  String get helpFullScreenS3Heading => 'ബാറിലെ ബട്ടണുകൾ';

  @override
  String get helpFullScreenS3P1 =>
      'പുറത്തുകടക്കൽ (ചുരുക്കൽ ചിഹ്നം) പൂർണ്ണ സ്ക്രീൻ വിടും.';

  @override
  String get helpFullScreenS3P2 => 'പൂട്ട് സ്ക്രീൻ പൂട്ടും — താഴെ കാണുക.';

  @override
  String get helpFullScreenS3P3 =>
      'മണി വേദി നിശ്ശബ്ദ രീതി ഓണാക്കുകയും ഓഫാക്കുകയും ചെയ്യും — താഴെ കാണുക.';

  @override
  String get helpFullScreenS3P4 =>
      'M, T എന്നിവ സ്വമേധയാ അല്ലെങ്കിൽ വേഗം രീതി തിരഞ്ഞെടുക്കും; വട്ട ബട്ടൺ തുടങ്ങുകയോ നിർത്തുകയോ ചെയ്യും.';

  @override
  String get helpFullScreenS3P5 =>
      'ബാറുകളുടെ ചിഹ്നം ശ്രുതിക്കുഴലും ശ്രുതിപ്പെട്ടിയും തുറക്കും.';

  @override
  String get helpFullScreenS3P6 =>
      'അവസാനത്തെ - ഉം + ഉം, ഇരട്ടത്തൊടലുകൾ പോലെതന്നെ, സ്വമേധയാ രീതിയിൽ വേഗവും വേഗം രീതിയിൽ ബാർ എണ്ണവും മാറ്റും.';

  @override
  String get helpFullScreenS3P7 =>
      'ബട്ടണുകൾക്കു താഴെയുള്ള വരി ശ്രുതിയും BPM-ഉം, വേഗം രീതിയിൽ ദൈർഘ്യവും, ആവർത്തിക്കും.';

  @override
  String get helpFullScreenS4Heading => 'സ്ക്രീൻ പൂട്ടുക';

  @override
  String get helpFullScreenS4P1 =>
      'വേദി കാഴ്ച പൂട്ടാൻ പൂട്ട് തൊടുക. അപ്പോൾ തൊടൽ നിയന്ത്രണങ്ങൾ നിൽക്കും; കൈയോ അബദ്ധത്തിലുള്ള സ്പർശമോ വേഗം മാറ്റുകയോ പാട്ടിനിടയിൽ നിർത്തുകയോ ചെയ്യില്ല.';

  @override
  String get helpFullScreenS4P2 =>
      'നിയന്ത്രണ ബാർ മറയുകയും മുകളിൽ വലതുവശത്ത് \"വേദി പൂട്ടി\" എന്ന ചെറിയ ചിപ്പ് പ്രത്യക്ഷപ്പെടുകയും ചെയ്യും.';

  @override
  String get helpFullScreenS4P3 =>
      'തുറക്കാൻ ആ ചിപ്പ് തൊടുക, അല്ലെങ്കിൽ പിന്നോട്ട് അമർത്തുക. അത് നിങ്ങളുടെ വിരലടയാളമോ, ഫോൺ ഇതിനകം ഉപയോഗിക്കുന്ന PIN, പാറ്റേൺ, പാസ്‌വേഡ് എന്നിവയിലൊന്നോ ചോദിക്കും.';

  @override
  String get helpFullScreenS4P4 =>
      'സ്ക്രീൻ പൂട്ട് സജ്ജമാക്കാത്ത ഫോണിൽ ഒത്തുനോക്കാൻ ഒന്നുമില്ല, അതിനാൽ നേരെ തുറക്കും.';

  @override
  String get helpFullScreenS4P5 =>
      'പരിശോധന നടത്താനേ കഴിയുന്നില്ലെങ്കിൽ, വേദി എന്തായാലും തുറക്കുകയും അത് അറിയിക്കുകയും ചെയ്യും. അബദ്ധസ്പർശങ്ങൾ തടയാനാണ് പൂട്ട്; അത് ഒരിക്കലും നിങ്ങളെ പുറത്താക്കില്ല.';

  @override
  String get helpFullScreenS5Heading => 'വേദി നിശ്ശബ്ദ രീതി';

  @override
  String get helpFullScreenS5P1 =>
      'വായിക്കുമ്പോൾ റിംഗറും അറിയിപ്പ് ശബ്ദങ്ങളും നിശ്ശബ്ദമാക്കാൻ മണി തൊടുക; അങ്ങനെ ഒരു വിളി PA വഴി മുഴങ്ങില്ല.';

  @override
  String get helpFullScreenS5P2 =>
      'ആപ്പിന്റെ സ്വന്തം ശബ്ദം തൊടില്ല — മെട്രോനോം ടിക്കും ശ്രുതി സൂചനയും ശ്രുതിയും എല്ലാം പ്രവർത്തിച്ചുകൊണ്ടിരിക്കും.';

  @override
  String get helpFullScreenS5P3 =>
      'ഫോൺ ശരിക്കും നിശ്ശബ്ദമായ ശേഷമേ ചിഹ്നം ചുവപ്പാകൂ. വീണ്ടും തൊടുക, പൂർണ്ണ സ്ക്രീൻ വിടുക, അല്ലെങ്കിൽ പാട്ട് വിടുക — നിങ്ങളുടെ സാധാരണ റിംഗർ ക്രമീകരണം തിരികെവരും, ആപ്പ് അടച്ചാലും.';

  @override
  String get helpFullScreenS5P4 =>
      'ആദ്യതവണ, LyricChord-ന് \"ശല്യപ്പെടുത്തരുത് (Do Not Disturb) ആക്‌സസ്\" അനുവദിക്കാൻ Android ചോദിച്ചേക്കാം. സന്ദേശത്തിലെ ക്രമീകരണം തുറക്കുക തൊടുക, അത് ഓണാക്കുക, പിന്നെ വീണ്ടും മണി തൊടുക.';

  @override
  String get helpFullScreenS5P5 =>
      'iPhone-കളിൽ ആപ്പുകൾക്ക് റിംഗർ മാറ്റാനാവില്ല, അതിനാൽ അവിടെ മണി കാണിക്കില്ല. പകരം റിംഗ്/സൈലന്റ് സ്വിച്ച് ഉപയോഗിക്കുക.';

  @override
  String get helpFullScreenS6Heading => 'തിരികെ പോകാൻ';

  @override
  String get helpFullScreenS6P1 =>
      'പിന്നോട്ട് അമർത്തുക, അല്ലെങ്കിൽ ഒരുതവണ തൊട്ട് നിയന്ത്രണ ബാറിലെ പുറത്തുകടക്കൽ ബട്ടൺ ഉപയോഗിക്കുക.';

  @override
  String get helpFullScreenS6P2 =>
      'അത് പൂർണ്ണ സ്ക്രീൻ മാത്രമേ വിടൂ — നിങ്ങൾ ഇപ്പോഴും അതേ പാട്ടിലാണ്. പാട്ടുപുസ്തകത്തിലേക്ക് മടങ്ങാൻ വീണ്ടും പിന്നോട്ട് അമർത്തുക.';

  @override
  String get helpFullScreenS6P3 =>
      'പൂർണ്ണ സ്ക്രീനിലായിരിക്കുമ്പോൾ വശത്തേക്ക് തെന്നിച്ചാൽ പാട്ട് മാറില്ല; അതിനാൽ അബദ്ധസ്പർശം പാട്ടിനിടയിൽ തെറ്റായ പാട്ട് കൊണ്ടുവരില്ല.';

  @override
  String get titleHelpMetronome => 'മെട്രോനോം';

  @override
  String get helpMetronomeSummary => 'പാട്ടിന്റെ വേഗത്തിൽ താളം നിലനിർത്തുക';

  @override
  String get helpMetronomeIntro =>
      'അവതരിപ്പിക്കുമ്പോൾ മെട്രോനോം താളം സൂക്ഷിക്കും. അതിന്റെ വേഗം ഓരോ പാട്ടിന്റെയും BPM-ൽ (മിനിറ്റിലെ താളങ്ങൾ) നിന്നാണ്; അത് പാട്ട് എഡിറ്ററിൽ നിശ്ചയിക്കാം.';

  @override
  String get helpMetronomeS1Heading => 'ഓണാക്കുക';

  @override
  String get helpMetronomeS1P1 =>
      'ക്രമീകരണങ്ങൾ > പൊതുവായവ > മെട്രോനോം എന്നതിലേക്ക് പോകുക.';

  @override
  String get helpMetronomeS1P2 => '\"മെട്രോനോം ഓണാക്കുക\" സ്വിച്ച് ഓണാക്കുക.';

  @override
  String get helpMetronomeS1P3 =>
      'ക്രമീകരണം സൂക്ഷിക്കും; ആപ്പ് വീണ്ടും തുടങ്ങിയാലും ഓണായിരിക്കും.';

  @override
  String get helpMetronomeS2Heading => 'മിന്നലും ടിക്ക് ശബ്ദവും';

  @override
  String get helpMetronomeS2P1 =>
      'മിന്നൽ ഓരോ താളത്തിലും മിന്നും — ശബ്ദം നിശ്ശബ്ദമാക്കിയിരിക്കുമ്പോൾ ഉപകാരപ്രദം.';

  @override
  String get helpMetronomeS2P2 =>
      'ടിക്ക് ശബ്ദം ഓരോ താളത്തിലും ചെറിയൊരു ടിക്ക് കേൾപ്പിക്കും.';

  @override
  String get helpMetronomeS2P3 =>
      'ഏതെങ്കിലും ഒന്നോ, രണ്ടുമോ, ഒന്നുമില്ലാതെയോ ഉപയോഗിക്കാം.';

  @override
  String get helpMetronomeS2P4 =>
      'മെട്രോനോം ഓണാക്കുന്നതുവരെ മിന്നലും ടിക്ക് ശബ്ദവും ചാരനിറത്തിൽ നിഷ്ക്രിയമായിരിക്കും.';

  @override
  String get helpMetronomeS2P5 =>
      'ടിക്ക് ശബ്ദനില ടിക്കിന്റെ ഉച്ചത നിശ്ചയിക്കും. ടിക്ക് മീഡിയ ശബ്ദനില ഉപയോഗിക്കുന്നു; കേൾക്കുന്നില്ലെങ്കിൽ പാട്ട് തുറന്നിരിക്കുമ്പോൾ ശബ്ദ ബട്ടണുകൾ കൂട്ടുക.';

  @override
  String get helpMetronomeS2P6 =>
      'പാട്ട് തുറക്കാതെ ഒരു ബാർ കേൾക്കാൻ മെട്രോനോം ക്രമീകരണങ്ങളിലെ \"ശബ്ദം പരീക്ഷിക്കുക\" തൊടുക.';

  @override
  String get helpMetronomeS3Heading => 'ഒരു ബാറിലെ മാത്രകൾ';

  @override
  String get helpMetronomeS3P1 =>
      'മെട്രോനോം ക്രമീകരണങ്ങളിൽ ഒരു ബാറിൽ 2, 3, 4, അല്ലെങ്കിൽ 6 മാത്ര തിരഞ്ഞെടുക്കുക.';

  @override
  String get helpMetronomeS3P2 =>
      '\"മാത്ര 1-ന് ഊന്നൽ\" ഓണാണെങ്കിൽ, ഓരോ ബാറിലെയും ആദ്യ മാത്ര ഉച്ചത്തിലും ഉയർന്നും കേൾക്കും; ബാർ എവിടെ തുടങ്ങുന്നുവെന്ന് കേട്ടറിയാം.';

  @override
  String get helpMetronomeS3P3 =>
      'താളം നടക്കുമ്പോൾ ബട്ടൺ മാത്ര എണ്ണം കാണിക്കും — 1, 2, 3, 4 — അതിനാൽ ശബ്ദമില്ലെങ്കിലും നിങ്ങളുടെ സ്ഥാനം കാണാം.';

  @override
  String get helpMetronomeS4Heading => 'വേഗം നിശ്ചയിക്കുക';

  @override
  String get helpMetronomeS4P1 => 'സ്വതവേ താളവേഗം പാട്ടിന്റെ BPM പിന്തുടരും.';

  @override
  String get helpMetronomeS4P2 => 'പാട്ട് എഡിറ്റ് ചെയ്ത് അതിന്റെ BPM മാറ്റുക.';

  @override
  String get helpMetronomeS4P3 =>
      'കൈകൊണ്ട് വേഗം നിശ്ചയിക്കാൻ മെട്രോനോം ബട്ടൺ അമർത്തിപ്പിടിക്കുക: - ഉം + ഉം ഉപയോഗിക്കുക, സ്ലൈഡർ വലിക്കുക, അല്ലെങ്കിൽ സംഗീതത്തോടൊപ്പം \"തട്ടി വേഗം\" തൊടുക.';

  @override
  String get helpMetronomeS4P4 =>
      'കൈകൊണ്ട് നിശ്ചയിച്ച വേഗം ഈ ഉപയോഗവേളയിൽ മാത്രം. പാട്ടിന്റെ സ്വന്തം വേഗത്തിലേക്ക് മടങ്ങാൻ \"പാട്ടിന്റെ വേഗം\" തൊടുക.';

  @override
  String get helpMetronomeS4P5 =>
      'BPM സൂക്ഷിക്കാത്ത പാട്ടിലും പ്രവർത്തിക്കും — നിങ്ങൾ അവസാനം ഉപയോഗിച്ച വേഗം മെട്രോനോം എടുക്കും.';

  @override
  String get titleHelpPitchPipeDrone => 'ശ്രുതിക്കുഴലും ശ്രുതിയും';

  @override
  String get helpPitchPipeDroneSummary =>
      'ആധാര ശ്രുതി സൂചനകളും സ്ഥിരമായ ശ്രുതിപ്പെട്ടി ശബ്ദവും';

  @override
  String get helpPitchPipeDroneIntro =>
      'പൂർണ്ണമായും ഓഫ്‌ലൈൻ ആയ ഒരു ശബ്ദസ്രഷ്ടാവ്: തുടങ്ങാൻ ഒരു ചെറിയ ആധാരസ്വരം, ഒപ്പം പാടാൻ സ്ഥിരമായ ശ്രുതിപ്പെട്ടി ശബ്ദം. ഒന്നും ഡൗൺലോഡ് ചെയ്യുന്നില്ല, ആപ്പിനൊപ്പം ശബ്ദഫയലുകളുമില്ല — ബട്ടൺ അമർത്തുമ്പോൾതന്നെ സ്വരങ്ങൾ ഉണ്ടാക്കുന്നു.';

  @override
  String get helpPitchPipeDroneS1Heading => 'ശ്രുതി ചെയ്യുന്നതും ചെയ്യാത്തതും';

  @override
  String get helpPitchPipeDroneS1P1 =>
      'ഓണായിരിക്കുന്നിടത്തോളം ശ്രുതി ഒരേയൊരു സ്ഥിരമായ സ്വരജോടി നിലനിർത്തും.';

  @override
  String get helpPitchPipeDroneS1P2 =>
      'അത് ഈണത്തെയോ വരികളെയോ കോർഡുകളെയോ പിന്തുടരില്ല. നിങ്ങൾ മാറ്റുന്നതുവരെ അത് ഒരിക്കലും മാറില്ല.';

  @override
  String get helpPitchPipeDroneS1P3 =>
      'ഒരിക്കലും നിൽക്കാത്ത ഒരു ട്യൂണിങ് ഫോർക്കായി കരുതുക; പാടുമ്പോൾ നിങ്ങളുടെ ചെവി ഉറച്ചുനിൽക്കും.';

  @override
  String get helpPitchPipeDroneS2Heading => 'എവിടെ കണ്ടെത്താം';

  @override
  String get helpPitchPipeDroneS2P1 =>
      'ഒരു പാട്ട് തുറന്ന്, മെട്രോനോമിന് അടുത്തുള്ള ശ്രുതി ബട്ടൺ (ബാറുകളുടെ ചിഹ്നം) തൊടുക.';

  @override
  String get helpPitchPipeDroneS2P2 =>
      'വേദി രീതി ബാറിലും, പ്ലേ ബട്ടണിന് അടുത്ത്, അതുണ്ട്.';

  @override
  String get helpPitchPipeDroneS2P3 =>
      'ക്രമീകരണങ്ങൾ → പൊതുവായവ → ശ്രുതിക്കുഴലും ശ്രുതിയും സ്വതവേയുള്ളവ നിശ്ചയിക്കും; അവിടെ പരീക്ഷണ ബട്ടണുകളുമുണ്ട്.';

  @override
  String get helpPitchPipeDroneS3Heading =>
      'ശ്രുതി സൂചന (പാശ്ചാത്യത്തിൽ കോർഡ് സൂചന)';

  @override
  String get helpPitchPipeDroneS3P1 =>
      '2 സെക്കൻഡ് ആധാരസ്വരം കേൾക്കാൻ \"ശ്രുതി സൂചന\" തൊടുക. ഇതൊരു ഡിജിറ്റൽ ശ്രുതിക്കുഴലാണ്: നിങ്ങളുടെ Sa (അല്ലെങ്കിൽ തിരഞ്ഞെടുത്ത ശ്രുതി) മുഴക്കി, സ്വയം നിൽക്കും.';

  @override
  String get helpPitchPipeDroneS3P2 =>
      'പാടിത്തുടങ്ങുംമുമ്പ് തുടക്കസ്വരം കണ്ടെത്താൻ ഇത് ഉപയോഗിക്കുക.';

  @override
  String get helpPitchPipeDroneS3P3 =>
      'പാശ്ചാത്യ രീതിയിൽ ഇതേ ബട്ടണിന്റെ പേര് \"കോർഡ് സൂചന\" എന്നാണ്; അത് മുഴുവൻ കോർഡും — ബാസ്, മൂലം, മൂന്നാമത്, അഞ്ചാമത് — വായിക്കും, കാരണം പാശ്ചാത്യ വാദകർക്ക് ഒരു സ്വരമല്ല, കോർഡാണ് വേണ്ടത്. മേജറോ മൈനറോ എന്നത് നിങ്ങൾ തിരഞ്ഞെടുത്ത ഗുണം പിന്തുടരും.';

  @override
  String get helpPitchPipeDroneS3P4 =>
      'ദൈർഘ്യം 2 സെക്കൻഡ് എന്ന് നിശ്ചിതമാണ്, അതിന് ക്രമീകരണമില്ല. ശ്രുതി വ്യക്തമായി കേൾക്കാൻ മതിയായ നീളവും തടസ്സമാകാത്തത്ര ചുരുക്കവുമാണ് അത്. തൊടുംമുമ്പ് എന്തു കിട്ടുമെന്ന് അറിയാൻ ബട്ടണിൽ \"(2 സെ.)\" എന്നുണ്ട്.';

  @override
  String get helpPitchPipeDroneS3P5 =>
      'കൂടുതൽ നേരം നിൽക്കുന്ന സ്വരം വേണമെങ്കിൽ പകരം ശ്രുതിപ്പെട്ടി ഉപയോഗിക്കുക. അതിനുവേണ്ടിയാണ് അത്.';

  @override
  String get helpPitchPipeDroneS4Heading => 'സൂചനയോ ശ്രുതിയോ — ഏത്?';

  @override
  String get helpPitchPipeDroneS4P1 =>
      'സൂചന: സ്വയം നിൽക്കുന്ന ഒരു ചെറിയ ശബ്ദം. തുടങ്ങുംമുമ്പ് സ്വരം കണ്ടെത്താൻ.';

  @override
  String get helpPitchPipeDroneS4P2 =>
      'ശ്രുതി: നിങ്ങൾ നിർത്തുന്നതുവരെ മുഴങ്ങിക്കൊണ്ടിരിക്കും. പരിശീലിക്കുമ്പോഴോ അവതരിപ്പിക്കുമ്പോഴോ ഒപ്പം പാടാൻ.';

  @override
  String get helpPitchPipeDroneS4P3 =>
      'രണ്ടും ബട്ടൺ അമർത്തുന്ന നിമിഷം ആപ്പിനുള്ളിൽ ഉണ്ടാക്കുന്നു. ഒന്നും ഡൗൺലോഡ് ചെയ്യുന്നില്ല, ആപ്പിനൊപ്പം ശബ്ദഫയലുകളുമില്ല.';

  @override
  String get helpPitchPipeDroneS5Heading => 'ശ്രുതിപ്പെട്ടി';

  @override
  String get helpPitchPipeDroneS5P1 =>
      'തുടർച്ചയായ പശ്ചാത്തല മൂളൽ തുടങ്ങാൻ \"ശ്രുതിപ്പെട്ടി\" തൊടുക.';

  @override
  String get helpPitchPipeDroneS5P2 =>
      'മിക്ക സംഗീതത്തിനും Sa + Pa (പഞ്ചമം) തിരഞ്ഞെടുക്കുക; മാൽകൗൺസ്, മാർവ പോലെ Pa ഒഴിവാക്കുന്ന രാഗങ്ങൾക്ക് Sa + Ma (മധ്യമം).';

  @override
  String get helpPitchPipeDroneS5P3 =>
      'രണ്ട് സ്വരങ്ങളും ശുദ്ധ അനുപാതങ്ങളിൽ (3:2, 4:3) ട്യൂൺ ചെയ്തിരിക്കുന്നു, ഒരു യഥാർത്ഥ ശ്രുതിവാദ്യം മുഴങ്ങുന്നതുപോലെ — തുല്യ ടെമ്പറമെന്റിലല്ല.';

  @override
  String get helpPitchPipeDroneS5P4 =>
      'നിങ്ങൾ നിർത്തുന്നതുവരെ ശ്രുതി മുഴങ്ങിക്കൊണ്ടിരിക്കും, അതിനാൽ ഇടയ്ക്ക് മുറിയാതെ പരിശീലിക്കാം.';

  @override
  String get helpPitchPipeDroneS6Heading => 'ഭാരതീയവും പാശ്ചാത്യവുമായ നാമകരണം';

  @override
  String get helpPitchPipeDroneS6P1 =>
      'Sa നീക്കാവുന്നതാണ്, അതിനാൽ നിങ്ങളുടെ Sa യഥാർത്ഥത്തിൽ ഏത് ശ്രുതിയാണെന്ന് ആപ്പ് അറിയണം. ക്രമീകരണങ്ങൾ → \"നിങ്ങളുടെ Sa (ശ്രുതി)\" എന്നതിൽ നിശ്ചയിക്കുക.';

  @override
  String get helpPitchPipeDroneS6P2 =>
      'രാഗമുള്ള പാട്ടിന് ഭാരതീയ രീതിയിൽ പേര്: കർണാടകത്തിന് \"5 kattai\", ഹിന്ദുസ്ഥാനിക്ക് \"safed 5\". ഏതെന്ന് താളം തീരുമാനിക്കും. ഭാരതീയ ഷീറ്റിൽ പാശ്ചാത്യ അക്ഷരങ്ങൾ വരില്ല.';

  @override
  String get helpPitchPipeDroneS6P3 =>
      'രാഗമില്ലാത്ത പാട്ടിന് പാശ്ചാത്യ രീതിയിൽ പേര്: വെറും \"G\".';

  @override
  String get helpPitchPipeDroneS6P4 =>
      'പാശ്ചാത്യ പാട്ട് പാട്ടിന്റെ സ്വന്തം ശ്രുതിയിൽ തുറക്കും. ഭാരതീയ പാട്ട് നിങ്ങളുടെ Sa-യിൽ തുറക്കും, കാരണം സ്വരലിപി Sa-യെ ആശ്രയിച്ചാണ് എഴുതുന്നത്.';

  @override
  String get helpPitchPipeDroneS7Heading => 'വേദിക്കുള്ള അക്ഷരവലുപ്പം';

  @override
  String get helpPitchPipeDroneS7P1 =>
      'ഒരേ ഷീറ്റ് കൈയിലെ ഫോണിലും രണ്ടടി അകലെയുള്ള സ്റ്റാൻഡിലും വായിക്കുന്നു, അതിനാൽ ശ്രുതി ഷീറ്റിൽ ഒരു അക്ഷരവലുപ്പ ക്രമീകരണമുണ്ട്.';

  @override
  String get helpPitchPipeDroneS7P2 =>
      'ശ്രുതി ഷീറ്റിന്റെ താഴെയുള്ള ചിപ്പുകളിൽനിന്ന് അഞ്ച് വലുപ്പങ്ങളിൽ ഒന്ന് തിരഞ്ഞെടുക്കുക — 85%, 95%, 100%, 115%, 130%.';

  @override
  String get helpPitchPipeDroneS7P3 =>
      'ക്രമീകരണങ്ങൾ → പൊതുവായവ → ശ്രുതിക്കുഴലും ശ്രുതിയും എന്നതിലും ഇതേ ചിപ്പുകളുണ്ട്; പരിപാടിക്കുമുമ്പ് നിശ്ചയിക്കാം.';

  @override
  String get helpPitchPipeDroneS7P4 =>
      'ഇത് പൂർണ്ണ സ്ക്രീനിൽ മാത്രമല്ല, എല്ലായിടത്തും ഷീറ്റിലെ അക്ഷരവലുപ്പത്തെ ഗുണിക്കും.';

  @override
  String get helpPitchPipeDroneS7P5 =>
      'രണ്ടു വിരൽകൊണ്ട് ഷീറ്റ് നുള്ളുന്നത് ഇപ്പോഴും പ്രവർത്തിക്കും; ഒരു പാട്ടിന് ചെറുതായി മാറ്റാൻ അതാണ് എളുപ്പവഴി.';

  @override
  String get titleHelpMelody => 'ഈണവരികൾ';

  @override
  String get helpMelodySummary => 'വരികൾക്കു താഴെ ഈണം എഴുതുക, പിന്നെ കേൾക്കുക.';

  @override
  String get helpMelodyIntro =>
      'കോർഡ് ഷീറ്റ് നിങ്ങളോട് വരികൾ പറയും, പക്കമേളക്കാരനോട് എന്തു വായിക്കണമെന്നും. ഈണം പറയില്ല. ഈണവരി അത് ചേർക്കുന്നു. ഒരു വരിക്കു താഴെ {melody} എഴുതുക; ആപ്പ് മാത്രകൾ വരച്ച് മൂളിക്കേൾപ്പിക്കും, അങ്ങനെ ഒരിക്കലും കേട്ടിട്ടില്ലാത്ത പാട്ടും പഠിക്കാം.';

  @override
  String get helpMelodyS1Heading => 'ഒന്ന് എഴുതുക';

  @override
  String get helpMelodyS1P1 =>
      '{melody} എന്ന് തുടങ്ങുന്ന ഒരു വരി, അത് ചേരുന്ന പാട്ടുവരിക്കു താഴെ ഇടുക.';

  @override
  String get helpMelodyS1P2 => 'ഉദാഹരണം: {melody} P ,  M2 | M2!G3~ ,  | R2 S';

  @override
  String get helpMelodyS1P3 =>
      'മാത്രകളെ സ്പേസുകൾ വേർതിരിക്കുന്നു. ഒരു മാത്ര, ഒരു സ്പേസ്.';

  @override
  String get helpMelodyS1P4 =>
      'അതിനു മുകളിലെ വരികളും കോർഡുകളും ഒട്ടും മാറില്ല.';

  @override
  String get helpMelodyS1P5 =>
      'ടൈപ്പ് ചെയ്യേണ്ടതില്ല. എഡിറ്ററിൽ, കൂടുതൽ → \"ഈണ കീപാഡ്\" പതിനാറ് സ്വരങ്ങളും എല്ലാ അടയാളങ്ങളുമുള്ള ഒരു പാഡ് തരും; തൊടുമ്പോൾ മാത്രകൾ വരയ്ക്കും, വരി താളം നിറയ്ക്കുന്നതുവരെ \"8-ൽ 6 മാത്ര\" എന്നിങ്ങനെ എണ്ണും.';

  @override
  String get helpMelodyS1P6 =>
      'കഴ്സർ ഇതിനകം ഒരു {melody} വരിയിലാണെങ്കിൽ, കീപാഡ് ആ വരി എടുക്കും; ആദ്യം ഇല്ലാതാക്കാതെതന്നെ അത് തിരുത്താം.';

  @override
  String get helpMelodyS1P7 =>
      'പ്രസിദ്ധീകരിച്ച കർണാടക സ്വരലിപിയുടെ ഒരു ഭാഗം ഒറ്റയടിക്ക് ഈണവരികളാക്കാം — ഇന്ത്യൻ പാട്ടുകൾ വിഷയം കാണുക.';

  @override
  String get helpMelodyS2Heading => 'അഞ്ച് അടയാളങ്ങൾ';

  @override
  String get helpMelodyS2P1 =>
      'കോമ ( , ) തൊട്ടുമുമ്പുള്ള സ്വരത്തെ ഒരു മാത്ര കൂടി നീട്ടും.';

  @override
  String get helpMelodyS2P2 =>
      'വര ( | ) പുതിയ താളഖണ്ഡം എവിടെ തുടങ്ങുന്നുവെന്ന് കാണിക്കും. അതിന് സമയമെടുക്കില്ല.';

  @override
  String get helpMelodyS2P3 =>
      'ഹൈഫൻ ( - ) ഒരു മാത്ര പങ്കിടുന്ന സ്വരങ്ങളെ ചേർക്കും: G3-R2 ഓരോന്നും അര മാത്ര.';

  @override
  String get helpMelodyS2P4 =>
      'ആശ്ചര്യചിഹ്നം ( ! ) ഒരു സ്വരത്തിലേക്ക് തെന്നിക്കയറും. M2!G3 തെന്നൽ Ma-യിൽ തുടങ്ങും. വെറും !G3 Ga-യ്ക്ക് തൊട്ടുതാഴെനിന്നുള്ള ചെറിയ തെന്നലാണ്.';

  @override
  String get helpMelodyS2P5 => 'ടിൽഡ് ( ~ ) സ്വരത്തെ കുലുക്കും (ഗമകം).';

  @override
  String get helpMelodyS3Heading => 'സ്വരങ്ങൾക്ക് പേരിടൽ';

  @override
  String get helpMelodyS3P1 =>
      'വെറും പേര് സാധാരണ Sa Re Ga Ma Pa Dha Ni നിരയിലെ സ്വരമാണ്; അതിനാൽ Ma മാത്രമായാൽ Ma1.';

  @override
  String get helpMelodyS3P2 =>
      'അക്കം കൃത്യമായ സ്വരം പറയും: Ma2 ഉയർന്ന Ma ആണ്, R1 R2 R3 മൂന്ന് Ri-കൾ.';

  @override
  String get helpMelodyS3P3 =>
      'Ma2-ഉം M2-ഉം ഒരേ സ്വരം. കോർഡുകളിൽ മുഴുവൻ പേരും ഈണവരികളിൽ ചെറിയ അക്ഷരങ്ങളും ഉപയോഗിക്കുക, അല്ലെങ്കിൽ വായിക്കാൻ എളുപ്പമുള്ളത്.';

  @override
  String get helpMelodyS3P4 =>
      'രാഗം ഒരു പേരിന്റെ അർത്ഥം ഒരിക്കലും മാറ്റില്ല, അതിനാൽ ഒന്നും ഊഹിക്കുന്നില്ല.';

  @override
  String get helpMelodyS3P5 =>
      'മുന്നിലെ കുത്ത് സ്വരത്തെ ഒരു സ്ഥായി താഴ്ത്തും (.N3). പിന്നിലെ അപ്പോസ്ട്രഫി ഉയർത്തും (S\').';

  @override
  String get helpMelodyS4Heading => 'കേൾക്കുക';

  @override
  String get helpMelodyS4P1 =>
      'നിങ്ങളുടെ Sa യഥാർത്ഥത്തിൽ എവിടെയെന്ന് ആപ്പ് അറിയാൻ {tonic: 1 kattai} ചേർക്കുക. ഇതില്ലെങ്കിലും മാത്രകൾ വരയ്ക്കും, പക്ഷേ ഒന്നും വായിക്കാനാവില്ല.';

  @override
  String get helpMelodyS4P2 =>
      'മാത്രകൾ ശരിയായി കൂട്ടമാക്കാൻ {tala: misra chapu} ചേർക്കുക.';

  @override
  String get helpMelodyS4P3 => 'പാട്ടിന്റെ വേഗമാണ് വേഗം നിശ്ചയിക്കുന്നത്.';

  @override
  String get helpMelodyS4P4 =>
      'ഒരു ഈണവരി മൂളിക്കേൾക്കാൻ അതിനടുത്തുള്ള പ്ലേ ബട്ടൺ തൊടുക.';

  @override
  String get helpMelodyS4P5 =>
      'ഈണനിരകളില്ലാതെ വരികൾ വായിക്കാൻ, കൂടുതൽ മെനു → അവതരണ നിയന്ത്രണം തുറന്ന് ഈണം കാണിക്കുക ഓഫാക്കുക. പൂർണ്ണ സ്ക്രീൻ ഒരിക്കലും ഈണനിരകൾ വരയ്ക്കില്ല.';

  @override
  String get helpMelodyS4P6 =>
      'വരി ആവർത്തിക്കാൻ ആവർത്തിക്കുക ഓണാക്കുക, പതുക്കെ പഠിക്കാൻ പകുതി വേഗം.';

  @override
  String get helpMelodyS4P7 =>
      'ആദ്യം ശ്രുതിപ്പെട്ടി തുടങ്ങുക — ഒറ്റയ്ക്കു കേൾക്കുന്നതിനേക്കാൾ ശ്രുതിയോടൊപ്പം ഈണം കേൾക്കാൻ വളരെ എളുപ്പമാണ്.';

  @override
  String get helpMelodyS5Heading => 'ഇതിന് ചെയ്യാവുന്നതും ചെയ്യാനാവാത്തതും';

  @override
  String get helpMelodyS5P1 =>
      'സ്വരങ്ങൾ എവിടെ വരുന്നുവെന്നും ഓരോന്നും എത്ര നീളുന്നുവെന്നും ഇത് കാണിക്കും.';

  @override
  String get helpMelodyS5P2 =>
      'ഒരു ഗായകനെപ്പോലെ അവയ്ക്ക് ഭാവം നൽകില്ല. അതിനായി ഒരു റെക്കോർഡിങ് കേൾക്കുക.';

  @override
  String get helpMelodyS5P3 =>
      'ഓരോ പാട്ടിനും ഈണം അറിയാവുന്ന ഒരാൾ അത് ടൈപ്പ് ചെയ്യണം. കുറുക്കുവഴിയില്ല.';

  @override
  String get titleHelpIndianSongs => 'ഇന്ത്യൻ പാട്ടുകൾ';

  @override
  String get helpIndianSongsSummary =>
      'സ്വരങ്ങൾ, രാഗം, താളം, നിങ്ങളുടെ Sa എവിടെ';

  @override
  String get helpIndianSongsIntro =>
      'ഇന്ത്യൻ പാട്ട് എഴുതുന്നത് കോർഡുകളിലല്ല, സ്വരങ്ങളിലാണ് — സ രി ഗ മ പ ധ നി — ആ പേരുകൾ ഒരു നിശ്ചിത ശ്രുതിയെയല്ല, Sa-യെ ആശ്രയിച്ചുള്ളവയാണ്. ആപ്പ് അത്തരം പാട്ടിനെ തുടക്കംമുതൽ ഒടുക്കംവരെ വ്യത്യസ്തമായി കൈകാര്യം ചെയ്യും.';

  @override
  String get helpIndianSongsS1Heading =>
      'പാട്ടിനെ ഇന്ത്യൻ എന്ന് അടയാളപ്പെടുത്തുക';

  @override
  String get helpIndianSongsS1P1 =>
      'എഡിറ്ററിൽ \"സ്വരലിപി\" കർണാടക അല്ലെങ്കിൽ ഹിന്ദുസ്ഥാനി ആക്കുക.';

  @override
  String get helpIndianSongsS1P2 =>
      '\"മൂല ശ്രുതി\" പെട്ടിക്കു പകരം രാഗവും താളവും വരും, കാരണം ഇന്ത്യൻ ഷീറ്റിൽ മാറ്റാനൊരു ശ്രുതിയില്ല.';

  @override
  String get helpIndianSongsS1P3 =>
      'പാശ്ചാത്യത്തിലേക്ക് തിരികെ മാറിയാൽ രാഗവും താളവും മായും; അതിനാൽ പഴയൊരു മൂല്യം പാട്ടിനെ വീണ്ടും ഇന്ത്യൻ ആയി കാണിക്കില്ല.';

  @override
  String get helpIndianSongsS2Heading => 'താളം പെട്ടിക്കു താഴെയുള്ള കുറിപ്പ്';

  @override
  String get helpIndianSongsS2P1 =>
      'മറ്റേ സമ്പ്രദായത്തിലെ ഒരു താളം — ഉദാഹരണത്തിന് കർണാടക പാട്ടിൽ കെഹർവ — ടൈപ്പ് ചെയ്താൽ പെട്ടിക്കു താഴെ ഒരു ചെറിയ കുറിപ്പ് കാണിക്കും.';

  @override
  String get helpIndianSongsS2P2 =>
      'അത് ഉപദേശം മാത്രം. സൂക്ഷിക്കുന്നത് ഒരിക്കലും തടയില്ല. ആപ്പിന് താളപ്പേരുകളുടെ ഒരു നിശ്ചിത പട്ടികയേ അറിയൂ; നിങ്ങളുടേത് അതിലില്ലാതിരിക്കാം.';

  @override
  String get helpIndianSongsS2P3 =>
      'വേഗം സ്വയംനീക്കത്തിനും ഈണവരിക്കു താഴെയുള്ള മാത്ര ഗ്രിഡിനും ഒരു ബാറിൽ എത്ര മാത്രയെന്ന് താളമാണ് തീരുമാനിക്കുന്നത്.';

  @override
  String get helpIndianSongsS3Heading => 'പാട്ട് സ്ക്രീനിൽ എന്തു മാറുന്നു';

  @override
  String get helpIndianSongsS3P1 =>
      'പാശ്ചാത്യ അക്ഷരങ്ങളൊന്നും കാണിക്കില്ല. നില വരി \"സ്വയം നീങ്ങൽ · 120 BPM\" എന്നായിരിക്കും; രാഗവും താളവും അതിനു താഴത്തെ വരിയിൽ.';

  @override
  String get helpIndianSongsS3P2 =>
      'ശ്രുതിമാറ്റ നിയന്ത്രണമില്ല, കാരണം സ്വരം നീങ്ങില്ല.';

  @override
  String get helpIndianSongsS3P3 =>
      'മെനു കോർഡ് സൂചികയ്ക്കു പകരം \"സ്വര സൂചിക\" നൽകും.';

  @override
  String get helpIndianSongsS3P4 =>
      'ശ്രുതി ഷീറ്റ് പാട്ടിന്റെ ശ്രുതിക്കു പകരം നിങ്ങൾ സൂക്ഷിച്ച Sa-യിൽ തുറക്കും, ഇന്ത്യൻ രീതിയിൽ പേരും നൽകും — കർണാടകത്തിന് \"5 kattai\", ഹിന്ദുസ്ഥാനിക്ക് \"safed 5\".';

  @override
  String get helpIndianSongsS4Heading => 'വരികളിൽ ചേർക്കാവുന്ന വരികൾ';

  @override
  String get helpIndianSongsS4P1 =>
      '{tonic: 1 kattai} നിങ്ങളുടെ Sa യഥാർത്ഥത്തിൽ എവിടെയെന്ന് പറയും. ഇതില്ലാതെ ഈണവരി വായിക്കാനാവില്ല.';

  @override
  String get helpIndianSongsS4P2 =>
      '{tala: misra chapu} മാത്രകളെ കൂട്ടമാക്കും.';

  @override
  String get helpIndianSongsS4P3 =>
      '{sruti: madhyama} ശ്രുതിയുടെ Pa കമ്പി ശുദ്ധ മധ്യമത്തിലേക്ക് താഴ്ത്തി പാടുന്ന പാട്ടിനെ അടയാളപ്പെടുത്തും, യമുനാകല്യാണി സാധാരണ പാടുന്നതുപോലെ. അപ്പോൾ എഴുതിയ Sa ഒരു മധ്യമം ഉയർന്ന് മുഴങ്ങും.';

  @override
  String get helpIndianSongsS4P4 =>
      '{melody} വരികൾ ഈണം സൂക്ഷിക്കും — ഈണവരികൾ വിഷയം കാണുക.';

  @override
  String get helpIndianSongsS4P5 =>
      'ഇവയെല്ലാം പാട്ടിന്റെ ടെക്സ്റ്റിലാണ്, അതിനാൽ ഇറക്കുമതിയും കയറ്റുമതിയും ഇവയെ മാറ്റമില്ലാതെ കൊണ്ടുപോകും.';

  @override
  String get helpIndianSongsS5Heading => 'പ്രസിദ്ധീകരിച്ച സ്വരലിപി ഒട്ടിക്കുക';

  @override
  String get helpIndianSongsS5P1 =>
      'എഡിറ്ററിൽ, കൂടുതൽ → \"കർണാടക ഒട്ടിക്കുക\" ഒരു പുസ്തകത്തിൽനിന്നോ താളിൽനിന്നോ പകർത്തിയ ഭാഗം എടുത്ത് {melody} വരികളാക്കും.';

  @override
  String get helpIndianSongsS5P2 =>
      'പ്രസിദ്ധീകരിച്ച സ്വരലിപിക്ക് ഒരൊറ്റ മാനദണ്ഡമില്ല: ചില താളുകളിൽ വലിയക്ഷരം നീണ്ട സ്വരത്തെയും, മറ്റു ചിലതിൽ ഉയർന്ന സ്ഥായിയെയും സൂചിപ്പിക്കും.';

  @override
  String get helpIndianSongsS5P3 =>
      'അതിനാൽ ആപ്പ് ആ ഭാഗം രണ്ടു രീതിയിലും വായിച്ച്, ഓരോന്നിനെയും പാട്ടിന്റെ താളവുമായി ഒത്തുനോക്കി, ഏതാണ് ചേർന്നതെന്നും എത്രത്തോളമെന്നും പറയും — \"1-ൽ 1 ആവർത്തങ്ങൾ താളത്തിന് ചേരുന്നു — അക്ഷരവലുപ്പം സ്വരദൈർഘ്യം കാണിക്കുന്നു എന്ന് വായിച്ചു\" എന്നതുപോലെ.';

  @override
  String get helpIndianSongsS5P4 =>
      'രണ്ടു രീതിക്കും ഒരേ ഫലമാണെങ്കിൽ ഊഹിക്കാതെ അത് തുറന്നുപറയും.';

  @override
  String get helpIndianSongsS5P5 =>
      'രണ്ട് Ma-കളിൽ ഏതെന്ന് അത് സ്വയം തിരഞ്ഞെടുക്കില്ല. അത് രാഗവ്യാകരണമാണ്, കണക്കല്ല — പക്ഷേ അത് തീരുമാനിക്കുന്ന പ്രയോഗം ചൂണ്ടിക്കാണിക്കും.';

  @override
  String get titleHelpSelectSongs => 'പാട്ടുകൾ തിരഞ്ഞെടുക്കുക';

  @override
  String get helpSelectSongsSummary => 'ഒരേസമയം പല പാട്ടുകളിൽ പ്രവർത്തിക്കുക';

  @override
  String get helpSelectSongsIntro =>
      'തിരഞ്ഞെടുക്കൽ രീതി പല പാട്ടുകളെ ഒരുമിച്ച് തിരഞ്ഞെടുത്ത് ഒറ്റ ഘട്ടത്തിൽ കയറ്റുമതി ചെയ്യാനോ ഇല്ലാതാക്കാനോ സഹായിക്കും.';

  @override
  String get helpSelectSongsS1Heading => 'തിരഞ്ഞെടുക്കൽ തുടങ്ങുക';

  @override
  String get helpSelectSongsS1P1 =>
      'പാട്ടുകളുടെ പട്ടികയിൽ, തിരഞ്ഞെടുക്കൽ രീതി തുടങ്ങാൻ ഏതെങ്കിലും പാട്ടിൽ അമർത്തിപ്പിടിക്കുക.';

  @override
  String get helpSelectSongsS1P2 =>
      'തിരഞ്ഞെടുപ്പിൽ ചേർക്കാൻ കൂടുതൽ പാട്ടുകൾ തൊടുക.';

  @override
  String get helpSelectSongsS1P3 =>
      'എത്ര പാട്ടുകൾ തിരഞ്ഞെടുത്തുവെന്ന് മുകളിലെ ബാർ കാണിക്കും.';

  @override
  String get helpSelectSongsS2Heading => 'എല്ലാം തിരഞ്ഞെടുക്കുക';

  @override
  String get helpSelectSongsS2P1 =>
      'കാണുന്ന എല്ലാ പാട്ടുകളും തിരഞ്ഞെടുക്കാൻ മുകളിലെ ബാറിലെ \"എല്ലാം തിരഞ്ഞെടുക്കുക\" ചിഹ്നം ഉപയോഗിക്കുക.';

  @override
  String get helpSelectSongsS2P2 =>
      'തിരഞ്ഞെടുപ്പ് മായ്ക്കാൻ അത് വീണ്ടും (\"എല്ലാം ഒഴിവാക്കുക\") തൊടുക.';

  @override
  String get helpSelectSongsS3Heading => 'എന്തെല്ലാം ചെയ്യാം';

  @override
  String get helpSelectSongsS3P1 =>
      'തിരഞ്ഞെടുത്ത പാട്ടുകൾ ഒരൊറ്റ ChordPro ഫയലായി കയറ്റുമതി ചെയ്യുക.';

  @override
  String get helpSelectSongsS3P2 =>
      'തിരഞ്ഞെടുത്ത പാട്ടുകൾ നിങ്ങളുടെ ശേഖരത്തിൽനിന്ന് ഇല്ലാതാക്കുക.';

  @override
  String get helpSelectSongsS3P3 =>
      'മാറ്റങ്ങളില്ലാതെ തിരഞ്ഞെടുക്കൽ രീതി വിടാൻ മുകളിൽ ഇടതുവശത്തെ X തൊടുക.';

  @override
  String get titleHelpImport => 'ഇറക്കുമതി';

  @override
  String get helpImportSummary => 'പാട്ടുകൾ ആപ്പിലേക്ക് കൊണ്ടുവരിക';

  @override
  String get helpImportIntro =>
      'ഇറക്കുമതി ChordPro അല്ലെങ്കിൽ സാധാരണ ടെക്സ്റ്റ് ഫയലുകളിൽനിന്ന് പാട്ടുകൾ നിങ്ങളുടെ ശേഖരത്തിൽ ചേർക്കും. വായന ജാഗ്രതയോടെയാണ് — കേടായതോ വായിക്കാനാവാത്തതോ ആയ ഫയലുകൾ സുരക്ഷിതമായി ഒഴിവാക്കും, അവ ഒരിക്കലും ആപ്പിനെ തകർക്കില്ല.';

  @override
  String get helpImportS1Heading => 'പിന്തുണയുള്ള ഫയൽ തരങ്ങൾ';

  @override
  String get helpImportS1P1 =>
      '.cho, .pro, .chordpro, അല്ലെങ്കിൽ .txt എന്ന് അവസാനിക്കുന്ന ഫയലുകൾ തിരഞ്ഞെടുക്കാം.';

  @override
  String get helpImportS1P2 =>
      'കോർഡുകൾക്കും തലക്കെട്ടുകൾക്കും ലളിതമായ ടാഗുകൾ ഉപയോഗിക്കുന്ന സാധാരണ ടെക്സ്റ്റ് ഫയലുകളാണ് ChordPro ഫയലുകൾ.';

  @override
  String get helpImportS1P3 => 'ഒരു ഫയലോ ഒരേസമയം പല ഫയലുകളോ തിരഞ്ഞെടുക്കാം.';

  @override
  String get helpImportS2Heading => 'ഒരു ഫയലിൽ പല പാട്ടുകൾ';

  @override
  String get helpImportS2P1 => 'ഒരൊറ്റ ഫയലിൽ പല പാട്ടുകളുണ്ടാകാം.';

  @override
  String get helpImportS2P2 =>
      'പാട്ടുകളെ വേർതിരിക്കാൻ അവയ്ക്കിടയിൽ {new_song} അല്ലെങ്കിൽ {ns} ഒറ്റയ്ക്കൊരു വരിയിൽ ഇടുക. മുഴുവൻ പാട്ടുപുസ്തകവും കയറ്റുമതി ചെയ്യുമ്പോൾ ഉപയോഗിക്കുന്നതും ഇതേ വേർതിരിവാണ്.';

  @override
  String get helpImportS2P3 =>
      'പുതിയൊരു {title: ...} അല്ലെങ്കിൽ {t: ...} ടാഗ് തുടങ്ങിയും പാട്ടുകളെ വേർതിരിക്കാം. പുതിയ പാട്ട് എവിടെ തുടങ്ങുന്നുവെന്ന് ആപ്പ് സ്വയം കണ്ടെത്തും.';

  @override
  String get helpImportS3Heading => 'ടാഗുകളില്ലാത്ത ടെക്സ്റ്റ് ഫയലുകൾ';

  @override
  String get helpImportS3P1 =>
      'ടാഗുകളില്ലാത്ത സാധാരണ ടെക്സ്റ്റ് ഫയൽ ഒരു പാട്ടായി സുരക്ഷിതമായി ഇറക്കുമതി ചെയ്യും.';

  @override
  String get helpImportS3P2 =>
      'ആപ്പ് അതിന് \"പേരില്ലാത്ത പാട്ട്\" എന്ന പേരും C ശ്രുതിയും നൽകും.';

  @override
  String get helpImportS3P3 =>
      'അതിന്റെ ശീർഷകം, കോർഡുകൾ, ശ്രുതി, വേഗം എന്നിവ എപ്പോൾ വേണമെങ്കിലും തുറന്ന് തിരുത്താം.';

  @override
  String get helpImportS4Heading => 'ഇരട്ടിച്ച പാട്ടുകൾ';

  @override
  String get helpImportS4P1 =>
      'ഒരു പാട്ടിന് ശേഖരത്തിലുള്ള ഒന്നിന്റെ അതേ ശീർഷകമാണെങ്കിൽ, ആപ്പ് നിങ്ങളുടെ ഇരട്ടിപ്പ് ക്രമീകരണം പിന്തുടരും.';

  @override
  String get helpImportS4P2 =>
      'നിലവിലുള്ള പാട്ടിനു മുകളിൽ എഴുതുക, പുതിയതിന്റെ പേരു മാറ്റുക, പഴയതിന്റെ പേരു മാറ്റുക, അല്ലെങ്കിൽ ഓരോ തവണയും ശീർഷകം ചോദിക്കുക — ഇവയിലൊന്ന് തിരഞ്ഞെടുക്കാം.';

  @override
  String get helpImportS4P3 =>
      'ഇത് ക്രമീകരണങ്ങൾ → പൊതുവായവ → ഇറക്കുമതി ക്രമീകരണം എന്നതിൽ നിശ്ചയിക്കുക.';

  @override
  String get helpImportS5Heading => 'സൂക്ഷിക്കുംമുമ്പ് പരിശോധിക്കുക';

  @override
  String get helpImportS5P1 =>
      'ഓരോ ഇറക്കുമതിയും ആദ്യം ഒരു മുൻകാഴ്ച സ്ക്രീനിൽ നിൽക്കും.';

  @override
  String get helpImportS5P2 =>
      'കണ്ടെത്തിയ ശീർഷകങ്ങളും കലാകാരന്മാരും ശ്രുതികളും വരികളും വായിക്കാം; എന്തെങ്കിലും എഴുതുംമുമ്പ് ഒരു ശീർഷകം തിരുത്താം.';

  @override
  String get helpImportS5P3 =>
      'നിങ്ങൾ ഉറപ്പിക്കുന്നതുവരെ ഒന്നും ശേഖരത്തിലെത്തില്ല.';

  @override
  String get helpImportS6Heading => 'പാട്ടുകൾ വരുന്ന മറ്റു വഴികൾ';

  @override
  String get helpImportS6P1 =>
      'ഫയൽ മാനേജറിൽനിന്നോ ഇമെയിലിൽനിന്നോ ചാറ്റ് ആപ്പിൽനിന്നോ ഒരു ChordPro ഫയൽ തുറന്നാൽ അത് LyricChord-ന് ലഭിക്കുകയും ഇതേ മുൻകാഴ്ച തുറക്കുകയും ചെയ്യും.';

  @override
  String get helpImportS6P2 =>
      'അടുത്തുനിൽക്കുന്ന ഒരു കൂട്ടുകാരന് ഫയലൊന്നുമില്ലാതെ പാട്ടുകൾ അയയ്ക്കാം — AirQR വിഷയം കാണുക.';

  @override
  String get titleHelpExport => 'കയറ്റുമതി';

  @override
  String get helpExportSummary =>
      'നിങ്ങളുടെ പാട്ടുകൾ ആപ്പിനു പുറത്ത് സൂക്ഷിക്കുക';

  @override
  String get helpExportIntro =>
      'കയറ്റുമതി പാട്ടുകളെ, നിങ്ങൾ സ്ഥലം തിരഞ്ഞെടുക്കുന്ന ഒരു ഫയലായി സൂക്ഷിക്കും. പങ്കിടൽ അതേ ഫയൽ നേരെ മറ്റൊരു ആപ്പിന് നൽകും. എല്ലാം ഓഫ്‌ലൈനായി തുടരും — ഒന്നും അപ്‌ലോഡ് ചെയ്യുന്നില്ല; സിസ്റ്റത്തിന്റെ ഫയൽ പിക്കറോ പങ്കിടൽ ഷീറ്റോ ആണ് ജോലി ചെയ്യുന്നത്.';

  @override
  String get helpExportS1Heading => 'എല്ലാ പാട്ടുകളും കയറ്റുമതി ചെയ്യുക';

  @override
  String get helpExportS1P1 =>
      'ക്രമീകരണങ്ങൾ > പൊതുവായവ > ഇറക്കുമതി എന്നതിലേക്ക് പോകുക.';

  @override
  String get helpExportS1P2 => '\"എല്ലാം കയറ്റുമതി\" തൊടുക.';

  @override
  String get helpExportS1P3 =>
      'നിങ്ങളുടെ മുഴുവൻ പാട്ടുപുസ്തകവും ഒരൊറ്റ ChordPro ഫയലായി സൂക്ഷിക്കും.';

  @override
  String get helpExportS2Heading => 'ചില പാട്ടുകൾ കയറ്റുമതി ചെയ്യുക (ChordPro)';

  @override
  String get helpExportS2P1 =>
      'പാട്ടുകളുടെ പട്ടികയിൽ, വേണ്ട പാട്ടുകൾ തിരഞ്ഞെടുക്കാൻ അമർത്തിപ്പിടിക്കുക.';

  @override
  String get helpExportS2P2 => 'മുകളിലെ ബാറിലെ കയറ്റുമതി ചിഹ്നം തൊടുക.';

  @override
  String get helpExportS2P3 =>
      'തിരഞ്ഞെടുത്ത പാട്ടുകൾ ഒരൊറ്റ ChordPro ഫയലായി സൂക്ഷിക്കും.';

  @override
  String get helpExportS3Heading => 'ഒരു പാട്ട് കയറ്റുമതി ചെയ്യുക';

  @override
  String get helpExportS3P1 =>
      'പാട്ട് തുറക്കുക, പിന്നെ മുകളിലെ ബാറിലെ മെനു (കൂടുതൽ) → \"കയറ്റുമതി ചെയ്യുക\".';

  @override
  String get helpExportS3P2 =>
      'ChordPro (.chordpro) അല്ലെങ്കിൽ PDF (.pdf) തിരഞ്ഞെടുത്ത്, കയറ്റുമതി ചെയ്യുക തൊടുക.';

  @override
  String get helpExportS3P3 =>
      'എവിടെ സൂക്ഷിക്കണമെന്ന് തിരഞ്ഞെടുക്കാൻ സിസ്റ്റത്തിന്റെ ഫയൽ സേവർ തുറക്കും.';

  @override
  String get helpExportS3P4 =>
      'നിങ്ങൾ എന്തു കയറ്റുമതി ചെയ്താലും നിങ്ങൾ കാണുന്ന ശ്രുതി ഉപയോഗിക്കും; ശ്രുതി മാറ്റിയ പാട്ട് ആ ശ്രുതിയിൽതന്നെ സൂക്ഷിക്കും.';

  @override
  String get helpExportS4Heading => 'PDF എങ്ങനെയിരിക്കും';

  @override
  String get helpExportS4P1 =>
      'മുകളിൽ ശീർഷകം, കലാകാരൻ, ശ്രുതി, BPM; അതിനു താഴെ ഗിറ്റാർ കോർഡ് ചിത്രങ്ങൾ; പിന്നെ മുകളിൽ കോർഡുകളോടെ വരികൾ.';

  @override
  String get helpExportS4P2 =>
      'വരികൾ ക്രമീകരണങ്ങൾ → അക്ഷരരൂപങ്ങൾ എന്നതിൽ നിങ്ങൾ തിരഞ്ഞെടുത്ത അക്ഷരരൂപം ഉപയോഗിക്കും; അതിനാൽ മലയാളം ശരിയായി രൂപപ്പെടുകയും ടെക്സ്റ്റ് തിരഞ്ഞെടുക്കാവുന്നതായി തുടരുകയും ചെയ്യും.';

  @override
  String get helpExportS4P3 =>
      'പാട്ടിന് ആവശ്യമുള്ളത്ര വീതി മാത്രമേ താളിനുണ്ടാകൂ — ചെറിയ വരികളുള്ള പാട്ടിന് ഫോൺ സ്ക്രീൻ നന്നായി നിറയ്ക്കുന്ന ഇടുങ്ങിയ, നീണ്ട താൾ — പരമാവധി A4 വീതി വരെ.';

  @override
  String get helpExportS4P4 =>
      'ഒരു വരി ഇപ്പോഴും നീളം കൂടുതലാണെങ്കിൽ, നടുവിൽ മുറിയാതിരിക്കാൻ അക്ഷരവലുപ്പം പടിപടിയായി കുറയ്ക്കും (ഒരിക്കലും 9 pt-ൽ താഴെയല്ല).';

  @override
  String get helpExportS5Heading => 'സൂക്ഷിക്കുന്നതിനു പകരം പങ്കിടുക';

  @override
  String get helpExportS5P1 =>
      'മുകളിലെ ബാറിലെ മെനുവിൽ \"പങ്കിടുക\" എന്നതുമുണ്ട്; അത് ഫയൽ സേവറിനു പകരം സിസ്റ്റത്തിന്റെ പങ്കിടൽ ഷീറ്റ് തുറക്കും.';

  @override
  String get helpExportS5P2 =>
      'ChordPro ആയോ PDF ആയോ AirQR ധാരയായോ പങ്കിടാം — AirQR വിഷയം കാണുക.';

  @override
  String get helpExportS5P3 =>
      'പാട്ടുകളുടെ പട്ടികയിൽ പല പാട്ടുകൾ തിരഞ്ഞെടുത്താൽ മുഴുവൻ കൂട്ടത്തിനും ഇതേ പങ്കിടൽ വഴികൾ ലഭിക്കും.';

  @override
  String get titleHelpAirqr => 'AirQR പങ്കിടൽ';

  @override
  String get helpAirqrSummary =>
      'ക്യാമറ വഴി മറ്റൊരു ഫോണിലേക്ക് പാട്ടുകൾ കൈമാറുക';

  @override
  String get helpAirqrIntro =>
      'ഒരു സ്ക്രീനിൽ QR കോഡുകളുടെ ഒരു നിര മിന്നിക്കുകയും മറ്റേ ഫോൺ ക്യാമറകൊണ്ട് അത് നോക്കുകയും ചെയ്ത്, AirQR പാട്ടുകളെ ഒരു ഫോണിൽനിന്ന് മറ്റൊന്നിലേക്ക് മാറ്റുന്നു. ഇന്റർനെറ്റ്, ബ്ലൂടൂത്ത്, വൈ-ഫൈ, കേബിൾ, അക്കൗണ്ട് ഒന്നും വേണ്ട — പരസ്പരം അഭിമുഖമായ രണ്ട് സ്ക്രീനുകൾ മാത്രം.';

  @override
  String get helpAirqrS1Heading => 'ഒരു പാട്ട് അയയ്ക്കുക';

  @override
  String get helpAirqrS1P1 =>
      'പാട്ട് തുറക്കുക, പിന്നെ മുകളിലെ ബാറിലെ മെനു → \"പങ്കിടുക\".';

  @override
  String get helpAirqrS1P2 => '\"AirQR ധാര\" തിരഞ്ഞെടുത്ത് പങ്കിടുക തൊടുക.';

  @override
  String get helpAirqrS1P3 =>
      'കോഡുകൾ ഉടൻ മിന്നിത്തുടങ്ങും. ഫോൺ അനക്കാതെ പിടിച്ച് മറ്റേ ഫോണിനെ വായിക്കാൻ അനുവദിക്കുക.';

  @override
  String get helpAirqrS1P4 =>
      'നിങ്ങൾ കാണുന്നതുപോലെയാണ് പാട്ട് അയയ്ക്കുന്നത്; അതിനാൽ നിങ്ങൾ മാറ്റിയ ശ്രുതിയും അതോടൊപ്പം പോകും.';

  @override
  String get helpAirqrS2Heading => 'പല പാട്ടുകൾ അയയ്ക്കുക';

  @override
  String get helpAirqrS2P1 =>
      'ക്രമീകരണങ്ങൾ → പൊതുവായവ → ഇറക്കുമതി → \"എല്ലാം AirQR വഴി\" മുഴുവൻ പാട്ടുപുസ്തകവും അയയ്ക്കും.';

  @override
  String get helpAirqrS2P2 =>
      'അല്ലെങ്കിൽ പാട്ടുകളുടെ പട്ടികയിൽ അമർത്തിപ്പിടിച്ച് ചില പാട്ടുകൾ തിരഞ്ഞെടുത്ത്, മുകളിലെ ബാറിലെ QR ചിഹ്നം തൊടുക.';

  @override
  String get helpAirqrS3Heading => 'സ്വീകരിക്കുക';

  @override
  String get helpAirqrS3P1 =>
      'സ്വീകരിക്കുന്ന ഫോണിൽ, പാട്ടുപുസ്തകത്തിന്റെ മുകളിലെ ബാറിലെ സ്കാൻ ചിഹ്നം തൊടുക, അല്ലെങ്കിൽ ക്രമീകരണങ്ങൾ → പൊതുവായവ → ഇറക്കുമതി → \"AirQR വഴി ഇറക്കുമതി\" എന്നതിലേക്ക് പോകുക.';

  @override
  String get helpAirqrS3P2 =>
      'അയയ്ക്കുന്ന സ്ക്രീനിലേക്ക് ക്യാമറ തിരിച്ച് കാത്തിരിക്കുക. ഖണ്ഡങ്ങൾ എത്തുന്നതനുസരിച്ച് പാനൽ എണ്ണും.';

  @override
  String get helpAirqrS3P3 =>
      'എല്ലാം കിട്ടുമ്പോൾ ഫോൺ വിറയ്ക്കുകയും ഇറക്കുമതി മുൻകാഴ്ച തുറക്കുകയും ചെയ്യും; സൂക്ഷിക്കുംമുമ്പ് പാട്ടുകൾ പരിശോധിക്കാം.';

  @override
  String get helpAirqrS3P4 =>
      'ആരെങ്കിലും ചിത്രമായി അയച്ച കോഡിന്, ഗാലറി ചിഹ്നം തത്സമയ ക്യാമറയ്ക്കു പകരം കോഡിന്റെ ഫോട്ടോ വായിക്കും.';

  @override
  String get helpAirqrS4Heading => 'വ്യക്തമായി വായിക്കാൻ';

  @override
  String get helpAirqrS4P1 =>
      'പാട്ടിനെ ചെറിയ ഖണ്ഡങ്ങളാക്കി ഒന്നിനു പിറകെ ഒന്നായി കാണിക്കും, ഇടയ്ക്ക് അധിക നന്നാക്കൽ ഖണ്ഡങ്ങളും; അതിനാൽ ക്യാമറ വിട്ടുപോയ ഒരു ചിത്രം വീണ്ടും തുടങ്ങാതെതന്നെ നികത്തും.';

  @override
  String get helpAirqrS4P2 =>
      'അയയ്ക്കുന്ന ഫോണിലെ \"ധാര വേഗം\" സ്ലൈഡർ സെക്കൻഡിൽ 5 മുതൽ 25 ചിത്രങ്ങൾ വരെ; തുടക്കം 10.';

  @override
  String get helpAirqrS4P3 =>
      'പഴയ ഫോണോ മങ്ങിയ സ്ക്രീനോ പതുക്കെയാകുമ്പോൾ നന്നായി വായിക്കും. എണ്ണം നീങ്ങാതായാൽ വേഗം കുറയ്ക്കുക.';

  @override
  String get helpAirqrS4P4 =>
      'രണ്ട് സ്ക്രീനുകളും അനക്കാതെ, തെളിച്ചത്തോടെ, ഏകദേശം ഒരു ചാൺ അകലത്തിൽ വയ്ക്കുക.';

  @override
  String get titleHelpAppearance => 'തീമുകളും അക്ഷരരൂപങ്ങളും';

  @override
  String get helpAppearanceSummary => 'ഷീറ്റ് വായിക്കാൻ എളുപ്പമാക്കുക';

  @override
  String get helpAppearanceIntro =>
      'ഇരുണ്ട വേദിയിൽ വായിക്കുന്ന ഷീറ്റും മേശപ്പുറത്ത് വായിക്കുന്ന ഷീറ്റും ഒരേ ജോലിയല്ല. മൂന്ന് ക്രമീകരണങ്ങൾ അത് കൈകാര്യം ചെയ്യും: തീം, വരികളുടെ അക്ഷരരൂപം, അക്ഷരവലുപ്പം.';

  @override
  String get helpAppearanceS1Heading => 'തീം';

  @override
  String get helpAppearanceS1P1 =>
      'ക്രമീകരണങ്ങൾ → തീമുകൾ സിസ്റ്റം തീം, തെളിഞ്ഞ രൂപം, ഇരുണ്ട രൂപം എന്നിവ നൽകും.';

  @override
  String get helpAppearanceS1P2 =>
      'സിസ്റ്റം, ഫോണിൽ എന്താണോ ക്രമീകരിച്ചിരിക്കുന്നത് അത് പിന്തുടരും.';

  @override
  String get helpAppearanceS1P3 =>
      'ഇരുണ്ടത് വേദിയിൽ കണ്ണിന് ആശ്വാസവും ബാറ്ററിക്ക് ലാഭവുമാണ്.';

  @override
  String get helpAppearanceS1P4 =>
      'തിരഞ്ഞെടുപ്പ് സൂക്ഷിക്കുകയും ഉടനെ പ്രാബല്യത്തിൽ വരികയും ചെയ്യും.';

  @override
  String get helpAppearanceS2Heading => 'വരികളുടെ അക്ഷരരൂപം';

  @override
  String get helpAppearanceS2P1 =>
      'ക്രമീകരണങ്ങൾ → അക്ഷരരൂപങ്ങൾ വരികൾ വരയ്ക്കുന്ന അക്ഷരരൂപം തിരഞ്ഞെടുക്കും: സിസ്റ്റം സ്വതവേ, Noto Sans Malayalam, Noto Serif Malayalam, Manjari, അല്ലെങ്കിൽ Gayathri.';

  @override
  String get helpAppearanceS2P2 =>
      'ഓരോ തിരഞ്ഞെടുപ്പും ഇംഗ്ലീഷിലും മലയാളത്തിലും തത്സമയ മാതൃക കാണിക്കും; തിരഞ്ഞെടുക്കുംമുമ്പ് അക്ഷരങ്ങളുടെ രൂപം കാണാം.';

  @override
  String get helpAppearanceS2P3 =>
      'മലയാളം അക്ഷരരൂപങ്ങൾ ചില്ലുകളും കൂട്ടക്ഷരങ്ങളും സ്വരചിഹ്നങ്ങളും ശരിയായി രൂപപ്പെടുത്തും. സിസ്റ്റം അക്ഷരരൂപം പലപ്പോഴും അങ്ങനെ ചെയ്യില്ല.';

  @override
  String get helpAppearanceS2P4 =>
      'ഒരു തിരഞ്ഞെടുപ്പ് ആപ്പ് മുഴുവൻ ബാധകമാകും; കയറ്റുമതി ചെയ്യുന്ന PDF-ഉം അതേ അക്ഷരരൂപം ഉപയോഗിക്കും.';

  @override
  String get helpAppearanceS2P5 =>
      'അക്ഷരരൂപങ്ങൾ ഒരു ഓപ്പൺ ലൈസൻസിൽ ആപ്പിനൊപ്പം ഉൾപ്പെടുത്തിയതാണ്; ആപ്പിനെക്കുറിച്ച് എന്നതിലെ ലൈസൻസ് താളിൽ അവ പട്ടികപ്പെടുത്തിയിട്ടുണ്ട്.';

  @override
  String get helpAppearanceS3Heading => 'അക്ഷരവലുപ്പം';

  @override
  String get helpAppearanceS3P1 =>
      'അക്ഷരങ്ങൾ വലുതാക്കാനോ ചെറുതാക്കാനോ വരികളിൽ രണ്ടു വിരൽകൊണ്ട് നുള്ളുക, 10 മുതൽ 32 വരെ.';

  @override
  String get helpAppearanceS3P2 =>
      'ഇത് സാധാരണ പാട്ട് സ്ക്രീനിലും പൂർണ്ണ സ്ക്രീനിലും പ്രവർത്തിക്കും; നീക്കത്തെ ബാധിക്കില്ല.';

  @override
  String get helpAppearanceS3P3 =>
      'ശ്രുതി ഷീറ്റിൽ അഞ്ച് നിശ്ചിത വലുപ്പങ്ങളുമുണ്ട് — 85%, 95%, 100%, 115%, 130% — നുള്ളൽ നിശ്ചയിച്ചതിനെ അവ ഗുണിക്കും. ഒരു വേദി വലുപ്പം ഒരിക്കൽ നിശ്ചയിച്ച് നിലനിർത്താൻ അവ ഉപയോഗിക്കുക.';

  @override
  String get helpTopicNotFound => 'സഹായ വിഷയം കണ്ടെത്തിയില്ല.';

  @override
  String labelAirQrFps(String fps) {
    return '$fps FPS';
  }

  @override
  String get errorStorageLoadSongs => 'പാട്ടുകൾ ലോഡ് ചെയ്യാൻ കഴിഞ്ഞില്ല.';

  @override
  String get errorStorageOpenSong => 'പാട്ട് തുറക്കാൻ കഴിഞ്ഞില്ല.';

  @override
  String get errorStorageFindSongByTitle =>
      'ശീർഷകം വഴി പാട്ട് തിരയാൻ കഴിഞ്ഞില്ല.';

  @override
  String get errorStorageSaveSong => 'പാട്ട് സൂക്ഷിക്കാൻ കഴിഞ്ഞില്ല.';

  @override
  String get errorStorageUpdateSong => 'പാട്ട് നവീകരിക്കാൻ കഴിഞ്ഞില്ല.';

  @override
  String get errorStorageSaveScrollSpeed =>
      'നീങ്ങൽ വേഗം സൂക്ഷിക്കാൻ കഴിഞ്ഞില്ല.';

  @override
  String get errorStorageDeleteSong => 'പാട്ട് ഇല്ലാതാക്കാൻ കഴിഞ്ഞില്ല.';

  @override
  String get errorStorageCreateSetlist =>
      'പാട്ടുപട്ടിക സൃഷ്ടിക്കാൻ കഴിഞ്ഞില്ല.';

  @override
  String get errorStorageUpdateSetlist =>
      'പാട്ടുപട്ടിക നവീകരിക്കാൻ കഴിഞ്ഞില്ല.';

  @override
  String get errorStorageUpdateSetlistSongs =>
      'പട്ടികയിലെ പാട്ടുകൾ നവീകരിക്കാൻ കഴിഞ്ഞില്ല.';

  @override
  String get errorStorageAddSongToSetlist =>
      'പാട്ട് പട്ടികയിൽ ചേർക്കാൻ കഴിഞ്ഞില്ല.';

  @override
  String get errorStorageDeleteSetlist =>
      'പാട്ടുപട്ടിക ഇല്ലാതാക്കാൻ കഴിഞ്ഞില്ല.';

  @override
  String get errorDroneErrorChordCue => 'കോർഡ് സൂചന വായിക്കാൻ കഴിഞ്ഞില്ല.';

  @override
  String get errorDroneErrorPitchCue => 'ശ്രുതി സൂചന വായിക്കാൻ കഴിഞ്ഞില്ല.';

  @override
  String get errorDroneErrorStartDrone => 'ശ്രുതി തുടങ്ങാൻ കഴിഞ്ഞില്ല.';

  @override
  String errorMelodyProblemUnreadable(String piece, String token) {
    return '\"$token\"-ൽ \"$piece\" വായിക്കാൻ കഴിഞ്ഞില്ല.';
  }

  @override
  String errorMelodyProblemNothingToPlay(String token) {
    return '\"$token\"-ൽ വായിക്കാൻ ഒന്നുമില്ല.';
  }

  @override
  String errorCarnaticProblemUnknownTala(String tala) {
    return '\"$tala\"-ൽ എത്ര മാത്രകളുണ്ടെന്ന് കണ്ടെത്താനായില്ല.';
  }

  @override
  String get errorCarnaticProblemNoNotation =>
      'വായിക്കാൻ സ്വരലിപി ഒന്നും കണ്ടെത്തിയില്ല.';

  @override
  String errorCarnaticProblemCyclesOff(int fitting, int total, String tala) {
    return '$total-ൽ $fitting ആവർത്തങ്ങൾ $tala-ന് ചേരുന്നു. ബാക്കിയുള്ളവയുടെ നീളം തെറ്റാണ്, അതിനാൽ ചില മാത്രകൾ തെറ്റും.';
  }

  @override
  String get errorCarnaticProblemReadingsTie =>
      'വലിയക്ഷരം/ചെറിയക്ഷരം എന്ന രണ്ടു വായനയ്ക്കും ഒരേ മാർക്ക്, അതിനാൽ തിരഞ്ഞെടുത്തത് ഊഹമാണ്. മൂലത്താളുമായി ഒത്തുനോക്കുക.';

  @override
  String get errorCarnaticProblemNothingReadable => 'വായിക്കാവുന്നതൊന്നുമില്ല';

  @override
  String errorCarnaticProblemWrongLength(String got, int wanted) {
    return '$got അക്ഷരകാലങ്ങളായി വായിക്കുന്നു, പക്ഷേ ഈ താളത്തിന് $wanted വേണം';
  }

  @override
  String errorCarnaticProblemUnreadableCharacter(
    String character,
    String token,
  ) {
    return '\"$token\"-ൽ \"$character\" വായിക്കാൻ കഴിഞ്ഞില്ല';
  }

  @override
  String errorCarnaticProblemInCycle(int cycle, String problem) {
    return 'ആവർത്തം $cycle: $problem';
  }

  @override
  String get errorWidgetFailed => 'സ്ക്രീനിന്റെ ഈ ഭാഗം കാണിക്കാൻ കഴിഞ്ഞില്ല.';

  @override
  String get titleStartupFailed => 'തുടങ്ങാനായില്ല';

  @override
  String get descStartupFailed =>
      'LyricChord-ന് സൂക്ഷിച്ച വിവരങ്ങൾ തുറക്കാൻ കഴിഞ്ഞില്ല. നിങ്ങളുടെ പാട്ടുകൾക്ക് മാറ്റമില്ല. വീണ്ടും ശ്രമിക്കുക, അല്ലെങ്കിൽ പ്രശ്നം അറിയിക്കാൻ വിശദാംശങ്ങൾ പകർത്തുക.';

  @override
  String get actionCopyDetails => 'വിശദാംശം പകർത്തുക';

  @override
  String get bodyDetailsCopied => 'വിശദാംശങ്ങൾ പകർത്തി';

  @override
  String get tooltipBack => 'പിന്നോട്ട്';

  @override
  String get tooltipAirQrReceiverTorchOn => 'ടോർച്ച് ഓണാക്കുക';

  @override
  String get tooltipAirQrReceiverTorchOff => 'ടോർച്ച് ഓഫാക്കുക';

  @override
  String get tooltipAirQrReceiverSwitchCamera => 'ക്യാമറ മാറ്റുക';

  @override
  String get aboutDetailAuthor => 'രചയിതാവ്';

  @override
  String get aboutDetailEmail => 'ഇമെയിൽ';

  @override
  String get aboutDetailLicense => 'ലൈസൻസ്';

  @override
  String get aboutDetailWebsite => 'വെബ്സൈറ്റ്';

  @override
  String get aboutDetailPrivacyPolicy => 'സ്വകാര്യതാ നയം';

  @override
  String get aboutDetailAiUsed => 'ഉപയോഗിച്ച AI';

  @override
  String get aboutDetailIdeUsed => 'ഉപയോഗിച്ച IDE';

  @override
  String get titleSettingsDeleteAllData => 'എല്ലാം ഇല്ലാതാക്കുക';

  @override
  String get descSettingsDeleteAllDataSubtitle =>
      'എല്ലാ പാട്ടുകളും പട്ടികകളും ക്രമീകരണങ്ങളും നീക്കുക';

  @override
  String get titleDeleteAllData => 'എല്ലാം ഇല്ലാതാക്കണോ?';

  @override
  String get descDeleteAllData =>
      'ഈ ഫോണിലെ എല്ലാ പാട്ടുകളും പട്ടികകളും കുറിപ്പുകളും ക്രമീകരണങ്ങളും ഇല്ലാതാക്കും. ഇത് പഴയപടിയാക്കാനാവില്ല. തുടർന്ന് LyricChord മാതൃകാ പാട്ടുകളോടെ പുതുതായി തുടങ്ങും.';

  @override
  String get actionDeleteEverything => 'എല്ലാം ഇല്ലാതാക്കുക';

  @override
  String get bodyAllDataDeleted => 'എല്ലാ വിവരങ്ങളും ഇല്ലാതാക്കി';

  @override
  String get errorStorageDeleteAllData =>
      'എല്ലാ വിവരങ്ങളും ഇല്ലാതാക്കാൻ കഴിഞ്ഞില്ല. ചിലത് ഇപ്പോഴും ബാക്കിയുണ്ടാകാം.';

  @override
  String get helpSongbookS6Heading => 'പുതുതായി തുടങ്ങുക';

  @override
  String get helpSongbookS6P1 =>
      'ക്രമീകരണങ്ങൾ → എല്ലാം ഇല്ലാതാക്കുക ഈ ഫോണിലെ എല്ലാ പാട്ടുകളും പട്ടികകളും കുറിപ്പുകളും ക്രമീകരണങ്ങളും നീക്കും. ഇത് പഴയപടിയാക്കാനാവില്ല.';

  @override
  String get helpSongbookS6P2 =>
      'തുടർന്ന് LyricChord ആദ്യം ഇൻസ്റ്റാൾ ചെയ്തപ്പോഴെന്നപോലെ, മാതൃകാ പാട്ടുകളോടെ, തുടങ്ങും.';

  @override
  String get helpSongbookS6P3 =>
      'പാട്ടുകൾ തിരികെ വേണ്ടിവന്നേക്കാമെങ്കിൽ ആദ്യം അവ കയറ്റുമതി ചെയ്യുക (കയറ്റുമതി വിഷയം കാണുക).';

  @override
  String get titleSettingsLanguage => 'ഭാഷ';

  @override
  String get labelLanguageSystem => 'സിസ്റ്റം സ്വതവേ';
}
