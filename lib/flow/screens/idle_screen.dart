import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/kiosk_button.dart';

class IdleScreen extends StatelessWidget {
  final VoidCallback onStart;

  const IdleScreen({
    super.key,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s64),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icona superiore geometrica
              const Icon(
                Icons.camera_alt_outlined,
                size: 80.0,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: AppSpacing.s32),

              // Titolo principale
              const Text(
                'Scatta una foto ricordo',
                style: AppTextStyles.header1,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.s12),

              // Sottotitolo
              const Text(
                'Il servizio è gratuito e richiede pochi secondi.',
                style: AppTextStyles.header2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.s48),

              // Pulsante di avvio gigante
              Center(
                child: KioskButton(
                  text: 'Tocca per iniziare',
                  onPressed: onStart,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
