import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:lyricchord/core/config/app_config.dart';
import 'package:lyricchord/core/constants/app_version.g.dart';
import 'package:lyricchord/core/constants/build_date.g.dart';
import 'package:lyricchord/l10n/app_localizations.dart';
import 'package:lyricchord/l10n/l10n_labels.dart';
import 'package:lyricchord/providers/config_provider.dart';

/// About screen. Fully data-driven: it reads [AppConfig] and renders each
/// entry in `details` as its own row, with a translated label
/// (`aboutDetail<Key>`) and the value for the active language. Adding or
/// removing a key in `app_config.json` is the only change needed — no field
/// names are hard-coded (guideline §1.6).
class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configAsync = ref.watch(appConfigProvider);
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).titleAbout)),
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
  String _versionLabel(AppConfig config, AppLocalizations l10n) {
    final generated = kAppVersion.trim();
    if (generated.isEmpty) {
      return l10n.labelAboutVersionBuild(config.version, config.build);
    }
    final parts = generated.split('+');
    if (parts.length == 2 && parts[1].isNotEmpty) {
      return l10n.labelAboutVersionBuild(parts[0], parts[1]);
    }
    return generated;
  }

  Future<void> _openMail(String address) async {
    final uri = Uri(scheme: 'mailto', path: address);
    await launchUrl(uri);
  }

  /// What tapping a row does: email opens the mail app, an https link opens
  /// the browser, anything else does nothing.
  VoidCallback? _tapActionFor(String key, String value) {
    if (key.trim().toLowerCase() == 'email') return () => _openMail(value);
    final uri = Uri.tryParse(value);
    if (uri != null && uri.scheme == 'https') {
      return () => launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
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
          child: Text(
            config.appName.resolve(lang),
            style: theme.textTheme.headlineSmall,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Text(
            config.description.resolve(lang),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
        ),
        Center(
          child: Text(
            l10n.labelAboutVersion(_versionLabel(config, l10n)),
            style: theme.textTheme.bodySmall,
          ),
        ),
        const Divider(height: 32),
        ListTile(
          leading: const Icon(Icons.calendar_today_outlined),
          title: Text(l10n.labelAboutBuildDate),
          subtitle: const Text(kBuildDate),
        ),
        for (final entry in config.details.entries)
          if (entry.key.trim().isNotEmpty &&
              entry.value.resolve(lang).trim().isNotEmpty)
            ListTile(
              title: Text(aboutDetailLabel(l10n, entry.key)),
              subtitle: Text(entry.value.resolve(lang)),
              onTap: _tapActionFor(entry.key, entry.value.resolve(lang)),
            ),
        // Flutter's built-in licence page, which also lists the bundled fonts'
        // Open Font Licence (registered in main.dart).
        ListTile(
          leading: const Icon(Icons.description_outlined),
          title: Text(l10n.labelAboutLicenses),
          onTap: () => showLicensePage(
            context: context,
            applicationName: config.appName.resolve(lang),
            applicationVersion: l10n.labelAboutVersion(
              _versionLabel(config, l10n),
            ),
          ),
        ),
      ],
    );
  }
}
