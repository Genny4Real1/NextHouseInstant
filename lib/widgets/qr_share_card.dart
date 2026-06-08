import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Figma `Frame 7` QR share card (48:152) - 570.24x648.24 white rounded card
/// with a centered QR code and "Scan me!" caption.
/// `progress` (0.0-1.0) drives the thin progress bar at the bottom of the
/// card (replaces the 30s visible countdown with a 60s non-blocking indicator).
class QrShareCard extends StatelessWidget {
  final String data;
  final double progress;

  const QrShareCard({super.key, required this.data, this.progress = 0.0});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 570.24,
      height: 648.24,
      padding: const EdgeInsets.all(30.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(60.0),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 30.0,
            offset: Offset(0.0, 15.0),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: Center(
              child: QrImageView(
                data: data,
                version: QrVersions.auto,
                size: 510.24,
                gapless: false,
                errorStateBuilder: (cxt, err) => const SizedBox(
                  width: 200.0,
                  height: 200.0,
                  child: Center(
                    child: Text(
                      'Error generating QR Code',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          const Text('Scan me!', style: AppTextStyles.scanMe),
          const SizedBox(height: 16.0),
          ClipRRect(
            borderRadius: BorderRadius.circular(4.0),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 8.0,
              backgroundColor: const Color(0xFFE0E0E0),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.nextHouseOrange,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
