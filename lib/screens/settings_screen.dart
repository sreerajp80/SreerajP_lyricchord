import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:lyricchord/l10n/app_localizations.dart';
import 'package:lyricchord/providers/data_purge_provider.dart';
import 'package:lyricchord/providers/locale_provider.dart';
import 'package:lyricchord/screens/language_settings_screen.dart';

/// Settings: cards that each open their own screen — General (Import and
/// Metronome), Themes, Language, Chords (custom chord notations), Fonts, Help
/// and About —
/// and, last, Delete all data. The back arrow (or system back) returns to the
/// songbook.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  /// Asks first (engineering standard §6.4: a destructive action needs a
  /// clear "Delete" label), then deletes everything and restarts the app.
  Future<void> _confirmDeleteAllData(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final scheme = Theme.of(dialogContext).colorScheme;
        return AlertDialog(
          title: Text(l10n.titleDeleteAllData),
          content: Text(l10n.descDeleteAllData),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.actionCancel),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: scheme.error,
                foregroundColor: scheme.onError,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.actionDeleteEverything),
            ),
          ],
        );
      },
    );
    if (confirmed != true) return;
    // Feedback only; the delete must not wait for it.
    unawaited(HapticFeedback.heavyImpact());
    await ref.read(deleteAllDataProvider)();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.titleSettings)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            _SettingsCard(
              icon: Icons.tune,
              title: l10n.titleSettingsGeneral,
              subtitle: l10n.descSettingsGeneralSubtitle,
              onTap: () => context.push('/settings/general'),
            ),
            _SettingsCard(
              icon: Icons.palette_outlined,
              title: l10n.titleSettingsThemes,
              subtitle: l10n.descSettingsThemesSubtitle,
              onTap: () => context.push('/settings/themes'),
            ),
            _SettingsCard(
              icon: Icons.translate,
              title: l10n.titleSettingsLanguage,
              subtitle: currentLanguageLabel(l10n, ref.watch(localeProvider)),
              onTap: () => context.push('/settings/language'),
            ),
            _SettingsCard(
              icon: Icons.music_note_outlined,
              title: l10n.titleSettingsChords,
              subtitle: l10n.descSettingsChordsSubtitle,
              onTap: () => context.push('/settings/chords'),
            ),
            _SettingsCard(
              icon: Icons.font_download_outlined,
              title: l10n.titleSettingsFonts,
              subtitle: l10n.descSettingsFontsSubtitle,
              onTap: () => context.push('/settings/fonts'),
            ),
            _SettingsCard(
              icon: Icons.help_outline,
              title: l10n.titleSettingsHelp,
              subtitle: l10n.descSettingsHelpSubtitle,
              onTap: () => context.push('/settings/help'),
            ),
            _SettingsCard(
              icon: Icons.info_outline,
              title: l10n.titleAbout,
              subtitle: l10n.descSettingsAboutSubtitle,
              onTap: () => context.push('/about'),
            ),
            _SettingsCard(
              icon: Icons.delete_forever_outlined,
              title: l10n.titleSettingsDeleteAllData,
              subtitle: l10n.descSettingsDeleteAllDataSubtitle,
              onTap: () => _confirmDeleteAllData(context, ref),
              destructive: true,
            ),
          ],
        ),
      ),
    );
  }
}

/// One tappable settings card.
class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.destructive = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  /// Shows the icon and title in the error colour, with no chevron.
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accent = destructive ? scheme.error : scheme.primary;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: ListTile(
        leading: Icon(icon, color: accent),
        title: Text(
          title,
          style: destructive ? TextStyle(color: scheme.error) : null,
        ),
        subtitle: Text(subtitle),
        trailing: destructive ? null : const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
