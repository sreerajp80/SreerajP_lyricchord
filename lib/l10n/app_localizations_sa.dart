// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Sanskrit (`sa`).
class AppLocalizationsSa extends AppLocalizations {
  AppLocalizationsSa([String locale = 'sa']) : super(locale);

  @override
  String get titleApp => 'LyricChord';

  @override
  String get titleAbout => 'विषयपरिचयः';

  @override
  String get titleSettings => 'विन्यासः';

  @override
  String get titleSongs => 'गीतानि';

  @override
  String get titleSetlists => 'गीतावल्यः';

  @override
  String get labelSearch => 'अन्वेषणम्';

  @override
  String get actionCancel => 'निरस्यताम्';

  @override
  String get actionSave => 'रक्ष्यताम्';

  @override
  String get actionDelete => 'लुप्यताम्';

  @override
  String get actionEdit => 'सम्पाद्यताम्';

  @override
  String get labelStageUnlockReason => 'रङ्गविधिः उद्घाट्यताम्';

  @override
  String get bodyStageUnlockDenied =>
      'रङ्गः अद्यापि कीलितः। अनुवर्तितुम् उद्घाट्यताम्।';

  @override
  String get bodyStageUnlockedWithoutCheck =>
      'रङ्गः उद्घाटितः। पटलकीलकस्य परीक्षा न उपलब्धा आसीत्।';

  @override
  String get bodyQuietModeOn =>
      'मौनविधिः सक्रियः — आह्वानानि सूचनाश्च मौनीकृताः।';

  @override
  String get bodyQuietModeOff =>
      'मौनविधिः निवृत्तः — दूरभाषस्य ध्वनिः पुनःस्थापितः।';

  @override
  String get bodyQuietModeNeedsAccess =>
      'आह्वानानि मौनीकर्तुं LyricChord इत्यस्मै “मा बाधस्व” इत्यनुमतिः दीयताम्।';

  @override
  String get actionQuietModeOpenSettings => 'विन्यासः उद्घाट्यताम्';

  @override
  String get errorQuietModeFailed => 'दूरभाषं मौनीकर्तुं नाशक्यत।';

  @override
  String get bodyQuietModeUnsupported => 'अस्मिन् उपकरणे मौनविधिः न उपलभ्यते।';

  @override
  String errorImportFileTooLarge(String fileName, int limitMb) {
    return '$fileName आनेतुम् अतिबृहत् (सीमा $limitMb MB)।';
  }

  @override
  String errorImportFileUnreadable(String fileName) {
    return '$fileName पठितुं नाशक्यत।';
  }

  @override
  String errorImportNoSongsFound(String fileName) {
    return '$fileName इत्यस्मिन् न किमपि गीतं प्राप्तम्।';
  }

  @override
  String errorImportFilesSkippedTooLarge(int limitMb, String fileNames) {
    return '$limitMb MB इत्यस्मात् बृहत्यः सञ्चिकाः त्यक्ताः: $fileNames';
  }

  @override
  String errorImportFilesSkippedUnreadable(String fileNames) {
    return 'पठितुं नाशक्यत: $fileNames';
  }

  @override
  String get errorAirQrTransferFailed =>
      'प्रेषणम् असफलम्। “पुनःसज्जीक्रियताम्” स्पृश्यताम्, पुनः वीक्ष्यताम् च।';

  @override
  String get actionAirQrReset => 'पुनःसज्जीक्रियताम्';

  @override
  String get actionCreate => 'सृज्यताम्';

  @override
  String get actionShare => 'वितीर्यताम्';

  @override
  String get actionTryAgain => 'पुनः प्रयत्यताम्';

  @override
  String get titleHomePickSong => 'गीतचयनम्';

  @override
  String get descHomePickSongMessage =>
      'अत्र उद्घाटयितुं वामतः एकं गीतं चीयताम्।';

  @override
  String get descAppSubtitle => 'गीतपाठानां स्वरसमूहानां च पुस्तिका';

  @override
  String titleSongListSelectedCount(int count) {
    return '$count चितानि';
  }

  @override
  String get tooltipSongListCancelSelection => 'चयनं निरस्यताम्';

  @override
  String get tooltipSongListExportSelected => 'चितानि निर्याप्यन्ताम्';

  @override
  String get tooltipSongListShareSelectedAirQr => 'AirQR-मार्गेण प्रेष्यताम्';

  @override
  String get tooltipSongListShareSelected => 'चितानि वितीर्यन्ताम्';

  @override
  String get tooltipSongListSelectAll => 'सर्वं चीयताम्';

  @override
  String get tooltipSongListDeselectAll => 'सर्वचयनं निरस्यताम्';

  @override
  String get tooltipSongListDeleteSelected => 'चितानि लुप्यन्ताम्';

  @override
  String get tooltipSongListScanAirQr => 'AirQR गीतं गृह्यताम्';

  @override
  String get tooltipSongListNewSong => 'नूतनं गीतम्';

  @override
  String get titleSongListExportDialog => 'चितानां निर्यापणम्';

  @override
  String bodySongListExported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count गीतानि निर्यापितानि।',
      one: '1 गीतं निर्यापितम्।',
    );
    return '$_temp0';
  }

  @override
  String get errorSongListExportFailed => 'चितानि गीतानि निर्यापयितुं नाशक्यत।';

  @override
  String titleSongListShareDialog(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count गीतानां वितरणम्',
      one: '1 गीतस्य वितरणम्',
    );
    return '$_temp0';
  }

  @override
  String get labelSongListFormatChordPro => 'ChordPro (.chordpro)';

  @override
  String get labelSongListFormatPdf => 'PDF (.pdf)';

  @override
  String get errorSongListShareFailed => 'चितानि गीतानि वितरितुं नाशक्यत।';

  @override
  String get errorSongListPdfFailed => 'PDF निर्मातुं नाशक्यत।';

  @override
  String get errorSongListSharePdfFailed =>
      'चितानि गीतानि PDF-रूपेण वितरितुं नाशक्यत।';

  @override
  String titleSongListDeleteMany(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count गीतानि लुप्यन्ताम्?',
      one: '1 गीतं लुप्यताम्?',
    );
    return '$_temp0';
  }

  @override
  String get descSongListDeleteManyMessage =>
      'चितानि गीतानि भवतः गीतपुस्तकात् अपनेष्यन्ते।';

  @override
  String bodySongListDeletedMany(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count गीतानि लुप्तानि।',
      one: '1 गीतं लुप्तम्।',
    );
    return '$_temp0';
  }

  @override
  String bodySongListCopied(String title) {
    return '\"$title\" प्रतिलिखितम्।';
  }

  @override
  String get titleSongListDeleteOne => 'गीतं लुप्यताम्?';

  @override
  String descSongListDeleteOneMessage(String title) {
    return '\"$title\" भवतः गीतपुस्तकात् अपनेष्यते।';
  }

  @override
  String bodySongListDeletedOne(String title) {
    return '\"$title\" लुप्तम्।';
  }

  @override
  String titleSongListAirQr(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count चितानि गीतानि',
      one: '1 चितं गीतम्',
    );
    return '$_temp0';
  }

  @override
  String get emptySongbookNoMatchesTitle => 'न किमपि प्राप्तम्';

  @override
  String get emptySongbookNoMatchesMessage =>
      'अन्वेषणेन सह न किमपि गीतं समेतम्। अन्ये शब्दाः प्रयुज्यन्ताम्।';

  @override
  String get emptySongbookNoStarredTitle => 'तारकाङ्कितानि गीतानि न सन्ति';

  @override
  String get emptySongbookNoStarredMessage =>
      'गीतम् अत्र स्थापयितुं तस्य तारका स्पृश्यताम्।';

  @override
  String get emptySongbookEmptyTitle => 'भवतः गीतपुस्तकं रिक्तम्';

  @override
  String get emptySongbookEmptyMessage =>
      'प्रथमं स्वरसमूहपत्रं लेखितुं + स्पृश्यताम्।';

  @override
  String get errorSongbookErrorTitle => 'गीतपुस्तकम् उद्घाटयितुं नाशक्यत';

  @override
  String get errorSongbookErrorMessage =>
      'भवतः गीतानि अद्यापि रक्षितानि। इदानीं तानि पठितुं नाशक्यत।';

  @override
  String labelSongCardKeySemantics(String key) {
    return 'स्वरमानम् $key';
  }

  @override
  String labelSongCardBpm(int bpm) {
    return '$bpm BPM';
  }

  @override
  String descSongCardBpmSemantics(int bpm) {
    return '$bpm लयमात्राः (BPM)';
  }

  @override
  String get tooltipSongCardAddStar => 'तारकाङ्क्यताम्';

  @override
  String get tooltipSongCardRemoveStar => 'तारका अपनीयताम्';

  @override
  String get tooltipSongCardDuplicate => 'गीतं प्रतिलिख्यताम्';

  @override
  String get tooltipSongCardDelete => 'गीतं लुप्यताम्';

  @override
  String get descSongSearchHint => 'गीतं गायकं पाठं वा अन्विष्यताम्';

  @override
  String get tooltipSongSearchClear => 'अन्वेषणं रिक्तीक्रियताम्';

  @override
  String labelSongFilterAll(int count) {
    return 'सर्वाणि ($count)';
  }

  @override
  String labelSongFilterStarred(int count) {
    return 'तारकाङ्कितानि ($count)';
  }

  @override
  String errorSetlistLoad(String error) {
    return 'गीतावल्यः आनेतुं दोषः: $error';
  }

  @override
  String get emptySetlistEmptyTitle => 'अद्यापि गीतावल्यः न सन्ति';

  @override
  String get emptySetlistEmptyMessage =>
      'प्रदर्शनाभ्यासयोः कृते गीतानि संयोजयितुं क्रमीकर्तुं च गीतावल्यः सृज्यन्ताम्।';

  @override
  String get actionSetlistCreate => 'गीतावली सृज्यताम्';

  @override
  String labelSetlistSongCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count गीतानि',
      one: '1 गीतम्',
    );
    return '$_temp0';
  }

  @override
  String get actionSetlistPerform => 'प्रस्तूयताम्';

  @override
  String get actionSetlistEditSongs => 'गीतानि सम्पाद्यन्ताम्';

  @override
  String get actionSetlistNew => 'नूतना गीतावली';

  @override
  String get titleSetlist => 'गीतावली';

  @override
  String errorSetlistLoadOne(String error) {
    return 'गीतावलीम् आनेतुं दोषः: $error';
  }

  @override
  String get errorSetlistNotFound => 'गीतावली न प्राप्ता।';

  @override
  String get tooltipSetlistShareAirQr => 'AirQR-मार्गेण प्रेष्यताम्';

  @override
  String get tooltipSetlistEditInfo => 'विवरणं सम्पाद्यताम्';

  @override
  String get tooltipSetlistDelete => 'गीतावली लुप्यताम्';

  @override
  String get actionSetlistPerformAll => 'गीतावली प्रस्तूयताम्';

  @override
  String titleSetlistSongCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count गीतानि',
      one: '1 गीतम्',
    );
    return '$_temp0';
  }

  @override
  String get actionSetlistAddSongs => 'गीतानि योज्यन्ताम्';

  @override
  String get emptySetlistNoSongs => 'अस्यां गीतावल्यां गीतानि न सन्ति';

  @override
  String get actionSetlistAddSongsNow => 'गीतानि योज्यन्ताम्';

  @override
  String descSetlistSongDetails(String key, int bpm) {
    return 'स्वरमानम्: $key • $bpm BPM';
  }

  @override
  String descSetlistSongDetailsWithArtist(String artist, String key, int bpm) {
    return '$artist • स्वरमानम्: $key • $bpm BPM';
  }

  @override
  String get tooltipSetlistRemoveSong => 'गीतावल्याः अपनीयताम्';

  @override
  String get titleSetlistDelete => 'गीतावली लुप्यताम्?';

  @override
  String descSetlistDeleteMessage(String name) {
    return '\"$name\" लोप्स्यते। भवतः गीतपुस्तकस्य गीतानि न लोप्स्यन्ते।';
  }

  @override
  String bodySetlistDeleted(String name) {
    return '\"$name\" गीतावली लुप्ता।';
  }

  @override
  String get bodySetlistNothingToShare => 'वितरणाय गीतावल्यां गीतानि न सन्ति।';

  @override
  String titleSetlistAirQr(String name) {
    return 'गीतावली: $name';
  }

  @override
  String get titleSetlistEdit => 'गीतावलीसम्पादनम्';

  @override
  String get labelSetlistName => 'गीतावलीनाम';

  @override
  String get descSetlistNameHint => 'उदा. रविवासरप्रदर्शनम्, अभ्यासः';

  @override
  String get errorSetlistNameRequired => 'गीतावल्याः नाम दीयताम्';

  @override
  String get labelSetlistDescription => 'विवरणम् (वैकल्पिकम्)';

  @override
  String get descSetlistDescriptionHint => 'उदा. स्थानम्, गायकाः, टिप्पण्यः';

  @override
  String get titleSetlistPicker => 'गीतावल्यां गीतयोजनम्';

  @override
  String actionSetlistPickerDone(int count) {
    return 'समाप्तम् ($count)';
  }

  @override
  String get descSetlistPickerSearchHint => 'गीतानि अन्विष्यन्ताम्...';

  @override
  String errorSetlistPickerLoad(String error) {
    return 'गीतानि आनेतुं दोषः: $error';
  }

  @override
  String get emptySetlistPickerNoSongs => 'न किमपि गीतं प्राप्तम्';

  @override
  String get actionDiscard => 'त्यज्यताम्';

  @override
  String get actionKeepEditing => 'सम्पादनम् अनुवर्त्यताम्';

  @override
  String get actionInsert => 'निवेश्यताम्';

  @override
  String get actionAdd => 'योज्यताम्';

  @override
  String get actionClear => 'रिक्तीक्रियताम्';

  @override
  String get labelTraditionWestern => 'पाश्चात्यम्';

  @override
  String get labelTraditionCarnatic => 'कर्णाटकम्';

  @override
  String get labelTraditionHindustani => 'हिन्दुस्थानी';

  @override
  String get descCarnaticReadingDuration => 'अक्षररूपं स्वरस्य कालं सूचयति';

  @override
  String get descCarnaticReadingOctave => 'अक्षररूपं सप्तकं सूचयति';

  @override
  String get titleEditorNew => 'नूतनं गीतम्';

  @override
  String get titleEditorEdit => 'गीतसम्पादनम्';

  @override
  String get tooltipEditorUndo => 'प्रत्यावर्त्यताम्';

  @override
  String get tooltipEditorRedo => 'पुनःक्रियताम्';

  @override
  String get tooltipEditorMoreOptions => 'अधिकम्';

  @override
  String get actionEditorMelodyKeypad => 'स्वरफलकम्';

  @override
  String get actionEditorPasteCarnatic => 'कर्णाटकं स्थाप्यताम्';

  @override
  String get actionEditorSaveAsCopy => 'प्रतिलिपिः रक्ष्यताम्';

  @override
  String get errorEditorLoad => 'इदं गीतम् उद्घाटयितुं नाशक्यत।';

  @override
  String get descEditorLyricsHint =>
      'गीतपाठः अत्र लिख्यताम्।\nसूचकस्थाने योजयितुम् उपरि स्वरसमूहः स्पृश्यताम्।';

  @override
  String errorEditorNeedsTala(String directive) {
    return 'प्रथमं $directive पङ्क्तिः योज्यताम् — स्वरलिपिः तालस्य मात्राभिः सह परीक्ष्यते।';
  }

  @override
  String get titleEditorDiscard => 'परिवर्तनानि त्यज्यन्ताम्?';

  @override
  String get descEditorDiscardMessage =>
      'अस्मिन् गीते कृतानि परिवर्तनानि न रक्षिष्यन्ते।';

  @override
  String get labelEditorUntitled => 'अनाम';

  @override
  String get labelUntitledSong => 'अनामगीतम्';

  @override
  String labelSongCopyTitle(String title) {
    return '$title (प्रतिलिपिः)';
  }

  @override
  String labelEditorSummaryKey(String key) {
    return 'स्वरमानम् $key';
  }

  @override
  String labelEditorSummaryBpm(String bpm) {
    return '$bpm BPM';
  }

  @override
  String descEditorTalaWarning(String tala, String tradition) {
    return '\"$tala\" प्रायः $tradition तालः। तथापि रक्षितुं शक्यते।';
  }

  @override
  String get labelSongMetaTitle => 'शीर्षकम्';

  @override
  String get labelSongMetaTitleHint => 'गीतस्य शीर्षकम्';

  @override
  String get labelSongMetaArtist => 'गायकः / वृन्दम्';

  @override
  String get labelSongMetaArtistHint => 'कः गायति';

  @override
  String get labelSongMetaNotation => 'स्वरलिपिः';

  @override
  String get descSongMetaNotationHelper =>
      'पाश्चात्यं स्वरसमूहान् उपयुङ्क्ते। भारतीयं स्वरान् उपयुङ्क्ते।';

  @override
  String get labelSongMetaRaga => 'रागः';

  @override
  String get labelSongMetaRagaHint => 'कल्याणी, यमन्';

  @override
  String get labelSongMetaKey => 'मूलस्वरमानम्';

  @override
  String get labelSongMetaKeyHint => 'C, Am, F#m';

  @override
  String get labelSongMetaTempo => 'लयः (BPM)';

  @override
  String get labelSongMetaTempoHint => '120';

  @override
  String get labelSongMetaTala => 'तालः';

  @override
  String get labelSongMetaTalaHint => 'आदिः, कहरवा';

  @override
  String get labelSongMetaSetlist => 'गीतावल्यां योज्यताम्';

  @override
  String get labelSongMetaSetlistNone => 'न किमपि (मा योजय)';

  @override
  String tooltipChordInserterInsert(String chord) {
    return '[$chord] योज्यताम्';
  }

  @override
  String get actionChordInserterCustom => 'स्वकीयम्';

  @override
  String get tooltipChordInserterCustom => 'स्वकीयः स्वरसमूहः योज्यताम्';

  @override
  String get titleChordInserterDialog => 'स्वकीयः स्वरसमूहः';

  @override
  String get labelChordInserterChord => 'स्वरसमूहः';

  @override
  String get labelChordInserterChordHint => 'F#m7, Cmaj7, D/F#';

  @override
  String get titleRenameImport => 'समानशीर्षकं गीतम्';

  @override
  String descRenameImportExists(String title) {
    return '\"$title\" इति शीर्षकं गीतं भवतः गीतपुस्तके पूर्वमेव वर्तते।';
  }

  @override
  String get descRenameImportPrompt =>
      'आनीयमानस्य गीतस्य नूतनं शीर्षकं दीयताम्:';

  @override
  String get labelRenameImport => 'गीतशीर्षकम्';

  @override
  String get errorRenameImportRequired => 'शीर्षकं दीयताम्';

  @override
  String get actionRenameImportSave => 'नवनाम्ना रक्ष्यताम्';

  @override
  String get titleMelodyKeypadDiscard => 'एषा स्वरपङ्क्तिः त्यज्यताम्?';

  @override
  String get descMelodyKeypadDiscardMessage => 'यत् स्पृष्टं तत् नश्यति।';

  @override
  String get labelMelodyKeypadHold => 'दीर्घम् ,';

  @override
  String get tooltipMelodyKeypadHold => 'एका मात्रा वर्ध्यताम्';

  @override
  String get labelMelodyKeypadBar => 'विभागः |';

  @override
  String get tooltipMelodyKeypadBar => 'विभागरेखा';

  @override
  String get labelMelodyKeypadShare => 'अंशः -';

  @override
  String get tooltipMelodyKeypadShare => 'इयं मात्रा विभज्यताम्';

  @override
  String get labelMelodyKeypadTie => 'बन्धः ,-';

  @override
  String get tooltipMelodyKeypadTie => 'मात्रामध्ये आरभ्यताम्';

  @override
  String get labelMelodyKeypadSilence => 'मौनम् x';

  @override
  String get tooltipMelodyKeypadSilence => 'ध्वनिः विरम्यताम्';

  @override
  String get labelMelodyKeypadOctaveUp => 'सप्तकम् ↑';

  @override
  String get labelMelodyKeypadOctaveDown => 'सप्तकम् ↓';

  @override
  String get labelMelodyKeypadSlide => 'सरणम् !';

  @override
  String get labelMelodyKeypadShake => 'कम्पितम् ~';

  @override
  String get tooltipMelodyKeypadBackspace => 'अन्तिमं लुप्यताम्';

  @override
  String labelMelodyKeypadBeats(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count मात्राः',
      one: '1 मात्रा',
    );
    return '$_temp0';
  }

  @override
  String descMelodyKeypadFits(int count, String tala) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count मात्राः — $tala तालं पूरयन्ति',
      one: '1 मात्रा — $tala तालं पूरयति',
    );
    return '$_temp0';
  }

  @override
  String labelMelodyKeypadOfBeats(int count, int total) {
    return '$total मध्ये $count मात्राः';
  }

  @override
  String get descMelodyKeypadStartHint =>
      'आरब्धुं स्वरः स्पृश्यताम्। “दीर्घम्” एकां मात्रां योजयति, “विभागः” समूहं चिह्नयति।';

  @override
  String descCarnaticSheetHelp(String tala) {
    return 'तालः: $tala। प्रतिपङ्क्ति एकः आवर्तः स्थाप्यताम्, अथवा || इत्यनेन विभज्यताम्। अधोरेखिताः भागाः _like_this_ इति लिख्यन्ताम्।';
  }

  @override
  String get labelCarnaticSheetAnyaTitle => 'Ga-Ma-Ri इत्यत्र Ma1';

  @override
  String get descCarnaticSheetAnyaSubtitle =>
      'यमुनाकल्याणी इव भाषाङ्गरागाय। मूलतः निष्क्रियम् — कः मध्यमः इति स्वरलिपिः न वदति।';

  @override
  String actionCarnaticSheetInsertLines(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count पङ्क्तयः योज्यन्ताम्',
      one: '1 पङ्क्तिः योज्यताम्',
    );
    return '$_temp0';
  }

  @override
  String descCarnaticSheetFit(int fitting, int total, String reading) {
    return '$total मध्ये $fitting आवर्ताः तालं पूरयन्ति — $reading इति पठितम्।';
  }

  @override
  String descCarnaticSheetOtherReading(String reading, int fitting, int total) {
    return 'अन्यत् पठनम् ($reading) $total मध्ये $fitting पूरयति।';
  }

  @override
  String descCarnaticSheetAnyaHint(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count आवर्तेषु Ga-Ma-Ri अवरोहः दृश्यते। भाषाङ्गरागे सः मध्यमः शुद्धमध्यमः।',
      one:
          '1 आवर्ते Ga-Ma-Ri अवरोहः दृश्यते। भाषाङ्गरागे सः मध्यमः शुद्धमध्यमः।',
    );
    return '$_temp0';
  }

  @override
  String get labelMelodyLineLoop => 'आवृत्तिः';

  @override
  String get labelMelodyLineHalfSpeed => 'अर्धलयः';

  @override
  String get errorMelodyLinePlayFailed => 'इयं स्वरपङ्क्तिः वादयितुं नाशक्यत।';

  @override
  String get tooltipMelodyLineStop => 'विरम्यताम्';

  @override
  String get tooltipMelodyLinePlay => 'इयं पङ्क्तिः गीयताम्';

  @override
  String tooltipMelodyLineNeedsTonic(String directive) {
    return '$directive पङ्क्तिः आवश्यकी';
  }

  @override
  String get actionClose => 'पिधीयताम्';

  @override
  String get actionExport => 'निर्याप्यताम्';

  @override
  String get tooltipPlay => 'आरभ्यताम्';

  @override
  String get tooltipPause => 'स्थग्यताम्';

  @override
  String get actionReset => 'पुनःसज्जीक्रियताम्';

  @override
  String labelInfoRaga(String raga) {
    return 'रागः $raga';
  }

  @override
  String labelInfoTala(String tala) {
    return 'तालः $tala';
  }

  @override
  String labelInfoKey(String key) {
    return 'स्वरमानम् $key';
  }

  @override
  String labelInfoKeyTransposed(String key, String semitones) {
    return 'स्वरमानम् $key ($semitones)';
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
      other: '$count आवर्ताः',
      one: '1 आवर्तः',
    );
    return '$_temp0';
  }

  @override
  String get labelInfoAutoScroll => 'स्वयंसर्पणम्';

  @override
  String get titlePerfSong => 'गीतम्';

  @override
  String get tooltipPerfPreviousSong => 'पूर्वं गीतम्';

  @override
  String get tooltipPerfNextSong => 'अग्रिमं गीतम्';

  @override
  String get tooltipPerfSetlistSongs => 'गीतावल्याः गीतानि';

  @override
  String get tooltipPerfEditSong => 'गीतं सम्पाद्यताम्';

  @override
  String titlePerfSetlistPosition(String name, int position, int total) {
    return '$name ($position/$total)';
  }

  @override
  String get errorPerfNotFoundTitle => 'गीतं न प्राप्तम्';

  @override
  String get descPerfNotFoundMessage => 'एतत् भवतः गीतपुस्तकात् लुप्तं स्यात्।';

  @override
  String get actionPerfControls => 'प्रस्तुतिनियन्त्रणम्';

  @override
  String get tooltipPerfGesturesHelp => 'सङ्केतसाहाय्यम्';

  @override
  String get actionPerfSwaraReference => 'स्वरसूचिका';

  @override
  String get actionPerfChordReferenceGuide => 'स्वरसमूहसूचिका';

  @override
  String get titlePerfExportDialog => 'गीतनिर्यापणम्';

  @override
  String get titlePerfShareDialog => 'गीतवितरणम्';

  @override
  String get labelPerfFormatAirQr => 'AirQR धारा';

  @override
  String get errorPerfShareChordProFailed =>
      'ChordPro सञ्चिकां वितरितुं नाशक्यत।';

  @override
  String get errorPerfPdfNoPages =>
      'PDF निर्यापयितुं नाशक्यत (पृष्ठानि न सन्ति)।';

  @override
  String get errorPerfPdfTimeout =>
      'PDF निर्यापणम् अतिदीर्घकालं गृहीतवत्, अतः स्थगितम्।';

  @override
  String get errorPerfSharePdfFailed => 'PDF वितरितुं नाशक्यत।';

  @override
  String get titlePerfExportPdf => 'PDF-रूपेण निर्यापणम्';

  @override
  String get titlePerfExportChordPro => 'ChordPro-रूपेण निर्यापणम्';

  @override
  String bodyPerfExported(String title) {
    return '\"$title\" निर्यापितम्।';
  }

  @override
  String get errorPerfExportPdfFailed => 'PDF निर्यापयितुं नाशक्यत।';

  @override
  String get errorPerfExportChordProFailed =>
      'ChordPro सञ्चिकां निर्यापयितुं नाशक्यत।';

  @override
  String get tooltipPerfDrone => 'श्रुतिवेणुः श्रुतिपेटिका च';

  @override
  String get tooltipPerfSpeed => 'सर्पणवेगः';

  @override
  String get tooltipPerfHideChords => 'स्वरसमूहाः गोप्यन्ताम्';

  @override
  String get tooltipPerfShowChords => 'स्वरसमूहाः दर्श्यन्ताम्';

  @override
  String get tooltipPerfHideMelody => 'स्वरपङ्क्तिः गोप्यताम्';

  @override
  String get tooltipPerfShowMelody => 'स्वरपङ्क्तिः दर्श्यताम्';

  @override
  String get tooltipAutoScrollFullScreen => 'पूर्णपटलम्';

  @override
  String get labelAutoScrollManual => 'स्वेच्छम्';

  @override
  String get labelAutoScrollTempo => 'लयः';

  @override
  String get actionAutoScrollManualShort => 'स्वे';

  @override
  String get actionAutoScrollTempoShort => 'ल';

  @override
  String get labelTranspose => 'स्वरमानपरिवर्तनम्';

  @override
  String get tooltipTransposeDown => 'स्वरमानम् अवरोप्यताम्';

  @override
  String get tooltipTransposeUp => 'स्वरमानम् आरोप्यताम्';

  @override
  String get descTransposeMelodySubtitle =>
      'पूर्णपटले स्वरपङ्क्तिः कदापि न दृश्यते';

  @override
  String get descTransposePinchTip =>
      'सूचना: अक्षरपरिमाणं परिवर्तयितुं द्वाभ्याम् अङ्गुलीभ्यां पाठः सङ्कोच्यताम्।';

  @override
  String get titleChordRef => 'स्वरसमूहसूचिका';

  @override
  String get emptyChordRefNoSwaras => 'अस्मिन् गीते स्वराः न सन्ति';

  @override
  String get emptyChordRefNoChords => 'अस्मिन् गीते स्वरसमूहाः न सन्ति';

  @override
  String get tabChordRefGuitar => 'गिटार्';

  @override
  String get tabChordRefHarmonium => 'हार्मोनियम्';

  @override
  String get tooltipStageExitFullScreen => 'पूर्णपटलात् निष्क्रम्यताम्';

  @override
  String get tooltipStageLock => 'रङ्गः कील्यताम्';

  @override
  String get tooltipStageQuietActive => 'मौनविधिः विरम्यताम्';

  @override
  String get tooltipStageQuietInactive => 'मौनविधिः आरभ्यताम्';

  @override
  String get tooltipStageFewerBars => 'आवर्ताः न्यूनीक्रियन्ताम्';

  @override
  String get tooltipStageMoreBars => 'आवर्ताः वर्ध्यन्ताम्';

  @override
  String get tooltipStageSlower => 'मन्दतरम्';

  @override
  String get tooltipStageFaster => 'शीघ्रतरम्';

  @override
  String get labelStageLocked => 'रङ्गः कीलितः';

  @override
  String get labelStagePlaying => 'प्रचलति';

  @override
  String get labelStagePaused => 'स्थगितम्';

  @override
  String get descStageHelpSubtitle => 'केवलं शब्दाः, इमे सङ्केताः च।';

  @override
  String get labelStageHelpTapOnce => 'एकवारं स्पर्शः';

  @override
  String get descStageHelpTapOnceMeaning =>
      'नियन्त्रणानि दर्श्यन्तां गोप्यन्तां वा';

  @override
  String get labelStageHelpDoubleTapTop => 'उपरि द्विस्पर्शः';

  @override
  String get labelStageHelpDoubleTapBottom => 'अधः द्विस्पर्शः';

  @override
  String get labelStageHelpTwoFingers => 'द्व्यङ्गुलिस्पर्शः';

  @override
  String get descStageHelpTwoFingersMeaning => 'आरम्भः स्थगनं वा';

  @override
  String get labelStageHelpPinch => 'सङ्कोचनम्';

  @override
  String get descStageHelpPinchMeaning => 'अक्षरपरिमाणपरिवर्तनम्';

  @override
  String get labelStageHelpBack => 'प्रत्यागमनम्';

  @override
  String get descStageHelpBackMeaning => 'पूर्णपटलात् निष्क्रमणम्';

  @override
  String get descStageHelpStart => 'आरब्धुं कुत्रापि स्पृश्यताम्';

  @override
  String get titleGestures => 'सङ्केताः लघुमार्गाः च';

  @override
  String get descGesturesSubtitle => 'वादनकाले हस्तं विना पत्रं नियम्यताम्';

  @override
  String get labelGesturesDoubleTapTop => 'उपरि द्विस्पर्शः';

  @override
  String get descGesturesDoubleTapTopMeaning =>
      'स्वेच्छविधौ वेगं वर्धयति, लयविधौ वा चतुरः आवर्तान् योजयति।';

  @override
  String get labelGesturesDoubleTapBottom => 'अधः द्विस्पर्शः';

  @override
  String get descGesturesDoubleTapBottomMeaning =>
      'स्वेच्छविधौ वेगं न्यूनीकरोति, लयविधौ वा चतुरः आवर्तान् अपनयति।';

  @override
  String get descGesturesTwoFingersMeaning =>
      'किमपि पिञ्जं विना स्पृष्ट्वा स्वयंसर्पणम् आरभ्यतां स्थग्यतां वा।';

  @override
  String get labelGesturesDrag => 'एकाङ्गुलिकर्षणम्';

  @override
  String get descGesturesDragMeaning =>
      'पत्रं हस्तेन चाल्यताम्; स्वयंसर्पणं प्रतीक्षते, अङ्गुलौ उत्थापितायां पुनः प्रचलति।';

  @override
  String get labelGesturesPinch => 'द्व्यङ्गुलिसङ्कोचनम्';

  @override
  String get descGesturesPinchMeaning =>
      'स्वरसमूहान् पाठं च बृहत्तरं लघुतरं वा कर्तुं विस्तार्यतां सङ्कोच्यतां वा।';

  @override
  String get labelGesturesFullScreen => 'पूर्णपटलम्';

  @override
  String get descGesturesFullScreenMeaning =>
      'एकः स्पर्शः नियन्त्रणानि दर्शयति गोपयति वा; प्रत्यागमनसङ्केतः पूर्णपटलात् निष्क्रामति।';

  @override
  String get actionGesturesHelpCenter => 'साहाय्यकेन्द्रम्';

  @override
  String get actionGesturesGotIt => 'अवगतम्';

  @override
  String get descMetronomeTapAlong => 'सङ्गीतेन सह स्पृश्यताम्';

  @override
  String get descMetronomeKeepTapping => 'स्पर्शः अनुवर्त्यताम्…';

  @override
  String descMetronomeTapsNeeded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'साधु — स्थिरीकर्तुं $count स्पर्शाः अवशिष्टाः',
      one: 'साधु — स्थिरीकर्तुम् 1 स्पर्शः अवशिष्टः',
    );
    return '$_temp0';
  }

  @override
  String get descMetronomeSteady => 'स्थिरम्';

  @override
  String get titleMetronomeTempo => 'तालयन्त्रलयः';

  @override
  String get descMetronomeSetByYou => 'अस्मै सत्राय भवता सज्जीकृतम्';

  @override
  String get descMetronomeUsingSongTempo => 'अस्य गीतस्य रक्षितः लयः उपयुज्यते';

  @override
  String get descMetronomeNoSongTempo => 'अस्मिन् गीते लयः न रक्षितः';

  @override
  String get tooltipMetronomeSlowerByOne => '1 न्यूनीक्रियताम्';

  @override
  String get tooltipMetronomeFasterByOne => '1 वर्ध्यताम्';

  @override
  String get labelMetronomeBpmUnit => 'BPM';

  @override
  String get actionMetronomeTapTempo => 'स्पर्शलयः';

  @override
  String get actionMetronomeUseSongTempo => 'गीतलयः उपयुज्यताम्';

  @override
  String get actionMetronomeNoSongTempoToRestore => 'गीतलयः नास्ति';

  @override
  String get tooltipMetronomeStop => 'तालयन्त्रं विरम्यताम्';

  @override
  String get tooltipMetronomeStart => 'तालयन्त्रम् आरभ्यताम्';

  @override
  String get errorDroneCouldNotPlay => 'ध्वनिं वादयितुं नाशक्यत।';

  @override
  String get titleDrone => 'श्रुतिवेणुः आधारनादः च';

  @override
  String get labelDroneModeClassical => 'शास्त्रीयम् (श्रुतिः)';

  @override
  String get labelDroneModeWestern => 'पाश्चात्यम् (समूहाः)';

  @override
  String get labelDroneSaPa => 'Sa + Pa (पञ्चमः)';

  @override
  String get labelDroneSaMa => 'Sa + Ma (मध्यमः)';

  @override
  String get labelDroneMajor => 'महत् (maj)';

  @override
  String get labelDroneMinor => 'लघु (min)';

  @override
  String get actionDroneChordCue => 'समूहसूचना (2 क्षणौ)';

  @override
  String get actionDronePitchCue => 'श्रुतिसूचना (2 क्षणौ)';

  @override
  String get actionDroneStop => 'नादः विरम्यताम्';

  @override
  String get actionDroneChord => 'स्वरसमूहनादः';

  @override
  String get actionDroneShruti => 'श्रुतिनादः';

  @override
  String get labelDroneTextScale => 'रङ्गाक्षरपरिमाणम्';

  @override
  String labelDroneYourSa(String name) {
    return 'भवतः Sa:  $name';
  }

  @override
  String labelDroneSongKey(String key) {
    return 'गीतस्वरमानम्:  $key';
  }

  @override
  String get labelDroneRootKey => 'मूलश्रुतिः';

  @override
  String get emptySheetNoLyrics => 'अस्य गीतस्य अद्यापि पाठः नास्ति।';

  @override
  String descDiagramNoGuitar(String name) {
    return '$name इत्यस्य गिटार्-स्वरसमूहचित्रं नास्ति';
  }

  @override
  String descDiagramGuitar(String name) {
    return '$name इत्यस्य गिटार्-स्वरसमूहचित्रम्';
  }

  @override
  String get labelDiagramNone => 'चित्रं नास्ति';

  @override
  String descDiagramHarmonium(String name) {
    return '$name इत्यस्य हार्मोनियम्-स्वरसमूहचित्रम्';
  }

  @override
  String descDiagramSwara(String swara) {
    return '$swara इत्यस्य स्वरचित्रम्';
  }

  @override
  String get labelMelodyGridHold => 'दीर्घम्';

  @override
  String get labelMelodyGridBarLine => 'विभागरेखा';

  @override
  String descMelodyGridUnreadable(String text) {
    return '$text पठितुं नाशक्यत';
  }

  @override
  String get titleSettingsGeneral => 'सामान्यम्';

  @override
  String get descSettingsGeneralSubtitle => 'आनयनं तालयन्त्रं च';

  @override
  String get titleSettingsThemes => 'रूपविन्यासाः';

  @override
  String get descSettingsThemesSubtitle =>
      'तन्त्रसिद्धं, दीप्तं, श्यामं वा रूपम्';

  @override
  String get titleSettingsChords => 'स्वरसमूहाः';

  @override
  String get descSettingsChordsSubtitle => 'सम्पादकाय भवतः स्वकीयाः स्वरसमूहाः';

  @override
  String get titleSettingsFonts => 'अक्षररूपाणि';

  @override
  String get descSettingsFontsSubtitle =>
      'पाठस्य अक्षररूपं चीयताम् (आङ्ग्लं मलयाळं च)';

  @override
  String get titleSettingsHelp => 'साहाय्यम्';

  @override
  String get descSettingsHelpSubtitle =>
      'गीतावलीनां तालयन्त्रस्य निर्यापणस्य इत्यादीनाम् उपयोगः';

  @override
  String get descSettingsAboutSubtitle => 'संस्करणम्, लेखकः, अनुज्ञापत्राणि च';

  @override
  String get titleGeneralImport => 'आनयनम्';

  @override
  String get descGeneralImportSubtitle =>
      'ChordPro सञ्चिकाः गीतरूपेण आनीयन्ताम्';

  @override
  String get titleGeneralImportSettings => 'आनयनविन्यासः';

  @override
  String get descGeneralImportSettingsSubtitle =>
      'ChordPro सञ्चिकासु समाननामगीतानां विषये निर्णयः क्रियताम्';

  @override
  String get descGeneralAutoScrollSubtitle => 'स्वेच्छसर्पणस्य आरम्भवेगः';

  @override
  String get titleGeneralMetronome => 'तालयन्त्रम्';

  @override
  String get descGeneralMetronomeSubtitle => 'तालः आरभ्यतां विरम्यतां वा';

  @override
  String get descGeneralDroneSubtitle =>
      'श्रुतिध्वनयः, स्थिरः आधारनादः, भवतः Sa (कट्टै) च';

  @override
  String get labelThemeSystem => 'तन्त्रसिद्धं रूपम्';

  @override
  String get labelThemeLight => 'दीप्तरूपम्';

  @override
  String get labelThemeDark => 'श्यामरूपम्';

  @override
  String get descFontSettingsNote =>
      'पटले निर्यापितेषु PDF-पत्रेषु च गीतपाठाय उपयुज्यते। आङ्ग्लाक्षररूपेऽपि PDF-मध्ये मलयाळं मुद्र्यते।';

  @override
  String get labelFontSystemDefault => 'तन्त्रसिद्धम्';

  @override
  String get titleScrollStartingSpeed => 'आरम्भवेगः';

  @override
  String get descScrollStartingSpeedNote =>
      'यस्य गीतस्य वेगः न निश्चितः, तत्र स्वेच्छसर्पणम् अनेन वेगेन आरभ्यते।';

  @override
  String actionScrollResetTo(String speed) {
    return '$speed क्रियताम्';
  }

  @override
  String errorChordSettingsAddFailed(int max) {
    return 'सः स्वरसमूहः योजयितुं नाशक्यत। अधिकतमं $max अक्षराणि उपयुज्यन्ताम्, पुनरुक्तिः मा भूत्।';
  }

  @override
  String bodyChordSettingsRemoved(String chord) {
    return '\"$chord\" अपनीतः।';
  }

  @override
  String get descChordSettingsIntro =>
      'स्वकीयाः स्वरसमूहाः योज्यन्ताम्। सम्पादकस्य स्वरसमूहपङ्क्तौ, स्वरमानस्य स्वसमूहानां पश्चात्, एते सदा दृश्यन्ते।';

  @override
  String get labelChordSettings => 'स्वरसमूहलेखः';

  @override
  String get emptyChordSettings => 'अद्यापि स्वकीयाः स्वरसमूहाः न सन्ति।';

  @override
  String tooltipChordSettingsRemove(String chord) {
    return '$chord अपनीयताम्';
  }

  @override
  String get descImportSettingsQuestion =>
      'भवतः गीतपुस्तके विद्यमानस्य गीतस्य समानशीर्षकं गीतम् आनीयमाने:';

  @override
  String get labelImportStrategyOverwrite => 'उपरि लिख्यताम्';

  @override
  String get descImportStrategyOverwrite =>
      'विद्यमानं गीतम् आनीतेन गीतेन प्रतिस्थाप्यताम्';

  @override
  String get labelImportStrategyRenameImported => 'आनीतस्य नवनाम';

  @override
  String get descImportStrategyRenameImported =>
      'शीर्षके कालमुद्रां योजयित्वा आनीतस्य गीतस्य नाम स्वयं परिवर्त्यताम्';

  @override
  String get labelImportStrategyRenameExisting => 'विद्यमानस्य नवनाम';

  @override
  String get descImportStrategyRenameExisting =>
      'शीर्षके कालमुद्रां योजयित्वा विद्यमानस्य गीतस्य नाम स्वयं परिवर्त्यताम्';

  @override
  String get labelImportStrategyUserSuggested => 'नवनाम पृच्छ्यताम्';

  @override
  String get descImportStrategyUserSuggested =>
      'आनीयमानस्य गीतस्य नाम लेखितुं भवन्तं प्रक्ष्यति';

  @override
  String get labelMetronomeEnable => 'तालयन्त्रं सक्रियम्';

  @override
  String get descMetronomeEnableSubtitle => 'गीतलयेन तालः धार्यताम्';

  @override
  String get labelMetronomeFlash => 'स्फुरणम्';

  @override
  String get descMetronomeFlashSubtitle =>
      'प्रतिमात्रं स्फुरति (मौने उपयुक्तम्)';

  @override
  String get labelMetronomeClick => 'टङ्कारः';

  @override
  String get descMetronomeClickSubtitle => 'प्रतिमात्रम् एकः टङ्कारः';

  @override
  String get labelMetronomeClickVolume => 'टङ्कारध्वनिमानम्';

  @override
  String get titleMetronomeBarHeading => 'आवर्तः';

  @override
  String get labelMetronomeBeatsInBar => 'आवर्ते मात्राः';

  @override
  String get descMetronomeBeatsInBarSubtitle => 'प्रथमा मात्रा गणनस्य आरम्भः';

  @override
  String get labelMetronomeAccent => 'प्रथममात्राबलम्';

  @override
  String get descMetronomeAccentSubtitle =>
      'प्रथममात्रायाम् उच्चतरः तारतरः टङ्कारः';

  @override
  String get labelMetronomeTest => 'ध्वनिपरीक्षा';

  @override
  String descMetronomeTestSubtitle(int bpm) {
    return '$bpm BPM इत्यनेन एकम् आवर्तं वादयति। यदि किमपि न श्रूयते, माध्यमध्वनिः वर्ध्यताम्।';
  }

  @override
  String descDroneSettingsTestWesternMajor(String key) {
    return 'परीक्षा: $key इत्यत्र पाश्चात्यः महत्स्वरसमूहः';
  }

  @override
  String descDroneSettingsTestWesternMinor(String key) {
    return 'परीक्षा: $key इत्यत्र पाश्चात्यः लघुस्वरसमूहः';
  }

  @override
  String descDroneSettingsTestClassical(String key, String interval) {
    return 'परीक्षा: $key + $interval इत्यत्र शास्त्रीयः आधारनादः';
  }

  @override
  String get titleDroneSettingsNaming => 'स्वरनामकरणम्';

  @override
  String get descDroneSettingsNamingCaption =>
      'स्वराणां नामानि कथं दीयन्ते, रागतालरहितं गीतं कथं गण्यते इति निश्चिनोति।';

  @override
  String get descDroneSettingsUsesIndian =>
      'रागतालरहितानि गीतानि अधोलिखितं भारतीयविन्यासम् उपयुञ्जते।';

  @override
  String get descDroneSettingsUsesWestern =>
      'रागतालरहितानि गीतानि अधोलिखितं पाश्चात्यविन्यासम् उपयुञ्जते।';

  @override
  String get titleDroneSettingsIndianSongs => 'भारतीयगीतानि';

  @override
  String get descDroneSettingsIndianCaption =>
      'रागतालयुक्तेभ्यः गीतेभ्यः। एतानि सदा भवतः Sa इत्यत्र शास्त्रीयम् आधारनादं वादयन्ति।';

  @override
  String get labelDroneSettingsYourSa => 'भवतः Sa (श्रुतिः)';

  @override
  String descDroneSettingsSaSits(String name) {
    return 'भवतः Sa अत्र: $name';
  }

  @override
  String get labelDroneSettingsInterval => 'नादान्तरम्';

  @override
  String get descDroneSettingsIntervalPa =>
      'Sa + Pa (पञ्चमः) — सामान्यः श्रुतिपेटिकानादः';

  @override
  String get descDroneSettingsIntervalMa =>
      'Sa + Ma (मध्यमः) — Pa-वर्जितेभ्यः रागेभ्यः';

  @override
  String get titleDroneSettingsWesternSongs => 'पाश्चात्यगीतानि';

  @override
  String get descDroneSettingsWesternCaption =>
      'स्वरनामकरणे पाश्चात्ये सति, रागतालरहितेभ्यः गीतेभ्यः।';

  @override
  String get labelDroneSettingsDefaultKey => 'मूलस्वरमानम्';

  @override
  String descDroneSettingsDefaultKeySubtitle(String key) {
    return 'गीते स्वरमानं नास्ति चेत् उपयुज्यते: $key';
  }

  @override
  String get labelDroneSettingsDefaultMode => 'मूलनादविधिः';

  @override
  String get descDroneSettingsModeClassicalNote =>
      'शास्त्रीयः आधारनादः (Sa + Pa/Ma)';

  @override
  String get descDroneSettingsModeWesternNote =>
      'पाश्चात्याः पृष्ठस्वरसमूहाः (महत् / लघु)';

  @override
  String get labelDroneSettingsClassical => 'शास्त्रीयम्';

  @override
  String get labelDroneSettingsDefaultQuality => 'स्वरसमूहप्रकारः';

  @override
  String get descDroneSettingsMajorNote =>
      'महत्त्रिस्वरम् (मूलम् + महत् 3 + 5)';

  @override
  String get descDroneSettingsMinorNote => 'लघुत्रिस्वरम् (मूलम् + लघु 3 + 5)';

  @override
  String get descDroneSettingsQualityOnlyWestern =>
      'उपरितनः नादविधिः पाश्चात्यः चेत् एव उपयुज्यते';

  @override
  String get labelChordQualityMajor => 'महत्';

  @override
  String get labelChordQualityMinor => 'लघु';

  @override
  String get titleDroneSettingsEverything => 'सर्वाणि गीतानि';

  @override
  String get descDroneSettingsEverythingCaption =>
      'एते उभे परम्परे प्रभावयन्ति।';

  @override
  String get labelDroneSettingsVolume => 'ध्वनिमानम्';

  @override
  String get labelDroneSettingsFontScale => 'रङ्गाक्षरपरिमाणम्';

  @override
  String descDroneSettingsFontScaleSubtitle(int percent) {
    return 'रङ्गविधौ अक्षरपरिमाणम्: $percent%';
  }

  @override
  String get titleDroneSettingsTryIt => 'परीक्षणम्';

  @override
  String get descDroneSettingsTryItCaption =>
      'परीक्षा उपरितनं विन्यासम् उपयुङ्क्ते।';

  @override
  String get actionDroneSettingsTestChordCue => 'समूहसूचनापरीक्षा';

  @override
  String get actionDroneSettingsTestPitchCue => 'श्रुतिसूचनापरीक्षा';

  @override
  String get actionDroneSettingsTestChordDrone => 'समूहनादपरीक्षा';

  @override
  String get actionDroneSettingsTestDrone => 'नादपरीक्षा';

  @override
  String get descDroneSettingsChordDroneNote =>
      'यावत् सक्रियः, तावत् स्वरसमूहनादः एकं स्थिरं पाश्चात्यं पृष्ठस्वरसमूहं धारयति।';

  @override
  String get descDroneSettingsDroneNote =>
      'यावत् सक्रियः, तावत् आधारनादः एकं स्थिरं स्वरयुगलं धारयति। सः गीतस्वरं न अनुसरति।';

  @override
  String labelAboutVersion(String version) {
    return 'संस्करणम् $version';
  }

  @override
  String labelAboutVersionBuild(String version, String build) {
    return '$version (निर्मितिः $build)';
  }

  @override
  String get labelAboutBuildDate => 'निर्मितिदिनाङ्कः';

  @override
  String get labelAboutLicenses => 'मुक्तस्रोतोऽनुज्ञाः';

  @override
  String get titleImportExport => 'आनयनं निर्यापणं च';

  @override
  String get labelImportExportPickFiles => 'ChordPro आनयनम्';

  @override
  String get descImportExportPickFilesSubtitle =>
      'गीतानि योजयितुम् एका अधिकाः वा .cho, .pro, पाठसञ्चिकाः वा चीयन्ताम्।';

  @override
  String get labelImportExportScan => 'AirQR-मार्गेण आनयनम्';

  @override
  String get descImportExportScanSubtitle =>
      'सहवादकस्य पटलात् चलं QR गीतधारां वीक्ष्यताम्।';

  @override
  String get labelImportExportAllChordPro => 'सर्वगीतनिर्यापणम्';

  @override
  String get descImportExportAllChordProSubtitle =>
      'समग्रं गीतपुस्तकम् एकस्यां ChordPro सञ्चिकायां रक्ष्यताम्।';

  @override
  String get labelImportExportAllAirQr => 'सर्वम् AirQR-मार्गेण';

  @override
  String get descImportExportAllAirQrSubtitle =>
      'समग्रं गीतपुस्तकं चलया QR धारया प्रेष्यताम्।';

  @override
  String get errorImportExportWrongType =>
      '.cho, .pro, .chordpro, .txt सञ्चिकाः एव आनेतुं शक्यन्ते।';

  @override
  String get errorImportExportNothingRead =>
      'चितासु सञ्चिकासु एकाम् अपि पठितुं नाशक्यत।';

  @override
  String descImportExportFilesSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count सञ्चिकाः चिताः',
      one: '1 सञ्चिका चिता',
    );
    return '$_temp0';
  }

  @override
  String get errorImportExportImportFailed => 'सञ्चिकाः आनेतुं नाशक्यत।';

  @override
  String get bodyImportExportNoSongsToExport => 'निर्यापणाय गीतानि न सन्ति।';

  @override
  String get titleImportExportAllDialog => 'सर्वगीतनिर्यापणम्';

  @override
  String bodyImportExportExported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count गीतानि निर्यापितानि।',
      one: '1 गीतं निर्यापितम्।',
    );
    return '$_temp0';
  }

  @override
  String get errorImportExportExportFailed => 'गीतानि निर्यापयितुं नाशक्यत।';

  @override
  String get bodyImportExportNoSongsToShare => 'वितरणाय गीतानि न सन्ति।';

  @override
  String titleImportExportFullSongbook(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'गीतपुस्तकम् ($count गीतानि)',
      one: 'गीतपुस्तकम् (1 गीतम्)',
    );
    return '$_temp0';
  }

  @override
  String get errorImportExportAirQrFailed =>
      'AirQR निर्यापणं सज्जीकर्तुं नाशक्यत।';

  @override
  String get titleImportPreview => 'आनयनपूर्वदर्शनम्';

  @override
  String get actionImportPreviewSelectAll => 'सर्वं चीयताम्';

  @override
  String get actionImportPreviewDeselectAll => 'सर्वचयनं निरस्यताम्';

  @override
  String descImportPreviewFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'सञ्चिकायां $count गीतानि प्राप्तानि। गीतपुस्तकम् आनेतव्यानि गीतानि चीयन्ताम्।',
      one:
          'सञ्चिकायां 1 गीतं प्राप्तम्। गीतपुस्तकम् आनेतव्यानि गीतानि चीयन्ताम्।',
    );
    return '$_temp0';
  }

  @override
  String get emptyImportPreviewNoSongs =>
      'अस्यां सञ्चिकायां न किमपि शुद्धं गीतं प्राप्तम्।';

  @override
  String get labelImportPreviewInSongbook => 'गीतपुस्तके';

  @override
  String get labelImportPreviewAlreadyInSongbook => 'पूर्वमेव गीतपुस्तके';

  @override
  String labelImportPreviewKey(String key) {
    return 'स्वरमानम्: $key';
  }

  @override
  String get actionImportPreviewPreview => 'पूर्वदर्शनम्';

  @override
  String get actionImportPreviewImporting => 'आनीयते...';

  @override
  String actionImportPreviewImportSelected(int count) {
    return 'आनयनम् ($count)';
  }

  @override
  String bodyImportPreviewImportedOne(String title) {
    return '\"$title\" आनीतम्।';
  }

  @override
  String bodyImportPreviewImportedMany(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count गीतानि आनीतानि।',
      one: '1 गीतम् आनीतम्।',
    );
    return '$_temp0';
  }

  @override
  String errorImportPreviewFailed(String reason) {
    return 'आनयनम् असफलम्: $reason';
  }

  @override
  String get titleAirQrReceiver => 'AirQR गीतग्राहकः';

  @override
  String get tooltipAirQrReceiverGallery => 'चित्रं वीक्ष्यताम्';

  @override
  String get tooltipAirQrReceiverResetStream => 'धारा पुनःसज्जीक्रियताम्';

  @override
  String get errorAirQrReceiverNoCode =>
      'चिते चित्रे AirQR सङ्केतः न प्राप्तः।';

  @override
  String get errorAirQrReceiverPhotoFailed => 'चित्रं वीक्षितुं नाशक्यत।';

  @override
  String get descAirQrReceiverStarting => 'AirQR छायायन्त्रग्राहकः आरभ्यते...';

  @override
  String get labelAirQrReceiverFileName => 'AirQR धारावितरणम्';

  @override
  String get descAirQrHudReassembled =>
      'धारा सम्पूर्णा - पूर्वदर्शनम् उद्घाट्यते...';

  @override
  String get descAirQrHudReceiving => 'AirQR गीतधारा गृह्यते...';

  @override
  String get descAirQrHudPointAt =>
      'चलां QR सङ्केतधाराम् अभि छायायन्त्रं नीयताम्';

  @override
  String descAirQrHudCaptured(int received, int total) {
    return 'प्राप्ताः: $received / $total खण्डाः';
  }

  @override
  String labelAirQrHudMissing(int count) {
    return 'अवशिष्टाः: $count';
  }

  @override
  String titleAirQrTransmitter(String title) {
    return 'AirQR वितरणम्: $title';
  }

  @override
  String descAirQrTransmitterSize(int bytes, int frames) {
    return '$bytes बाइट् • $frames चित्रखण्डाः';
  }

  @override
  String get labelAirQrTransmitterSpeed => 'धारावेगः:';

  @override
  String get actionAirQrTransmitterPause => 'धारा स्थग्यताम्';

  @override
  String get actionAirQrTransmitterResume => 'धारा अनुवर्त्यताम्';

  @override
  String get emptyAirQrTransmitterNoFrames => 'न कोऽपि चित्रखण्डः निर्मितः';

  @override
  String descAirQrTransmitterParityFrame(int index, int total) {
    return 'चित्रम् $index/$total • Fountain FEC';
  }

  @override
  String descAirQrTransmitterBlockFrame(int index, int total, int block) {
    return 'चित्रम् $index/$total • खण्डः $block';
  }

  @override
  String get descAirQrTransmitterHint =>
      'ग्राहकदूरभाषस्य छायायन्त्रम् अस्य पटलस्य अभि नीयताम्।\nअन्तर्जालं, ब्लूटूथ्, वाय्-फाय् वा नापेक्ष्यते।';

  @override
  String get titleHelpSongbook => 'भवतः गीतपुस्तकम्';

  @override
  String get helpSongbookSummary =>
      'गीतानाम् अन्वेषणं, तारकाङ्कनं, प्रतिलेखनम्, अपनयनं च';

  @override
  String get helpSongbookIntro =>
      'मुख्यपटलम् एव भवतः गीतपुस्तकम्। तत्र द्वे पत्रिके स्तः — गीतानि, गीतावल्यः च। भवता लिखितं वा आनीतं वा सर्वं गीतानि इति पत्रिकायाम् अस्ति; अन्तिमवारं परिवर्तितं गीतं सर्वोपरि दृश्यते।';

  @override
  String get helpSongbookS1Heading => 'गीतयोजनम्';

  @override
  String get helpSongbookS1P1 =>
      'नूतनं लेखितुम् अधः दक्षिणतः स्थितं + पिञ्जं स्पृश्यताम्।';

  @override
  String get helpSongbookS1P2 =>
      'अथवा सञ्चिकायाः गीतानि आनीयन्ताम् — आनयनविषयः दृश्यताम्।';

  @override
  String get helpSongbookS1P3 =>
      'नूतनस्थापने त्रीणि निदर्शनगीतानि एका गीतावली च पूर्वमेव सन्ति, अतः किमपि अलिखित्वा एव सर्वं परीक्षितुं शक्यते।';

  @override
  String get helpSongbookS2Heading => 'गीतान्वेषणम्';

  @override
  String get helpSongbookS2P1 =>
      'उपरि स्थिते अन्वेषणपेटके लिख्यताम्। तत् शीर्षके गायके पदेषु च अन्विष्यति, अतः स्मृता अर्धपङ्क्तिः अपि पर्याप्ता।';

  @override
  String get helpSongbookS2P2 => 'अन्वेषणं मार्ष्टुं पेटके X स्पृश्यताम्।';

  @override
  String get helpSongbookS2P3 =>
      'तस्य अधः \"सर्वाणि\", \"तारकाङ्कितानि\" इति द्वे चिह्नके स्तः; प्रत्येकस्मिन् कति गीतानि इति सङ्ख्या अपि दृश्यते।';

  @override
  String get helpSongbookS2P4 =>
      'गीतं तारकाङ्कितेषु स्थापयितुं तस्य तारकां स्पृश्यताम्। अपनेतुं पुनः स्पृश्यताम्।';

  @override
  String get helpSongbookS3Heading => 'गीतपत्रे किं दृश्यते';

  @override
  String get helpSongbookS3P1 => 'शीर्षकं गायकः च।';

  @override
  String get helpSongbookS3P2 =>
      'गीते यदि स्तः, C अथवा Am इव स्वरमानं, 120 BPM इव लयः च।';

  @override
  String get helpSongbookS3P3 => 'एका तारका, प्रतिलेखनपिञ्जं, लोपपिञ्जं च।';

  @override
  String get helpSongbookS4Heading => 'एकस्य गीतस्य प्रतिलेखनं लोपः च';

  @override
  String get helpSongbookS4P1 =>
      'प्रतिलेखनं \"<नाम> (प्रतिलिपिः)\" इति नाम्ना पृथक् द्वितीयं गीतं रचयति। एकस्यैव गीतस्य भिन्नसंयोजनाय उपयुक्तम्।';

  @override
  String get helpSongbookS4P2 =>
      'लोपः प्रथमं पृच्छति, ततः गीतं भवतः गीतकोशात् तद्धारिणीभ्यः सर्वाभ्यः गीतावलीभ्यः च अपनयति।';

  @override
  String get helpSongbookS4P3 =>
      'एकदा अनेकेषु गीतेषु कार्यं कर्तुं गीतचयनविषयः दृश्यताम्।';

  @override
  String get helpSongbookS5Heading => 'फलकयन्त्रे';

  @override
  String get helpSongbookS5P1 =>
      'विस्तृते पटले वामतः सूची दक्षिणतः गीतं च दृश्यते, अतः गीतचयनेन सूची न तिरोभवति।';

  @override
  String get helpSongbookS5P2 =>
      'तस्मिन् दक्षिणार्धे पूर्णपटलं न लभ्यते, यतः तत् समग्रं पटलं न, केवलं तदर्धम् एव पूरयेत्।';

  @override
  String get titleHelpEditor => 'गीतलेखनम्';

  @override
  String get helpEditorSummary =>
      'पदानि लिख्यन्ताम्, उपरि स्वरसमूहाः स्थाप्यन्ताम्, रक्ष्यताम्';

  @override
  String get helpEditorIntro =>
      'सम्पादकः पदानां कृते एकं सरलं पेटकम्; तस्य उपरि शीर्षक-गायक-स्वरमान-लयानां कृते कतिचन क्षेत्राणि। स्वरसमूहाः चतुरस्रकोष्ठकेषु पदानाम् अन्तः लिख्यन्ते।';

  @override
  String get helpEditorS1Heading => 'पदेषु स्वरसमूहाः';

  @override
  String get helpEditorS1P1 =>
      'यस्मिन् अक्षरे स्वरसमूहः पतति, तस्मात् सद्यः पूर्वं चतुरस्रकोष्ठके लिख्यताम्: [G]Amazing [C]grace.';

  @override
  String get helpEditorS1P2 =>
      'गीतपटले सः स्वरसमूहः अक्षरस्य उपरि प्लवमानः दृश्यते। कोष्ठकानि कदापि न दृश्यन्ते।';

  @override
  String get helpEditorS1P3 =>
      'इदं मानकं ChordPro, अतः अन्यस्मिन् अनुप्रयोगे लिखिता सञ्चिका अपि अत्र तथैव पठ्यते।';

  @override
  String get helpEditorS2Heading => 'कुञ्जीफलकस्य उपरि स्वरसमूहपङ्क्तिः';

  @override
  String get helpEditorS2P1 =>
      'पदलेखनकाले कुञ्जीफलकस्य सद्यः उपरि स्वरसमूहपिञ्जानां पङ्क्तिः भवति।';

  @override
  String get helpEditorS2P2 =>
      'भवता चिते स्वरमाने प्रायः अन्तर्भूताः स्वरसमूहाः एव दर्श्यन्ते — I, ii, iii, IV, V, vi इत्यादयः।';

  @override
  String get helpEditorS2P3 =>
      'एकं स्पृष्टं चेत् तत् कोष्ठकैः सह सूचकस्थाने योज्यते।';

  @override
  String get helpEditorS2P4 =>
      'स्वरमानं रिक्तं वा अपठनीयं वा चेत्, किमपि अदर्शयित्वा स्थातुं विना पङ्क्तिः शान्तं C स्वरमानम् आश्रयते।';

  @override
  String get helpEditorS2P5 =>
      'भवतः स्वकीयाः स्वरसमूहाः तेषां पश्चात् आयान्ति। तत्क्षणम् एकं योजयितुं \"स्वकीयम्\" स्पृश्यताम्, अथवा समग्रा सूची विन्यासः → स्वरसमूहाः इत्यत्र रक्ष्यताम्।';

  @override
  String get helpEditorS2P6 =>
      'स्वकीयः स्वरसमूहः द्वादशवर्णपर्यन्तं भवितुम् अर्हति; एकः एव स्वरसमूहः द्विवारं न रक्ष्यते।';

  @override
  String get helpEditorS3Heading => 'उपरितनक्षेत्राणि';

  @override
  String get helpEditorS3P1 => 'शीर्षकं, गायकः / वृन्दम्।';

  @override
  String get helpEditorS3P2 =>
      'स्वरलिपिः: पाश्चात्यम्, कर्णाटकम्, हिन्दुस्थानी वा। पाश्चात्यं \"मूलस्वरमानम्\" इति पेटकं दर्शयति; भारतीयविकल्पयोः अन्यतरः तस्य स्थाने रागं तालं च दर्शयति — कर्णाटक-हिन्दुस्थानीविषयः दृश्यताम्।';

  @override
  String get helpEditorS3P3 =>
      'लयः (BPM) तालयन्त्रं लयानुसारि स्वयंसर्पणं च चालयति।';

  @override
  String get helpEditorS3P4 =>
      '\"गीतावल्यां योज्यताम्\" इति रक्षणकाले एव गीतं गीतावल्यां स्थापयति।';

  @override
  String get helpEditorS3P5 =>
      'पदेषु स्पृष्टमात्रे एतानि क्षेत्राणि एकपङ्क्तिसारांशे संकुच्यन्ते, येन पटलं पदेभ्यः लभ्यते। पुनः उद्घाटयितुं सारांशः स्पृश्यताम्।';

  @override
  String get helpEditorS4Heading => 'निरसनं, रक्षणं, प्रतिलिपिः च';

  @override
  String get helpEditorS4P1 =>
      'उपरितनपट्टिकायां निरसन-पुनःकरण-बाणाः भवतः लेखने पश्चात् पुरः च गच्छन्ति।';

  @override
  String get helpEditorS4P2 =>
      'रक्ष्यताम् इति गीतं रक्षित्वा सम्पादकं पिदधाति।';

  @override
  String get helpEditorS4P3 =>
      'अधिकम् → \"प्रतिलिपिः रक्ष्यताम्\" इति इदानीं पटले यत् अस्ति, अरक्षितपरिवर्तनैः सह, तत् नूतनगीतरूपेण रक्षति। मूलगीतं यथापूर्वं तिष्ठति।';

  @override
  String get helpEditorS4P4 =>
      'अरक्षितपरिवर्तनैः सह निर्गमने प्रथमं पृच्छति, अतः प्रमादात् कृतः प्रत्यागमनसङ्केतः भवतः कार्यं न नाशयति। किमपि अपरिवर्तितं चेत् साक्षात् पिधीयते।';

  @override
  String get helpEditorS5Heading => 'अधिकविकल्पाः';

  @override
  String get helpEditorS5P1 =>
      'स्वरफलकम् — लेखनस्य स्थाने स्पर्शेन स्वरमालां योजयतु। स्वरपङ्क्तिविषयः दृश्यताम्।';

  @override
  String get helpEditorS5P2 =>
      'कर्णाटकं स्थाप्यताम् — प्रकाशितस्वरलिप्याः खण्डं स्वरपङ्क्तिषु परिणमयतु। भारतीयगीतविषयः दृश्यताम्।';

  @override
  String get titleHelpSetlists => 'गीतावल्यः';

  @override
  String get helpSetlistsSummary =>
      'प्रदर्शनाय अभ्यासाय वा गीतानि सङ्गृह्य क्रमयतु';

  @override
  String get helpSetlistsIntro =>
      'गीतावली क्रमबद्धः गीतसमूहः, यं प्रत्येकं गीतम् अनन्विष्य एकवारेण वादयितुं शक्यते। गीतावल्यः कदापि प्रतिलिपीः न रचयन्ति — केवलं भवतः गीतकोशे विद्यमानानि गीतानि निर्दिशन्ति।';

  @override
  String get helpSetlistsS1Heading => 'गीतावलीनिर्माणम्';

  @override
  String get helpSetlistsS1P1 =>
      'मुख्यपटले \"गीतावल्यः\" इति पत्रिका उद्घाट्यताम्।';

  @override
  String get helpSetlistsS1P2 => '\"नूतना गीतावली\" स्पृश्यताम्।';

  @override
  String get helpSetlistsS1P3 => 'तस्यै नाम, इच्छया विवरणं च दीयताम्।';

  @override
  String get helpSetlistsS2Heading => 'गीतयोजनं क्रमणं च';

  @override
  String get helpSetlistsS2P1 =>
      'गीतावल्याः अन्तः भवतः गीतकोशात् चेतुं \"गीतानि योज्यन्ताम्\" स्पृश्यताम्।';

  @override
  String get helpSetlistsS2P2 =>
      'क्रमं परिवर्तयितुं दक्षिणतः ग्रहणिकां कर्षतु।';

  @override
  String get helpSetlistsS2P3 =>
      'गीतं गीतावल्याः अपनेतुं रक्तम् ऋणचिह्नं स्पृश्यताम्।';

  @override
  String get helpSetlistsS2P4 =>
      'गीतावल्याः गीतस्य अपनयनेन तत् भवतः गीतकोशात् न लुप्यते।';

  @override
  String get helpSetlistsS3Heading => 'गीतावलीप्रस्तुतिः';

  @override
  String get helpSetlistsS3P1 =>
      'प्रथमगीतात् आरब्धुं \"गीतावली प्रस्तूयताम्\" स्पृश्यताम्।';

  @override
  String get helpSetlistsS3P2 =>
      'अथवा ततः आरब्धुं सूच्यां किमपि गीतं स्पृश्यताम्।';

  @override
  String get helpSetlistsS3P3 =>
      'प्रस्तुतिकाले गीतावल्याः क्रमेण गीतेषु सञ्चरतु।';

  @override
  String get helpSetlistsS4Heading => 'गीतावलीलोपः';

  @override
  String get helpSetlistsS4P1 =>
      'गीतावलीम् उद्घाट्य उपरितनपट्टिकायां लोपचिह्नम् (अवकरपात्रम्) उपयुज्यताम्।';

  @override
  String get helpSetlistsS4P2 =>
      'एतत् केवलं गीतावलीम् अपनयति। गीतानि भवतः गीतकोशे तिष्ठन्ति।';

  @override
  String get titleHelpTranspose => 'स्वरमानपरिवर्तनं स्वरसमूहाः च';

  @override
  String get helpTransposeSummary =>
      'स्वरमानं परिवर्त्यताम्, स्वरसमूहाः गोप्यन्ताम्, आकाराः दृश्यन्ताम्';

  @override
  String get helpTransposeIntro =>
      'स्वरमानपरिवर्तनं गीतस्य सर्वान् स्वरसमूहान् समानमात्रया उपरि अधः वा नयति, अतः किमपि पुनः अलिखित्वा गायकस्य अनुकूले स्वरमाने वादयितुं शक्यते।';

  @override
  String get helpTransposeS1Heading => 'स्वरमानपरिवर्तनम्';

  @override
  String get helpTransposeS1P1 =>
      'गीतम् उद्घाट्यताम्, ततः उपरितनपट्टिकायाः सूची (अधिकम्) → \"प्रस्तुतिनियन्त्रणम्\"।';

  @override
  String get helpTransposeS1P2 =>
      'एकैकम् अर्धस्वरम् अधः उपरि वा गन्तुं - + च उपयुज्येताम्।';

  @override
  String get helpTransposeS1P3 =>
      'पत्रम् इदानीं यस्मिन् स्वरमाने ध्वनति, तत् द्वयोः पिञ्जयोः मध्ये दृश्यते।';

  @override
  String get helpTransposeS1P4 =>
      'नियन्त्रणपङ्क्तेः अधः स्थिता पङ्क्तिः कियत् गतम् इति वदति, यथा \"स्वरमानम् A (+2)\"।';

  @override
  String get helpTransposeS1P5 =>
      '\"पुनःसज्जीक्रियताम्\" इति गीतं लिखितं स्वरमानं प्रति प्रत्यानयति।';

  @override
  String get helpTransposeS1P6 =>
      'परिधिः अधः एकादश अर्धस्वरेभ्यः उपरि एकादश अर्धस्वरपर्यन्तम्। पूर्णाः द्वादश तु पुनः तमेव स्वरमानं प्रापयेयुः।';

  @override
  String get helpTransposeS2Heading => 'किं परिवर्तते';

  @override
  String get helpTransposeS2P1 =>
      'तिर्यक्रेखास्वरसमूहाः अपि चलन्ति: C/E द्विवारम् उपरि नीतः D/F# भवति।';

  @override
  String get helpTransposeS2P2 =>
      'नूतनस्वरमानानुकूलाः तीव्राः कोमलाः वा चीयन्ते, अतः A# न, Bb लभ्यते।';

  @override
  String get helpTransposeS2P3 =>
      'परिवर्तनम् अस्य पत्रस्य एव — तत् कदापि गीते पुनः न लिख्यते।';

  @override
  String get helpTransposeS2P4 =>
      'निर्यापणं वितरणं च भवता दृश्यमानं स्वरमानम् एव उपयुङ्क्तः, अतः परिवर्तितस्वरमानं गीतं तथैव बहिः गच्छति।';

  @override
  String get helpTransposeS2P5 =>
      'कर्णाटक-हिन्दुस्थानीगीतेषु स्वरमानपरिवर्तननियन्त्रणं नास्ति, यतः स्वराणां नामानि षड्जसापेक्षाणि, ते न चलन्ति।';

  @override
  String get helpTransposeS3Heading => 'स्वरसमूहगोपनम्';

  @override
  String get helpTransposeS3P1 =>
      'तस्मिन्नेव प्रस्तुतिनियन्त्रणपत्रे \"स्वरसमूहाः दर्श्यन्ताम्\" इति स्विच् अस्ति।';

  @override
  String get helpTransposeS3P2 =>
      'तस्य निष्क्रियीकरणेन शुद्धानि पदानि एव अवशिष्यन्ते, यत् गायकः प्रायः इच्छति।';

  @override
  String get helpTransposeS3P3 =>
      'गीतस्य उपरि पङ्क्तौ सङ्गीतचिह्नपिञ्जम् एकेन स्पर्शेन तदेव करोति।';

  @override
  String get helpTransposeS4Heading => 'स्वरसमूहसूचिका';

  @override
  String get helpTransposeS4P1 =>
      'उपरितनपट्टिकायाः सूची → \"स्वरसमूहसूचिका\" गीते प्रयुक्तान् सर्वान् स्वरसमूहान्, भवता वाद्यमानं स्वरमानं प्रति पूर्वमेव नीतान्, दर्शयति।';

  @override
  String get helpTransposeS4P2 =>
      'प्रत्येकः स्वरसमूहः द्विधा चित्र्यते: अङ्गुलिबिन्दुभिः, मुक्तानां मूकीकृतानां च तन्त्रीणां कृते O X चिह्नैः च युक्तं षट्तन्त्रीकं गिटार्-फलकम्; स्वराः यत्र दीप्यन्ते तादृशं हार्मोनियम्- अथवा पियानो-कुञ्जीफलकं च।';

  @override
  String get helpTransposeS4P3 =>
      'मूलस्वरः एकेन वर्णेन; तिर्यक्रेखास्वरसमूहस्य मन्द्रस्वरः, यथा C/E इत्यत्र E, अन्येन वर्णेन।';

  @override
  String get helpTransposeS4P4 =>
      'सामान्यान् मुक्ताकारान् एषा जानाति; अन्येषां सर्वेषां कृते चलान् बार्-आकारान् गणयति।';

  @override
  String get helpTransposeS4P5 =>
      'कर्णाटक-हिन्दुस्थानीगीते एषा \"स्वरसूचिका\" भवति, स्वरसमूहाकाराणां स्थाने प्रत्येकः स्वरः कुञ्जीफलके कुत्र तिष्ठति इति मन्द्रात् तारपर्यन्तं दर्शयति।';

  @override
  String get titleHelpAutoScroll => 'स्वयंसर्पणम्';

  @override
  String get helpAutoScrollSummary => 'वादनकाले हस्तं विना पत्रं सर्पतु';

  @override
  String get helpAutoScrollIntro =>
      'प्रस्तुतिकाले स्वयंसर्पणं स्वरसमूहपत्रं भवतः कृते उपरि नयति, अतः पटलस्पर्शः नापेक्ष्यते। द्वौ विधी स्तः: स्वेच्छम्, लयः च।';

  @override
  String get helpAutoScrollS1Heading => 'द्वौ विधी';

  @override
  String get helpAutoScrollS1P1 =>
      'स्वेच्छविधिः भवता निश्चिते स्थिरवेगे सर्पति, 0.10x तः 2.00x पर्यन्तम्। पत्रे द्विस्पर्शेन परिवर्त्यताम्; प्रत्येकः स्पर्शः 0.05x परिवर्तयति।';

  @override
  String get helpAutoScrollS1P2 =>
      'भवता गीताय निश्चितं वेगं तद्गीतं स्मरति। यस्य वेगः न निश्चितः, तद्गीतं विन्यासः → सामान्यम् → स्वयंसर्पणम् इत्यत्र स्थिते आरम्भवेगे उद्घाट्यते।';

  @override
  String get helpAutoScrollS1P3 =>
      'लयविधिः गीतस्य दैर्घ्यं गणयित्वा गीतान्ते एव समाप्तिः यथा स्यात् तथा सर्पणवेगं नियमयति।';

  @override
  String get helpAutoScrollS2Heading => '\"आवर्तः\" इत्यस्य अर्थः';

  @override
  String get helpAutoScrollS2P1 =>
      'आवर्तः (मापः इत्यपि) सङ्गीते कालस्य एकः एककः।';

  @override
  String get helpAutoScrollS2P2 =>
      'यत् गीतं तालं न निर्दिशति, तत् सामान्यं 4/4 कालम् उपयुङ्क्ते, अतः एकस्मिन् आवर्ते चतस्रः मात्राः।';

  @override
  String get helpAutoScrollS2P3 =>
      '{tala} पङ्क्तियुक्तं गीतं तस्य तालस्य स्वकीयाः मात्राः गणयति, अतः मिश्रचापुगीते प्रत्यावर्तं सप्त मात्राः।';

  @override
  String get helpAutoScrollS2P4 =>
      'गीतानि 32 आवर्तैः उद्घाट्यन्ते। पत्रे द्विस्पर्शेन सङ्ख्या परिवर्त्यताम् — प्रत्येकः द्विस्पर्शः चतुरः आवर्तान् योजयति अपनयति वा।';

  @override
  String get helpAutoScrollS2P5 =>
      'सङ्ख्या 1 आवर्तात् 512 पर्यन्तं भवितुम् अर्हति।';

  @override
  String get helpAutoScrollS3Heading => 'लयविधिः वेगं कथं निश्चिनोति';

  @override
  String get helpAutoScrollS3P1 =>
      'गीतदैर्घ्यम् आवर्तेभ्यः गीतस्य BPM-तः च: आवर्ताः x 4 मात्राः, भवता निश्चिते BPM-मध्ये।';

  @override
  String get helpAutoScrollS3P2 =>
      'अधिकाः आवर्ताः मन्दतरः BPM वा दीर्घतरं मन्दतरं च सर्पणं जनयन्ति।';

  @override
  String get helpAutoScrollS3P3 =>
      'उच्चतरः BPM ह्रस्वतरं शीघ्रतरं च सर्पणं जनयति।';

  @override
  String get helpAutoScrollS3P4 =>
      'स्थितिपङ्क्तिः आवर्तान् गणितं दैर्घ्यं च दर्शयति, यथा \"32 आवर्ताः · 1:04\"।';

  @override
  String get helpAutoScrollS4Heading => 'स्पर्शेन वेगपरिवर्तनम्';

  @override
  String get helpAutoScrollS4G1Title => 'उपरि द्विस्पर्शः';

  @override
  String get helpAutoScrollS4G1Description => 'शीघ्रतरम्';

  @override
  String get helpAutoScrollS4G2Title => 'अधः द्विस्पर्शः';

  @override
  String get helpAutoScrollS4G2Description => 'मन्दतरम्';

  @override
  String get helpAutoScrollS4G3Title => 'द्वाभ्याम् अङ्गुलीभ्यां स्पर्शः';

  @override
  String get helpAutoScrollS4G3Description => 'आरम्भः / विरामः';

  @override
  String get helpAutoScrollS4P1 =>
      'एते एव स्पर्शाः अत्र पूर्णपटले च कार्यं कुर्वन्ति, अतः स्मर्तव्यम् एकम् एव।';

  @override
  String get helpAutoScrollS4P2 =>
      'लयविधौ एते एव द्विस्पर्शाः तस्य स्थाने आवर्तान् योजयन्ति अपनयन्ति वा।';

  @override
  String get helpAutoScrollS4P3 =>
      'नूतनं मूल्यं पटलस्य मध्ये बृहत् स्फुरति, अतः आधारस्थात् अपि पठितुं शक्यते।';

  @override
  String get helpAutoScrollS4P4 =>
      'अयं वेगः स्वयंसर्पणकाले एव उपयुज्यते। अङ्गुल्या कर्षणे पत्रस्य गतिं कदापि न परिवर्तयति।';

  @override
  String get helpAutoScrollS4P5 =>
      'एका अङ्गुली अद्यापि सर्पयति, द्वाभ्याम् अङ्गुलीभ्यां सङ्कोचनेन अक्षरपरिमाणं परिवर्तते।';

  @override
  String get helpAutoScrollS5Heading => 'आरम्भः विरामः च';

  @override
  String get helpAutoScrollS5P1 =>
      'सर्पणम् आरब्धुं विरमयितुं च पत्रं द्वाभ्याम् अङ्गुलीभ्यां स्पृश्यताम्। अस्मिन् पटले इतः परं वादनपिञ्जं नास्ति।';

  @override
  String get helpAutoScrollS5P2 =>
      'पूर्णपटले नियन्त्रणपट्टिकायां वादनपिञ्जम् अपि अद्यापि अस्ति।';

  @override
  String get helpAutoScrollS5P3 => 'लयविधौ गीतान्ते सर्पणं स्वयं विरमति।';

  @override
  String get helpAutoScrollS6Heading => 'हस्तेन पत्रचालनम्';

  @override
  String get helpAutoScrollS6P1 =>
      'स्वयंसर्पणकाले अपि, यदा कदापि एकया अङ्गुल्या पत्रं कर्षितुं शक्यते।';

  @override
  String get helpAutoScrollS6P2 =>
      'अङ्गुल्याम् अधःस्थितायां स्वयंसर्पणं प्रतीक्षते, यत्र मुच्यते ततः अनुवर्तते, अतः स्थानशोधनाय विरम्य पुनः आरम्भः कदापि नापेक्ष्यते।';

  @override
  String get helpAutoScrollS6P3 =>
      'शीघ्रः क्षेपः अग्रे न प्लवते, यत्र अङ्गुली उत्थाप्यते तत्र एव तिष्ठति, यतः स्वयंसर्पणं सद्यः पुनः नियन्त्रणं गृह्णाति।';

  @override
  String get helpAutoScrollS7Heading => 'गीतस्य उपरितनपङ्क्तिः';

  @override
  String get helpAutoScrollS7P1 =>
      'M T च विधिं चिनुतः; बाणचिह्नं पूर्णपटलं गच्छति।';

  @override
  String get helpAutoScrollS7P2 =>
      'स्वेच्छविधौ \"0.40x\" इव वेगः दक्षिणतः दृश्यते। तत् केवलं पठनाय — परिवर्तयितुं पत्रे द्विस्पर्शः क्रियताम्।';

  @override
  String get helpAutoScrollS7P3 => 'सङ्गीतचिह्नं स्वरसमूहान् गोपयति दर्शयति च।';

  @override
  String get helpAutoScrollS7P4 =>
      'पियानोचिह्नं स्वरपङ्क्तीः गोपयति दर्शयति च। यस्मिन् गीते स्वरमाला लिखिता, तत्र एव तत् दृश्यते।';

  @override
  String get titleHelpFullScreen => 'पूर्णपटलम्';

  @override
  String get helpFullScreenSummary => 'पदानि एव, स्पर्शैः नियन्त्रितानि';

  @override
  String get helpFullScreenIntro =>
      'पूर्णपटलम् उपरितनपट्टिकां दूरभाषस्य स्वकीयाः पट्टिकाः च गोपयति, येन गीतं समग्रं पटलं पूरयति। एतत् सजीवप्रस्तुत्यै निर्मितम्, यत्र आधारस्थं पटलं दृश्यते, यथासम्भवं न्यूनं च स्पृश्यते।';

  @override
  String get helpFullScreenS1Heading => 'पूर्णपटलप्रवेशः';

  @override
  String get helpFullScreenS1P1 =>
      'स्वयंसर्पणपङ्क्तौ पूर्णपटलपिञ्जं स्पृश्यताम्।';

  @override
  String get helpFullScreenS1P2 =>
      'गीतं, स्वरमानम्, अक्षरपरिमाणं, सर्पणस्थानं च सर्वं यथापूर्वं तिष्ठति।';

  @override
  String get helpFullScreenS1P3 =>
      'सामान्यगीतदर्शने इव पटलं जागरितम् एव तिष्ठति।';

  @override
  String get helpFullScreenS2Heading => 'स्पर्शसङ्केताः';

  @override
  String get helpFullScreenS2G1Title => 'एकवारं स्पर्शः';

  @override
  String get helpFullScreenS2G1Description =>
      'नियन्त्रणानि दर्श्यन्तां / गोप्यन्ताम्';

  @override
  String get helpFullScreenS2G2Title => 'उपरि द्विस्पर्शः';

  @override
  String get helpFullScreenS2G2Description => 'शीघ्रतरम्';

  @override
  String get helpFullScreenS2G3Title => 'अधः द्विस्पर्शः';

  @override
  String get helpFullScreenS2G3Description => 'मन्दतरम्';

  @override
  String get helpFullScreenS2G4Title => 'द्वाभ्याम् अङ्गुलीभ्यां स्पर्शः';

  @override
  String get helpFullScreenS2G4Description => 'आरम्भः / विरामः';

  @override
  String get helpFullScreenS2G5Title => 'सङ्कोचनम्';

  @override
  String get helpFullScreenS2G5Description => 'अक्षरपरिमाणपरिवर्तनम्';

  @override
  String get helpFullScreenS2G6Title => 'प्रत्यागमनम्';

  @override
  String get helpFullScreenS2G6Description => 'पूर्णपटलात् निर्गमः';

  @override
  String get helpFullScreenS2P1 =>
      'नियन्त्रणपट्टिकां दर्शयितुं गोपयितुं वा एकवारं स्पृश्यताम्। कतिपयक्षणेभ्यः परं सा पुनः अपसरति।';

  @override
  String get helpFullScreenS2P2 =>
      'शीघ्रतरं गन्तुम् उपरितनार्धे द्विस्पर्शः; मन्दतरं गन्तुम् अधस्तनार्धे द्विस्पर्शः। नूतनं मूल्यं पटले बृहत् स्फुरति।';

  @override
  String get helpFullScreenS2P3 =>
      'लयविधौ एते एव द्विस्पर्शाः आवर्तान् योजयन्ति अपनयन्ति वा, यतः तत्र आवर्ताः एव वेगं निश्चिन्वन्ति।';

  @override
  String get helpFullScreenS2P4 =>
      'आरब्धुं विरमयितुं वा द्वाभ्याम् अङ्गुलीभ्यां स्पृश्यताम्।';

  @override
  String get helpFullScreenS2P5 =>
      'सामान्यवत्, अक्षरपरिमाणं परिवर्तयितुं सङ्कोच्यताम्।';

  @override
  String get helpFullScreenS3Heading => 'पट्टिकायाः पिञ्जानि';

  @override
  String get helpFullScreenS3P1 => 'निर्गमः (सङ्कोचचिह्नम्) पूर्णपटलं त्यजति।';

  @override
  String get helpFullScreenS3P2 => 'तालकं पटलं कीलयति — अधः दृश्यताम्।';

  @override
  String get helpFullScreenS3P3 =>
      'घण्टा रङ्गमौनविधिं सक्रियं निष्क्रियं च करोति — अधः दृश्यताम्।';

  @override
  String get helpFullScreenS3P4 =>
      'M T च स्वेच्छं लयं वा चिनुतः, वर्तुलपिञ्जं च आरभते विरमति वा।';

  @override
  String get helpFullScreenS3P5 =>
      'पट्टचिह्नं श्रुतिवेणुं श्रुतिपेटिकां च उद्घाटयति।';

  @override
  String get helpFullScreenS3P6 =>
      'अन्ते स्थिते - + च, द्विस्पर्शवत् एव, स्वेच्छविधौ वेगं लयविधौ आवर्तसङ्ख्यां च परिवर्तयतः।';

  @override
  String get helpFullScreenS3P7 =>
      'पिञ्जानाम् अधः पङ्क्तिः स्वरमानं, BPM, लयविधौ दैर्घ्यं च पुनः दर्शयति।';

  @override
  String get helpFullScreenS4Heading => 'पटलकीलनम्';

  @override
  String get helpFullScreenS4P1 =>
      'रङ्गदर्शनं कीलयितुं तालकं स्पृश्यताम्। ततः स्पर्शनियन्त्रणानि निष्क्रियाणि भवन्ति, अतः वस्त्राञ्चलः प्रमादहस्तः वा वेगं न परिवर्तयति, गीतमध्ये न विरमयति च।';

  @override
  String get helpFullScreenS4P2 =>
      'नियन्त्रणपट्टिका अपसरति, उपरि दक्षिणतः \"रङ्गः कीलितः\" इति लघु चिह्नकं दृश्यते।';

  @override
  String get helpFullScreenS4P3 =>
      'उद्घाटयितुं तत् चिह्नकं स्पृश्यताम्, अथवा प्रत्यागमनं नुद्यताम्। तत् भवतः अङ्गुलिमुद्रां, अथवा दूरभाषे पूर्वमेव प्रयुक्तं PIN, रेखाचित्रं, गूढशब्दं वा पृच्छति।';

  @override
  String get helpFullScreenS4P4 =>
      'यस्मिन् दूरभाषे पटलकीलनं न सज्जितम्, तत्र परीक्षणीयं किमपि नास्ति, अतः साक्षात् उद्घाट्यते।';

  @override
  String get helpFullScreenS4P5 =>
      'परीक्षणं सर्वथा न प्रवर्तते चेत्, रङ्गः तथापि उद्घाट्यते तत् च निवेदयति। कीलनं प्रमादस्पर्शनिवारणाय, अतः तत् भवन्तं कदापि बहिः न रुणद्धि।';

  @override
  String get helpFullScreenS5Heading => 'रङ्गमौनविधिः';

  @override
  String get helpFullScreenS5P1 =>
      'वादनकाले घण्टानादं सूचनाध्वनीन् च मौनीकर्तुं घण्टा स्पृश्यताम्, येन आह्वानं ध्वनिवर्धकेन न श्रूयते।';

  @override
  String get helpFullScreenS5P2 =>
      'अनुप्रयोगस्य स्वकीयः ध्वनिः अस्पृष्टः — तालयन्त्रटङ्कारः, श्रुतिसूचना, आधारनादः च सर्वे कार्यं कुर्वन्ति एव।';

  @override
  String get helpFullScreenS5P3 =>
      'दूरभाषे यथार्थतः मौने जाते एव चिह्नं रक्तं भवति। पुनः स्पृश्यताम्, पूर्णपटलं त्यज्यताम्, गीतं वा त्यज्यताम् — भवतः सामान्यः घण्टाविन्यासः प्रत्यागच्छति, अनुप्रयोगे पिहिते अपि।';

  @override
  String get helpFullScreenS5P4 =>
      'प्रथमवारम् Android LyricChord-कृते \"मा बाधताम् (Do Not Disturb) अधिकारः\" अनुमन्तुं पृच्छेत्। सन्देशे विन्यासः उद्घाट्यताम् इति स्पृश्यताम्, तत् सक्रियं क्रियताम्, ततः पुनः घण्टा स्पृश्यताम्।';

  @override
  String get helpFullScreenS5P5 =>
      'iPhone-यन्त्रेषु अनुप्रयोगाः घण्टानादं परिवर्तयितुं न शक्नुवन्ति, अतः तत्र घण्टा न दृश्यते। तस्य स्थाने नाद/मौन-स्विच् उपयुज्यताम्।';

  @override
  String get helpFullScreenS6Heading => 'प्रत्यागमनम्';

  @override
  String get helpFullScreenS6P1 =>
      'प्रत्यागमनं नुद्यताम्, अथवा एकवारं स्पृष्ट्वा नियन्त्रणपट्टिकायां निर्गमपिञ्जम् उपयुज्यताम्।';

  @override
  String get helpFullScreenS6P2 =>
      'तत् केवलं पूर्णपटलं त्यजति — भवान् अद्यापि तस्मिन्नेव गीते अस्ति। गीतपुस्तकं प्रति प्रत्यागन्तुं पुनः प्रत्यागमनं नुद्यताम्।';

  @override
  String get helpFullScreenS6P3 =>
      'पूर्णपटले पार्श्वतः सर्पणेन गीतं न परिवर्तते, अतः प्रमादस्पर्शः गीतमध्ये अन्यद् गीतं न आनयति।';

  @override
  String get titleHelpMetronome => 'तालयन्त्रम्';

  @override
  String get helpMetronomeSummary => 'गीतलयेन तालः धार्यताम्';

  @override
  String get helpMetronomeIntro =>
      'प्रस्तुतिकाले तालयन्त्रं कालं धारयति। तस्य वेगः प्रत्येकस्य गीतस्य BPM-तः (प्रतिनिमेषं मात्राः) आगच्छति, यः गीतसम्पादके निश्चीयते।';

  @override
  String get helpMetronomeS1Heading => 'सक्रियीकरणम्';

  @override
  String get helpMetronomeS1P1 =>
      'विन्यासः > सामान्यम् > तालयन्त्रम् इत्यत्र गम्यताम्।';

  @override
  String get helpMetronomeS1P2 =>
      '\"तालयन्त्रं सक्रियम्\" इति स्विच् सक्रियं क्रियताम्।';

  @override
  String get helpMetronomeS1P3 =>
      'विन्यासः रक्ष्यते, अनुप्रयोगस्य पुनरारम्भे अपि सक्रियः तिष्ठति।';

  @override
  String get helpMetronomeS2Heading => 'स्फुरणं टङ्कारः च';

  @override
  String get helpMetronomeS2P1 =>
      'स्फुरणं प्रतिमात्रं स्फुरति — ध्वनौ मौनीकृते उपयुक्तम्।';

  @override
  String get helpMetronomeS2P2 => 'टङ्कारः प्रतिमात्रं लघुं टङ्कारं वादयति।';

  @override
  String get helpMetronomeS2P3 =>
      'अन्यतरम्, उभयं, न किमपि वा उपयोक्तुं शक्यते।';

  @override
  String get helpMetronomeS2P4 =>
      'तालयन्त्रे सक्रिये यावत् न भवति, तावत् स्फुरणं टङ्कारः च धूसरवर्णौ निष्क्रियौ तिष्ठतः।';

  @override
  String get helpMetronomeS2P5 =>
      'टङ्कारध्वनिमानं टङ्कारस्य उच्चतां निश्चिनोति। टङ्कारः माध्यमध्वनिमानम् उपयुङ्क्ते, अतः न श्रूयते चेत् गीते उद्घाटिते ध्वनिपिञ्जैः ध्वनिः वर्ध्यताम्।';

  @override
  String get helpMetronomeS2P6 =>
      'गीतम् अनुद्घाट्य एकम् आवर्तं श्रोतुं तालयन्त्रविन्यासे \"ध्वनिपरीक्षा\" स्पृश्यताम्।';

  @override
  String get helpMetronomeS3Heading => 'आवर्ते मात्राः';

  @override
  String get helpMetronomeS3P1 =>
      'तालयन्त्रविन्यासे आवर्ते 2, 3, 4, 6 वा मात्राः चीयन्ताम्।';

  @override
  String get helpMetronomeS3P2 =>
      '\"प्रथममात्राबलम्\" सक्रियं चेत्, प्रत्यावर्तं प्रथमा मात्रा उच्चतरा तारतरा च श्रूयते, येन आवर्तः कुत्र आरभते इति ज्ञायते।';

  @override
  String get helpMetronomeS3P3 =>
      'तालप्रवृत्तिकाले पिञ्जं मात्रासङ्ख्यां गणयति — 1, 2, 3, 4 — अतः ध्वनिं विना अपि स्वस्थानं दृश्यते।';

  @override
  String get helpMetronomeS4Heading => 'लयनिर्धारणम्';

  @override
  String get helpMetronomeS4P1 => 'मूलतः मात्रावेगः गीतस्य BPM अनुसरति।';

  @override
  String get helpMetronomeS4P2 => 'गीतं सम्पाद्य तस्य BPM परिवर्त्यताम्।';

  @override
  String get helpMetronomeS4P3 =>
      'हस्तेन वेगं निश्चेतुं तालयन्त्रपिञ्जं दीर्घं नुद्यताम्: - + च उपयुज्येताम्, सर्पकं कृष्यताम्, अथवा सङ्गीतेन सह \"स्पर्शलयः\" स्पृश्यताम्।';

  @override
  String get helpMetronomeS4P4 =>
      'हस्तेन निश्चितः लयः अस्मिन् सत्रे एव तिष्ठति। गीतस्य स्वकीयं वेगं प्रति प्रत्यागन्तुं \"गीतलयः उपयुज्यताम्\" स्पृश्यताम्।';

  @override
  String get helpMetronomeS4P5 =>
      'BPM-रहिते गीते अपि कार्यं करोति — तालयन्त्रं भवता अन्तिमवारं प्रयुक्तं वेगम् उपयुङ्क्ते।';

  @override
  String get titleHelpPitchPipeDrone => 'श्रुतिवेणुः आधारनादः च';

  @override
  String get helpPitchPipeDroneSummary =>
      'आधारश्रुतिसूचनाः स्थिरः श्रुतिपेटिकानादः च';

  @override
  String get helpPitchPipeDroneIntro =>
      'सर्वथा अन्तर्जालरहितः ध्वनिजनकः: आरम्भाय लघुः आधारस्वरः, सह गातुं स्थिरः श्रुतिपेटिकानादः च। किमपि नावतार्यते, अनुप्रयोगेण सह ध्वनिसञ्चिकाः अपि न सन्ति — पिञ्जनोदनक्षणे एव स्वराः निर्मीयन्ते।';

  @override
  String get helpPitchPipeDroneS1Heading => 'आधारनादः किं करोति, किं न करोति';

  @override
  String get helpPitchPipeDroneS1P1 =>
      'यावत् सक्रियः, तावत् आधारनादः एकम् एव स्थिरं स्वरयुगलं धारयति।';

  @override
  String get helpPitchPipeDroneS1P2 =>
      'सः स्वरमालां, पदानि, स्वरसमूहान् वा न अनुसरति। यावत् भवान् न परिवर्तयति, तावत् कदापि न परिवर्तते।';

  @override
  String get helpPitchPipeDroneS1P3 =>
      'कदापि न विरमन्तं स्वरशोधनदण्डम् इव मन्यताम्, येन गानकाले भवतः श्रोत्रं स्थिरम् आश्रितं तिष्ठति।';

  @override
  String get helpPitchPipeDroneS2Heading => 'कुत्र लभ्यते';

  @override
  String get helpPitchPipeDroneS2P1 =>
      'गीतम् उद्घाट्य तालयन्त्रस्य पार्श्वे स्थितं श्रुतिपिञ्जं (पट्टचिह्नम्) स्पृश्यताम्।';

  @override
  String get helpPitchPipeDroneS2P2 =>
      'रङ्गविधिपट्टिकायाम् अपि, वादनपिञ्जस्य पार्श्वे, तत् अस्ति।';

  @override
  String get helpPitchPipeDroneS2P3 =>
      'विन्यासः → सामान्यम् → श्रुतिवेणुः आधारनादः च इत्यत्र मूलविन्यासाः निश्चीयन्ते, परीक्षापिञ्जानि अपि सन्ति।';

  @override
  String get helpPitchPipeDroneS3Heading =>
      'श्रुतिसूचना (पाश्चात्ये समूहसूचना)';

  @override
  String get helpPitchPipeDroneS3P1 =>
      'द्विक्षणात्मकम् आधारस्वरं श्रोतुं \"श्रुतिसूचना\" स्पृश्यताम्। एषः अङ्कीयः श्रुतिवेणुः: भवतः Sa (अथवा चितं स्वरमानं) ध्वनयित्वा स्वयं विरमति।';

  @override
  String get helpPitchPipeDroneS3P2 =>
      'गानारम्भात् पूर्वम् आरम्भस्वरं ज्ञातुम् एतत् उपयुज्यताम्।';

  @override
  String get helpPitchPipeDroneS3P3 =>
      'पाश्चात्यविधौ तदेव पिञ्जं \"समूहसूचना\" इति नाम्ना, सम्पूर्णं स्वरसमूहं — मन्द्रं, मूलं, तृतीयं, पञ्चमं च — वादयति, यतः पाश्चात्यवादकाः एकं स्वरं न, स्वरसमूहम् इच्छन्ति। मेजर् माइनर् वा इति भवता चितं गुणम् अनुसरति।';

  @override
  String get helpPitchPipeDroneS3P4 =>
      'दैर्घ्यं द्विक्षणम् इति नियतम्, तस्य विन्यासः नास्ति। श्रुतिं स्पष्टं श्रोतुं पर्याप्तं दीर्घम्, बाधां न कर्तुं पर्याप्तं ह्रस्वं च। स्पर्शात् पूर्वं किं लप्स्यते इति ज्ञातुं पिञ्जे \"(2 क्षणौ)\" इति लिखितम्।';

  @override
  String get helpPitchPipeDroneS3P5 =>
      'दीर्घकालं तिष्ठन्तं स्वरम् इच्छति चेत्, तस्य स्थाने श्रुतिनादः उपयुज्यताम्। तस्य प्रयोजनं तदेव।';

  @override
  String get helpPitchPipeDroneS4Heading => 'सूचना वा नादः वा — कः?';

  @override
  String get helpPitchPipeDroneS4P1 =>
      'सूचना: स्वयं विरमन् एकः लघुः ध्वनिः। आरम्भात् पूर्वं स्वरं ज्ञातुम्।';

  @override
  String get helpPitchPipeDroneS4P2 =>
      'नादः: यावत् भवान् न विरमयति, तावत् ध्वनति। अभ्यासे प्रस्तुतौ वा सह गातुम्।';

  @override
  String get helpPitchPipeDroneS4P3 =>
      'उभौ पिञ्जनोदनक्षणे एव अनुप्रयोगस्य अन्तः निर्मीयेते। किमपि नावतार्यते, अनुप्रयोगेण सह ध्वनिसञ्चिकाः अपि न सन्ति।';

  @override
  String get helpPitchPipeDroneS5Heading => 'श्रुतिपेटिकानादः';

  @override
  String get helpPitchPipeDroneS5P1 =>
      'निरन्तरं पृष्ठगुञ्जनम् आरब्धुं \"श्रुतिनादः\" स्पृश्यताम्।';

  @override
  String get helpPitchPipeDroneS5P2 =>
      'अधिकांशसङ्गीताय Sa + Pa (पञ्चमः) चीयताम्; मालकौंस-मारवा इव पञ्चमवर्जितरागेभ्यः Sa + Ma (मध्यमः)।';

  @override
  String get helpPitchPipeDroneS5P3 =>
      'उभौ स्वरौ शुद्धानुपातयोः (3:2, 4:3) शोधितौ, यथा यथार्थं श्रुतिवाद्यं ध्वनति — न तु समविभक्तस्वरपद्धत्याम्।';

  @override
  String get helpPitchPipeDroneS5P4 =>
      'यावत् भवान् न विरमयति, तावत् नादः प्रवर्तते, अतः विच्छेदं विना अभ्यासः शक्यः।';

  @override
  String get helpPitchPipeDroneS6Heading => 'भारतीयं पाश्चात्यं च नामकरणम्';

  @override
  String get helpPitchPipeDroneS6P1 =>
      'Sa चलः, अतः भवतः Sa यथार्थतः का श्रुतिः इति अनुप्रयोगेण ज्ञातव्यम्। विन्यासः → \"भवतः Sa (श्रुतिः)\" इत्यत्र निश्चीयताम्।';

  @override
  String get helpPitchPipeDroneS6P2 =>
      'रागयुक्तस्य गीतस्य भारतीयरीत्या नाम: कर्णाटकाय \"5 kattai\", हिन्दुस्थान्यै \"safed 5\"। कतरत् इति तालः निर्णयति। भारतीयपत्रे पाश्चात्याक्षराणि न दृश्यन्ते।';

  @override
  String get helpPitchPipeDroneS6P3 =>
      'रागरहितस्य गीतस्य पाश्चात्यरीत्या नाम: केवलं \"G\"।';

  @override
  String get helpPitchPipeDroneS6P4 =>
      'पाश्चात्यगीतं स्वकीये स्वरमाने उद्घाट्यते। भारतीयगीतं भवतः Sa-मध्ये उद्घाट्यते, यतः स्वरलिपिः Sa-सापेक्षं लिख्यते।';

  @override
  String get helpPitchPipeDroneS7Heading => 'रङ्गाय अक्षरपरिमाणम्';

  @override
  String get helpPitchPipeDroneS7P1 =>
      'तदेव पत्रं हस्तस्थे दूरभाषे पदद्वयदूरे आधारे च पठ्यते, अतः श्रुतिपत्रे अक्षरपरिमाणविन्यासः अस्ति।';

  @override
  String get helpPitchPipeDroneS7P2 =>
      'श्रुतिपत्रस्य अधः स्थितेभ्यः चिह्नकेभ्यः पञ्चसु परिमाणेषु एकं चीयताम् — 85%, 95%, 100%, 115%, 130% वा।';

  @override
  String get helpPitchPipeDroneS7P3 =>
      'विन्यासः → सामान्यम् → श्रुतिवेणुः आधारनादः च इत्यत्र अपि तान्येव चिह्नकानि सन्ति, अतः प्रदर्शनात् पूर्वं निश्चेतुं शक्यते।';

  @override
  String get helpPitchPipeDroneS7P4 =>
      'एतत् न केवलं पूर्णपटले, सर्वत्र पत्राक्षरपरिमाणं गुणयति।';

  @override
  String get helpPitchPipeDroneS7P5 =>
      'द्वाभ्याम् अङ्गुलीभ्यां पत्रसङ्कोचनम् अद्यापि कार्यं करोति, एकस्य गीतस्य किञ्चित् परिवर्तनाय शीघ्रतरः उपायः सः एव।';

  @override
  String get titleHelpMelody => 'स्वरपङ्क्तयः';

  @override
  String get helpMelodySummary => 'पदानाम् अधः स्वरमालां लिखित्वा शृणोतु।';

  @override
  String get helpMelodyIntro =>
      'स्वरसमूहपत्रं भवते पदानि वदति, सहवादकाय किं वादनीयम् इति च। स्वरमालां तु न वदति। स्वरपङ्क्तिः ताम् योजयति। पदपङ्क्तेः अधः {melody} लिख्यताम्; अनुप्रयोगः मात्राः चित्रयित्वा गुञ्जनेन श्रावयति, येन अश्रुतपूर्वम् अपि गीतं शिक्षितुं शक्यते।';

  @override
  String get helpMelodyS1Heading => 'लेखनम्';

  @override
  String get helpMelodyS1P1 =>
      '{melody} इत्यनेन आरभमाणां पङ्क्तिं सम्बद्धायाः पदपङ्क्तेः अधः स्थाप्यताम्।';

  @override
  String get helpMelodyS1P2 => 'उदाहरणम्: {melody} P ,  M2 | M2!G3~ ,  | R2 S';

  @override
  String get helpMelodyS1P3 =>
      'मात्राः रिक्तस्थानैः पृथक् क्रियन्ते। एका मात्रा, एकं रिक्तस्थानम्।';

  @override
  String get helpMelodyS1P4 =>
      'तस्य उपरि पदानि स्वरसमूहाः च किञ्चिद् अपि न परिवर्तन्ते।';

  @override
  String get helpMelodyS1P5 =>
      'लेखनं नापेक्ष्यते। सम्पादके अधिकम् → \"स्वरफलकम्\" षोडशस्वरैः सर्वैः चिह्नैः च युक्तं फलकं ददाति, स्पर्शे मात्राः चित्रयति, पङ्क्तिः तालं यावत् न पूरयति तावत् \"8 मध्ये 6 मात्राः\" इति गणयति च।';

  @override
  String get helpMelodyS1P6 =>
      'सूचके पूर्वमेव {melody} पङ्क्तौ स्थिते, फलकं तां पङ्क्तिम् आनयति, येन प्रथमं लोपं विना एव संशोधनं शक्यम्।';

  @override
  String get helpMelodyS1P7 =>
      'प्रकाशितकर्णाटकस्वरलिप्याः खण्डः एकवारेण स्वरपङ्क्तिषु परिणमयितुं शक्यते — भारतीयगीतविषयः दृश्यताम्।';

  @override
  String get helpMelodyS2Heading => 'पञ्च चिह्नानि';

  @override
  String get helpMelodyS2P1 =>
      'अल्पविरामः ( , ) पूर्वस्वरम् एकां मात्राम् अधिकं धारयति।';

  @override
  String get helpMelodyS2P2 =>
      'दण्डः ( | ) नूतनः तालखण्डः कुत्र आरभते इति दर्शयति। सः कालं न गृह्णाति।';

  @override
  String get helpMelodyS2P3 =>
      'योजकचिह्नम् ( - ) एकां मात्रां विभजमानान् स्वरान् योजयति: G3-R2 प्रत्येकम् अर्धमात्रा।';

  @override
  String get helpMelodyS2P4 =>
      'विस्मयचिह्नं ( ! ) स्वरं प्रति सरति। M2!G3 इत्यत्र सरणं Ma-तः आरभते। केवलं !G3 तु Ga-तः किञ्चित् अधस्तात् लघुसरणम्।';

  @override
  String get helpMelodyS2P5 => 'तरङ्गचिह्नं ( ~ ) स्वरं कम्पयति (गमकम्)।';

  @override
  String get helpMelodyS3Heading => 'स्वरनामकरणम्';

  @override
  String get helpMelodyS3P1 =>
      'केवलं नाम सामान्यपङ्क्तेः Sa Re Ga Ma Pa Dha Ni स्वरः, अतः एकाकी Ma इति Ma1।';

  @override
  String get helpMelodyS3P2 =>
      'अङ्कः यथार्थं स्वरं निर्दिशति: Ma2 तीव्रः Ma, R1 R2 R3 त्रयः Ri-स्वराः।';

  @override
  String get helpMelodyS3P3 =>
      'Ma2 M2 च एकः एव स्वरः। स्वरसमूहेषु पूर्णनामानि स्वरपङ्क्तिषु लघ्वक्षराणि उपयुज्यन्ताम्, अथवा यत् सुपठम्।';

  @override
  String get helpMelodyS3P4 =>
      'रागः नाम्नः अर्थं कदापि न परिवर्तयति, अतः किमपि न अनुमीयते।';

  @override
  String get helpMelodyS3P5 =>
      'पुरतः बिन्दुः स्वरम् एकं सप्तकम् अवरोहयति (.N3)। पश्चात् उत्क्षेपचिह्नम् आरोहयति (S\')।';

  @override
  String get helpMelodyS4Heading => 'श्रवणम्';

  @override
  String get helpMelodyS4P1 =>
      'भवतः Sa यथार्थतः कुत्र इति अनुप्रयोगः ज्ञातुं {tonic: 1 kattai} योज्यताम्। तद्विना अपि मात्राः चित्र्यन्ते, किन्तु किमपि वादयितुं न शक्यते।';

  @override
  String get helpMelodyS4P2 =>
      'मात्राः सम्यक् समूहीकर्तुं {tala: misra chapu} योज्यताम्।';

  @override
  String get helpMelodyS4P3 => 'गीतस्य लयः एव वेगं निश्चिनोति।';

  @override
  String get helpMelodyS4P4 =>
      'स्वरपङ्क्तिं गुञ्जनेन श्रोतुं तस्याः पार्श्वे वादनपिञ्जं स्पृश्यताम्।';

  @override
  String get helpMelodyS4P5 =>
      'स्वरपङ्क्तीः विना पदानि पठितुम् अधिकसूचीम् → प्रस्तुतिनियन्त्रणम् उद्घाट्य स्वरपङ्क्तिः दर्श्यताम् इति निष्क्रियं क्रियताम्। पूर्णपटलं स्वरपङ्क्तीः कदापि न चित्रयति।';

  @override
  String get helpMelodyS4P6 =>
      'पङ्क्तिं पुनः पुनः वादयितुम् आवृत्तिः सक्रिया क्रियताम्, मन्दं शिक्षितुम् अर्धलयः।';

  @override
  String get helpMelodyS4P7 =>
      'प्रथमं श्रुतिनादः आरभ्यताम् — एकाकिन्याः अपेक्षया आधारनादेन सह स्वरमाला बहु सुश्रवा।';

  @override
  String get helpMelodyS5Heading => 'किं शक्यं किम् अशक्यं च';

  @override
  String get helpMelodyS5P1 =>
      'स्वराः कुत्र आयान्ति, प्रत्येकः कियत्कालं तिष्ठति इति एतत् दर्शयति।';

  @override
  String get helpMelodyS5P2 =>
      'गायकः इव तान् भावेन न अलङ्करोति। तदर्थं ध्वनिमुद्रणं श्रूयताम्।';

  @override
  String get helpMelodyS5P3 =>
      'प्रत्येकस्य गीतस्य कृते स्वरमालाज्ञः कश्चित् ताम् अवश्यं लिखेत्। लघुमार्गः नास्ति।';

  @override
  String get titleHelpIndianSongs => 'भारतीयगीतानि';

  @override
  String get helpIndianSongsSummary =>
      'स्वराः, रागः, तालः, भवतः Sa कुत्र इति च';

  @override
  String get helpIndianSongsIntro =>
      'भारतीयगीतं स्वरसमूहैः न, स्वरैः लिख्यते — स रि ग म प ध नि — तानि नामानि नियतश्रुतिसापेक्षाणि न, Sa-सापेक्षाणि। अनुप्रयोगः तादृशं गीतम् आद्यन्तं भिन्नरीत्या व्यवहरति।';

  @override
  String get helpIndianSongsS1Heading => 'गीतं भारतीयम् इति चिह्न्यताम्';

  @override
  String get helpIndianSongsS1P1 =>
      'सम्पादके \"स्वरलिपिः\" कर्णाटकं हिन्दुस्थानी वा क्रियताम्।';

  @override
  String get helpIndianSongsS1P2 =>
      '\"मूलस्वरमानम्\" इति पेटकस्य स्थाने रागः तालः च आयातः, यतः भारतीयपत्रे परिवर्तनीयं स्वरमानं नास्ति।';

  @override
  String get helpIndianSongsS1P3 =>
      'पाश्चात्यं प्रति पुनः परिवर्तने रागः तालः च मृज्येते, अतः पुरातनं मूल्यं गीतं पुनः भारतीयवत् कदापि न दर्शयति।';

  @override
  String get helpIndianSongsS2Heading => 'तालपेटकस्य अधः टिप्पणी';

  @override
  String get helpIndianSongsS2P1 =>
      'अन्यसम्प्रदायस्य तालः — यथा कर्णाटकगीते केहरवा — लिखितः चेत्, पेटकस्य अधः लघ्वी टिप्पणी दृश्यते।';

  @override
  String get helpIndianSongsS2P2 =>
      'सा उपदेशमात्रम्। रक्षणं कदापि न निरुणद्धि। अनुप्रयोगः तालनाम्नां नियतां सूचीम् एव जानाति, भवतः तालः तस्यां न स्यात् अपि।';

  @override
  String get helpIndianSongsS2P3 =>
      'लयानुसारिस्वयंसर्पणाय स्वरपङ्क्तेः अधः मात्राजालाय च आवर्ते कति मात्राः इति तालः एव निर्णयति।';

  @override
  String get helpIndianSongsS3Heading => 'गीतपटले किं परिवर्तते';

  @override
  String get helpIndianSongsS3P1 =>
      'न किमपि पाश्चात्याक्षरं दृश्यते। स्थितिपङ्क्तिः \"स्वयंसर्पणम् · 120 BPM\" इति पठ्यते, रागः तालः च तस्याः अधः पङ्क्तौ।';

  @override
  String get helpIndianSongsS3P2 =>
      'स्वरमानपरिवर्तननियन्त्रणं नास्ति, यतः स्वरः न चलति।';

  @override
  String get helpIndianSongsS3P3 =>
      'सूची स्वरसमूहसूचिकायाः स्थाने \"स्वरसूचिका\" ददाति।';

  @override
  String get helpIndianSongsS3P4 =>
      'श्रुतिपत्रं गीतस्वरमानस्य स्थाने भवता रक्षिते Sa-मध्ये उद्घाट्यते, भारतीयरीत्या नाम च ददाति — कर्णाटकाय \"5 kattai\", हिन्दुस्थान्यै \"safed 5\"।';

  @override
  String get helpIndianSongsS4Heading => 'पदेषु योजनीयाः पङ्क्तयः';

  @override
  String get helpIndianSongsS4P1 =>
      '{tonic: 1 kattai} भवतः Sa यथार्थतः कुत्र इति वदति। तद्विना स्वरपङ्क्तिः वादयितुं न शक्यते।';

  @override
  String get helpIndianSongsS4P2 => '{tala: misra chapu} मात्राः समूहीकरोति।';

  @override
  String get helpIndianSongsS4P3 =>
      '{sruti: madhyama} यस्मिन् गीते आधारनादस्य पञ्चमतन्त्री शुद्धमध्यमं प्रति अवरोह्यते, तत् चिह्नयति, यथा यमुनाकल्याणी प्रायः गीयते। तदा लिखितः Sa चतुर्थस्वरान्तरम् उच्चतरं ध्वनति।';

  @override
  String get helpIndianSongsS4P4 =>
      '{melody} पङ्क्तयः स्वरमालां धारयन्ति — स्वरपङ्क्तिविषयः दृश्यताम्।';

  @override
  String get helpIndianSongsS4P5 =>
      'एतानि सर्वाणि गीतपाठे एव वसन्ति, अतः आनयनं निर्यापणं च तानि अपरिवर्तितानि वहतः।';

  @override
  String get helpIndianSongsS5Heading => 'प्रकाशितस्वरलिपेः स्थापनम्';

  @override
  String get helpIndianSongsS5P1 =>
      'सम्पादके अधिकम् → \"कर्णाटकं स्थाप्यताम्\" पुस्तकात् पृष्ठात् वा प्रतिलिखितं खण्डं गृहीत्वा {melody} पङ्क्तिषु परिणमयति।';

  @override
  String get helpIndianSongsS5P2 =>
      'प्रकाशितस्वरलिपेः एकं मानकं नास्ति: केषुचित् पृष्ठेषु बृहदक्षरं दीर्घस्वरं सूचयति, अन्येषु तारसप्तकम्।';

  @override
  String get helpIndianSongsS5P3 =>
      'अतः अनुप्रयोगः तं खण्डम् उभयथा पठित्वा, प्रत्येकं गीतस्य तालेन सह परीक्ष्य, कतरत् अनुकूलं कियत् च इति वदति — यथा \"1 मध्ये 1 आवर्ताः तालं पूरयन्ति — अक्षररूपं स्वरस्य कालं सूचयति इति पठितम्\"।';

  @override
  String get helpIndianSongsS5P4 =>
      'यत्र उभे पठने समे, तत्र अनुमानं विना तत् स्पष्टं वदति।';

  @override
  String get helpIndianSongsS5P5 =>
      'द्वयोः Ma-स्वरयोः कतरः इति स्वयं न चिनोति। तत् रागव्याकरणम्, न गणितम् — किन्तु निर्णायकं प्रयोगं निर्दिशति।';

  @override
  String get titleHelpSelectSongs => 'गीतचयनम्';

  @override
  String get helpSelectSongsSummary => 'एकदा अनेकेषु गीतेषु कार्यम्';

  @override
  String get helpSelectSongsIntro =>
      'चयनविधिः बहूनि गीतानि सह चित्वा एकेन पदेन निर्यापयितुं लोप्तुं वा साहाय्यं करोति।';

  @override
  String get helpSelectSongsS1Heading => 'चयनारम्भः';

  @override
  String get helpSelectSongsS1P1 =>
      'गीतसूच्यां चयनविधिम् आरब्धुं किमपि गीतं दीर्घं नुद्यताम्।';

  @override
  String get helpSelectSongsS1P2 =>
      'चयने योजयितुम् अधिकानि गीतानि स्पृश्यन्ताम्।';

  @override
  String get helpSelectSongsS1P3 =>
      'कति गीतानि चितानि इति उपरितनपट्टिका दर्शयति।';

  @override
  String get helpSelectSongsS2Heading => 'सर्वचयनम्';

  @override
  String get helpSelectSongsS2P1 =>
      'सर्वाणि दृश्यमानानि गीतानि चेतुम् उपरितनपट्टिकायां \"सर्वं चीयताम्\" इति चिह्नम् उपयुज्यताम्।';

  @override
  String get helpSelectSongsS2P2 =>
      'चयनं मार्ष्टुं तत् पुनः (\"सर्वचयनं निरस्यताम्\") स्पृश्यताम्।';

  @override
  String get helpSelectSongsS3Heading => 'किं कर्तुं शक्यते';

  @override
  String get helpSelectSongsS3P1 =>
      'चितानि गीतानि एकस्यां ChordPro सञ्चिकायां निर्याप्यन्ताम्।';

  @override
  String get helpSelectSongsS3P2 => 'चितानि गीतानि भवतः गीतकोशात् लुप्यन्ताम्।';

  @override
  String get helpSelectSongsS3P3 =>
      'परिवर्तनं विना चयनविधिं त्यक्तुम् उपरि वामतः X स्पृश्यताम्।';

  @override
  String get titleHelpImport => 'आनयनम्';

  @override
  String get helpImportSummary => 'गीतानि अनुप्रयोगे आनीयन्ताम्';

  @override
  String get helpImportIntro =>
      'आनयनं ChordPro-सञ्चिकाभ्यः सरलपाठसञ्चिकाभ्यः वा गीतानि भवतः गीतकोशे योजयति। पठनं सावधानम् — भग्नाः अपठनीयाः वा सञ्चिकाः सुरक्षितं त्यज्यन्ते, अनुप्रयोगं कदापि न भञ्जन्ति।';

  @override
  String get helpImportS1Heading => 'समर्थिताः सञ्चिकाप्रकाराः';

  @override
  String get helpImportS1P1 =>
      '.cho, .pro, .chordpro, .txt वा इति अन्तयुक्ताः सञ्चिकाः चेतुं शक्यन्ते।';

  @override
  String get helpImportS1P2 =>
      'ChordPro-सञ्चिकाः सरलपाठसञ्चिकाः, याः स्वरसमूहेभ्यः शीर्षलेखेभ्यः च सरलचिह्नानि उपयुञ्जते।';

  @override
  String get helpImportS1P3 =>
      'एका सञ्चिका एकदा अनेकाः सञ्चिकाः वा चेतुं शक्यन्ते।';

  @override
  String get helpImportS2Heading => 'एकस्यां सञ्चिकायाम् अनेकानि गीतानि';

  @override
  String get helpImportS2P1 =>
      'एकस्यां सञ्चिकायां बहूनि गीतानि भवितुम् अर्हन्ति।';

  @override
  String get helpImportS2P2 =>
      'गीतानि पृथक्कर्तुं तेषां मध्ये {new_song} अथवा {ns} स्वतन्त्रपङ्क्तौ स्थाप्यताम्। समग्रगीतपुस्तकनिर्यापणे अपि अयम् एव विभाजकः प्रयुज्यते।';

  @override
  String get helpImportS2P3 =>
      'नूतनं {title: ...} अथवा {t: ...} चिह्नम् आरभ्य अपि गीतानि पृथक् कर्तुं शक्यन्ते। नूतनं गीतं कुत्र आरभते इति अनुप्रयोगः स्वयं जानाति।';

  @override
  String get helpImportS3Heading => 'चिह्नरहिताः पाठसञ्चिकाः';

  @override
  String get helpImportS3P1 =>
      'चिह्नरहिता सरलपाठसञ्चिका एकं गीतम् इति सुरक्षितम् आनीयते।';

  @override
  String get helpImportS3P2 =>
      'अनुप्रयोगः तस्मै \"अनामगीतम्\" इति नाम C स्वरमानं च ददाति।';

  @override
  String get helpImportS3P3 =>
      'तस्य शीर्षकं, स्वरसमूहाः, स्वरमानं, लयः च यदा कदापि उद्घाट्य संशोधयितुं शक्यन्ते।';

  @override
  String get helpImportS4Heading => 'द्विरुक्तानि गीतानि';

  @override
  String get helpImportS4P1 =>
      'यदि गीतस्य शीर्षकं गीतकोशस्थस्य कस्यचित् समानं, तर्हि अनुप्रयोगः भवतः द्विरुक्तिविन्यासम् अनुसरति।';

  @override
  String get helpImportS4P2 =>
      'विद्यमानस्य गीतस्य उपरि लेखनं, नूतनस्य नामपरिवर्तनं, पुरातनस्य नामपरिवर्तनं, प्रतिवारं शीर्षकप्रश्नः वा — एषु एकं चेतुं शक्यते।';

  @override
  String get helpImportS4P3 =>
      'एतत् विन्यासः → सामान्यम् → आनयनविन्यासः इत्यत्र निश्चीयताम्।';

  @override
  String get helpImportS5Heading => 'रक्षणात् पूर्वं परीक्षा';

  @override
  String get helpImportS5P1 =>
      'प्रत्येकम् आनयनं प्रथमं पूर्वदर्शनपटले तिष्ठति।';

  @override
  String get helpImportS5P2 =>
      'प्राप्तानि शीर्षकाणि, गायकाः, स्वरमानानि, पदानि च पठितुं शक्यन्ते; किमपि लेखनात् पूर्वं शीर्षकं संशोधयितुं च।';

  @override
  String get helpImportS5P3 =>
      'यावत् भवान् न दृढीकरोति, तावत् किमपि गीतकोशं न प्राप्नोति।';

  @override
  String get helpImportS6Heading => 'गीतागमनस्य अन्ये मार्गाः';

  @override
  String get helpImportS6P1 =>
      'सञ्चिकाप्रबन्धकात् विद्युत्पत्रात् संवादानुप्रयोगात् वा ChordPro-सञ्चिकायाः उद्घाटनेन सा LyricChord प्राप्नोति, तदेव पूर्वदर्शनं च उद्घाट्यते।';

  @override
  String get helpImportS6P2 =>
      'समीपस्थः सहवादकः सञ्चिकां विना अपि गीतानि प्रेषयितुं शक्नोति — AirQR विषयः दृश्यताम्।';

  @override
  String get titleHelpExport => 'निर्यापणम्';

  @override
  String get helpExportSummary => 'भवतः गीतानि अनुप्रयोगात् बहिः रक्ष्यन्ताम्';

  @override
  String get helpExportIntro =>
      'निर्यापणं गीतानि सञ्चिकारूपेण रक्षति, यस्याः स्थानं भवान् चिनोति। वितरणं तामेव सञ्चिकां साक्षात् अन्यस्मै अनुप्रयोगाय ददाति। सर्वम् अन्तर्जालरहितम् एव — किमपि नोपार्प्यते; तन्त्रस्य सञ्चिकाचयनी वितरणपत्रं वा कार्यं करोति।';

  @override
  String get helpExportS1Heading => 'सर्वगीतनिर्यापणम्';

  @override
  String get helpExportS1P1 =>
      'विन्यासः > सामान्यम् > आनयनम् इत्यत्र गम्यताम्।';

  @override
  String get helpExportS1P2 => '\"सर्वगीतनिर्यापणम्\" स्पृश्यताम्।';

  @override
  String get helpExportS1P3 =>
      'भवतः समग्रं गीतपुस्तकम् एकस्यां ChordPro सञ्चिकायां रक्ष्यते।';

  @override
  String get helpExportS2Heading => 'कतिपयगीतनिर्यापणम् (ChordPro)';

  @override
  String get helpExportS2P1 =>
      'गीतसूच्याम् इष्टानि गीतानि चेतुं दीर्घं नुद्यताम्।';

  @override
  String get helpExportS2P2 => 'उपरितनपट्टिकायां निर्यापणचिह्नं स्पृश्यताम्।';

  @override
  String get helpExportS2P3 =>
      'चितानि गीतानि एकस्यां ChordPro सञ्चिकायां रक्ष्यन्ते।';

  @override
  String get helpExportS3Heading => 'एकगीतनिर्यापणम्';

  @override
  String get helpExportS3P1 =>
      'गीतम् उद्घाट्यताम्, ततः उपरितनपट्टिकायाः सूची (अधिकम्) → \"निर्याप्यताम्\"।';

  @override
  String get helpExportS3P2 =>
      'ChordPro (.chordpro) अथवा PDF (.pdf) चित्वा \"निर्याप्यताम्\" स्पृश्यताम्।';

  @override
  String get helpExportS3P3 =>
      'कुत्र रक्षणीयम् इति चेतुं तन्त्रस्य सञ्चिकारक्षकः उद्घाट्यते।';

  @override
  String get helpExportS3P4 =>
      'यत् किमपि निर्याप्यते, तत् दृश्यमानं स्वरमानम् उपयुङ्क्ते, अतः परिवर्तितस्वरमानं गीतं तस्मिन्नेव स्वरमाने रक्ष्यते।';

  @override
  String get helpExportS4Heading => 'PDF कीदृशम्';

  @override
  String get helpExportS4P1 =>
      'उपरि शीर्षकं, गायकः, स्वरमानं, BPM च; तस्य अधः गिटार्-स्वरसमूहचित्राणि; ततः उपरि स्वरसमूहैः सह पदानि।';

  @override
  String get helpExportS4P2 =>
      'पदानि विन्यासः → अक्षररूपाणि इत्यत्र भवता चितम् अक्षररूपम् उपयुञ्जते, अतः मलयाळम् सम्यक् आकारं प्राप्नोति, पाठः च चयनीयः तिष्ठति।';

  @override
  String get helpExportS4P3 =>
      'पृष्ठं गीतस्य आवश्यकं यावत् एव विस्तृतम् — ह्रस्वपङ्क्तियुक्तस्य गीतस्य कृते सङ्कीर्णं दीर्घं पृष्ठं, यत् दूरभाषपटलं सम्यक् पूरयति — अधिकतमम् A4 विस्तारपर्यन्तम्।';

  @override
  String get helpExportS4P4 =>
      'यदि पङ्क्तिः अद्यापि अतिदीर्घा, तर्हि मध्ये न विभज्येत इति अक्षरपरिमाणं क्रमशः न्यूनीक्रियते (कदापि 9 pt-तः न्यूनं न)।';

  @override
  String get helpExportS5Heading => 'रक्षणस्य स्थाने वितरणम्';

  @override
  String get helpExportS5P1 =>
      'उपरितनपट्टिकायाः सूच्यां \"वितीर्यताम्\" इति अपि अस्ति, तत् सञ्चिकारक्षकस्य स्थाने तन्त्रस्य वितरणपत्रम् उद्घाटयति।';

  @override
  String get helpExportS5P2 =>
      'ChordPro-रूपेण, PDF-रूपेण, AirQR-धारारूपेण वा वितरितुं शक्यते — AirQR विषयः दृश्यताम्।';

  @override
  String get helpExportS5P3 =>
      'गीतसूच्याम् अनेकेषां गीतानां चयनेन समग्रसमूहाय तानि एव वितरणविकल्पानि लभ्यन्ते।';

  @override
  String get titleHelpAirqr => 'AirQR वितरणम्';

  @override
  String get helpAirqrSummary =>
      'छायायन्त्रेण अन्यं दूरभाषं प्रति गीतानि प्रेष्यन्ताम्';

  @override
  String get helpAirqrIntro =>
      'एकस्मिन् पटले QR-सङ्केतानां शृङ्खलां स्फोरयित्वा, अन्यः दूरभाषः छायायन्त्रेण तां पश्यति, एवम् AirQR गीतानि एकस्मात् दूरभाषात् अन्यं प्रति नयति। अन्तर्जालं, ब्लूटूथ्, वाय्-फाय्, तन्तुः, लेखा वा नापेक्ष्यते — केवलं परस्पराभिमुखे द्वे पटले।';

  @override
  String get helpAirqrS1Heading => 'एकगीतप्रेषणम्';

  @override
  String get helpAirqrS1P1 =>
      'गीतम् उद्घाट्यताम्, ततः उपरितनपट्टिकायाः सूची → \"वितीर्यताम्\"।';

  @override
  String get helpAirqrS1P2 =>
      '\"AirQR धारा\" चित्वा \"वितीर्यताम्\" स्पृश्यताम्।';

  @override
  String get helpAirqrS1P3 =>
      'सङ्केताः सद्यः स्फुरितुम् आरभन्ते। दूरभाषं स्थिरं धृत्वा अन्यं पठितुं अनुमन्यताम्।';

  @override
  String get helpAirqrS1P4 =>
      'यथा दृश्यते तथैव गीतं प्रेष्यते, अतः भवता परिवर्तितं स्वरमानम् अपि तेन सह गच्छति।';

  @override
  String get helpAirqrS2Heading => 'अनेकगीतप्रेषणम्';

  @override
  String get helpAirqrS2P1 =>
      'विन्यासः → सामान्यम् → आनयनम् → \"सर्वम् AirQR-मार्गेण\" इति समग्रं गीतपुस्तकं प्रेषयति।';

  @override
  String get helpAirqrS2P2 =>
      'अथवा गीतसूच्यां दीर्घनोदनेन कानिचित् गीतानि चित्वा उपरितनपट्टिकायां QR चिह्नं स्पृश्यताम्।';

  @override
  String get helpAirqrS3Heading => 'ग्रहणम्';

  @override
  String get helpAirqrS3P1 =>
      'ग्राहकदूरभाषे गीतपुस्तकस्य उपरितनपट्टिकायां वीक्षणचिह्नं स्पृश्यताम्, अथवा विन्यासः → सामान्यम् → आनयनम् → \"AirQR-मार्गेण आनयनम्\" इत्यत्र गम्यताम्।';

  @override
  String get helpAirqrS3P2 =>
      'प्रेषकपटलम् अभि छायायन्त्रं नीत्वा प्रतीक्ष्यताम्। खण्डाः यथा आगच्छन्ति तथा फलकं गणयति।';

  @override
  String get helpAirqrS3P3 =>
      'सर्वं प्राप्ते दूरभाषः कम्पते, आनयनपूर्वदर्शनं च उद्घाट्यते, येन रक्षणात् पूर्वं गीतानि परीक्षितुं शक्यन्ते।';

  @override
  String get helpAirqrS3P4 =>
      'केनचित् चित्ररूपेण प्रेषितस्य सङ्केतस्य कृते, चित्रवीथिचिह्नं सजीवछायायन्त्रस्य स्थाने सङ्केतस्य छायाचित्रं पठति।';

  @override
  String get helpAirqrS4Heading => 'स्पष्टपठनाय';

  @override
  String get helpAirqrS4P1 =>
      'गीतं लघुखण्डेषु विभज्य एकैकशः दर्श्यते, मध्ये अतिरिक्ताः संशोधनखण्डाः अपि मिश्रिताः, अतः छायायन्त्रेण त्यक्तं चित्रं पुनरारम्भं विना पूर्यते।';

  @override
  String get helpAirqrS4P2 =>
      'प्रेषकदूरभाषे \"धारावेगः\" इति सर्पकः प्रतिक्षणं 5 तः 25 चित्रपर्यन्तं, आरम्भः 10।';

  @override
  String get helpAirqrS4P3 =>
      'पुरातनः दूरभाषः मन्दप्रकाशं पटलं वा मन्दवेगे सम्यक् पठति। सङ्ख्या न चलति चेत् वेगः न्यूनीक्रियताम्।';

  @override
  String get helpAirqrS4P4 =>
      'उभे पटले स्थिरे दीप्ते च, प्रायः एकवितस्तिदूरे, स्थाप्येताम्।';

  @override
  String get titleHelpAppearance => 'रूपविन्यासाः अक्षररूपाणि च';

  @override
  String get helpAppearanceSummary => 'पत्रं सुपठं क्रियताम्';

  @override
  String get helpAppearanceIntro =>
      'अन्धकारमये रङ्गे पठ्यमानं पत्रं, लेखनपीठे पठ्यमानं पत्रं च न समानं कार्यम्। त्रयः विन्यासाः तत् व्याप्नुवन्ति: रूपविन्यासः, पदाक्षररूपम्, अक्षरपरिमाणं च।';

  @override
  String get helpAppearanceS1Heading => 'रूपविन्यासः';

  @override
  String get helpAppearanceS1P1 =>
      'विन्यासः → रूपविन्यासाः इत्यत्र तन्त्रसिद्धं रूपं, दीप्तरूपं, श्यामरूपं च लभ्यन्ते।';

  @override
  String get helpAppearanceS1P2 =>
      'तन्त्रसिद्धं दूरभाषे यत् विन्यस्तं तत् अनुसरति।';

  @override
  String get helpAppearanceS1P3 =>
      'श्यामरूपं रङ्गे नेत्रयोः सुखदं, विद्युत्कोशस्य च मितव्ययि।';

  @override
  String get helpAppearanceS1P4 => 'चयनं रक्ष्यते सद्यः प्रभवति च।';

  @override
  String get helpAppearanceS2Heading => 'पदाक्षररूपम्';

  @override
  String get helpAppearanceS2P1 =>
      'विन्यासः → अक्षररूपाणि इत्यत्र पदानि येन अक्षररूपेण चित्र्यन्ते तत् चीयते: तन्त्रसिद्धम्, Noto Sans Malayalam, Noto Serif Malayalam, Manjari, Gayathri वा।';

  @override
  String get helpAppearanceS2P2 =>
      'प्रत्येकः विकल्पः आङ्ग्लभाषायां मलयाळभाषायां च सजीवनिदर्शनं दर्शयति, येन चयनात् पूर्वम् अक्षराकाराः दृश्यन्ते।';

  @override
  String get helpAppearanceS2P3 =>
      'मलयाळ-अक्षररूपाणि चिल्लु-संयुक्ताक्षर-स्वरचिह्नानि सम्यक् आकारयन्ति। तन्त्राक्षररूपं प्रायः तथा न करोति।';

  @override
  String get helpAppearanceS2P4 =>
      'एकं चयनं समग्रम् अनुप्रयोगं व्याप्नोति, निर्यापितं PDF अपि तदेव अक्षररूपम् उपयुङ्क्ते।';

  @override
  String get helpAppearanceS2P5 =>
      'अक्षररूपाणि मुक्तानुज्ञया अनुप्रयोगेण सह सन्निहितानि, विषये इति विभागस्य अनुज्ञापृष्ठे च सूचितानि।';

  @override
  String get helpAppearanceS3Heading => 'अक्षरपरिमाणम्';

  @override
  String get helpAppearanceS3P1 =>
      'अक्षराणि बृहत्तराणि लघुतराणि वा कर्तुं पदानि द्वाभ्याम् अङ्गुलीभ्यां सङ्कोच्यन्ताम्, 10 तः 32 पर्यन्तम्।';

  @override
  String get helpAppearanceS3P2 =>
      'एतत् सामान्यगीतपटले पूर्णपटले च कार्यं करोति, सर्पणं च न बाधते।';

  @override
  String get helpAppearanceS3P3 =>
      'श्रुतिपत्रे पञ्च नियतपरिमाणानि अपि सन्ति — 85%, 95%, 100%, 115%, 130% च — यानि सङ्कोचनेन निश्चितं गुणयन्ति। रङ्गपरिमाणम् एकवारं निश्चित्य धारयितुं तानि उपयुज्यन्ताम्।';

  @override
  String get helpTopicNotFound => 'साहाय्यविषयः न प्राप्तः।';

  @override
  String labelAirQrFps(String fps) {
    return '$fps FPS';
  }

  @override
  String get errorStorageLoadSongs => 'गीतानि आनेतुं नाशक्यत।';

  @override
  String get errorStorageOpenSong => 'गीतम् उद्घाटयितुं नाशक्यत।';

  @override
  String get errorStorageFindSongByTitle =>
      'शीर्षकेण गीतम् अन्वेष्टुं नाशक्यत।';

  @override
  String get errorStorageSaveSong => 'गीतं रक्षितुं नाशक्यत।';

  @override
  String get errorStorageUpdateSong => 'गीतम् अद्यतनीकर्तुं नाशक्यत।';

  @override
  String get errorStorageSaveScrollSpeed => 'सर्पणवेगं रक्षितुं नाशक्यत।';

  @override
  String get errorStorageDeleteSong => 'गीतं लोप्तुं नाशक्यत।';

  @override
  String get errorStorageCreateSetlist => 'गीतावलीं स्रष्टुं नाशक्यत।';

  @override
  String get errorStorageUpdateSetlist => 'गीतावलीम् अद्यतनीकर्तुं नाशक्यत।';

  @override
  String get errorStorageUpdateSetlistSongs =>
      'गीतावल्याः गीतानि अद्यतनीकर्तुं नाशक्यत।';

  @override
  String get errorStorageAddSongToSetlist =>
      'गीतं गीतावल्यां योजयितुं नाशक्यत।';

  @override
  String get errorStorageDeleteSetlist => 'गीतावलीं लोप्तुं नाशक्यत।';

  @override
  String get errorDroneErrorChordCue => 'स्वरसमूहसूचनां वादयितुं नाशक्यत।';

  @override
  String get errorDroneErrorPitchCue => 'श्रुतिसूचनां वादयितुं नाशक्यत।';

  @override
  String get errorDroneErrorStartDrone => 'आधारनादम् आरब्धुं नाशक्यत।';

  @override
  String errorMelodyProblemUnreadable(String piece, String token) {
    return '\"$token\" इत्यत्र \"$piece\" पठितुं नाशक्यत।';
  }

  @override
  String errorMelodyProblemNothingToPlay(String token) {
    return '\"$token\" इत्यत्र वादनीयं न किमपि।';
  }

  @override
  String errorCarnaticProblemUnknownTala(String tala) {
    return '\"$tala\" इत्यस्मिन् कति मात्राः इति ज्ञातुं नाशक्यत।';
  }

  @override
  String get errorCarnaticProblemNoNotation => 'पठनीया स्वरलिपिः न प्राप्ता।';

  @override
  String errorCarnaticProblemCyclesOff(int fitting, int total, String tala) {
    return '$total मध्ये $fitting आवर्ताः $tala तालं पूरयन्ति। शेषाणां दैर्घ्यम् अशुद्धम्, अतः काश्चन मात्राः विचलिष्यन्ति।';
  }

  @override
  String get errorCarnaticProblemReadingsTie =>
      'उभयोः पठनयोः (बृहदक्षर/लघ्वक्षर) समानाङ्काः, अतः चयनम् अनुमानमात्रम्। मूलपृष्ठेन सह परीक्ष्यताम्।';

  @override
  String get errorCarnaticProblemNothingReadable => 'पठनीयं न किमपि';

  @override
  String errorCarnaticProblemWrongLength(String got, int wanted) {
    return '$got अक्षरकालाः इति पठ्यते, किन्तु अयं तालः $wanted अपेक्षते';
  }

  @override
  String errorCarnaticProblemUnreadableCharacter(
    String character,
    String token,
  ) {
    return '\"$token\" इत्यत्र \"$character\" पठितुं नाशक्यत';
  }

  @override
  String errorCarnaticProblemInCycle(int cycle, String problem) {
    return 'आवर्तः $cycle: $problem';
  }

  @override
  String get errorWidgetFailed => 'पटलस्य अयं भागः दर्शयितुं नाशक्यत।';

  @override
  String get titleStartupFailed => 'आरम्भः असफलः';

  @override
  String get descStartupFailed =>
      'LyricChord रक्षितं दत्तांशम् उद्घाटयितुं नाशक्नोत्। भवतः गीतानि अपरिवर्तितानि। पुनः प्रयत्यताम्, अथवा समस्यां निवेदयितुं विवरणं प्रतिलिख्यताम्।';

  @override
  String get actionCopyDetails => 'विवरणं प्रतिलिख्यताम्';

  @override
  String get bodyDetailsCopied => 'विवरणं प्रतिलिखितम्';

  @override
  String get tooltipBack => 'प्रत्यागमनम्';

  @override
  String get tooltipAirQrReceiverTorchOn => 'दीपः प्रज्वाल्यताम्';

  @override
  String get tooltipAirQrReceiverTorchOff => 'दीपः शाम्यताम्';

  @override
  String get tooltipAirQrReceiverSwitchCamera => 'छायायन्त्रं परिवर्त्यताम्';

  @override
  String get aboutDetailAuthor => 'लेखकः';

  @override
  String get aboutDetailEmail => 'विद्युत्पत्रम्';

  @override
  String get aboutDetailLicense => 'अनुज्ञापत्रम्';

  @override
  String get aboutDetailWebsite => 'जालस्थानम्';

  @override
  String get aboutDetailPrivacyPolicy => 'गोपनीयतानीतिः';

  @override
  String get aboutDetailAiUsed => 'प्रयुक्ता कृत्रिमबुद्धिः';

  @override
  String get aboutDetailIdeUsed => 'प्रयुक्तं विकाससाधनम्';

  @override
  String get titleSettingsDeleteAllData => 'सर्वदत्तांशलोपः';

  @override
  String get descSettingsDeleteAllDataSubtitle =>
      'सर्वाणि गीतानि गीतावलीः विन्यासं च अपनयतु';

  @override
  String get titleDeleteAllData => 'सर्वं लुप्यताम्?';

  @override
  String get descDeleteAllData =>
      'अस्मिन् दूरभाषे सर्वाणि गीतानि गीतावल्यः टिप्पण्यः विन्यासाः च लोप्स्यन्ते। एतत् प्रत्यावर्तयितुं न शक्यते। ततः LyricChord निदर्शनगीतैः सह नूतनतया आरभते।';

  @override
  String get actionDeleteEverything => 'सर्वं लुप्यताम्';

  @override
  String get bodyAllDataDeleted => 'सर्वः दत्तांशः लुप्तः';

  @override
  String get errorStorageDeleteAllData =>
      'सर्वं दत्तांशं लोप्तुं नाशक्यत। किञ्चित् अद्यापि अवशिष्टं स्यात्।';

  @override
  String get helpSongbookS6Heading => 'नूतनारम्भः';

  @override
  String get helpSongbookS6P1 =>
      'विन्यासः → सर्वदत्तांशलोपः इति अस्मात् दूरभाषात् सर्वाणि गीतानि गीतावलीः टिप्पणीः विन्यासान् च अपनयति। एतत् प्रत्यावर्तयितुं न शक्यते।';

  @override
  String get helpSongbookS6P2 =>
      'ततः LyricChord प्रथमस्थापने इव निदर्शनगीतैः सह आरभते।';

  @override
  String get helpSongbookS6P3 =>
      'गीतानि पुनः अपेक्षितानि स्युः चेत्, प्रथमं तानि निर्याप्यन्ताम् (निर्यापणविषयः दृश्यताम्)।';

  @override
  String get titleSettingsLanguage => 'भाषा';

  @override
  String get labelLanguageSystem => 'तन्त्रसिद्धम्';

  @override
  String get tooltipHideList => 'सूची गोप्यताम्';

  @override
  String get tooltipShowList => 'सूची दर्श्यताम्';

  @override
  String get descResizeListHandle =>
      'गीतसूच्याः विस्तारं परिवर्तयितुं कर्ष्यताम्। गोपयितुं दर्शयितुं वा द्विवारं स्पृश्यताम्।';
}
