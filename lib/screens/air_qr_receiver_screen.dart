import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:lyricchord/models/air_qr_progress.dart';
import 'package:lyricchord/models/import_preview_args.dart';
import 'package:lyricchord/providers/air_qr_provider.dart';
import 'package:lyricchord/services/chord_pro_service.dart';

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
      final parsedSongs = const ChordProService().parseMultiple(rawContent);

      if (mounted) {
        context.pushReplacement(
          '/import-preview',
          extra: ImportPreviewArgs(
            fileName: 'AirQR Stream Share',
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
            const SnackBar(
              content: Text('No AirQR code detected in chosen photo.'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not scan photo.')));
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

  @override
  Widget build(BuildContext context) {
    final progress = ref.watch(airQrProvider);

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
          ),
          title: const Text('AirQR Song Receiver'),
          elevation: 0,
          backgroundColor: Colors.black87,
          actions: [
            IconButton(
              icon: const Icon(Icons.photo_library_outlined),
              onPressed: _scanFromGallery,
              tooltip: 'Scan Photo from Gallery',
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                setState(() {
                  _hasProcessedCompletion = false;
                });
                ref.read(airQrProvider.notifier).resetStream();
              },
              tooltip: 'Reset Stream',
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
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.sensors_outlined,
                          size: 48,
                          color: Colors.cyanAccent,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Initializing AirQR Camera Receiver...',
                          style: TextStyle(color: Colors.white70),
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
                          '${progress.fps.toStringAsFixed(1)} FPS',
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
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // HUD Matrix & Progress Panel (Bottom)
            Positioned(
              bottom: 24,
              left: 16,
              right: 16,
              child: _buildHudPanel(progress),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHudPanel(AirQrProgress progress) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                progress.status == AirQrStatus.completed
                    ? 'STREAM REASSEMBLED - OPENING PREVIEW...'
                    : progress.status == AirQrStatus.receiving
                    ? 'RECEIVING AIRQR SONG STREAM...'
                    : 'POINT AT ANIMATED QR CODE STREAM',
                style: TextStyle(
                  color: progress.status == AirQrStatus.completed
                      ? Colors.greenAccent
                      : Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
              Text(
                '${(progress.progressPercentage * 100).toInt()}%',
                style: const TextStyle(
                  color: Colors.cyanAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress.progressPercentage,
              minHeight: 10,
              backgroundColor: Colors.white10,
              valueColor: const AlwaysStoppedAnimation<Color>(
                Colors.cyanAccent,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Captured: ${progress.receivedBlockCount} / ${progress.totalBlocks} Blocks',
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
              Text(
                'Missing: ${progress.missingBlockCount}',
                style: const TextStyle(color: Colors.amberAccent, fontSize: 13),
              ),
            ],
          ),
          if (progress.totalBlocks > 0) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 36,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(progress.totalBlocks, (index) {
                    final isCaptured = progress.capturedIndices.contains(index);
                    return Container(
                      width: 14,
                      height: 28,
                      margin: const EdgeInsets.only(right: 4),
                      decoration: BoxDecoration(
                        color: isCaptured ? Colors.cyanAccent : Colors.white10,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
