import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lyricchord/l10n/app_localizations.dart';

import 'package:lyricchord/providers/theme_mode_provider.dart';

/// Settings → Themes: pick System, Light, or Dark.
///
/// The choice is saved right away through [themeModeProvider], so the app
/// changes look while this screen is still open.
class ThemeSettingsScreen extends ConsumerWidget {
  const ThemeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(themeModeProvider);
    final l10n = AppLocalizations.of(context);

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
      appBar: AppBar(title: Text(l10n.titleSettingsThemes)),
      body: SafeArea(
        child: RadioGroup<ThemeMode>(
          groupValue: current,
          onChanged: (chosen) {
            if (chosen != null) {
              ref.read(themeModeProvider.notifier).setMode(chosen);
            }
          },
          child: ListView(
            children: [
              option(
                l10n.labelThemeSystem,
                Icons.brightness_auto,
                ThemeMode.system,
              ),
              option(l10n.labelThemeLight, Icons.light_mode, ThemeMode.light),
              option(l10n.labelThemeDark, Icons.dark_mode, ThemeMode.dark),
            ],
          ),
        ),
      ),
    );
  }
}
