import 'package:material_ui/material_ui.dart';

import 'package:lyricchord/l10n/app_localizations.dart';

/// Shown in release builds in place of a widget that failed to build
/// (`ErrorWidget.builder`, engineering standard §11.1).
///
/// It shows no error text and has no buttons, so it cannot fail the same way.
/// The message is used only when the app's strings are reachable here; a
/// failure above the app's `Localizations` gets the icon alone.
class SafeErrorFallback extends StatelessWidget {
  const SafeErrorFallback({super.key});

  @override
  Widget build(BuildContext context) {
    final message = Localizations.of<AppLocalizations>(
      context,
      AppLocalizations,
    )?.errorWidgetFailed;
    final scheme = Theme.of(context).colorScheme;

    return Semantics(
      label: message,
      child: ColoredBox(
        color: scheme.surfaceContainerHighest,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, color: scheme.onSurfaceVariant),
                if (message != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: scheme.onSurfaceVariant),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
