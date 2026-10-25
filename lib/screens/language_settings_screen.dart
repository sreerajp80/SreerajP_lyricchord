import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:lyricchord/l10n/app_localizations.dart';
import 'package:lyricchord/l10n/language_names.dart';
import 'package:lyricchord/providers/locale_provider.dart';

/// Settings → Language: System default first, then each language by its own
/// name (engineering standard §8.4). The choice is saved and applied at once,
/// without a restart, while this screen is still open.
class LanguageSettingsScreen extends ConsumerWidget {
  const LanguageSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final current =
        ref.watch(localeProvider)?.languageCode ?? systemLanguageValue;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.titleSettingsLanguage)),
      body: SafeArea(
        child: RadioGroup<String>(
          groupValue: current,
          onChanged: (chosen) {
            if (chosen != null) {
              ref.read(localeProvider.notifier).setLanguage(chosen);
            }
          },
          child: ListView(
            children: [
              RadioListTile<String>(
                value: systemLanguageValue,
                secondary: const Icon(Icons.settings_suggest_outlined),
                title: Text(l10n.labelLanguageSystem),
              ),
              for (final code in availableLanguageCodes)
                RadioListTile<String>(
                  value: code,
                  secondary: const Icon(Icons.translate),
                  title: Text(languageEndonym(code)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The current language as the Settings card shows it.
String currentLanguageLabel(AppLocalizations l10n, Locale? chosen) =>
    chosen == null
    ? l10n.labelLanguageSystem
    : languageEndonym(chosen.languageCode);
