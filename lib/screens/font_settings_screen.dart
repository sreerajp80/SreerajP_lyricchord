import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lyriccord/models/lyric_font.dart';
import 'package:lyriccord/providers/lyric_font_provider.dart';

/// Settings → Fonts: pick the font used for lyric text.
///
/// The choice is saved right away through [lyricFontProvider], so the
/// performance view, the editor's lyric box, and the exported PDF all switch to
/// it. Each option shows a small preview (English + Malayalam) rendered in that
/// font so the letters are visible before choosing.
class FontSettingsScreen extends ConsumerWidget {
  const FontSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(lyricFontProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Fonts')),
      body: RadioGroup<LyricFont>(
        groupValue: current,
        onChanged: (chosen) {
          if (chosen != null) {
            ref.read(lyricFontProvider.notifier).setFont(chosen);
          }
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Text(
                'Used for song lyrics on screen and in exported PDFs. '
                'Malayalam always prints in PDFs, even with an English font.',
              ),
            ),
            for (final font in LyricFont.values)
              RadioListTile<LyricFont>(
                value: font,
                isThreeLine: true,
                title: Text(font.label),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    font.previewText,
                    style: TextStyle(
                      // A null family falls back to the theme default font.
                      fontFamily: font.family,
                      fontSize: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
