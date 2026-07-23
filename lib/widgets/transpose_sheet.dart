import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lyriccord/providers/performance_provider.dart';
import 'package:lyriccord/services/chord_transposer.dart';

/// Opens the Performance-controls bottom sheet: transpose and show-chords.
///
/// [writtenKey] is the key the song is stored in; the sheet shows the live
/// transposed key while it is open.
Future<void> showTransposeSheet(
  BuildContext context, {
  required String writtenKey,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (_) => TransposeSheet(writtenKey: writtenKey),
  );
}

/// The content of the Performance-controls bottom sheet.
///
/// It watches [performanceSettingsProvider], so the key read-out and the
/// switch stay live while the sheet is open — and the chord sheet behind it
/// updates at the same time.
class TransposeSheet extends ConsumerWidget {
  const TransposeSheet({super.key, required this.writtenKey});

  /// The key the song is stored in ("as written").
  final String writtenKey;

  static const ChordTransposer _transposer = ChordTransposer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settings = ref.watch(performanceSettingsProvider);
    final controls = ref.read(performanceSettingsProvider.notifier);
    final currentKey = _transposer.transposeKey(writtenKey, settings.semitones);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Performance controls', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              runSpacing: 4,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Text('Transpose', style: theme.textTheme.bodyLarge),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton.filledTonal(
                      tooltip: 'Transpose down',
                      onPressed: controls.transposeDown,
                      icon: const Icon(Icons.remove),
                    ),
                    SizedBox(
                      width: 72,
                      child: Text(
                        currentKey,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                    IconButton.filledTonal(
                      tooltip: 'Transpose up',
                      onPressed: controls.transposeUp,
                      icon: const Icon(Icons.add),
                    ),
                    TextButton(
                      onPressed: settings.isTransposed
                          ? controls.resetTranspose
                          : null,
                      child: const Text('Reset'),
                    ),
                  ],
                ),
              ],
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Show chords'),
              value: settings.showChords,
              onChanged: (_) => controls.toggleChords(),
            ),
            const SizedBox(height: 4),
            Text(
              'Tip: pinch the lyrics with two fingers to change the text size.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
