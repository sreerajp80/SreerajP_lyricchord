import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// The editor's Title / Artist / Key / BPM block.
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
  });

  final TextEditingController titleController;
  final TextEditingController artistController;
  final TextEditingController keyController;
  final TextEditingController bpmController;

  final ValueChanged<String> onTitleChanged;
  final ValueChanged<String> onArtistChanged;
  final ValueChanged<String> onKeyChanged;
  final ValueChanged<String> onBpmChanged;

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
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
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
        ],
      ),
    );
  }
}
