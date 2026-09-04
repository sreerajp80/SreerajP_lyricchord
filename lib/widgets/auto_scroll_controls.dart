import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lyricchord/providers/auto_scroll_provider.dart';
import 'package:lyricchord/providers/stage_mode_provider.dart';

/// The compact auto-scroll controls row shown under the app bar.
///
/// One row: a round Manual / Tempo (M / T) toggle and the full screen button.
/// Everything else is a gesture on the sheet itself — see `ScrollGestureLayer`:
/// a double-tap changes the speed (Manual) or the bar count (Tempo), and a
/// two-finger tap plays or pauses. It only reads and sets [autoScrollProvider];
/// the actual scrolling is driven by the performance screen, which listens to
/// the same provider. The speed read-out, the chord and melody toggles and the
/// status line all live in the parent header, not here.
class AutoScrollControls extends ConsumerWidget {
  const AutoScrollControls({super.key, this.showFullScreenButton = true});

  /// Whether to offer the Stage Mode (full screen) button. Hidden in the
  /// tablet's split view, where full screen would only fill the pane.
  final bool showFullScreenButton;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(autoScrollProvider);
    final controls = ref.read(autoScrollProvider.notifier);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ModeToggle(mode: settings.mode, onChanged: controls.setMode),
        if (showFullScreenButton) ...[
          const SizedBox(width: 8),
          // Same 40 dp circle as the M / T buttons, so the row reads as one
          // set. Tonal rather than filled: going full screen is a normal
          // action, not a loud one.
          SizedBox(
            width: _CircleToggle.size,
            height: _CircleToggle.size,
            child: IconButton.filledTonal(
              tooltip: 'Full screen',
              onPressed: ref.read(stageModeProvider.notifier).enter,
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.fullscreen),
            ),
          ),
        ],
      ],
    );
  }
}

/// The round Manual / Tempo toggle: two circular buttons (M and T). The selected
/// mode is filled with the primary colour; the other is an outlined circle.
class _ModeToggle extends StatelessWidget {
  const _ModeToggle({required this.mode, required this.onChanged});

  final AutoScrollMode mode;
  final ValueChanged<AutoScrollMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _CircleToggle(
          label: 'M',
          tooltip: 'Manual',
          selected: mode == AutoScrollMode.manual,
          onPressed: () => onChanged(AutoScrollMode.manual),
        ),
        const SizedBox(width: 6),
        _CircleToggle(
          label: 'T',
          tooltip: 'Tempo',
          selected: mode == AutoScrollMode.tempo,
          onPressed: () => onChanged(AutoScrollMode.tempo),
        ),
      ],
    );
  }
}

/// A single round mode button. Filled when [selected], outlined otherwise, and
/// always a comfortable tap target.
class _CircleToggle extends StatelessWidget {
  const _CircleToggle({
    required this.label,
    required this.tooltip,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final String tooltip;
  final bool selected;
  final VoidCallback onPressed;

  /// Diameter of the button — kept an easy tap target even though the label is
  /// a single letter. Shared with the full screen button so the whole row of
  /// round controls is one size.
  static const double size = 40;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final child = Text(
      label,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        color: selected ? scheme.onPrimary : scheme.onSurfaceVariant,
      ),
    );

    return Tooltip(
      message: tooltip,
      child: SizedBox(
        width: size,
        height: size,
        child: selected
            ? IconButton.filled(
                onPressed: onPressed,
                style: IconButton.styleFrom(
                  backgroundColor: scheme.primary,
                  foregroundColor: scheme.onPrimary,
                ),
                icon: child,
              )
            : IconButton.outlined(onPressed: onPressed, icon: child),
      ),
    );
  }
}

/// The Manual-mode speed as it is shown to the user: always two decimals plus
/// an `x`, so `0.10x`, `1.00x`, `2.00x`.
///
/// Always two decimals so the width does not jump as the value changes. Used by
/// the gesture layer, which flashes this label whenever a double-tap changes the
/// speed.
String formatSpeedLabel(double speed) => '${speed.toStringAsFixed(2)}x';
