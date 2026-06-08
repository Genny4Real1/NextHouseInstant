import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/kiosk_button.dart';
import '../../widgets/nexthouse_instant_logo.dart';

/// Figma node 1:2 — "Start Page" (white bg).
/// Hosts the Nexthouseinstant_logo (257:209) and the asymmetric
/// NextHouse_Selfie_Button (28:236).
class IdleScreen extends StatelessWidget {
  final VoidCallback onStart;

  const IdleScreen({super.key, required this.onStart});

  static const _selfieButtonBorderRadius = BorderRadius.only(
    topRight: Radius.circular(80.0),
    bottomLeft: Radius.circular(80.0),
    bottomRight: Radius.circular(80.0),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Nexthouseinstant_logo (Figma 257:209)
              const NexthouseInstantLogo(
                width: 719.0,
                height: 509.322,
              ),
              const SizedBox(height: 48.0),

              // CTA "TAKE A SELFIE" (Figma 28:236) — geometria intenzionalmente
              // cablata sui valori del Figma frame (AGENT.md §1.4).
              KioskButton(
                text: 'TAKE A SELFIE',
                onPressed: onStart,
                backgroundColor: AppColors.nextHouseBlack,
                textColor: Colors.white,
                width: 694.0,
                height: 171.0,
                borderRadius: _selfieButtonBorderRadius,
                textStyle: AppTextStyles.kioskCta,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
