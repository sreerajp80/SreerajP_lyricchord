import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lyricchord/l10n/app_localizations.dart';

import 'package:lyricchord/models/metronome_settings.dart';
import 'package:lyricchord/providers/metronome_provider.dart';
import 'package:lyricchord/services/metronome_audio_service.dart';
import 'package:lyricchord/services/metronome_calculator.dart';

/// Settings → General → Metronome.
///
/// Turn the metronome on, choose whether each beat flashes and/or clicks, set how
/// loud the click is, pick how many beats make a bar, and hear a test bar without
/// having to open a song. Every choice is saved right away through
/// [metronomeSettingsProvider], so it survives a restart. Everything below the
/// master switch is greyed out until the metronome is enabled.
class MetronomeSettingsScreen extends ConsumerStatefulWidget {
  const MetronomeSettingsScreen({super.key});

  @override
  ConsumerState<MetronomeSettingsScreen> createState() =>
      _MetronomeSettingsScreenState();
}

class _MetronomeSettingsScreenState
    extends ConsumerState<MetronomeSettingsScreen> {
  static const MetronomeCalculator _calc = MetronomeCalculator();

  /// The test plays one bar at a comfortable walking speed.
  static const int _testBpm = 100;

  Timer? _testTimer;
  bool _testing = false;

  @override
  void dispose() {
    _testTimer?.cancel();
    super.dispose();
  }

  /// Plays one bar of clicks so the user can check the sound here and now.
  Future<void> _playTestBar() async {
    if (_testing) return;
    final settings = ref.read(metronomeSettingsProvider);
    final audio = ref.read(metronomeAudioProvider);

    setState(() => _testing = true);
    await audio.prepare();
    await audio.setVolume(settings.volume);

    final gap = Duration(
      microseconds:
          (_calc.secondsPerBeat(_testBpm) * Duration.microsecondsPerSecond)
              .round(),
    );

    var beat = 0;
    void playOne() {
      if (!mounted) return;
      final isAccent =
          settings.accent && _calc.beatInBar(beat, settings.beatsPerBar) == 0;
      if (isAccent) {
        audio.playAccent();
      } else {
        audio.playNormal();
      }
      beat++;
      if (beat < settings.beatsPerBar) {
        _testTimer = Timer(gap, playOne);
      } else {
        _testTimer = Timer(gap, () {
          if (mounted) setState(() => _testing = false);
        });
      }
    }

    playOne();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = ref.watch(metronomeSettingsProvider);
    final notifier = ref.read(metronomeSettingsProvider.notifier);
    final on = settings.enabled;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.titleGeneralMetronome)),
      body: SafeArea(
        child: ListView(
          children: [
            SwitchListTile(
              secondary: const Icon(Icons.av_timer),
              title: Text(l10n.labelMetronomeEnable),
              subtitle: Text(l10n.descMetronomeEnableSubtitle),
              value: settings.enabled,
              onChanged: notifier.setEnabled,
            ),
            const Divider(),
            SwitchListTile(
              secondary: const Icon(Icons.flash_on),
              title: Text(l10n.labelMetronomeFlash),
              subtitle: Text(l10n.descMetronomeFlashSubtitle),
              value: settings.flash,
              onChanged: on ? notifier.setFlash : null,
            ),
            SwitchListTile(
              secondary: const Icon(Icons.volume_up_outlined),
              title: Text(l10n.labelMetronomeClick),
              subtitle: Text(l10n.descMetronomeClickSubtitle),
              value: settings.click,
              onChanged: on ? notifier.setClick : null,
            ),
            ListTile(
              enabled: on && settings.click,
              leading: const Icon(Icons.graphic_eq),
              title: Text(l10n.labelMetronomeClickVolume),
              subtitle: Slider(
                value: settings.volume,
                divisions: 10,
                label: '${(settings.volume * 100).round()}%',
                onChanged: on && settings.click ? notifier.setVolume : null,
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Text(
                l10n.titleMetronomeBarHeading,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: on
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            ListTile(
              enabled: on,
              leading: const Icon(Icons.straighten),
              title: Text(l10n.labelMetronomeBeatsInBar),
              subtitle: Text(l10n.descMetronomeBeatsInBarSubtitle),
              trailing: SegmentedButton<int>(
                segments: [
                  for (final choice in MetronomeSettings.beatsPerBarChoices)
                    ButtonSegment<int>(value: choice, label: Text('$choice')),
                ],
                selected: {settings.beatsPerBar},
                showSelectedIcon: false,
                onSelectionChanged: on
                    ? (selected) => notifier.setBeatsPerBar(selected.first)
                    : null,
              ),
            ),
            SwitchListTile(
              secondary: const Icon(Icons.music_note_outlined),
              title: Text(l10n.labelMetronomeAccent),
              subtitle: Text(l10n.descMetronomeAccentSubtitle),
              value: settings.accent,
              onChanged: on ? notifier.setAccent : null,
            ),
            const Divider(),
            ListTile(
              enabled: on,
              leading: Icon(_testing ? Icons.hourglass_top : Icons.play_arrow),
              title: Text(l10n.labelMetronomeTest),
              subtitle: Text(l10n.descMetronomeTestSubtitle(_testBpm)),
              onTap: on && !_testing ? _playTestBar : null,
            ),
          ],
        ),
      ),
    );
  }
}
