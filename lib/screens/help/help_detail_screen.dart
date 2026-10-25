import 'package:material_ui/material_ui.dart';

import 'package:lyricchord/l10n/app_localizations.dart';
import 'package:lyricchord/screens/help/help_content.dart';

/// Settings → Help → one topic. Renders a [HelpTopic] as an intro paragraph
/// followed by titled sections with bullet points.
///
/// If [topicId] is unknown, it shows a safe "not found" message instead of
/// crashing.
class HelpDetailScreen extends StatelessWidget {
  const HelpDetailScreen({super.key, required this.topicId});

  final String topicId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final topic = helpTopicById(l10n, topicId);
    final theme = Theme.of(context);

    if (topic == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.titleSettingsHelp)),
        body: Center(child: Text(l10n.helpTopicNotFound)),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(topic.title)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            Row(
              children: [
                Icon(topic.icon, color: theme.colorScheme.primary, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    topic.title,
                    style: theme.textTheme.headlineSmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              topic.intro,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 8),
            for (final section in topic.sections)
              _SectionBlock(section: section),
          ],
        ),
      ),
    );
  }
}

/// One heading plus its gesture items and bullet points.
class _SectionBlock extends StatelessWidget {
  const _SectionBlock({required this.section});

  final HelpSection section;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gestureItems = section.gestureItems;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(
          section.heading,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        if (gestureItems != null && gestureItems.isNotEmpty) ...[
          for (final item in gestureItems) _GestureRow(item: item),
          const SizedBox(height: 4),
        ],
        for (final point in section.points) _Bullet(text: point),
      ],
    );
  }
}

/// A gesture item row with icon, title, and description.
class _GestureRow extends StatelessWidget {
  const _GestureRow({required this.item});

  final GestureHelpItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Icon(item.icon, color: theme.colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  item.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A single bullet line.
class _Bullet extends StatelessWidget {
  const _Bullet({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6, right: 10),
            child: Icon(
              Icons.circle,
              size: 6,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
