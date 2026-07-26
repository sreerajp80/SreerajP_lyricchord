import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lyricchord/services/chord_sheet_parser.dart';
import 'package:lyricchord/theme/app_colors.dart';
import 'package:lyricchord/theme/app_theme.dart';
import 'package:lyricchord/widgets/chord_sheet_view.dart';

void main() {
  const line = ChordLine([
    ChordSegment(chord: 'G', text: 'Amazing '),
    ChordSegment(chord: 'C', text: 'Grace'),
  ]);

  testWidgets('renders chords with high contrast primary color in light mode', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(body: ChordSheetView(lines: [line], fontSize: 16)),
      ),
    );

    final chordTextWidget = tester.widget<Text>(find.text('G'));
    expect(chordTextWidget.style?.color, equals(AppColors.lightPrimary));
  });

  testWidgets('renders chords with high contrast primary color in dark mode', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: const Scaffold(body: ChordSheetView(lines: [line], fontSize: 16)),
      ),
    );

    final chordTextWidget = tester.widget<Text>(find.text('G'));
    expect(chordTextWidget.style?.color, equals(AppColors.darkPrimary));
  });
}
