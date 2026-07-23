import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lyriccord/core/constants/app_constants.dart';
import 'package:lyriccord/providers/custom_chords_provider.dart';
import 'package:lyriccord/providers/theme_mode_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<(ProviderContainer, SharedPreferences)> makeContainer({
    List<String>? saved,
  }) async {
    SharedPreferences.setMockInitialValues({
      AppConstants.prefCustomChords: ?saved,
    });
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);
    return (container, prefs);
  }

  test('starts empty when nothing is saved', () async {
    final (container, _) = await makeContainer();

    expect(container.read(customChordsProvider), isEmpty);
  });

  test('loads previously saved chords', () async {
    final (container, _) = await makeContainer(saved: ['Cmaj7', 'D/F#']);

    expect(container.read(customChordsProvider), ['Cmaj7', 'D/F#']);
  });

  test('add trims, saves, and persists the chord', () async {
    final (container, prefs) = await makeContainer();
    final notifier = container.read(customChordsProvider.notifier);

    expect(await notifier.add('  Dsus4  '), isTrue);

    expect(container.read(customChordsProvider), ['Dsus4']);
    expect(prefs.getStringList(AppConstants.prefCustomChords), ['Dsus4']);
  });

  test('rejects blank, too long, and repeated chords', () async {
    final (container, _) = await makeContainer(saved: ['Cmaj7']);
    final notifier = container.read(customChordsProvider.notifier);

    expect(await notifier.add('   '), isFalse);
    expect(await notifier.add('Cmaj7'), isFalse);
    expect(
      await notifier.add('X' * (CustomChordsNotifier.maxChordLength + 1)),
      isFalse,
    );

    expect(container.read(customChordsProvider), ['Cmaj7']);
  });

  test('remove deletes the chord and persists the change', () async {
    final (container, prefs) = await makeContainer(saved: ['Cmaj7', 'Dsus4']);
    final notifier = container.read(customChordsProvider.notifier);

    await notifier.remove('Cmaj7');

    expect(container.read(customChordsProvider), ['Dsus4']);
    expect(prefs.getStringList(AppConstants.prefCustomChords), ['Dsus4']);
  });

  test('removing an unknown chord changes nothing', () async {
    final (container, _) = await makeContainer(saved: ['Cmaj7']);
    final notifier = container.read(customChordsProvider.notifier);

    await notifier.remove('Zz9');

    expect(container.read(customChordsProvider), ['Cmaj7']);
  });
}
