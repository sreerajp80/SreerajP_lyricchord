import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

import 'package:lyricchord/l10n/app_localizations.dart';
import 'package:lyricchord/screens/help/help_content.dart';

/// Settings → Help: a hub of help topics, one card each.
///
/// Tapping a card opens that topic's detail page. The back arrow (or system
/// back) returns to the Settings screen.
class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.titleSettingsHelp)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            for (final topic in helpTopics(l10n))
              _HelpCard(
                icon: topic.icon,
                title: topic.title,
                subtitle: topic.summary,
                onTap: () => context.push('/settings/help/${topic.id}'),
              ),
          ],
        ),
      ),
    );
  }
}

/// One tappable help topic card.
class _HelpCard extends StatelessWidget {
  const _HelpCard({
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
