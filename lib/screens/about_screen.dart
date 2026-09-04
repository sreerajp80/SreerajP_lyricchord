import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:lyricchord/core/config/app_config.dart';
import 'package:lyricchord/core/constants/app_version.g.dart';
import 'package:lyricchord/core/constants/build_date.g.dart';
import 'package:lyricchord/providers/config_provider.dart';

/// About screen. Fully data-driven: it reads [AppConfig] and renders each
/// entry in `details` as its own row. Adding or removing a key in
/// `app_config.json` is the only change needed — no field names are hard-coded.
class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configAsync = ref.watch(appConfigProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: SafeArea(
        child: configAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => const _AboutBody(config: AppConfig.fallback),
          data: (config) => _AboutBody(config: config),
        ),
      ),
    );
  }
}

class _AboutBody extends StatelessWidget {
  const _AboutBody({required this.config});

  final AppConfig config;

  /// Version text for display. The generated [kAppVersion] comes straight from
  /// `pubspec.yaml`, so it can never drift from the real build. The values in
  /// `app_config.json` are only a fallback if the generated string is empty.
  String _versionLabel(AppConfig config) {
    final generated = kAppVersion.trim();
    if (generated.isEmpty) {
      return '${config.version} (build ${config.build})';
    }
    final parts = generated.split('+');
    if (parts.length == 2 && parts[1].isNotEmpty) {
      return '${parts[0]} (build ${parts[1]})';
    }
    return generated;
  }

  Future<void> _openMail(String address) async {
    final uri = Uri(scheme: 'mailto', path: address);
    await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      children: [
        const SizedBox(height: 16),
        Center(
          child: Icon(
            Icons.library_music,
            size: 64,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(config.appName, style: theme.textTheme.headlineSmall),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Text(
            config.description,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
        ),
        Center(
          child: Text(
            'Version ${_versionLabel(config)}',
            style: theme.textTheme.bodySmall,
          ),
        ),
        const Divider(height: 32),
        const ListTile(
          leading: Icon(Icons.calendar_today_outlined),
          title: Text('Build date'),
          subtitle: Text(kBuildDate),
        ),
        for (final entry in config.details.entries)
          if (entry.key.trim().isNotEmpty && entry.value.trim().isNotEmpty)
            ListTile(
              title: Text(entry.key),
              subtitle: Text(entry.value),
              onTap: entry.key.trim().toLowerCase() == 'email'
                  ? () => _openMail(entry.value)
                  : null,
            ),
        // Flutter's built-in licence page, which also lists the bundled fonts'
        // Open Font Licence (registered in main.dart).
        ListTile(
          leading: const Icon(Icons.description_outlined),
          title: const Text('Open source licenses'),
          onTap: () => showLicensePage(
            context: context,
            applicationName: config.appName,
            applicationVersion: 'Version ${_versionLabel(config)}',
          ),
        ),
      ],
    );
  }
}
