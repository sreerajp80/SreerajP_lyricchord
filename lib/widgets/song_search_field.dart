import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lyricchord/providers/song_list_provider.dart';
import 'package:lyricchord/l10n/app_localizations.dart';

/// The songbook search box. Typing updates [searchQueryProvider], which the
/// list watches; the filtering itself happens in the provider layer.
class SongSearchField extends ConsumerStatefulWidget {
  const SongSearchField({super.key});

  @override
  ConsumerState<SongSearchField> createState() => _SongSearchFieldState();
}

class _SongSearchFieldState extends ConsumerState<SongSearchField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: ref.read(searchQueryProvider));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchQueryProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: TextField(
        controller: _controller,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context).descSongSearchHint,
          prefixIcon: const Icon(Icons.search),
          isDense: true,
          border: const OutlineInputBorder(),
          suffixIcon: query.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.clear),
                  tooltip: AppLocalizations.of(context).tooltipSongSearchClear,
                  onPressed: () {
                    _controller.clear();
                    ref.read(searchQueryProvider.notifier).clear();
                  },
                ),
        ),
        onChanged: (value) =>
            ref.read(searchQueryProvider.notifier).setQuery(value),
      ),
    );
  }
}
