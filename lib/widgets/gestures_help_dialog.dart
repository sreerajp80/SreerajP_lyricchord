import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:lyricchord/l10n/app_localizations.dart';

/// One gesture and what it does on the song sheet.
class _GestureInfo {
  const _GestureInfo(this.icon, this.gesture, this.description);

  final IconData icon;
  final String gesture;
  final String description;
}

List<_GestureInfo> _sheetGestures(AppLocalizations l10n) => [
  _GestureInfo(
    Icons.keyboard_double_arrow_up,
    l10n.labelGesturesDoubleTapTop,
    l10n.descGesturesDoubleTapTopMeaning,
  ),
  _GestureInfo(
    Icons.keyboard_double_arrow_down,
    l10n.labelGesturesDoubleTapBottom,
    l10n.descGesturesDoubleTapBottomMeaning,
  ),
  _GestureInfo(
    Icons.pan_tool_outlined,
    l10n.labelStageHelpTwoFingers,
    l10n.descGesturesTwoFingersMeaning,
  ),
  _GestureInfo(
    Icons.swipe_vertical,
    l10n.labelGesturesDrag,
    l10n.descGesturesDragMeaning,
  ),
  _GestureInfo(
    Icons.zoom_out_map,
    l10n.labelGesturesPinch,
    l10n.descGesturesPinchMeaning,
  ),
  _GestureInfo(
    Icons.fullscreen,
    l10n.labelGesturesFullScreen,
    l10n.descGesturesFullScreenMeaning,
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
    final l10n = AppLocalizations.of(context);

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
                          l10n.titleGestures,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          l10n.descGesturesSubtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: l10n.actionClose,
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
                      for (final item in _sheetGestures(l10n))
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
                    label: Text(l10n.actionGesturesHelpCenter),
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.push('/settings/help/auto-scroll');
                    },
                  ),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(l10n.actionGesturesGotIt),
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
