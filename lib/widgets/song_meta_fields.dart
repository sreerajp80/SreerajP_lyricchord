import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:lyricchord/models/pitch_tradition.dart';
import 'package:lyricchord/models/setlist.dart';

/// The editor's Title / Artist / Tradition / Key or Raga+Tala / BPM block.
///
/// Pure UI: it holds no state of its own and knows nothing about storage. The
/// screen owns the controllers and decides what a change means.
class SongMetaFields extends StatelessWidget {
  const SongMetaFields({
    super.key,
    required this.titleController,
    required this.artistController,
    required this.keyController,
    required this.bpmController,
    required this.onTitleChanged,
    required this.onArtistChanged,
    required this.onKeyChanged,
    required this.onBpmChanged,
    this.tradition = PitchTradition.western,
    this.ragaController,
    this.talaController,
    this.onTraditionChanged,
    this.onRagaChanged,
    this.onTalaChanged,
    this.talaWarning,
    this.selectedSetlistId,
    this.availableSetlists = const [],
    this.onSetlistChanged,
  });

  final TextEditingController titleController;
  final TextEditingController artistController;
  final TextEditingController keyController;
  final TextEditingController bpmController;

  final ValueChanged<String> onTitleChanged;
  final ValueChanged<String> onArtistChanged;
  final ValueChanged<String> onKeyChanged;
  final ValueChanged<String> onBpmChanged;

  /// Which notation the song is written in. Western shows a Key field; the two
  /// Indian traditions show Raga and Tala instead, because an Indian sheet is
  /// written in swaras and has no key to transpose.
  final PitchTradition tradition;

  final TextEditingController? ragaController;
  final TextEditingController? talaController;
  final ValueChanged<PitchTradition>? onTraditionChanged;
  final ValueChanged<String>? onRagaChanged;
  final ValueChanged<String>? onTalaChanged;

  /// Shown under the Tala field when the typed tala belongs to the other
  /// tradition. A warning only — the user may know better, so saving is never
  /// blocked.
  final String? talaWarning;

  final int? selectedSetlistId;
  final List<Setlist> availableSetlists;
  final ValueChanged<int?>? onSetlistChanged;

  bool get _isIndian => tradition != PitchTradition.western;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        children: [
          TextField(
            controller: titleController,
            onChanged: onTitleChanged,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Title',
              hintText: 'Song title',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: artistController,
            onChanged: onArtistChanged,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Artist / Band',
              hintText: 'Who performs it',
              border: OutlineInputBorder(),
            ),
          ),
          if (onTraditionChanged != null) ...[
            const SizedBox(height: 12),
            DropdownButtonFormField<PitchTradition>(
              initialValue: tradition,
              decoration: const InputDecoration(
                labelText: 'Notation',
                helperText: 'Western uses chords. Indian uses swaras.',
                prefixIcon: Icon(Icons.library_music_outlined),
                border: OutlineInputBorder(),
              ),
              items: PitchTradition.values
                  .map(
                    (t) => DropdownMenuItem<PitchTradition>(
                      value: t,
                      child: Text(t.displayName),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) onTraditionChanged!(value);
              },
            ),
          ],
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // An Indian song has a raga, not a key: its swaras are already
              // named relative to Sa, so there is nothing to transpose and a
              // key box would only invite a meaningless answer.
              Expanded(
                child: _isIndian
                    ? TextField(
                        controller: ragaController,
                        onChanged: onRagaChanged,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Raga',
                          hintText: 'Kalyani, Yaman',
                          border: OutlineInputBorder(),
                        ),
                      )
                    : TextField(
                        controller: keyController,
                        onChanged: onKeyChanged,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Original key',
                          hintText: 'C, Am, F#m',
                          border: OutlineInputBorder(),
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: bpmController,
                  onChanged: onBpmChanged,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(3),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Tempo (BPM)',
                    hintText: '120',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          if (_isIndian) ...[
            const SizedBox(height: 12),
            TextField(
              controller: talaController,
              onChanged: onTalaChanged,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'Tala',
                hintText: 'Adi, Keherwa',
                helperText: talaWarning,
                helperMaxLines: 3,
                helperStyle: talaWarning == null
                    ? null
                    : TextStyle(color: Theme.of(context).colorScheme.error),
                border: const OutlineInputBorder(),
              ),
            ),
          ],
          if (availableSetlists.isNotEmpty && onSetlistChanged != null) ...[
            const SizedBox(height: 12),
            DropdownButtonFormField<int?>(
              initialValue: selectedSetlistId,
              decoration: const InputDecoration(
                labelText: 'Add to Setlist (Optional)',
                prefixIcon: Icon(Icons.queue_music),
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem<int?>(
                  value: null,
                  child: Text('None (Do not add)'),
                ),
                ...availableSetlists.map(
                  (setlist) => DropdownMenuItem<int?>(
                    value: setlist.id,
                    child: Text(setlist.name),
                  ),
                ),
              ],
              onChanged: onSetlistChanged,
            ),
          ],
        ],
      ),
    );
  }
}
