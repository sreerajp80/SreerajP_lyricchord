import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lyricchord/core/constants/app_constants.dart';
import 'package:lyricchord/models/import_settings.dart';
import 'package:lyricchord/providers/theme_mode_provider.dart';

/// Holds the chosen import duplicate strategy and saves changes to `shared_preferences`.
class ImportSettingsNotifier extends Notifier<ImportDuplicateStrategy> {
  @override
  ImportDuplicateStrategy build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final savedName = prefs.getString(AppConstants.prefImportDuplicateStrategy);
    if (savedName != null) {
      for (final strategy in ImportDuplicateStrategy.values) {
        if (strategy.name == savedName) return strategy;
      }
    }
    return ImportDuplicateStrategy.renameImported;
  }

  /// Changes the duplicate strategy and saves it for future imports.
  Future<void> setStrategy(ImportDuplicateStrategy strategy) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(
      AppConstants.prefImportDuplicateStrategy,
      strategy.name,
    );
    state = strategy;
  }
}

/// The current import duplicate strategy provider.
final importSettingsProvider =
    NotifierProvider<ImportSettingsNotifier, ImportDuplicateStrategy>(
      ImportSettingsNotifier.new,
    );
