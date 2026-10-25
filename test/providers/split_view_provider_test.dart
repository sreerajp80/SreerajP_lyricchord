import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lyricchord/core/constants/app_constants.dart';
import 'package:lyricchord/providers/split_view_provider.dart';
import 'package:lyricchord/providers/theme_mode_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<(ProviderContainer, SharedPreferences)> makeContainer({
    double? fraction,
    bool? collapsed,
  }) async {
    SharedPreferences.setMockInitialValues({
      AppConstants.prefSplitListFraction: ?fraction,
      AppConstants.prefSplitListCollapsed: ?collapsed,
    });
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);
    return (container, prefs);
  }

  test('defaults to the Android 38% split with the list open', () async {
    final (container, _) = await makeContainer();
    final layout = container.read(splitViewProvider);

    expect(layout.listFraction, AppConstants.splitDefaultListFraction);
    expect(layout.listCollapsed, isFalse);
  });

  test('loads the previously saved layout', () async {
    final (container, _) = await makeContainer(fraction: 0.5, collapsed: true);
    final layout = container.read(splitViewProvider);

    expect(layout.listFraction, 0.5);
    expect(layout.listCollapsed, isTrue);
  });

  test('an out-of-range saved fraction falls back to the default', () async {
    for (final bad in [0.0, -0.2, 0.9, double.nan]) {
      final (container, _) = await makeContainer(fraction: bad);

      expect(
        container.read(splitViewProvider).listFraction,
        AppConstants.splitDefaultListFraction,
        reason: 'saved $bad',
      );
    }
  });

  test('setListFraction opens the list and saves the width', () async {
    final (container, prefs) = await makeContainer(collapsed: true);

    await container.read(splitViewProvider.notifier).setListFraction(0.45);

    final layout = container.read(splitViewProvider);
    expect(layout.listFraction, 0.45);
    expect(layout.listCollapsed, isFalse);
    expect(prefs.getDouble(AppConstants.prefSplitListFraction), 0.45);
    expect(prefs.getBool(AppConstants.prefSplitListCollapsed), isFalse);
  });

  test('setListCollapsed saves the choice and keeps the width', () async {
    final (container, prefs) = await makeContainer(fraction: 0.5);

    await container.read(splitViewProvider.notifier).setListCollapsed(true);

    final layout = container.read(splitViewProvider);
    expect(layout.listCollapsed, isTrue);
    expect(layout.listFraction, 0.5);
    expect(prefs.getBool(AppConstants.prefSplitListCollapsed), isTrue);
  });
}
