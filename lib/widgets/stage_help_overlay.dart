import 'package:flutter/material.dart';

/// The one-time guide shown the first time Stage Mode is opened.
///
/// Gestures nobody can see are gestures nobody uses, so this lists them once,
/// then never again (the flag lives in `shared_preferences`). Tapping anywhere
/// dismisses it.
class StageHelpOverlay extends StatelessWidget {
  const StageHelpOverlay({super.key, required this.onDismiss});

  /// Called when the user taps to close the guide.
  final VoidCallback onDismiss;

  static const List<(IconData, String, String)> _gestures = [
    (Icons.touch_app_outlined, 'Tap once', 'Show or hide the controls'),
    (Icons.keyboard_double_arrow_up, 'Double-tap up top', 'Faster'),
    (Icons.keyboard_double_arrow_down, 'Double-tap down low', 'Slower'),
    (Icons.pan_tool_outlined, 'Tap with two fingers', 'Play or pause'),
    (Icons.zoom_out_map, 'Pinch', 'Change the text size'),
    (Icons.arrow_back, 'Back', 'Leave full screen'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onDismiss,
      behavior: HitTestBehavior.opaque,
      child: ColoredBox(
        color: Colors.black.withValues(alpha: 0.82),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Full screen',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Only the words, and these gestures.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 24),
                  for (final (icon, gesture, meaning) in _gestures)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        children: [
                          Icon(icon, color: theme.colorScheme.primary),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  gesture,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  meaning,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Tap anywhere to start',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
