import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Settings: five cards, each opening its own screen.
///
/// General (Import and Metronome), Themes, Chords (custom chord notations),
/// Fonts, and About. The back arrow (or system back) returns to the songbook.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _SettingsCard(
            icon: Icons.tune,
            title: 'General',
            subtitle: 'Import and metronome',
            onTap: () => context.push('/settings/general'),
          ),
          _SettingsCard(
            icon: Icons.palette_outlined,
            title: 'Themes',
            subtitle: 'System, light, or dark look',
            onTap: () => context.push('/settings/themes'),
          ),
          _SettingsCard(
            icon: Icons.music_note_outlined,
            title: 'Chords',
            subtitle: 'Your own chord notations for the editor',
            onTap: () => context.push('/settings/chords'),
          ),
          _SettingsCard(
            icon: Icons.font_download_outlined,
            title: 'Fonts',
            subtitle: 'Pick the lyric font (English and Malayalam)',
            onTap: () => context.push('/settings/fonts'),
          ),
          _SettingsCard(
            icon: Icons.help_outline,
            title: 'Help',
            subtitle: 'How to use setlists, metronome, export and more',
            onTap: () => context.push('/settings/help'),
          ),
          _SettingsCard(
            icon: Icons.info_outline,
            title: 'About',
            subtitle: 'App version, author, and licenses',
            onTap: () => context.push('/about'),
          ),
        ],
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
