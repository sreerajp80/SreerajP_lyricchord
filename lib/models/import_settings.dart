enum ImportDuplicateStrategy {
  overwrite,
  renameImported,
  renameExisting,
  userSuggested;

  String get label {
    switch (this) {
      case ImportDuplicateStrategy.overwrite:
        return 'Overwrite';
      case ImportDuplicateStrategy.renameImported:
        return 'Rename imported songs';
      case ImportDuplicateStrategy.renameExisting:
        return 'Rename existing songs';
      case ImportDuplicateStrategy.userSuggested:
        return 'User suggested name for imported song';
    }
  }

  String get description {
    switch (this) {
      case ImportDuplicateStrategy.overwrite:
        return 'Replace existing song content with the imported song';
      case ImportDuplicateStrategy.renameImported:
        return 'Automatically rename imported song by adding timestamp to the title';
      case ImportDuplicateStrategy.renameExisting:
        return 'Automatically rename existing song by adding timestamp to the title';
      case ImportDuplicateStrategy.userSuggested:
        return 'Prompt UI for user to type custom name for imported song';
    }
  }
}
