import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lyricchord/l10n/app_localizations.dart';
import 'package:lyricchord/l10n/l10n_labels.dart';

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
    final l10n = AppLocalizations.of(context);

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
        ? (settings.chordQuality == ChordQuality.major
              ? l10n.descDroneSettingsTestWesternMajor(testKeyLabel)
              : l10n.descDroneSettingsTestWesternMinor(testKeyLabel))
        : l10n.descDroneSettingsTestClassical(
            testKeyLabel,
            settings.droneInterval,
          );

    Future<void> run(Future<bool> Function() action) async {
      final ok = await action();
      if (ok || !context.mounted) return;
      final message = ref.read(pitchDroneProvider).lastError;
      notifier.clearError();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message?.text(l10n) ?? l10n.errorDroneCouldNotPlay),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.titleDrone)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            _SettingsSection(
              title: l10n.titleDroneSettingsNaming,
              caption: l10n.descDroneSettingsNamingCaption,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: SegmentedButton<PitchTradition>(
                    segments: PitchTradition.values
                        .map(
                          (t) => ButtonSegment(
                            value: t,
                            label: Text(t.label(l10n)),
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
                      ? l10n.descDroneSettingsUsesIndian
                      : l10n.descDroneSettingsUsesWestern,
                ),
              ],
            ),

            _SettingsSection(
              title: l10n.titleDroneSettingsIndianSongs,
              caption: l10n.descDroneSettingsIndianCaption,
              highlighted: treatsSongsAsIndian,
              children: [
                // Sa comes first: for an Indian song this is the one that
                // matters, and it is the setting people will look for.
                ListTile(
                  leading: const Icon(Icons.self_improvement),
                  title: Text(l10n.labelDroneSettingsYourSa),
                  subtitle: Text(
                    l10n.descDroneSettingsSaSits(
                      _naming.shortLabel(settings.saKey, _saNaming(naming)),
                    ),
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
                  title: Text(l10n.labelDroneSettingsInterval),
                  subtitle: Text(
                    settings.droneInterval == 'Pa'
                        ? l10n.descDroneSettingsIntervalPa
                        : l10n.descDroneSettingsIntervalMa,
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
              title: l10n.titleDroneSettingsWesternSongs,
              caption: l10n.descDroneSettingsWesternCaption,
              highlighted: !treatsSongsAsIndian,
              children: [
                ListTile(
                  leading: const Icon(Icons.music_note),
                  title: Text(l10n.labelDroneSettingsDefaultKey),
                  subtitle: Text(
                    l10n.descDroneSettingsDefaultKeySubtitle(
                      settings.selectedKey,
                    ),
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
                  title: Text(l10n.labelDroneSettingsDefaultMode),
                  subtitle: Text(
                    settings.droneMode == DroneMode.classical
                        ? l10n.descDroneSettingsModeClassicalNote
                        : l10n.descDroneSettingsModeWesternNote,
                  ),
                  trailing: SegmentedButton<DroneMode>(
                    segments: [
                      ButtonSegment(
                        value: DroneMode.classical,
                        label: Text(l10n.labelDroneSettingsClassical),
                      ),
                      ButtonSegment(
                        value: DroneMode.western,
                        label: Text(l10n.labelTraditionWestern),
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
                  title: Text(l10n.labelDroneSettingsDefaultQuality),
                  subtitle: Text(
                    settings.droneMode == DroneMode.western
                        ? (settings.chordQuality == ChordQuality.major
                              ? l10n.descDroneSettingsMajorNote
                              : l10n.descDroneSettingsMinorNote)
                        : l10n.descDroneSettingsQualityOnlyWestern,
                  ),
                  trailing: SegmentedButton<ChordQuality>(
                    segments: [
                      for (final quality in ChordQuality.values)
                        ButtonSegment(
                          value: quality,
                          label: Text(quality.label(l10n)),
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
              title: l10n.titleDroneSettingsEverything,
              caption: l10n.descDroneSettingsEverythingCaption,
              children: [
                ListTile(
                  leading: const Icon(Icons.volume_up),
                  title: Text(l10n.labelDroneSettingsVolume),
                  subtitle: Slider(
                    value: settings.volume,
                    onChanged: notifier.setVolume,
                  ),
                  trailing: Text('${(settings.volume * 100).round()}%'),
                ),
                ListTile(
                  leading: const Icon(Icons.format_size),
                  title: Text(l10n.labelDroneSettingsFontScale),
                  subtitle: Text(
                    l10n.descDroneSettingsFontScaleSubtitle(
                      (settings.fontScaleFactor * 100).round(),
                    ),
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
              title: l10n.titleDroneSettingsTryIt,
              caption: l10n.descDroneSettingsTryItCaption,
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
                                ? l10n.actionDroneSettingsTestChordCue
                                : l10n.actionDroneSettingsTestPitchCue,
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
                                ? l10n.actionDroneStop
                                : (testMode == DroneMode.western
                                      ? l10n.actionDroneSettingsTestChordDrone
                                      : l10n.actionDroneSettingsTestDrone),
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
                      ? l10n.descDroneSettingsChordDroneNote
                      : l10n.descDroneSettingsDroneNote,
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
