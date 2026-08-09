import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lyricchord/models/pitch_drone_settings.dart';
import 'package:lyricchord/providers/pitch_drone_provider.dart';

/// Modal bottom sheet providing controls for Pitch Pipe, Shruti Box drone,
/// and stage text scaling.
class PitchDroneControlsSheet extends ConsumerWidget {
  const PitchDroneControlsSheet({super.key, this.songKey});

  /// Optional initial key of the current song sheet.
  final String? songKey;

  static const List<String> availableKeys = [
    'C',
    'C#',
    'D',
    'D#',
    'E',
    'F',
    'F#',
    'G',
    'G#',
    'A',
    'A#',
    'B',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(pitchDroneProvider);
    final notifier = ref.read(pitchDroneProvider.notifier);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final activeKey = settings.selectedKey;

    return Padding(
      padding: EdgeInsets.only(
        left: 20.0,
        right: 20.0,
        top: 16.0,
        bottom: MediaQuery.of(context).padding.bottom + 20.0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: scheme.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pitch Pipe & Shruti Drone',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Key Selector
          Text(
            'Root Pitch Key',
            style: theme.textTheme.labelMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: availableKeys.map((key) {
                final selected = key == activeKey;
                return Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: ChoiceChip(
                    label: Text(key),
                    selected: selected,
                    onSelected: (_) => notifier.setSelectedKey(key),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Drone Interval Selector
          Row(
            children: [
              Expanded(
                child: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'Pa', label: Text('Root + 5th (Pa)')),
                    ButtonSegment(value: 'Ma', label: Text('Root + 4th (Ma)')),
                  ],
                  selected: {settings.droneInterval},
                  onSelectionChanged: (set) {
                    if (set.isNotEmpty) notifier.setDroneInterval(set.first);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Audio Action Buttons
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  icon: const Icon(Icons.music_note),
                  label: const Text('Pitch Cue (2s)'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () => notifier.playPitchCue(key: activeKey),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  icon: Icon(
                    settings.dronePlaying
                        ? Icons.stop_circle
                        : Icons.graphic_eq,
                    color: settings.dronePlaying
                        ? scheme.error
                        : scheme.primary,
                  ),
                  label: Text(
                    settings.dronePlaying ? 'Stop Drone' : 'Shruti Drone',
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(
                      color: settings.dronePlaying
                          ? scheme.error
                          : scheme.primary,
                      width: 2,
                    ),
                  ),
                  onPressed: () => notifier.toggleDrone(key: activeKey),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Volume Slider
          Row(
            children: [
              Icon(Icons.volume_down, color: scheme.onSurfaceVariant),
              Expanded(
                child: Slider(
                  value: settings.volume,
                  onChanged: (val) => notifier.setVolume(val),
                ),
              ),
              Icon(Icons.volume_up, color: scheme.onSurfaceVariant),
            ],
          ),
          const Divider(),
          const SizedBox(height: 8),

          // 5-Tier Font Scale Selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Stage Text Scale',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              Text(
                '${(settings.fontScaleFactor * 100).round()}%',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(fontScaleTiers.length, (idx) {
              final scale = fontScaleTiers[idx];
              final isSelected = idx == settings.fontScaleIndex;
              return ActionChip(
                label: Text('${(scale * 100).round()}%'),
                backgroundColor: isSelected ? scheme.primaryContainer : null,
                labelStyle: TextStyle(
                  color: isSelected
                      ? scheme.onPrimaryContainer
                      : scheme.onSurface,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                onPressed: () => notifier.setFontScaleIndex(idx),
              );
            }),
          ),
        ],
      ),
    );
  }
}
