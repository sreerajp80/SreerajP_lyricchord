import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lyriccord/core/router/app_router.dart';
import 'package:lyriccord/data/app_database.dart';
import 'package:lyriccord/providers/database_provider.dart';
import 'package:lyriccord/providers/theme_mode_provider.dart';
import 'package:lyriccord/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Open the database (seeds the classic songs on first run) and load the saved
  // preferences before the first frame, so the app opens with the right theme.
  final database = AppDatabase();
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const LyricCordApp(),
    ),
  );
}

class LyricCordApp extends ConsumerWidget {
  const LyricCordApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp.router(
      title: 'LyricCord',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: ref.watch(goRouterProvider),
    );
  }
}
