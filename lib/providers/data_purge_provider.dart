import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Deletes all app data, then starts the app again fresh (engineering
/// standard §15.4). `main()` overrides this through `AppStartup`; the default
/// throws, the same way `appDatabaseProvider` does, so a test that forgets to
/// override it fails loudly.
final deleteAllDataProvider = Provider<Future<void> Function()>((ref) {
  throw UnimplementedError(
    'deleteAllDataProvider must be overridden (AppStartup does this).',
  );
});
