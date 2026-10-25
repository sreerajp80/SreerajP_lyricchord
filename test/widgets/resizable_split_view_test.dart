import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lyricchord/core/constants/app_constants.dart';
import 'package:lyricchord/providers/split_view_provider.dart';
import 'package:lyricchord/providers/theme_mode_provider.dart';
import 'package:lyricchord/widgets/resizable_split_view.dart';

import '../helpers/localized_app.dart';
import '../helpers/tooltip_expectations.dart';

const _listKey = ValueKey('list');
const _handleKey = ValueKey('splitViewHandle');

/// The screen is 1000 dp wide, so the default list is 380 dp, the minimum is
/// 240 dp and the maximum is 600 dp.
const _screenWidth = 1000.0;

void main() {
  late ProviderContainer container;

  Future<void> pumpSplit(
    WidgetTester tester, {
    Map<String, Object> saved = const {},
  }) async {
    tester.view.physicalSize = const Size(_screenWidth, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    SharedPreferences.setMockInitialValues(saved);
    final prefs = await SharedPreferences.getInstance();
    container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: localizedApp(
          const Scaffold(
            body: ResizableSplitView(
              list: SizedBox.expand(key: _listKey),
              detail: SizedBox.expand(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// The visible width of the list pane (the clip around it).
  double listPaneWidth(WidgetTester tester) => tester
      .getSize(
        find.ancestor(
          of: find.byKey(_listKey),
          matching: find.byType(ClipRect),
        ),
      )
      .width;

  Future<void> dragHandle(WidgetTester tester, double dx) async {
    // Grab the handle near the top, away from the chevron button.
    final handle = tester.getRect(find.byKey(_handleKey));
    await tester.dragFrom(
      Offset(handle.center.dx, handle.top + 40),
      Offset(dx, 0),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('starts at the default 38% width with tooltips', (tester) async {
    await pumpSplit(tester);

    expect(listPaneWidth(tester), 380);
    expect(find.byTooltip('Hide list'), findsOneWidget);
    expectAllIconButtonsHaveTooltips(tester);
  });

  testWidgets('dragging the handle resizes the list and saves it', (
    tester,
  ) async {
    await pumpSplit(tester);

    await dragHandle(tester, 70);

    expect(listPaneWidth(tester), closeTo(450, 1));
    expect(container.read(splitViewProvider).listFraction, closeTo(0.45, 0.01));
  });

  testWidgets('the width is held between the minimum and maximum', (
    tester,
  ) async {
    await pumpSplit(tester);

    await dragHandle(tester, 500);
    expect(listPaneWidth(tester), closeTo(600, 1));

    // 600 - 400 = 200: under the minimum, but not narrow enough to hide.
    await dragHandle(tester, -400);
    expect(listPaneWidth(tester), AppConstants.splitMinListWidth);
    expect(container.read(splitViewProvider).listCollapsed, isFalse);
  });

  testWidgets('dragging far left hides the list; dragging right opens it', (
    tester,
  ) async {
    await pumpSplit(tester);

    await dragHandle(tester, -350);
    expect(listPaneWidth(tester), 0);
    expect(container.read(splitViewProvider).listCollapsed, isTrue);
    expect(find.byTooltip('Show list'), findsOneWidget);

    await dragHandle(tester, 300);
    expect(listPaneWidth(tester), closeTo(300, 1));
    expect(container.read(splitViewProvider).listCollapsed, isFalse);
  });

  testWidgets('the chevron button hides and shows the list', (tester) async {
    await pumpSplit(tester);

    await tester.tap(find.byTooltip('Hide list'));
    await tester.pumpAndSettle();
    expect(listPaneWidth(tester), 0);

    await tester.tap(find.byTooltip('Show list'));
    await tester.pumpAndSettle();
    expect(listPaneWidth(tester), 380);
  });

  testWidgets('double-tapping the handle hides the list', (tester) async {
    await pumpSplit(tester);

    final handle = tester.getRect(find.byKey(_handleKey));
    final point = Offset(handle.center.dx, handle.top + 40);
    await tester.tapAt(point);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tapAt(point);
    await tester.pumpAndSettle();

    expect(container.read(splitViewProvider).listCollapsed, isTrue);
    expect(listPaneWidth(tester), 0);
  });

  testWidgets('restores a saved hidden list', (tester) async {
    await pumpSplit(
      tester,
      saved: {
        AppConstants.prefSplitListFraction: 0.5,
        AppConstants.prefSplitListCollapsed: true,
      },
    );

    expect(listPaneWidth(tester), 0);

    await tester.tap(find.byTooltip('Show list'));
    await tester.pumpAndSettle();
    expect(listPaneWidth(tester), 500);
  });
}
