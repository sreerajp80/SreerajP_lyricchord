import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lyriccord/core/constants/app_constants.dart';
import 'package:lyriccord/models/lyric_font.dart';
import 'package:lyriccord/providers/lyric_font_provider.dart';
import 'package:lyriccord/providers/theme_mode_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<(ProviderContainer, SharedPreferences)> makeContainer({
    String? saved,
  }) async {
    SharedPreferences.setMockInitialValues({
      AppConstants.prefLyricFont: ?saved,
    });
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);
    return (container, prefs);
  }

  test('defaults to the system font when nothing is saved', () async {
    final (container, _) = await makeContainer();

    expect(container.read(lyricFontProvider), LyricFont.system);
  });

  test('loads the previously saved font', () async {
    final (container, _) = await makeContainer(saved: LyricFont.manjari.id);

    expect(container.read(lyricFontProvider), LyricFont.manjari);
  });

  test('an unknown saved value falls back to the system font', () async {
    final (container, _) = await makeContainer(saved: 'no_such_font');

    expect(container.read(lyricFontProvider), LyricFont.system);
  });

  test('setFont updates state and persists the choice', () async {
    final (container, prefs) = await makeContainer();
    final notifier = container.read(lyricFontProvider.notifier);

    await notifier.setFont(LyricFont.gayathri);

    expect(container.read(lyricFontProvider), LyricFont.gayathri);
    expect(prefs.getString(AppConstants.prefLyricFont), LyricFont.gayathri.id);
  });
}
