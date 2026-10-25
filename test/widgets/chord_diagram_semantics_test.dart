import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lyricchord/l10n/app_localizations.dart';
import 'package:lyricchord/l10n/app_localizations_delegates.dart';
import 'package:lyricchord/services/chord_shape_service.dart';
import 'package:lyricchord/widgets/guitar_chord_diagram.dart';
import 'package:lyricchord/widgets/harmonium_chord_diagram.dart';

/// The painted chord diagrams are invisible to a screen reader, so each one
/// carries a `Semantics` image label naming its chord (accessibility pass,
/// Phase 8).
void main() {
  const service = ChordShapeService();

  Future<void> pump(WidgetTester tester, Widget child) {
    return tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: appLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: Center(child: child)),
      ),
    );
  }

  testWidgets('guitar diagram names its chord for a screen reader', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pump(
      tester,
      GuitarChordDiagram(name: 'G', shape: service.guitarShape('G')),
    );

    expect(
      find.bySemanticsLabel(RegExp('Guitar chord diagram for G')),
      findsOneWidget,
    );

    handle.dispose();
  });

  testWidgets('guitar diagram labels a missing shape as not available', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pump(tester, const GuitarChordDiagram(name: 'Zz', shape: null));

    expect(
      find.bySemanticsLabel(RegExp('No guitar chord diagram for Zz')),
      findsOneWidget,
    );

    handle.dispose();
  });

  testWidgets('harmonium diagram names its chord for a screen reader', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pump(
      tester,
      HarmoniumChordDiagram(name: 'C', shape: service.harmoniumShape('C')),
    );

    expect(
      find.bySemanticsLabel(RegExp('Harmonium chord diagram for C')),
      findsOneWidget,
    );

    handle.dispose();
  });
}
