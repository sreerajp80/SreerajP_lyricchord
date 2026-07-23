import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lyriccord/providers/theme_mode_provider.dart';

/// Settings → Themes: pick System, Light, or Dark.
///
/// The choice is saved right away through [themeModeProvider], so the app
/// changes look while this screen is still open.
class ThemeSettingsScreen extends ConsumerWidget {
  const ThemeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(themeModeProvider);

    RadioListTile<ThemeMode> option(
      String label,
      IconData icon,
      ThemeMode mode,
    ) {
      return RadioListTile<ThemeMode>(
        value: mode,
        secondary: Icon(icon),
        title: Text(label),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Themes')),
      body: RadioGroup<ThemeMode>(
        groupValue: current,
        onChanged: (chosen) {
          if (chosen != null) {
            ref.read(themeModeProvider.notifier).setMode(chosen);
          }
        },
        child: ListView(
          children: [
            option('System theme', Icons.brightness_auto, ThemeMode.system),
            option('Light theme', Icons.light_mode, ThemeMode.light),
            option('Dark theme', Icons.dark_mode, ThemeMode.dark),
          ],
        ),
      ),
    );
  }
}
