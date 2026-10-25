import 'package:material_ui/material_ui.dart';

import 'package:lyricchord/l10n/app_localizations.dart';
import 'package:lyricchord/l10n/l10n_labels.dart';

import 'package:lyricchord/models/carnatic_import_result.dart';
import 'package:lyricchord/services/carnatic_notation_import_service.dart';

/// Paste published Carnatic notation, see what it converts to, then insert it.
///
/// The conversion is never presented as certain. Published notation has no one
/// standard — the same letter case means note length on some pages and octave
/// on others — so the sheet shows which reading was used, how well it landed on
/// the tala, and anything that did not add up. See `docs/carnatic_notation.md`.
///
/// Returns the `{melody}` lines to insert, or `null` when the user backs out.
class CarnaticNotationSheet extends StatefulWidget {
  const CarnaticNotationSheet({super.key, required this.tala});

  /// The song's tala. Every cycle is checked against its beat count.
  final String tala;

  @override
  State<CarnaticNotationSheet> createState() => _CarnaticNotationSheetState();
}

class _CarnaticNotationSheetState extends State<CarnaticNotationSheet> {
  final _input = TextEditingController();
  final _importer = const CarnaticNotationImporter();

  CarnaticImportResult? _result;
  bool _applyAnyaSvara = false;

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _convert() {
    final text = _input.text.trim();
    if (text.isEmpty) {
      setState(() => _result = null);
      return;
    }
    setState(() {
      _result = _importer.convert(
        text,
        tala: widget.tala,
        applyAnyaSvaraRule: _applyAnyaSvara,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final result = _result;
    final l10n = AppLocalizations.of(context);

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.actionEditorPasteCarnatic,
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                l10n.descCarnaticSheetHelp(widget.tala),
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _input,
                maxLines: 6,
                minLines: 3,
                style: const TextStyle(fontFamily: 'monospace'),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: '; ; S | G , m | R ; ||',
                ),
                onChanged: (_) => _convert(),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                value: _applyAnyaSvara,
                onChanged: (on) {
                  setState(() => _applyAnyaSvara = on);
                  _convert();
                },
                title: Text(l10n.labelCarnaticSheetAnyaTitle),
                subtitle: Text(l10n.descCarnaticSheetAnyaSubtitle),
              ),
              if (result != null) ...[
                const Divider(height: 24),
                _Summary(result: result),
                const SizedBox(height: 12),
                if (result.hasLines)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Text(
                        result.melodyLines.join('\n'),
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(l10n.actionCancel),
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: result != null && result.hasLines
                        ? () => Navigator.of(context).pop(result.melodyLines)
                        : null,
                    icon: const Icon(Icons.add),
                    label: Text(
                      result == null || !result.hasLines
                          ? l10n.actionInsert
                          : l10n.actionCarnaticSheetInsertLines(
                              result.melodyLines.length,
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// How the conversion went, in plain words.
class _Summary extends StatelessWidget {
  const _Summary({required this.result});

  final CarnaticImportResult result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final fit = result.chosen;
    final good = fit.isPerfect && !result.isAmbiguous;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              good ? Icons.check_circle_outline : Icons.info_outline,
              size: 18,
              color: good ? theme.colorScheme.primary : theme.colorScheme.error,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.descCarnaticSheetFit(
                  fit.fitting,
                  fit.total,
                  fit.reading.label(l10n),
                ),
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
        if (result.rejected != null)
          Padding(
            padding: const EdgeInsets.only(left: 26, top: 2),
            child: Text(
              l10n.descCarnaticSheetOtherReading(
                result.rejected!.reading.label(l10n),
                result.rejected!.fitting,
                result.rejected!.total,
              ),
              style: theme.textTheme.bodySmall,
            ),
          ),
        for (final problem in result.problems)
          Padding(
            padding: const EdgeInsets.only(left: 26, top: 4),
            child: Text(
              problem.text(l10n),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
        if (result.anyaSvaraHints.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 26, top: 4),
            child: Text(
              l10n.descCarnaticSheetAnyaHint(result.anyaSvaraHints.length),
              style: theme.textTheme.bodySmall,
            ),
          ),
      ],
    );
  }
}
