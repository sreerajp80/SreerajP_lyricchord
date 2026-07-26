import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lyricchord/providers/song_list_provider.dart';

/// Modal bottom sheet to pick songs from the songbook to add to a setlist.
class SetlistSongPickerSheet extends ConsumerStatefulWidget {
  const SetlistSongPickerSheet({
    super.key,
    required this.alreadySelectedSongIds,
  });

  final List<int> alreadySelectedSongIds;

  static Future<List<int>?> show(
    BuildContext context, {
    required List<int> alreadySelectedSongIds,
  }) {
    return showModalBottomSheet<List<int>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => SetlistSongPickerSheet(
        alreadySelectedSongIds: alreadySelectedSongIds,
      ),
    );
  }

  @override
  ConsumerState<SetlistSongPickerSheet> createState() =>
      _SetlistSongPickerSheetState();
}

class _SetlistSongPickerSheetState
    extends ConsumerState<SetlistSongPickerSheet> {
  late Set<int> _selectedIds;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selectedIds = Set.from(widget.alreadySelectedSongIds);
  }

  @override
  Widget build(BuildContext context) {
    final songsAsync = ref.watch(songsStreamProvider);
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Add Songs to Setlist',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () =>
                        Navigator.of(context).pop(_selectedIds.toList()),
                    child: Text('Done (${_selectedIds.length})'),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search songs...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 12,
                  ),
                ),
                onChanged: (val) =>
                    setState(() => _searchQuery = val.trim().toLowerCase()),
              ),
            ),
            const Divider(),
            Expanded(
              child: songsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) =>
                    Center(child: Text('Error loading songs: $err')),
                data: (allSongs) {
                  final filtered = _searchQuery.isEmpty
                      ? allSongs
                      : allSongs.where((s) {
                          return s.title.toLowerCase().contains(_searchQuery) ||
                              s.artist.toLowerCase().contains(_searchQuery);
                        }).toList();

                  if (filtered.isEmpty) {
                    return const Center(child: Text('No songs found'));
                  }

                  return ListView.builder(
                    controller: scrollController,
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final song = filtered[index];
                      final isChecked = _selectedIds.contains(song.id);
                      return CheckboxListTile(
                        value: isChecked,
                        title: Text(
                          song.title,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: song.artist.isNotEmpty
                            ? Text(song.artist)
                            : null,
                        secondary: Text(
                          song.key,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        onChanged: (val) {
                          setState(() {
                            if (val == true) {
                              _selectedIds.add(song.id);
                            } else {
                              _selectedIds.remove(song.id);
                            }
                          });
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
