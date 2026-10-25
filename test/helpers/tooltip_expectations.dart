import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Fails when an icon-only control on screen has no tooltip (engineering
/// standard §7.8). Call it after pumping a screen in its widget test.
///
/// Checks every [IconButton], [FloatingActionButton] and [PopupMenuButton]
/// in the tree. A [FloatingActionButton.extended] shows a text label, so it is
/// skipped.
void expectAllIconButtonsHaveTooltips(WidgetTester tester) {
  for (final button in tester.widgetList<IconButton>(find.byType(IconButton))) {
    expect(
      button.tooltip?.trim().isNotEmpty ?? false,
      isTrue,
      reason: 'IconButton with icon ${button.icon} has no tooltip',
    );
  }

  for (final fab in tester.widgetList<FloatingActionButton>(
    find.byType(FloatingActionButton),
  )) {
    if (fab.isExtended) continue;
    expect(
      fab.tooltip?.trim().isNotEmpty ?? false,
      isTrue,
      reason: 'FloatingActionButton with child ${fab.child} has no tooltip',
    );
  }

  for (final menu in tester.widgetList<PopupMenuButton<dynamic>>(
    find.byWidgetPredicate((widget) => widget is PopupMenuButton),
  )) {
    expect(
      menu.tooltip?.trim().isNotEmpty ?? false,
      isTrue,
      reason: 'PopupMenuButton with icon ${menu.icon} has no tooltip',
    );
  }
}
