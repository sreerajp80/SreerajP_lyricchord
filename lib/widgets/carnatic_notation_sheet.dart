import 'package:flutter/material.dart';

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
                'Paste Carnatic notation',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                'Tala: ${widget.tala}. Paste one avarta per line, or separate '
                'them with ||. Underlined runs: write them _like_this_.',
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
                title: const Text('Shuddha madhyamam in Ga-Ma-Ri'),
                subtitle: const Text(
                  'For a bhashanga raga such as Yamunakalyani. Off by default — '
                  'the notation does not say which madhyamam is meant.',
                ),
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
                    child: const Text('Cancel'),
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: result != null && result.hasLines
                        ? () => Navigator.of(context).pop(result.melodyLines)
                        : null,
                    icon: const Icon(Icons.add),
                    label: Text(
                      result == null || !result.hasLines
                          ? 'Insert'
                          : 'Insert ${result.melodyLines.length} line'
                                '${result.melodyLines.length == 1 ? '' : 's'}',
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
                '${fit.fitting} of ${fit.total} cycles fit the tala — '
                'read with ${fit.reading.label}.',
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
        if (result.rejected != null)
          Padding(
            padding: const EdgeInsets.only(left: 26, top: 2),
            child: Text(
              'The other reading (${result.rejected!.reading.label}) fits '
              '${result.rejected!.fitting} of ${result.rejected!.total}.',
              style: theme.textTheme.bodySmall,
            ),
          ),
        for (final problem in result.problems)
          Padding(
            padding: const EdgeInsets.only(left: 26, top: 4),
            child: Text(
              problem,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
        if (result.anyaSvaraHints.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 26, top: 4),
            child: Text(
              'A Ga-Ma-Ri descent appears in '
              '${result.anyaSvaraHints.length} cycle'
              '${result.anyaSvaraHints.length == 1 ? '' : 's'}. '
              'In a bhashanga raga that madhyamam is the shuddha one.',
              style: theme.textTheme.bodySmall,
            ),
          ),
      ],
    );
  }
}
