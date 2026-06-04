import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/kiosk_button.dart';

/// Figma node 28:234 — `Frame 2` (864x521.86) on the white "Start Page".
/// Hosts the `NextHouse_Logo` (28:235) and the asymmetric `NextHouse_Selfie_Button`
/// (28:236) routed through the extended `KioskButton`.
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
              // Logo Next House Copenhagen da Figma (local asset)
              Image.asset(
                'assets/images/nexthouse_logo.png',
                height: 250.0,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Text(
                    'Next House\nCOPENHAGEN',
                    style: AppTextStyles.body.copyWith(
                      fontSize: 48.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      letterSpacing: 2.0,
                    ),
                    textAlign: TextAlign.center,
                  );
                },
              ),
              const SizedBox(height: AppSpacing.s48),

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
