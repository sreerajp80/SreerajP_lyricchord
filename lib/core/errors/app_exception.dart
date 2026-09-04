/// Domain exception hierarchy for LyricChord (architecture §10).
///
/// These are thrown by the data and service layers and are meant to be caught
/// at the UI edge and shown as a `SnackBar` — they must never crash the app.
sealed class AppException implements Exception {
  /// Human-readable message safe to show or log.
  final String message;

  /// The underlying error, if any.
  final Object? cause;

  const AppException(this.message, {this.cause});

  /// The friendly message plus the real reason underneath it.
  ///
  /// A failure that only happens on a phone, in a release build, is impossible
  /// to fix from the friendly message alone — that is how the file-open import
  /// bug stayed a dead end. Screens that catch an [AppException] show this
  /// instead, so the reason travels with the report.
  ///
  /// The cause is a database or file error, never song text, so this stays
  /// within the rule that song content is not logged.
  String get debugDetails => cause == null ? message : '$message ($cause)';

  @override
  String toString() => '$runtimeType: $message';
}

/// A database read or write failed.
class StorageException extends AppException {
  const StorageException(super.message, {super.cause});
}

/// A file could not be parsed as ChordPro (used from Phase 7).
class ImportException extends AppException {
  const ImportException(super.message, {super.cause});
}

/// An export (PDF or ChordPro) could not be written (used from Phase 7).
class ExportException extends AppException {
  const ExportException(super.message, {super.cause});
}
