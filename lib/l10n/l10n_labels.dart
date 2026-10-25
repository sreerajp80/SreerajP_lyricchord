import 'package:lyricchord/core/errors/app_exception.dart';
import 'package:lyricchord/core/utils/formatting_locale.dart';
import 'package:lyricchord/l10n/app_localizations.dart';
import 'package:lyricchord/models/carnatic_import_result.dart';
import 'package:lyricchord/models/import_settings.dart';
import 'package:lyricchord/models/lyric_font.dart';
import 'package:lyricchord/models/melody_line.dart';
import 'package:lyricchord/models/pitch_drone_settings.dart';
import 'package:lyricchord/models/pitch_tradition.dart';
import 'package:lyricchord/models/song_title_words.dart';

/// Screen names for model enums.
///
/// Models must not hold UI text, so the words live in the ARB file and these
/// extensions pick the right one. Any screen that shows these values uses them.
extension PitchTraditionLabel on PitchTradition {
  /// The tradition's name, e.g. "Western".
  String label(AppLocalizations l10n) => switch (this) {
    PitchTradition.western => l10n.labelTraditionWestern,
    PitchTradition.carnatic => l10n.labelTraditionCarnatic,
    PitchTradition.hindustani => l10n.labelTraditionHindustani,
  };
}

extension CarnaticCaseReadingLabel on CarnaticCaseReading {
  /// A short description of how letter case was read.
  String label(AppLocalizations l10n) => switch (this) {
    CarnaticCaseReading.duration => l10n.descCarnaticReadingDuration,
    CarnaticCaseReading.octave => l10n.descCarnaticReadingOctave,
  };
}

extension ImportDuplicateStrategyLabel on ImportDuplicateStrategy {
  /// The choice's short name, e.g. "Overwrite".
  String label(AppLocalizations l10n) => switch (this) {
    ImportDuplicateStrategy.overwrite => l10n.labelImportStrategyOverwrite,
    ImportDuplicateStrategy.renameImported =>
      l10n.labelImportStrategyRenameImported,
    ImportDuplicateStrategy.renameExisting =>
      l10n.labelImportStrategyRenameExisting,
    ImportDuplicateStrategy.userSuggested =>
      l10n.labelImportStrategyUserSuggested,
  };

  /// One sentence on what the choice does.
  String description(AppLocalizations l10n) => switch (this) {
    ImportDuplicateStrategy.overwrite => l10n.descImportStrategyOverwrite,
    ImportDuplicateStrategy.renameImported =>
      l10n.descImportStrategyRenameImported,
    ImportDuplicateStrategy.renameExisting =>
      l10n.descImportStrategyRenameExisting,
    ImportDuplicateStrategy.userSuggested =>
      l10n.descImportStrategyUserSuggested,
  };
}

extension ChordQualityLabel on ChordQuality {
  /// "Major" or "Minor".
  String label(AppLocalizations l10n) => switch (this) {
    ChordQuality.major => l10n.labelChordQualityMajor,
    ChordQuality.minor => l10n.labelChordQualityMinor,
  };
}

extension LyricFontLabel on LyricFont {
  /// The name shown in Settings. Font names stay as they are; only the
  /// "System default" choice is app text.
  String displayLabel(AppLocalizations l10n) =>
      this == LyricFont.system ? l10n.labelFontSystemDefault : label;
}

extension AppExceptionText on AppException {
  /// The sentence to show the user. Storage failures get translated words;
  /// any other [AppException] is thrown by the UI itself with words that are
  /// already translated, so its [message] is shown as it is.
  String text(AppLocalizations l10n) => switch (this) {
    StorageException(:final kind) => kind.text(l10n),
    _ => message,
  };
}

extension StorageFailureText on StorageFailure {
  String text(AppLocalizations l10n) => switch (this) {
    StorageFailure.loadSongs => l10n.errorStorageLoadSongs,
    StorageFailure.openSong => l10n.errorStorageOpenSong,
    StorageFailure.findSongByTitle => l10n.errorStorageFindSongByTitle,
    StorageFailure.saveSong => l10n.errorStorageSaveSong,
    StorageFailure.updateSong => l10n.errorStorageUpdateSong,
    StorageFailure.saveScrollSpeed => l10n.errorStorageSaveScrollSpeed,
    StorageFailure.deleteSong => l10n.errorStorageDeleteSong,
    StorageFailure.createSetlist => l10n.errorStorageCreateSetlist,
    StorageFailure.updateSetlist => l10n.errorStorageUpdateSetlist,
    StorageFailure.updateSetlistSongs => l10n.errorStorageUpdateSetlistSongs,
    StorageFailure.addSongToSetlist => l10n.errorStorageAddSongToSetlist,
    StorageFailure.deleteSetlist => l10n.errorStorageDeleteSetlist,
    StorageFailure.deleteAllData => l10n.errorStorageDeleteAllData,
  };
}

extension DroneErrorText on DroneError {
  String text(AppLocalizations l10n) => switch (this) {
    DroneError.chordCue => l10n.errorDroneErrorChordCue,
    DroneError.pitchCue => l10n.errorDroneErrorPitchCue,
    DroneError.startDrone => l10n.errorDroneErrorStartDrone,
  };
}

extension MelodyProblemText on MelodyProblem {
  String text(AppLocalizations l10n) => switch (kind) {
    MelodyProblemKind.unreadablePiece => l10n.errorMelodyProblemUnreadable(
      piece,
      token,
    ),
    MelodyProblemKind.nothingToPlay => l10n.errorMelodyProblemNothingToPlay(
      token,
    ),
  };
}

extension CarnaticProblemText on CarnaticProblem {
  String text(AppLocalizations l10n) {
    final words = switch (this) {
      CarnaticUnknownTala(:final tala) => l10n.errorCarnaticProblemUnknownTala(
        tala,
      ),
      CarnaticNoNotation() => l10n.errorCarnaticProblemNoNotation,
      CarnaticCyclesOffTala(:final fitting, :final total, :final tala) =>
        l10n.errorCarnaticProblemCyclesOff(fitting, total, tala),
      CarnaticReadingsTie() => l10n.errorCarnaticProblemReadingsTie,
      CarnaticNothingReadable() => l10n.errorCarnaticProblemNothingReadable,
      CarnaticWrongLength(:final got, :final wanted) =>
        l10n.errorCarnaticProblemWrongLength(
          // A whole number, or one decimal place for a half.
          formatFixed(got, got == got.roundToDouble() ? 0 : 1, l10n.localeName),
          wanted,
        ),
      CarnaticUnreadableCharacter(:final character, :final token) =>
        l10n.errorCarnaticProblemUnreadableCharacter(character, token),
    };
    final cycle = this.cycle;
    return cycle == null
        ? words
        : l10n.errorCarnaticProblemInCycle(cycle, words);
  }
}

/// The translated row label for an About `details` key from
/// `assets/config/app_config.json` (guideline §1.6). An unknown key shows as
/// itself, so a newly added row still appears until its label is added here
/// and in the ARB file.
String aboutDetailLabel(AppLocalizations l10n, String key) => switch (key) {
  'author' => l10n.aboutDetailAuthor,
  'email' => l10n.aboutDetailEmail,
  'license' => l10n.aboutDetailLicense,
  'website' => l10n.aboutDetailWebsite,
  'privacyPolicy' => l10n.aboutDetailPrivacyPolicy,
  'aiUsed' => l10n.aboutDetailAiUsed,
  'ideUsed' => l10n.aboutDetailIdeUsed,
  _ => key,
};

/// The words saved into a song's title by the app itself ("Untitled Song",
/// "<title> (Copy)"), in the user's language.
SongTitleWords songTitleWords(AppLocalizations l10n) => SongTitleWords(
  untitled: l10n.labelUntitledSong,
  copyOf: l10n.labelSongCopyTitle,
);
