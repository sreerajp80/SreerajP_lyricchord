import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lyricchord/models/pitch_drone_settings.dart';
import 'package:lyricchord/models/pitch_tradition.dart';
import 'package:lyricchord/providers/pitch_drone_provider.dart';
import 'package:lyricchord/services/pitch_naming_service.dart';

/// Modal bottom sheet providing controls for Pitch Pipe, Shruti Box drone,
/// and stage text scaling.
///
/// **The sheet opens on the right pitch for the song.** Which pitch that is
/// depends on the tradition:
///
/// * A **Western** song opens on the song's own key. Its chords sound in G, so
///   the reference tone must be G.
/// * A **Carnatic or Hindustani** song opens on the singer's saved **Sa**. The
///   notation is written relative to Sa, so the written key is not the pitch
///   actually sung — using it would hand the singer the wrong note.
///
/// The chips are also named the way that song's musicians speak: `G`,
/// `5 kattai (G)` or `safed 5 (G)`.
///
/// Choosing a different chip here lasts for this sheet only. It never
/// overwrites the saved default in Settings, because a key picked for one song
/// should not follow the user into the next one.
class PitchDroneControlsSheet extends ConsumerStatefulWidget {
  const PitchDroneControlsSheet({
    super.key,
    this.songKey,
    this.raga,
    this.tala,
  });

  /// The key of the current song sheet, already transposed.
  final String? songKey;

  /// The song's raga, when it names one. Its presence means the song is Indian.
  final String? raga;

  /// The song's tala, when it names one. Says which Indian tradition.
  final String? tala;

  /// The twelve pitches offered, written with sharps.
  static const List<String> availableKeys = PitchNamingService.chromatic;

  @override
  ConsumerState<PitchDroneControlsSheet> createState() =>
      _PitchDroneControlsSheetState();
}

class _PitchDroneControlsSheetState
    extends ConsumerState<PitchDroneControlsSheet> {
  static const PitchNamingService _naming = PitchNamingService();

  /// The pitch this sheet is working on. Local on purpose — see the class doc.
  late String _activeKey;

  /// The song's tradition, settled once when the sheet opens.
  late final PitchTradition _tradition;

  /// True when the opening pitch came from the song rather than from Settings.
  bool _fromSongKey = false;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(pitchDroneProvider);
    _tradition = _naming.detect(
      raga: widget.raga,
      tala: widget.tala,
      fallback: settings.pitchNaming,
    );
    _activeKey = _openingKey(settings);
  }

  /// Works out the pitch to open on.
  String _openingKey(PitchDroneSettings settings) {
    if (_tradition == PitchTradition.western) {
      final fromSong = widget.songKey == null
          ? null
          : _naming.chipForSongKey(widget.songKey!);
      if (fromSong != null) {
        _fromSongKey = true;
        return fromSong;
      }
      return settings.selectedKey;
    }
    // Indian song: the singer's own Sa, not the written key.
    return _naming.chipForSongKey(settings.saKey) ?? settings.saKey;
  }

  /// Moves the sheet to [key], and makes a sounding drone follow it.
  Future<void> _selectKey(String key) async {
    setState(() {
      _activeKey = key;
      _fromSongKey = false;
    });

    final notifier = ref.read(pitchDroneProvider.notifier);
    if (!ref.read(pitchDroneProvider).dronePlaying) return;

    await notifier.stopDrone();
    if (!mounted) return;
    await _run(() => notifier.toggleDrone(key: key));
  }

  Future<void> _run(Future<bool> Function() action) async {
    final ok = await action();
    if (ok || !mounted) return;

    final message = ref.read(pitchDroneProvider).lastError;
    ref.read(pitchDroneProvider.notifier).clearError();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message ?? 'Could not play the sound.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(pitchDroneProvider);
    final notifier = ref.read(pitchDroneProvider.notifier);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final tradition = _tradition;
    final activeKey = _activeKey;

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
                'Pitch Pipe & Shruti Box',
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

          // Where the opening pitch came from, so it is never a mystery.
          Text(
            _sourceLine(tradition, activeKey),
            style: theme.textTheme.labelMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: PitchDroneControlsSheet.availableKeys.map((key) {
                final selected = key == activeKey;
                return Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: ChoiceChip(
                    label: Text(_naming.shortLabel(key, tradition)),
                    selected: selected,
                    onSelected: (_) => _selectKey(key),
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
                    ButtonSegment(value: 'Pa', label: Text('Sa + Pa (5th)')),
                    ButtonSegment(value: 'Ma', label: Text('Sa + Ma (4th)')),
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
                  onPressed: () =>
                      _run(() => notifier.playPitchCue(key: activeKey)),
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
                  onPressed: () =>
                      _run(() => notifier.toggleDrone(key: activeKey)),
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

  /// `Song key: G`, `Your Sa: 5 kattai` or a plain prompt.
  ///
  /// No Western letter on an Indian sheet — see the note on [PitchNamingService]
  /// about which name belongs to which musician.
  String _sourceLine(PitchTradition tradition, String activeKey) {
    if (tradition != PitchTradition.western) {
      return 'Your Sa:  ${_naming.shortLabel(activeKey, tradition)}';
    }
    if (_fromSongKey) return 'Song key:  $activeKey';
    return 'Root Pitch Key';
  }
}
