import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// One gesture and what it does on the song sheet.
class _GestureInfo {
  const _GestureInfo(this.icon, this.gesture, this.description);

  final IconData icon;
  final String gesture;
  final String description;
}

const List<_GestureInfo> _sheetGestures = [
  _GestureInfo(
    Icons.keyboard_double_arrow_up,
    'Double-tap top half',
    'Faster in Manual mode, or adds 4 bars in Tempo mode.',
  ),
  _GestureInfo(
    Icons.keyboard_double_arrow_down,
    'Double-tap bottom half',
    'Slower in Manual mode, or removes 4 bars in Tempo mode.',
  ),
  _GestureInfo(
    Icons.pan_tool_outlined,
    'Tap with two fingers',
    'Play or pause auto-scroll without touching any button.',
  ),
  _GestureInfo(
    Icons.swipe_vertical,
    'Drag with one finger',
    'Move the sheet by hand; auto-scroll waits and resumes when you lift.',
  ),
  _GestureInfo(
    Icons.zoom_out_map,
    'Pinch with two fingers',
    'Zoom in or out to make the chord and lyric text larger or smaller.',
  ),
  _GestureInfo(
    Icons.fullscreen,
    'Full screen (Stage Mode)',
    'Single tap toggles HUD controls; back gesture leaves full screen.',
  ),
];

/// Opens the Gestures & Shortcuts dialog.
Future<void> showGesturesHelpDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (_) => const GesturesHelpDialog(),
  );
}

/// A friendly dialog explaining all touch gestures that control the song sheet.
class GesturesHelpDialog extends StatelessWidget {
  const GesturesHelpDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.touch_app_outlined,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Gestures & Shortcuts',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Control the sheet hands-free while playing',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 8),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final item in _sheetGestures)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primaryContainer
                                      .withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  item.icon,
                                  size: 20,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.gesture,
                                      style: theme.textTheme.titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      item.description,
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: theme
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.help_outline, size: 18),
                    label: const Text('Help Center'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.push('/settings/help/auto-scroll');
                    },
                  ),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Got it'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
