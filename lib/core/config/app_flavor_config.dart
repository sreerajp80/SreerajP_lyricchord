import 'package:flutter/foundation.dart';

/// The build flavors. Android builds pass one with `--flavor dev|prod`.
enum AppFlavor { dev, prod }

/// Which flavor this build is (engineering standard §5.2).
///
/// The flavor arrives in one of two ways, read in this order:
///
/// 1. `APP_FLAVOR` — passed with `--dart-define=APP_FLAVOR=<name>` on a platform
///    that cannot use `--flavor`.
/// 2. `FLUTTER_APP_FLAVOR` — set by the Flutter tool itself whenever `--flavor`
///    is passed. Never pass this one yourself; the build fails if you do.
///
/// A build with neither (for example a plain `flutter test`) counts as `prod`.
class AppFlavorConfig {
  const AppFlavorConfig._(this.flavor);

  static const String _appFlavorValue = String.fromEnvironment('APP_FLAVOR');
  static const String _frameworkFlavorValue = String.fromEnvironment(
    'FLUTTER_APP_FLAVOR',
    defaultValue: 'prod',
  );

  /// The flavor of the running build.
  static final AppFlavorConfig instance = AppFlavorConfig._(
    parse(_appFlavorValue.isNotEmpty ? _appFlavorValue : _frameworkFlavorValue),
  );

  /// A config for a given flavor, for tests.
  @visibleForTesting
  const AppFlavorConfig.forTesting(this.flavor);

  final AppFlavor flavor;

  bool get isDev => flavor == AppFlavor.dev;
  bool get isProd => flavor == AppFlavor.prod;

  /// Trace and debug logs are written only in the dev flavor.
  bool get enableVerboseLogging => isDev;

  /// Turns a flavor name into an [AppFlavor]. Anything unknown is `prod`, so a
  /// typo can never switch on dev-only behaviour in a release.
  @visibleForTesting
  static AppFlavor parse(String value) {
    switch (value.trim().toLowerCase()) {
      case 'dev':
        return AppFlavor.dev;
      default:
        return AppFlavor.prod;
    }
  }
}
