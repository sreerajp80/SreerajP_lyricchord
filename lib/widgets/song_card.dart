import 'package:flutter/material.dart';

import 'package:lyriccord/models/song_note.dart';

/// One song in the songbook list: title, artist, a key badge, a BPM badge, a
/// star toggle and a delete button.
///
/// This widget is presentation only — it takes callbacks and knows nothing
/// about the database.
class SongCard extends StatelessWidget {
  const SongCard({
    super.key,
    required this.song,
    required this.onTap,
    required this.onToggleFavorite,
    required this.onDelete,
    this.selected = false,
  });

  /// The song to show.
  final SongNote song;

  /// Called when the card body is tapped (open the song).
  final VoidCallback onTap;

  /// Called when the star button is tapped.
  final VoidCallback onToggleFavorite;

  /// Called when the delete button is tapped.
  final VoidCallback onDelete;

  /// Whether this card is the one open in the tablet detail pane.
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasArtist = song.artist.trim().isNotEmpty;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      color: selected ? theme.colorScheme.primaryContainer : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 4, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      song.title,
                      style: theme.textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (hasArtist) ...[
                      const SizedBox(height: 2),
                      Text(
                        song.artist,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        _Badge(label: song.key),
                        _Badge(label: '${song.bpm} BPM'),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(song.favorite ? Icons.star : Icons.star_border),
                color: song.favorite ? theme.colorScheme.primary : null,
                tooltip: song.favorite
                    ? 'Remove from starred'
                    : 'Add to starred',
                onPressed: onToggleFavorite,
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Delete song',
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A small rounded chip used for the key and BPM values.
class _Badge extends StatelessWidget {
  const _Badge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSecondaryContainer,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
