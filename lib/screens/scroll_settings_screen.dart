import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lyricchord/providers/auto_scroll_provider.dart';
import 'package:lyricchord/providers/scroll_speed_settings_provider.dart';

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

    return Scaffold(
      appBar: AppBar(title: const Text('Auto-scroll')),
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
                    Text('Starting speed', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      'Manual scrolling starts at this speed for a song you have '
                      'not set a speed for yet.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton.filledTonal(
                          tooltip: 'Slower',
                          onPressed: speed > AutoScrollSettings.minSpeed
                              ? controls.decrease
                              : null,
                          icon: const Icon(Icons.remove),
                        ),
                        SizedBox(
                          width: 96,
                          child: Text(
                            '${speed.toStringAsFixed(2)}x',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleLarge,
                          ),
                        ),
                        IconButton.filledTonal(
                          tooltip: 'Faster',
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
                        child: const Text('Reset to 1.00x'),
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
