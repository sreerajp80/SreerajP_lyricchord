import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lyricchord/services/app_lifecycle_service.dart';

/// Counts how often the cache was cleared.
class _CountingImageCache extends ImageCache {
  int clears = 0;
  int liveClears = 0;

  @override
  void clear() {
    clears++;
    super.clear();
  }

  @override
  void clearLiveImages() {
    liveClears++;
    super.clearLiveImages();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('detached runs the shutdown work', () async {
    var calls = 0;
    final service = AppLifecycleService(onDetached: () async => calls++);

    service.didChangeAppLifecycleState(AppLifecycleState.detached);
    await Future<void>.delayed(Duration.zero);

    expect(calls, 1);
  });

  test('other states do not run the shutdown work', () async {
    var calls = 0;
    final service = AppLifecycleService(onDetached: () async => calls++);

    for (final state in [
      AppLifecycleState.resumed,
      AppLifecycleState.inactive,
      AppLifecycleState.hidden,
      AppLifecycleState.paused,
    ]) {
      service.didChangeAppLifecycleState(state);
    }
    await Future<void>.delayed(Duration.zero);

    expect(calls, 0);
  });

  test('a failing shutdown step does not throw', () async {
    final service = AppLifecycleService(
      onDetached: () async => throw StateError('disk gone'),
    );

    service.didChangeAppLifecycleState(AppLifecycleState.detached);
    await Future<void>.delayed(Duration.zero);
  });

  test('memory pressure clears the image cache', () {
    final cache = _CountingImageCache();
    final service = AppLifecycleService(
      onDetached: () async {},
      imageCache: cache,
    );

    service.didHaveMemoryPressure();

    expect(cache.clears, 1);
    expect(cache.liveClears, 1);
  });
}
