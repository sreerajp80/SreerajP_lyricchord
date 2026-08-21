import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lyricchord/models/pitch_drone_settings.dart';
import 'package:lyricchord/models/pitch_tradition.dart';
import 'package:lyricchord/providers/pitch_drone_provider.dart';
import 'package:lyricchord/services/pitch_naming_service.dart';

/// Settings → General → Pitch Pipe & Shruti Box: configured defaults for the
/// singer's Sa, pitch naming, root key, interval, master volume, and stage font
/// scale.
class PitchDroneSettingsScreen extends ConsumerWidget {
  const PitchDroneSettingsScreen({super.key});

  static const PitchNamingService _naming = PitchNamingService();

  /// Which naming to label the **Sa** row with.
  ///
  /// Sa is an Indian idea, so naming it "C" would say nothing. When the user
  /// has picked Western naming they are not using Sa at all, and Carnatic is
  /// the sensible thing to show in that row rather than a bare letter.
  static PitchTradition _saNaming(PitchTradition naming) =>
      naming == PitchTradition.western ? PitchTradition.carnatic : naming;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(pitchDroneProvider);
    final notifier = ref.read(pitchDroneProvider.notifier);
    final naming = settings.pitchNaming;

    Future<void> run(Future<bool> Function() action) async {
      final ok = await action();
      if (ok || !context.mounted) return;
      final message = ref.read(pitchDroneProvider).lastError;
      notifier.clearError();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message ?? 'Could not play the sound.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Pitch Pipe & Shruti Box')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          ListTile(
            leading: const Icon(Icons.translate),
            title: const Text('Pitch naming'),
            subtitle: const Text(
              'How pitches are named when a song does not say',
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: SegmentedButton<PitchTradition>(
              segments: PitchTradition.values
                  .map(
                    (t) => ButtonSegment(value: t, label: Text(t.displayName)),
                  )
                  .toList(),
              selected: {naming},
              onSelectionChanged: (set) {
                if (set.isNotEmpty) notifier.setPitchNaming(set.first);
              },
            ),
          ),
          const Divider(),

          // Sa comes before the Western key: for an Indian song this is the
          // one that matters, and it is the setting people will look for.
          ListTile(
            leading: const Icon(Icons.self_improvement),
            title: const Text('Your Sa (Shruti)'),
            subtitle: Text(
              'Where your Sa sits: ${_naming.shortLabel(settings.saKey, _saNaming(naming))}',
            ),
            trailing: DropdownButton<String>(
              value: settings.saKey,
              underline: const SizedBox.shrink(),
              items: PitchNamingService.chromatic.map((key) {
                return DropdownMenuItem(
                  value: key,
                  child: Text(_naming.shortLabel(key, _saNaming(naming))),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) notifier.setSaKey(val);
              },
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.music_note),
            title: const Text('Default key (Western songs)'),
            subtitle: Text(
              'Used when a song names no key: ${settings.selectedKey}',
            ),
            trailing: DropdownButton<String>(
              value: settings.selectedKey,
              underline: const SizedBox.shrink(),
              items: PitchNamingService.chromatic.map((key) {
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
                  ? 'Sa + Pa (fifth) — the usual shruti box drone'
                  : 'Sa + Ma (fourth) — for ragas that leave out Pa',
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
                    onPressed: () => run(() => notifier.playPitchCue()),
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
                    onPressed: () => run(() => notifier.toggleDrone()),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'The drone holds one steady pair of notes for as long as it is '
              'on. It does not follow the tune.',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
