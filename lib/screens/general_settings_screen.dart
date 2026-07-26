import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Settings → General: groups the Import and Metronome items.
///
/// Each card opens its own screen. The back arrow (or system back) returns to
/// the Settings screen.
class GeneralSettingsScreen extends StatelessWidget {
  const GeneralSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('General')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _GeneralCard(
            icon: Icons.import_export,
            title: 'Import',
            subtitle: 'Bring in ChordPro files as songs',
            onTap: () => context.push('/settings/general/import'),
          ),
          _GeneralCard(
            icon: Icons.tune,
            title: 'Import Settings',
            subtitle: 'Configure duplicate song handling for ChordPro files',
            onTap: () => context.push('/settings/general/import-settings'),
          ),
          _GeneralCard(
            icon: Icons.av_timer,
            title: 'Metronome',
            subtitle: 'Turn the beat on or off',
            onTap: () => context.push('/settings/general/metronome'),
          ),
        ],
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
