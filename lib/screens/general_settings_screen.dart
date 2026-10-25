import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:lyricchord/l10n/app_localizations.dart';

/// Settings → General: groups the Import and Metronome items.
///
/// Each card opens its own screen. The back arrow (or system back) returns to
/// the Settings screen.
class GeneralSettingsScreen extends StatelessWidget {
  const GeneralSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.titleSettingsGeneral)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            _GeneralCard(
              icon: Icons.import_export,
              title: l10n.titleGeneralImport,
              subtitle: l10n.descGeneralImportSubtitle,
              onTap: () => context.push('/settings/general/import'),
            ),
            _GeneralCard(
              icon: Icons.tune,
              title: l10n.titleGeneralImportSettings,
              subtitle: l10n.descGeneralImportSettingsSubtitle,
              onTap: () => context.push('/settings/general/import-settings'),
            ),
            _GeneralCard(
              icon: Icons.swap_vert,
              title: l10n.labelInfoAutoScroll,
              subtitle: l10n.descGeneralAutoScrollSubtitle,
              onTap: () => context.push('/settings/general/auto-scroll'),
            ),
            _GeneralCard(
              icon: Icons.av_timer,
              title: l10n.titleGeneralMetronome,
              subtitle: l10n.descGeneralMetronomeSubtitle,
              onTap: () => context.push('/settings/general/metronome'),
            ),
            _GeneralCard(
              icon: Icons.graphic_eq,
              title: l10n.titleDrone,
              subtitle: l10n.descGeneralDroneSubtitle,
              onTap: () => context.push('/settings/general/pitch-drone'),
            ),
          ],
        ),
      ),
    );
  }
}

/// One tappable card on the General screen.
class _GeneralCard extends StatelessWidget {
  const _GeneralCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
