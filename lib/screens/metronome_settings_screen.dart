import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lyricchord/providers/metronome_provider.dart';

/// Settings → General → Metronome: turn the metronome on, and pick whether each
/// beat flashes and/or clicks.
///
/// The choices are saved right away through [metronomeSettingsProvider], so they
/// survive a restart. Flash and Click are greyed out until the metronome is
/// enabled.
class MetronomeSettingsScreen extends ConsumerWidget {
  const MetronomeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(metronomeSettingsProvider);
    final notifier = ref.read(metronomeSettingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Metronome')),
      body: ListView(
        children: [
          SwitchListTile(
            secondary: const Icon(Icons.av_timer),
            title: const Text('Enable metronome'),
            subtitle: const Text('Keep the beat at the song tempo'),
            value: settings.enabled,
            onChanged: notifier.setEnabled,
          ),
          const Divider(),
          SwitchListTile(
            secondary: const Icon(Icons.flash_on),
            title: const Text('Flash'),
            subtitle: const Text('Blink on every beat (good when muted)'),
            value: settings.flash,
            onChanged: settings.enabled ? notifier.setFlash : null,
          ),
          SwitchListTile(
            secondary: const Icon(Icons.volume_up_outlined),
            title: const Text('Click'),
            subtitle: const Text('Play a tick on every beat'),
            value: settings.click,
            onChanged: settings.enabled ? notifier.setClick : null,
          ),
        ],
      ),
    );
  }
}
