import 'package:material_ui/material_ui.dart';
import 'package:lyricchord/l10n/app_localizations.dart';

/// The one-time guide shown the first time Stage Mode is opened.
///
/// Gestures nobody can see are gestures nobody uses, so this lists them once,
/// then never again (the flag lives in `shared_preferences`). Tapping anywhere
/// dismisses it.
class StageHelpOverlay extends StatelessWidget {
  const StageHelpOverlay({super.key, required this.onDismiss});

  /// Called when the user taps to close the guide.
  final VoidCallback onDismiss;

  static List<(IconData, String, String)> _gestures(AppLocalizations l10n) => [
    (
      Icons.touch_app_outlined,
      l10n.labelStageHelpTapOnce,
      l10n.descStageHelpTapOnceMeaning,
    ),
    (
      Icons.keyboard_double_arrow_up,
      l10n.labelStageHelpDoubleTapTop,
      l10n.tooltipStageFaster,
    ),
    (
      Icons.keyboard_double_arrow_down,
      l10n.labelStageHelpDoubleTapBottom,
      l10n.tooltipStageSlower,
    ),
    (
      Icons.pan_tool_outlined,
      l10n.labelStageHelpTwoFingers,
      l10n.descStageHelpTwoFingersMeaning,
    ),
    (
      Icons.zoom_out_map,
      l10n.labelStageHelpPinch,
      l10n.descStageHelpPinchMeaning,
    ),
    (Icons.arrow_back, l10n.labelStageHelpBack, l10n.descStageHelpBackMeaning),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

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
                    l10n.tooltipAutoScrollFullScreen,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.descStageHelpSubtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 24),
                  for (final (icon, gesture, meaning) in _gestures(l10n))
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
                      l10n.descStageHelpStart,
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
