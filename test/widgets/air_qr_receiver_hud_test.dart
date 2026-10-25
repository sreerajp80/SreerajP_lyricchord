import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lyricchord/l10n/app_localizations.dart';
import 'package:lyricchord/l10n/app_localizations_delegates.dart';
import 'package:lyricchord/models/air_qr_progress.dart';
import 'package:lyricchord/widgets/air_qr_receiver_hud.dart';

void main() {
  Future<void> pumpHud(WidgetTester tester, AirQrProgress progress) {
    return tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: appLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: AirQrReceiverHud(progress: progress)),
      ),
    );
  }

  testWidgets('a failed transfer says so instead of "point at the code"', (
    tester,
  ) async {
    await pumpHud(
      tester,
      const AirQrProgress(
        totalBlocks: 3,
        receivedBlockCount: 3,
        capturedIndices: {0, 1, 2},
        status: AirQrStatus.error,
        errorMessage: 'Checksum verification failed during reassembly.',
      ),
    );

    expect(find.text('Transfer failed. Tap Reset and scan again.'), findsOne);
    expect(find.text('POINT AT ANIMATED QR CODE STREAM'), findsNothing);
    expect(find.text('100%'), findsOne);
  });

  testWidgets('an idle stream asks the user to point at the code', (
    tester,
  ) async {
    await pumpHud(tester, const AirQrProgress());

    expect(find.text('POINT AT ANIMATED QR CODE STREAM'), findsOne);
    expect(
      find.text('Transfer failed. Tap Reset and scan again.'),
      findsNothing,
    );
  });

  testWidgets('a stream in progress shows the receiving line', (tester) async {
    await pumpHud(
      tester,
      const AirQrProgress(
        totalBlocks: 4,
        receivedBlockCount: 1,
        capturedIndices: {0},
        status: AirQrStatus.receiving,
      ),
    );

    expect(find.text('RECEIVING AIRQR SONG STREAM...'), findsOne);
    expect(find.text('25%'), findsOne);
    expect(find.text('Missing: 3'), findsOne);
  });
}
