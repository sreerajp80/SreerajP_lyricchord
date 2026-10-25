import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lyricchord/l10n/app_localizations.dart';
import 'package:lyricchord/l10n/l10n_labels.dart';

import 'package:lyricchord/models/import_settings.dart';
import 'package:lyricchord/providers/import_settings_provider.dart';

/// Settings → General → Import Settings: configure conflict resolution when importing songs.
class ImportSettingsScreen extends ConsumerWidget {
  const ImportSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentStrategy = ref.watch(importSettingsProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.titleGeneralImportSettings)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                l10n.descImportSettingsQuestion,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              clipBehavior: Clip.antiAlias,
              child: RadioGroup<ImportDuplicateStrategy>(
                groupValue: currentStrategy,
                onChanged: (selected) {
                  if (selected != null) {
                    ref
                        .read(importSettingsProvider.notifier)
                        .setStrategy(selected);
                  }
                },
                child: Column(
                  children: [
                    for (final strategy in ImportDuplicateStrategy.values) ...[
                      RadioListTile<ImportDuplicateStrategy>(
                        value: strategy,
                        title: Text(
                          strategy.label(l10n),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(strategy.description(l10n)),
                      ),
                      if (strategy != ImportDuplicateStrategy.values.last)
                        const Divider(height: 1),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
