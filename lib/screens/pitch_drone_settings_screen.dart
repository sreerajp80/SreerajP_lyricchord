import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lyricchord/models/pitch_drone_settings.dart';
import 'package:lyricchord/providers/pitch_drone_provider.dart';
import 'package:lyricchord/widgets/pitch_drone_controls.dart';

/// Settings → General → Pitch Pipe & Shruti Drone: configured defaults for root
/// key, interval, master volume, and stage font scale.
class PitchDroneSettingsScreen extends ConsumerWidget {
  const PitchDroneSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(pitchDroneProvider);
    final notifier = ref.read(pitchDroneProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Pitch Pipe & Shruti Drone')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          ListTile(
            leading: const Icon(Icons.music_note),
            title: const Text('Default Key'),
            subtitle: Text(
              'Root pitch for synthesizers: ${settings.selectedKey}',
            ),
            trailing: DropdownButton<String>(
              value: settings.selectedKey,
              underline: const SizedBox.shrink(),
              items: PitchDroneControlsSheet.availableKeys.map((key) {
                return DropdownMenuItem(value: key, child: Text(key));
              }).toList(),
              onChanged: (val) {
                if (val != null) notifier.setSelectedKey(val);
              },
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.graphic_eq),
            title: const Text('Drone Interval'),
            subtitle: Text(
              settings.droneInterval == 'Pa'
                  ? 'Root + Fifth (Pa) — Traditional Tanpura'
                  : 'Root + Fourth (Ma) — Soft Harmonium Drone',
            ),
            trailing: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'Pa', label: Text('Pa')),
                ButtonSegment(value: 'Ma', label: Text('Ma')),
              ],
              selected: {settings.droneInterval},
              onSelectionChanged: (set) {
                if (set.isNotEmpty) notifier.setDroneInterval(set.first);
              },
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.volume_up),
            title: const Text('Volume'),
            subtitle: Slider(
              value: settings.volume,
              onChanged: notifier.setVolume,
            ),
            trailing: Text('${(settings.volume * 100).round()}%'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.format_size),
            title: const Text('Stage Font Scale'),
            subtitle: Text(
              'Stage mode text zoom: ${(settings.fontScaleFactor * 100).round()}%',
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(fontScaleTiers.length, (idx) {
                final scale = fontScaleTiers[idx];
                final isSelected = idx == settings.fontScaleIndex;
                return ChoiceChip(
                  label: Text('${(scale * 100).round()}%'),
                  selected: isSelected,
                  onSelected: (_) => notifier.setFontScaleIndex(idx),
                );
              }),
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    icon: const Icon(Icons.music_note),
                    label: const Text('Test Pitch Cue'),
                    onPressed: () => notifier.playPitchCue(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: Icon(
                      settings.dronePlaying ? Icons.stop : Icons.play_arrow,
                    ),
                    label: Text(
                      settings.dronePlaying ? 'Stop Drone' : 'Test Drone',
                    ),
                    onPressed: () => notifier.toggleDrone(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
