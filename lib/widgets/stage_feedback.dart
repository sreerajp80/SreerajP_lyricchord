import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lyricchord/l10n/app_localizations.dart';
import 'package:lyricchord/providers/stage_mode_provider.dart';
import 'package:lyricchord/services/stage_quiet_mode_service.dart';

/// Asks to unlock Stage Lock and tells the user what happened.
///
/// Shared by the Back button and the on-screen "unlock" chip so both give the
/// same feedback. A plain success needs no message.
Future<void> unlockStageWithFeedback(
  BuildContext context,
  WidgetRef ref,
) async {
  final l10n = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.maybeOf(context);
  final result = await ref
      .read(stageModeProvider.notifier)
      .unlockStageWithAuth(reason: l10n.labelStageUnlockReason);
  if (messenger == null || result.isSuccess) return;
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          result.isDenied
              ? l10n.bodyStageUnlockDenied
              : l10n.bodyStageUnlockedWithoutCheck,
        ),
      ),
    );
}

/// Toggles Stage Quiet Mode and tells the user whether the phone is silent.
Future<void> toggleQuietModeWithFeedback(
  BuildContext context,
  WidgetRef ref,
) async {
  final l10n = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.maybeOf(context);
  final quietService = ref.read(stageQuietModeServiceProvider);
  final result = await ref.read(stageModeProvider.notifier).toggleQuietMode();
  if (messenger == null) return;

  final SnackBar snackBar;
  switch (result) {
    case null:
      snackBar = SnackBar(content: Text(l10n.bodyQuietModeOff));
    case QuietModeResult.on:
      snackBar = SnackBar(content: Text(l10n.bodyQuietModeOn));
    case QuietModeResult.needsAccess:
      snackBar = SnackBar(
        content: Text(l10n.bodyQuietModeNeedsAccess),
        duration: const Duration(seconds: 6),
        action: SnackBarAction(
          label: l10n.actionQuietModeOpenSettings,
          onPressed: quietService.openAccessSettings,
        ),
      );
    case QuietModeResult.unsupported:
      snackBar = SnackBar(content: Text(l10n.bodyQuietModeUnsupported));
    case QuietModeResult.failed:
      snackBar = SnackBar(content: Text(l10n.errorQuietModeFailed));
  }
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(snackBar);
}
