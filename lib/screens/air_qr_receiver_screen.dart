import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:lyricchord/core/utils/formatting_locale.dart';
import 'package:lyricchord/l10n/app_localizations.dart';
import 'package:lyricchord/models/air_qr_progress.dart';
import 'package:lyricchord/models/import_preview_args.dart';
import 'package:lyricchord/providers/air_qr_provider.dart';
import 'package:lyricchord/services/chord_pro_service.dart';
import 'package:lyricchord/widgets/air_qr_receiver_hud.dart';

class AirQrReceiverScreen extends ConsumerStatefulWidget {
  const AirQrReceiverScreen({super.key});

  @override
  ConsumerState<AirQrReceiverScreen> createState() =>
      _AirQrReceiverScreenState();
}

class _AirQrReceiverScreenState extends ConsumerState<AirQrReceiverScreen>
    with WidgetsBindingObserver {
  MobileScannerController? _controller;
  bool _isTorchOn = false;
  bool _isFrontCamera = false;
  bool _hasProcessedCompletion = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = MobileScannerController(
      formats: const [BarcodeFormat.qrCode],
      detectionSpeed: DetectionSpeed.unrestricted,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(airQrProvider.notifier).resetStream();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null || !_controller!.value.isInitialized) return;
    switch (state) {
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        try {
          if (_controller!.value.isRunning) {
            _controller?.stop();
          }
        } catch (_) {}
        break;
      case AppLifecycleState.resumed:
        try {
          if (!_controller!.value.isRunning) {
            _controller?.start();
          }
        } catch (_) {}
        break;
      case AppLifecycleState.inactive:
        break;
    }
  }

  void _onDetect(BarcodeCapture capture) {
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final notifier = ref.read(airQrProvider.notifier);
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        notifier.processScannedCode(barcode.rawValue!);
      }
    }

    final progress = ref.read(airQrProvider);
    if (progress.status == AirQrStatus.completed && !_hasProcessedCompletion) {
      _hasProcessedCompletion = true;
      HapticFeedback.heavyImpact();

      final rawContent = progress.reassembledContent ?? '';
      final parsedSongs = const ChordProService().parseMultiple(
        rawContent,
        untitledTitle: AppLocalizations.of(context).labelUntitledSong,
      );

      if (mounted) {
        context.pushReplacement(
          '/import-preview',
          extra: ImportPreviewArgs(
            fileName: AppLocalizations.of(context).labelAirQrReceiverFileName,
            rawContent: rawContent,
            parsedSongs: parsedSongs,
          ),
        );
      }
    }
  }

  Future<void> _scanFromGallery() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      final capture = await _controller?.analyzeImage(image.path);
      if (capture != null && capture.barcodes.isNotEmpty) {
        _onDetect(capture);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context).errorAirQrReceiverNoCode,
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).errorAirQrReceiverPhotoFailed,
            ),
          ),
        );
      }
    }
  }

  Future<void> _handleBack() async {
    try {
      if (_controller != null) {
        await _controller!.stop();
        await _controller!.dispose();
        _controller = null;
      }
    } catch (_) {}
    if (mounted) {
      context.pop();
    }
  }

  /// Clears the received blocks so a new transfer can start.
  void _resetStream() {
    // The SnackBar action can fire after this screen has closed.
    if (!mounted) return;
    setState(() => _hasProcessedCompletion = false);
    ref.read(airQrProvider.notifier).resetStream();
  }

  @override
  Widget build(BuildContext context) {
    final progress = ref.watch(airQrProvider);
    final l10n = AppLocalizations.of(context);
    ref.listen<AirQrProgress>(airQrProvider, (previous, next) {
      if (next.status != AirQrStatus.error ||
          previous?.status == AirQrStatus.error) {
        return;
      }
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.errorAirQrTransferFailed),
          action: SnackBarAction(
            label: l10n.actionAirQrReset,
            onPressed: _resetStream,
          ),
        ),
      );
    });

    return PopScope(
      onPopInvokedWithResult: (didPop, result) async {
        try {
          if (_controller != null) {
            await _controller!.stop();
            await _controller!.dispose();
            _controller = null;
          }
        } catch (_) {}
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _handleBack,
            tooltip: l10n.tooltipBack,
          ),
          title: Text(l10n.titleAirQrReceiver),
          elevation: 0,
          backgroundColor: Colors.black87,
          actions: [
            IconButton(
              icon: const Icon(Icons.photo_library_outlined),
              onPressed: _scanFromGallery,
              tooltip: l10n.tooltipAirQrReceiverGallery,
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _resetStream,
              tooltip: l10n.tooltipAirQrReceiverResetStream,
            ),
          ],
        ),
        body: Stack(
          children: [
            if (_controller != null)
              MobileScanner(
                controller: _controller!,
                onDetect: _onDetect,
                errorBuilder: (context, error, child) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.sensors_outlined,
                          size: 48,
                          color: Colors.cyanAccent,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n.descAirQrReceiverStarting,
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  );
                },
              ),
            // HUD Controls Bar (Top)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.cyanAccent.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.sensors,
                          color: Colors.cyanAccent,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n.labelAirQrFps(
                            formatFixed(progress.fps, 1, l10n.localeName),
                          ),
                          style: const TextStyle(
                            color: Colors.cyanAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            _isTorchOn ? Icons.flash_on : Icons.flash_off,
                            color: _isTorchOn ? Colors.amber : Colors.white,
                          ),
                          onPressed: () async {
                            await _controller?.toggleTorch();
                            setState(() => _isTorchOn = !_isTorchOn);
                          },
                          tooltip: _isTorchOn
                              ? l10n.tooltipAirQrReceiverTorchOff
                              : l10n.tooltipAirQrReceiverTorchOn,
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.cameraswitch,
                            color: _isFrontCamera
                                ? Colors.cyanAccent
                                : Colors.white,
                          ),
                          onPressed: () async {
                            await _controller?.switchCamera();
                            setState(() => _isFrontCamera = !_isFrontCamera);
                          },
                          tooltip: l10n.tooltipAirQrReceiverSwitchCamera,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // HUD Matrix & Progress Panel (Bottom)
            Positioned(
              left: 16,
              right: 16,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: AirQrReceiverHud(progress: progress),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
