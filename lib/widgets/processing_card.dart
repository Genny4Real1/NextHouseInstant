import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Orange processing card overlay (Figma nodes 74:83 / 74:86 — `NextHouse_SpinningProcessing`).
/// Renders the "Processing" label and the spinning wheel bundled at
/// `assets/images/processing_spinner.png` (Figma node 74:74).
class ProcessingCard extends StatelessWidget {
  final Animation<double> rotation;

  const ProcessingCard({super.key, required this.rotation});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 600.88,
      padding: const EdgeInsets.symmetric(
        vertical: 42.0,
        horizontal: AppSpacing.s48,
      ),
      decoration: BoxDecoration(
        color: AppColors.nextHouseOrange,
        borderRadius: BorderRadius.circular(60.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x4C000000),
            blurRadius: 30.0,
            offset: Offset(0.0, 15.0),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Processing', style: AppTextStyles.processingTitle),
          const SizedBox(height: 42.0),
          RotationTransition(
            turns: rotation,
            child: Image.asset(
              'assets/images/processing_spinner.png',
              width: 262.56,
              height: 259.67,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const SizedBox(
                width: 100.0,
                height: 100.0,
                child: CircularProgressIndicator(
                  strokeWidth: 6.0,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
