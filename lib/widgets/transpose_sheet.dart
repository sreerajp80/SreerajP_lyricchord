import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lyricchord/l10n/app_localizations.dart';

import 'package:lyricchord/providers/performance_provider.dart';
import 'package:lyricchord/services/chord_transposer.dart';

/// Opens the Performance-controls bottom sheet: transpose and show-chords.
///
/// [writtenKey] is the key the song is stored in; the sheet shows the live
/// transposed key while it is open.
///
/// Pass `showTranspose: false` for a song written in swaras. See
/// [TransposeSheet.showTranspose].
///
/// Pass `showMelodyToggle: true` only for a song that has `{melody}` lines. See
/// [TransposeSheet.showMelodyToggle].
Future<void> showTransposeSheet(
  BuildContext context, {
  required String writtenKey,
  bool showTranspose = true,
  bool showMelodyToggle = false,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (_) => TransposeSheet(
      writtenKey: writtenKey,
      showTranspose: showTranspose,
      showMelodyToggle: showMelodyToggle,
    ),
  );
}

/// The content of the Performance-controls bottom sheet.
///
/// It watches [performanceSettingsProvider], so the key read-out and the
/// switch stay live while the sheet is open — and the chord sheet behind it
/// updates at the same time.
class TransposeSheet extends ConsumerWidget {
  const TransposeSheet({
    super.key,
    required this.writtenKey,
    this.showTranspose = true,
    this.showMelodyToggle = false,
  });

  /// The key the song is stored in ("as written").
  final String writtenKey;

  /// False for a song written in swaras, which hides the transpose row.
  ///
  /// A swara is already named relative to Sa, so moving Sa moves every swara
  /// with it and the written notation never changes — the buttons would do
  /// nothing. Show chords stays, because hiding the swara markers is still
  /// useful.
  final bool showTranspose;

  /// True when the song has `{melody}` lines, which adds the Show melody
  /// switch. A song with no tune does not get a switch that does nothing.
  final bool showMelodyToggle;

  static const ChordTransposer _transposer = ChordTransposer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settings = ref.watch(performanceSettingsProvider);
    final controls = ref.read(performanceSettingsProvider.notifier);
    final currentKey = _transposer.transposeKey(writtenKey, settings.semitones);
    final l10n = AppLocalizations.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.actionPerfControls, style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            if (showTranspose)
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                runSpacing: 4,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Text(
                      l10n.labelTranspose,
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton.filledTonal(
                        tooltip: l10n.tooltipTransposeDown,
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
                        tooltip: l10n.tooltipTransposeUp,
                        onPressed: controls.transposeUp,
                        icon: const Icon(Icons.add),
                      ),
                      TextButton(
                        onPressed: settings.isTransposed
                            ? controls.resetTranspose
                            : null,
                        child: Text(l10n.actionReset),
                      ),
                    ],
                  ),
                ],
              ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.tooltipPerfShowChords),
              value: settings.showChords,
              onChanged: (_) => controls.toggleChords(),
            ),
            if (showMelodyToggle)
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.tooltipPerfShowMelody),
                subtitle: Text(l10n.descTransposeMelodySubtitle),
                value: settings.showMelody,
                onChanged: (_) => controls.toggleMelody(),
              ),
            const SizedBox(height: 4),
            Text(
              l10n.descTransposePinchTip,
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
