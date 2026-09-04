import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lyricchord/core/constants/app_constants.dart';
import 'package:lyricchord/providers/auto_scroll_provider.dart';
import 'package:lyricchord/providers/scroll_speed_settings_provider.dart';
import 'package:lyricchord/providers/theme_mode_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<(ProviderContainer, SharedPreferences)> makeContainer({
    double? saved,
  }) async {
    SharedPreferences.setMockInitialValues({
      AppConstants.prefDefaultScrollSpeed: ?saved,
    });
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);
    return (container, prefs);
  }

  test('starts at 1.00x when nothing is saved', () async {
    final (container, _) = await makeContainer();

    expect(
      container.read(defaultScrollSpeedProvider),
      AutoScrollSettings.defaultSpeed,
    );
  });

  test('loads the saved speed', () async {
    final (container, _) = await makeContainer(saved: 0.35);

    expect(container.read(defaultScrollSpeedProvider), closeTo(0.35, 1e-9));
  });

  test('setSpeed saves the new speed', () async {
    final (container, prefs) = await makeContainer();

    await container.read(defaultScrollSpeedProvider.notifier).setSpeed(0.20);

    expect(container.read(defaultScrollSpeedProvider), closeTo(0.20, 1e-9));
    expect(
      prefs.getDouble(AppConstants.prefDefaultScrollSpeed),
      closeTo(0.20, 1e-9),
    );
  });

  test('steps up and down by one step', () async {
    final (container, _) = await makeContainer(saved: 1.0);
    final notifier = container.read(defaultScrollSpeedProvider.notifier);

    await notifier.increase();
    expect(container.read(defaultScrollSpeedProvider), closeTo(1.05, 1e-9));

    await notifier.decrease();
    expect(container.read(defaultScrollSpeedProvider), closeTo(1.00, 1e-9));
  });

  test('stops at the ends of the range', () async {
    final (container, _) = await makeContainer();
    final notifier = container.read(defaultScrollSpeedProvider.notifier);

    await notifier.setSpeed(9);
    expect(
      container.read(defaultScrollSpeedProvider),
      AutoScrollSettings.maxSpeed,
    );

    await notifier.setSpeed(-4);
    expect(
      container.read(defaultScrollSpeedProvider),
      AutoScrollSettings.minSpeed,
    );
  });

  test('a value off the step grid is snapped onto it', () async {
    final (container, _) = await makeContainer(saved: 0.37);

    expect(container.read(defaultScrollSpeedProvider), closeTo(0.35, 1e-9));
  });

  test('reset goes back to 1.00x', () async {
    final (container, _) = await makeContainer(saved: 0.30);

    await container.read(defaultScrollSpeedProvider.notifier).reset();

    expect(
      container.read(defaultScrollSpeedProvider),
      AutoScrollSettings.defaultSpeed,
    );
  });
}
