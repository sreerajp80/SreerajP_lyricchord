import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lyricchord/l10n/app_localizations.dart';

import 'package:lyricchord/providers/auto_scroll_provider.dart';
import 'package:lyricchord/providers/scroll_speed_settings_provider.dart';
import 'package:lyricchord/widgets/auto_scroll_controls.dart';

/// Settings → General → Auto-scroll: the speed a song starts scrolling at.
///
/// Only songs that have never had a speed set follow this. A song you have
/// already set a speed for keeps its own.
class ScrollSettingsScreen extends ConsumerWidget {
  const ScrollSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final speed = ref.watch(defaultScrollSpeedProvider);
    final controls = ref.read(defaultScrollSpeedProvider.notifier);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.labelInfoAutoScroll)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.titleScrollStartingSpeed,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.descScrollStartingSpeedNote,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton.filledTonal(
                          tooltip: l10n.tooltipStageSlower,
                          onPressed: speed > AutoScrollSettings.minSpeed
                              ? controls.decrease
                              : null,
                          icon: const Icon(Icons.remove),
                        ),
                        SizedBox(
                          width: 96,
                          child: Text(
                            formatSpeedLabel(speed, l10n.localeName),
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleLarge,
                          ),
                        ),
                        IconButton.filledTonal(
                          tooltip: l10n.tooltipStageFaster,
                          onPressed: speed < AutoScrollSettings.maxSpeed
                              ? controls.increase
                              : null,
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: speed == AutoScrollSettings.defaultSpeed
                            ? null
                            : controls.reset,
                        child: Text(
                          l10n.actionScrollResetTo(
                            formatSpeedLabel(
                              AutoScrollSettings.defaultSpeed,
                              l10n.localeName,
                            ),
                          ),
                        ),
                      ),
                    ),
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
