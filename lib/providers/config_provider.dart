import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lyricchord/core/config/app_config.dart';
import 'package:lyricchord/core/config/config_service.dart';

/// The About-config loader.
final configServiceProvider = Provider<ConfigService>((ref) {
  return ConfigService();
});

/// The loaded [AppConfig] for the About screen. Degrades to a safe
/// fallback inside [ConfigService], so this never throws.
final appConfigProvider = FutureProvider<AppConfig>((ref) {
  return ref.watch(configServiceProvider).loadAndVerify();
});
