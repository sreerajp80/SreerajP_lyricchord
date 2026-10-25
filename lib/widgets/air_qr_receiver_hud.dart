import 'package:material_ui/material_ui.dart';

import 'package:lyricchord/l10n/app_localizations.dart';
import 'package:lyricchord/models/air_qr_progress.dart';

/// The progress panel at the bottom of the AirQR receiver: status line,
/// percentage, progress bar, block counts and the captured-block strip.
///
/// When the stream has failed it says so in red, so the user knows to reset
/// instead of waiting on a bar that sits at 100 %.
class AirQrReceiverHud extends StatelessWidget {
  const AirQrReceiverHud({super.key, required this.progress});

  final AirQrProgress progress;

  @override
  Widget build(BuildContext context) {
    final isError = progress.status == AirQrStatus.error;
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isError ? Colors.redAccent : Colors.white24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  isError
                      ? l10n.errorAirQrTransferFailed
                      : progress.status == AirQrStatus.completed
                      ? l10n.descAirQrHudReassembled
                      : progress.status == AirQrStatus.receiving
                      ? l10n.descAirQrHudReceiving
                      : l10n.descAirQrHudPointAt,
                  style: TextStyle(
                    color: isError
                        ? Colors.redAccent
                        : progress.status == AirQrStatus.completed
                        ? Colors.greenAccent
                        : Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
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
              valueColor: AlwaysStoppedAnimation<Color>(
                isError ? Colors.redAccent : Colors.cyanAccent,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.descAirQrHudCaptured(
                  progress.receivedBlockCount,
                  progress.totalBlocks,
                ),
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
              Text(
                l10n.labelAirQrHudMissing(progress.missingBlockCount),
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
