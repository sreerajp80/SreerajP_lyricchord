import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:lyricchord/screens/air_qr_transmitter_screen.dart';

import '../helpers/localized_app.dart';
import '../helpers/tooltip_expectations.dart';

void main() {
  /// Long enough for several 160-byte blocks.
  final payload = List.generate(
    12,
    (i) => '{title: Song $i}\n[G]Amazing [C]grace, line $i',
  ).join('\n{new_song}\n');

  Future<void> pump(WidgetTester tester, String text) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      localizedApp(
        AirQrTransmitterScreen(
          args: AirQrTransmitterArgs(
            title: 'Sunday Gig',
            chordProPayload: text,
          ),
        ),
      ),
    );
  }

  /// Removes the screen so its frame timer is cancelled.
  Future<void> unmount(WidgetTester tester) =>
      tester.pumpWidget(const SizedBox());

  testWidgets('shows a QR frame for the songs and starts streaming', (
    tester,
  ) async {
    await pump(tester, payload);

    expect(find.text('AirQR Share: Sunday Gig'), findsOneWidget);
    expect(find.byType(QrImageView), findsOneWidget);
    expect(find.textContaining('Optical Frames'), findsOneWidget);
    expect(find.text('Pause stream'), findsOneWidget);
    expect(find.text('10 FPS'), findsWidgets);
    expectAllIconButtonsHaveTooltips(tester);

    await unmount(tester);
  });

  testWidgets('the shown frame moves on while streaming', (tester) async {
    await pump(tester, payload);

    final before = tester.widget<QrImageView>(find.byType(QrImageView));
    await tester.pump(const Duration(milliseconds: 250));
    final after = tester.widget<QrImageView>(find.byType(QrImageView));
    expect(identical(before, after), isFalse);
    expect(find.textContaining('Frame 1/'), findsNothing);

    await unmount(tester);
  });

  testWidgets('pause stops the stream and resume restarts it', (tester) async {
    await pump(tester, payload);

    await tester.tap(find.text('Pause stream'));
    await tester.pump();
    expect(find.text('Resume stream'), findsOneWidget);

    final frameText = find.textContaining('Frame ');
    final shown = tester.widget<Text>(frameText).data;
    await tester.pump(const Duration(seconds: 1));
    expect(tester.widget<Text>(frameText).data, shown);

    await tester.tap(find.text('Resume stream'));
    await tester.pump();
    expect(find.text('Pause stream'), findsOneWidget);

    await unmount(tester);
  });

  testWidgets('empty text shows no frames and cannot stream', (tester) async {
    await pump(tester, '   ');

    expect(find.byType(QrImageView), findsNothing);
    expect(find.text('No frames generated'), findsOneWidget);

    await unmount(tester);
  });
}
