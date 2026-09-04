import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lyricchord/models/pitch_drone_settings.dart';
import 'package:lyricchord/models/pitch_tradition.dart';
import 'package:lyricchord/providers/pitch_drone_provider.dart';
import 'package:lyricchord/services/pitch_naming_service.dart';

/// Settings → General → Pitch Pipe & Shruti Box.
///
/// The rows are grouped so it is clear which ones belong together. Two of the
/// settings only ever apply to Indian songs, three only to Western songs, and
/// two apply to everything. When they all sat in one flat list, changing pitch
/// naming looked broken: only the Sa row re-labelled itself and nothing else
/// moved, even though naming is exactly what decides which of the two groups a
/// song without a raga or tala will use.
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

    // What a song with no raga or tala falls back to. This is the whole reason
    // the naming choice is not merely cosmetic, so the screen says it out loud.
    final treatsSongsAsIndian = naming != PitchTradition.western;

    // The test buttons must play what the performance sheet would play, so they
    // follow the same rule it uses: an Indian song drones on the singer's Sa in
    // Classical mode, whatever the Western defaults happen to be.
    final testMode = treatsSongsAsIndian
        ? DroneMode.classical
        : settings.droneMode;
    final testKey = treatsSongsAsIndian ? settings.saKey : settings.selectedKey;
    final testKeyLabel = treatsSongsAsIndian
        ? _naming.shortLabel(settings.saKey, _saNaming(naming))
        : settings.selectedKey;
    final testDescription = testMode == DroneMode.western
        ? 'Test plays: Western '
              '${settings.chordQuality.displayName.toLowerCase()} chord '
              'on $testKeyLabel'
        : 'Test plays: Classical drone on $testKeyLabel '
              '+ ${settings.droneInterval}';

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
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            _SettingsSection(
              title: 'Pitch naming',
              caption:
                  'Sets how pitches are named, and how a song is treated when it '
                  'names no raga or tala.',
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: SegmentedButton<PitchTradition>(
                    segments: PitchTradition.values
                        .map(
                          (t) => ButtonSegment(
                            value: t,
                            label: Text(t.displayName),
                          ),
                        )
                        .toList(),
                    selected: {naming},
                    onSelectionChanged: (set) {
                      if (set.isNotEmpty) notifier.setPitchNaming(set.first);
                    },
                  ),
                ),
                _SectionNote(
                  treatsSongsAsIndian
                      ? 'Songs with no raga or tala use the Indian songs '
                            'settings below.'
                      : 'Songs with no raga or tala use the Western songs '
                            'settings below.',
                ),
              ],
            ),

            _SettingsSection(
              title: 'Indian songs (Carnatic / Hindustani)',
              caption:
                  'Used for songs with a raga or tala. These always play the '
                  'Classical shruti drone, on your Sa.',
              highlighted: treatsSongsAsIndian,
              children: [
                // Sa comes first: for an Indian song this is the one that
                // matters, and it is the setting people will look for.
                ListTile(
                  leading: const Icon(Icons.self_improvement),
                  title: const Text('Your Sa (Shruti)'),
                  subtitle: Text(
                    'Where your Sa sits: '
                    '${_naming.shortLabel(settings.saKey, _saNaming(naming))}',
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
                // Always shown. It used to hide whenever the drone mode was
                // Western, but an Indian song ignores the drone mode and always
                // uses this interval, so hiding it was misleading.
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
              ],
            ),

            _SettingsSection(
              title: 'Western songs',
              caption:
                  'Used for songs with no raga or tala, when pitch naming is '
                  'Western.',
              highlighted: !treatsSongsAsIndian,
              children: [
                ListTile(
                  leading: const Icon(Icons.music_note),
                  title: const Text('Default key'),
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
                ListTile(
                  leading: const Icon(Icons.tune),
                  title: const Text('Default drone mode'),
                  subtitle: Text(
                    settings.droneMode == DroneMode.classical
                        ? 'Classical Shruti drone (Sa + Pa/Ma)'
                        : 'Western backing chords (Major / Minor)',
                  ),
                  trailing: SegmentedButton<DroneMode>(
                    segments: const [
                      ButtonSegment(
                        value: DroneMode.classical,
                        label: Text('Classical'),
                      ),
                      ButtonSegment(
                        value: DroneMode.western,
                        label: Text('Western'),
                      ),
                    ],
                    selected: {settings.droneMode},
                    onSelectionChanged: (set) {
                      if (set.isNotEmpty) notifier.setDroneMode(set.first);
                    },
                  ),
                ),
                // Stays on screen even when it is idle. Swapping it out for the
                // interval row was what made the screen look like it was not
                // reacting; greyed out, it can be seen and its reason read.
                ListTile(
                  enabled: settings.droneMode == DroneMode.western,
                  leading: const Icon(Icons.piano),
                  title: const Text('Default chord quality'),
                  subtitle: Text(
                    settings.droneMode == DroneMode.western
                        ? (settings.chordQuality == ChordQuality.major
                              ? 'Major triad (Root + Major 3rd + 5th)'
                              : 'Minor triad (Root + Minor 3rd + 5th)')
                        : 'Used only when the drone mode above is Western',
                  ),
                  trailing: SegmentedButton<ChordQuality>(
                    segments: const [
                      ButtonSegment(
                        value: ChordQuality.major,
                        label: Text('Major'),
                      ),
                      ButtonSegment(
                        value: ChordQuality.minor,
                        label: Text('Minor'),
                      ),
                    ],
                    selected: {settings.chordQuality},
                    onSelectionChanged: settings.droneMode == DroneMode.western
                        ? (set) {
                            if (set.isNotEmpty) {
                              notifier.setChordQuality(set.first);
                            }
                          }
                        : null,
                  ),
                ),
              ],
            ),

            _SettingsSection(
              title: 'Applies to everything',
              caption: 'These affect both traditions.',
              children: [
                ListTile(
                  leading: const Icon(Icons.volume_up),
                  title: const Text('Volume'),
                  subtitle: Slider(
                    value: settings.volume,
                    onChanged: notifier.setVolume,
                  ),
                  trailing: Text('${(settings.volume * 100).round()}%'),
                ),
                ListTile(
                  leading: const Icon(Icons.format_size),
                  title: const Text('Stage Font Scale'),
                  subtitle: Text(
                    'Stage mode text zoom: '
                    '${(settings.fontScaleFactor * 100).round()}%',
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
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
              ],
            ),

            _SettingsSection(
              title: 'Try it out',
              caption: 'The test uses the settings above.',
              children: [
                _SectionNote(testDescription),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          icon: const Icon(Icons.music_note),
                          label: Text(
                            testMode == DroneMode.western
                                ? 'Test Chord Cue'
                                : 'Test Pitch Cue',
                          ),
                          onPressed: () => run(
                            () => notifier.playPitchCue(
                              key: testKey,
                              mode: testMode,
                              quality: settings.chordQuality,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: Icon(
                            settings.dronePlaying
                                ? Icons.stop
                                : Icons.play_arrow,
                          ),
                          label: Text(
                            settings.dronePlaying
                                ? 'Stop Drone'
                                : (testMode == DroneMode.western
                                      ? 'Test Chord Drone'
                                      : 'Test Drone'),
                          ),
                          onPressed: () => run(
                            () => notifier.toggleDrone(
                              key: testKey,
                              mode: testMode,
                              quality: settings.chordQuality,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _SectionNote(
                  testMode == DroneMode.western
                      ? 'The chord drone holds one steady Western backing chord '
                            'for as long as it is on.'
                      : 'The drone holds one steady pair of notes for as long as '
                            'it is on. It does not follow the tune.',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// One titled group of rows, so the reader can see what belongs with what.
///
/// [highlighted] marks the group the current pitch naming will actually use for
/// a song that names no raga or tala. It is a border, not a hidden row: the
/// other group is still there to be read and changed.
class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.caption,
    required this.children,
    this.highlighted = false,
  });

  final String title;
  final String caption;
  final List<Widget> children;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      shape: highlighted
          ? RoundedRectangleBorder(
              side: BorderSide(color: scheme.primary, width: 1.5),
              borderRadius: BorderRadius.circular(12),
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text(
              title,
              style: textTheme.titleSmall?.copyWith(
                color: scheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              caption,
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          ...children,
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

/// A small explaining line inside a section.
class _SectionNote extends StatelessWidget {
  const _SectionNote(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}
