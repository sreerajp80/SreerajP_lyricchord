import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lyriccord/providers/theme_mode_provider.dart';

/// The three theme choices (System / Light / Dark) as overflow-menu entries.
///
/// Returned as a list so any screen's `PopupMenuButton` can drop them in next
/// to its own items. A check mark marks the saved choice.
List<PopupMenuEntry<VoidCallback>> buildThemeMenuItems(WidgetRef ref) {
  final current = ref.read(themeModeProvider);

  PopupMenuItem<VoidCallback> item(
    String label,
    IconData icon,
    ThemeMode mode,
  ) {
    return PopupMenuItem<VoidCallback>(
      value: () => ref.read(themeModeProvider.notifier).setMode(mode),
      child: ListTile(
        dense: true,
        contentPadding: EdgeInsets.zero,
        leading: Icon(icon),
        title: Text(label),
        trailing: current == mode ? const Icon(Icons.check) : null,
      ),
    );
  }

  return [
    item('System theme', Icons.brightness_auto, ThemeMode.system),
    item('Light theme', Icons.light_mode, ThemeMode.light),
    item('Dark theme', Icons.dark_mode, ThemeMode.dark),
  ];
}
