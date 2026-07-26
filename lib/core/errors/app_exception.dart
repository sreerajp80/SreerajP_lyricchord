/// Domain exception hierarchy for LyricChord (architecture §10).
///
/// These are thrown by the data and service layers and are meant to be caught
/// at the UI edge and shown as a `SnackBar` — they must never crash the app.
sealed class AppException implements Exception {
  /// Human-readable message safe to show or log.
  final String message;

  /// The underlying error, if any (kept for debugging; never shown to users).
  final Object? cause;

  const AppException(this.message, {this.cause});

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
