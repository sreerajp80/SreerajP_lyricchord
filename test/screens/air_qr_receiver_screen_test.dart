import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:lyricchord/l10n/app_localizations.dart';
import 'package:lyricchord/l10n/app_localizations_delegates.dart';
import 'package:lyricchord/models/air_qr_progress.dart';
import 'package:lyricchord/providers/air_qr_provider.dart';
import 'package:lyricchord/screens/air_qr_receiver_screen.dart';

import '../helpers/tooltip_expectations.dart';

/// An [AirQrNotifier] whose state a test can set directly.
class _TestAirQrNotifier extends AirQrNotifier {
  void emit(AirQrProgress progress) => state = progress;
}

// The live camera preview (`MobileScanner`) needs the real camera plugin, which
// a widget test does not have; it shows its own error view here. These tests
// cover everything around it: the bar, the progress panel and the error
// message. Scanning itself is covered by the AirQR provider and service tests.
void main() {
  late ProviderContainer container;

  Future<void> pump(WidgetTester tester) async {
    container = ProviderContainer(
      overrides: [airQrProvider.overrideWith(_TestAirQrNotifier.new)],
    );
    addTearDown(container.dispose);
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const Scaffold(body: Text('home')),
          routes: [
            GoRoute(
              path: 'receive',
              builder: (_, _) => const AirQrReceiverScreen(),
            ),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    router.push('/receive');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
  }

  _TestAirQrNotifier notifier() =>
      container.read(airQrProvider.notifier) as _TestAirQrNotifier;

  testWidgets('shows the bar with every control named', (tester) async {
    await pump(tester);

    expect(find.text('AirQR Song Receiver'), findsOneWidget);
    expect(find.byTooltip('Scan a photo'), findsOneWidget);
    expect(find.byTooltip('Reset Stream'), findsOneWidget);
    expect(find.byTooltip('Turn on flashlight'), findsOneWidget);
    expect(find.byTooltip('Switch camera'), findsOneWidget);
    expectAllIconButtonsHaveTooltips(tester);
  });

  testWidgets('opening the receiver starts a fresh stream', (tester) async {
    await pump(tester);

    expect(container.read(airQrProvider).status, AirQrStatus.idle);
  });

  testWidgets('Reset Stream clears progress', (tester) async {
    await pump(tester);
    notifier().emit(
      const AirQrProgress(
        streamId: '123456',
        totalBlocks: 4,
        receivedBlockCount: 2,
        capturedIndices: {0, 1},
        status: AirQrStatus.receiving,
      ),
    );
    await tester.pump();

    await tester.tap(find.byTooltip('Reset Stream'));
    await tester.pump();

    expect(container.read(airQrProvider).status, AirQrStatus.idle);
    expect(container.read(airQrProvider).receivedBlockCount, 0);
  });

  testWidgets('a failed transfer says so and offers Reset', (tester) async {
    await pump(tester);

    notifier().emit(
      const AirQrProgress(
        streamId: '123456',
        totalBlocks: 2,
        receivedBlockCount: 2,
        status: AirQrStatus.error,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Shown both in the progress panel and in a SnackBar with a Reset action.
    expect(
      find.descendant(
        of: find.byType(SnackBar),
        matching: find.text('Transfer failed. Tap Reset and scan again.'),
      ),
      findsOneWidget,
    );
    await tester.tap(find.widgetWithText(SnackBarAction, 'Reset'));
    await tester.pump();
    expect(container.read(airQrProvider).status, AirQrStatus.idle);
  });

  testWidgets('Back leaves the receiver', (tester) async {
    await pump(tester);

    await tester.tap(find.byTooltip('Back'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('home'), findsOneWidget);
  });
}
