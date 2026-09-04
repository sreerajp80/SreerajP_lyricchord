import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:lyricchord/models/air_qr_frame.dart';
import 'package:lyricchord/services/air_qr_service.dart';

class AirQrTransmitterArgs {
  final String title;
  final String chordProPayload;

  const AirQrTransmitterArgs({
    required this.title,
    required this.chordProPayload,
  });
}

class AirQrTransmitterScreen extends StatefulWidget {
  final AirQrTransmitterArgs args;

  const AirQrTransmitterScreen({super.key, required this.args});

  @override
  State<AirQrTransmitterScreen> createState() => _AirQrTransmitterScreenState();
}

class _AirQrTransmitterScreenState extends State<AirQrTransmitterScreen> {
  int _fps = 10;
  bool _isBroadcasting = false;
  List<AirQrFrame> _encodedFrames = [];
  int _currentFrameIndex = 0;
  Timer? _broadcastTimer;

  @override
  void initState() {
    super.initState();
    _prepareFrames();
  }

  @override
  void dispose() {
    _broadcastTimer?.cancel();
    super.dispose();
  }

  void _prepareFrames() {
    final text = widget.args.chordProPayload.trim();
    if (text.isEmpty) {
      setState(() {
        _encodedFrames = [];
        _currentFrameIndex = 0;
      });
      return;
    }

    final frames = AirQrService.encodePayload(text, blockSize: 160);

    setState(() {
      _encodedFrames = frames;
      _currentFrameIndex = 0;
    });

    if (frames.isNotEmpty) {
      _startBroadcasting();
    }
  }

  void _toggleBroadcasting() {
    if (_isBroadcasting) {
      _stopBroadcasting();
    } else {
      _startBroadcasting();
    }
  }

  void _startBroadcasting() {
    if (_encodedFrames.isEmpty) return;

    _broadcastTimer?.cancel();
    final intervalMs = (1000 / _fps).round();

    setState(() {
      _isBroadcasting = true;
    });

    _broadcastTimer = Timer.periodic(Duration(milliseconds: intervalMs), (_) {
      if (mounted) {
        setState(() {
          _currentFrameIndex = (_currentFrameIndex + 1) % _encodedFrames.length;
        });
      }
    });
  }

  void _stopBroadcasting() {
    _broadcastTimer?.cancel();
    if (mounted) {
      setState(() {
        _isBroadcasting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentFrame = _encodedFrames.isNotEmpty
        ? _encodedFrames[_currentFrameIndex]
        : null;

    final qrString = currentFrame?.toQrString() ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text('AirQR Share: ${widget.args.title}'),
        elevation: 2,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.qr_code_2,
                        color: Colors.purple,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.args.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '${widget.args.chordProPayload.length} bytes • ${_encodedFrames.length} Optical Frames',
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text(
                    'Stream Speed:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: Slider(
                      value: _fps.toDouble(),
                      min: 5,
                      max: 25,
                      divisions: 20,
                      label: '$_fps FPS',
                      onChanged: (val) {
                        setState(() {
                          _fps = val.toInt();
                        });
                        if (_isBroadcasting) {
                          _stopBroadcasting();
                          _startBroadcasting();
                        }
                      },
                    ),
                  ),
                  Text(
                    '$_fps FPS',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _encodedFrames.isEmpty ? null : _toggleBroadcasting,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: _isBroadcasting
                      ? Colors.redAccent
                      : Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
                icon: Icon(_isBroadcasting ? Icons.pause : Icons.play_arrow),
                label: Text(
                  _isBroadcasting
                      ? 'Pause Optical Stream'
                      : 'Resume Optical Stream',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // High-Speed QR Visual Display Container
              Center(
                child: Container(
                  width: 290,
                  height: 290,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: qrString.isNotEmpty
                            ? QrImageView(
                                data: qrString,
                                version: QrVersions.auto,
                                errorCorrectionLevel: QrErrorCorrectLevel.M,
                                size: 240,
                                gapless: false,
                              )
                            : const Center(
                                child: Text(
                                  'No frames generated',
                                  style: TextStyle(color: Colors.black54),
                                ),
                              ),
                      ),
                      const SizedBox(height: 8),
                      if (currentFrame != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: currentFrame.isParity
                                ? Colors.purple.shade50
                                : Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            currentFrame.isParity
                                ? 'Frame ${_currentFrameIndex + 1}/${_encodedFrames.length} • Fountain FEC'
                                : 'Frame ${_currentFrameIndex + 1}/${_encodedFrames.length} • Block ${currentFrame.sequenceIndex + 1}',
                            style: TextStyle(
                              color: currentFrame.isParity
                                  ? Colors.purple.shade900
                                  : Colors.blue.shade900,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (_encodedFrames.isNotEmpty)
                Text(
                  'Point receiving phone camera at this screen.\nNo internet, Bluetooth, or Wi-Fi required.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
