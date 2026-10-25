import 'package:material_ui/material_ui.dart';

import 'package:lyricchord/theme/app_theme.dart';

/// A plain "please wait" app with no words and no data: shown while all data
/// is deleted, so no screen can read the database while it is closed.
class BusyApp extends StatelessWidget {
  const BusyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: const Scaffold(body: Center(child: CircularProgressIndicator())),
    );
  }
}
