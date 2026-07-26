import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lyricchord/models/import_settings.dart';
import 'package:lyricchord/providers/import_settings_provider.dart';

/// Settings → General → Import Settings: configure conflict resolution when importing songs.
class ImportSettingsScreen extends ConsumerWidget {
  const ImportSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentStrategy = ref.watch(importSettingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Import Settings')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'When importing a song whose title matches an existing song in your songbook:',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
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
                        strategy.label,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(strategy.description),
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
    );
  }
}
