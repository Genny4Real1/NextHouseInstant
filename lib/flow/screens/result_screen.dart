import 'dart:io';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/camera_placeholder.dart';
import '../../widgets/qr_code_placeholder.dart';
import '../../widgets/kiosk_container.dart';
import '../../widgets/kiosk_button.dart';

class ResultScreen extends StatelessWidget {
  final VoidCallback onReset;
  final String? capturedImagePath;

  const ResultScreen({
    super.key,
    required this.onReset,
    this.capturedImagePath,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasCapturedImage = capturedImagePath != null && capturedImagePath!.isNotEmpty;

    return Container(
      color: AppColors.background,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s32),
          child: Column(
            children: [
              // Layout a due colonne (split-screen)
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Colonna sinistra: Anteprima reale della foto scattata o fallback placeholder
                    Expanded(
                      flex: 4,
                      child: Center(
                        child: AspectRatio(
                          aspectRatio: 4 / 3,
                          child: KioskContainer(
                            child: hasCapturedImage
                                ? Image.file(
                                    File(capturedImagePath!),
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        const CameraPlaceholder(showGuides: false),
                                  )
                                : const CameraPlaceholder(showGuides: false),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: AppSpacing.s48),

                    // Colonna destra: QR Code e istruzioni
                    Expanded(
                      flex: 5,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Inquadra per scaricare la foto',
                            style: AppTextStyles.header1,
                          ),
                          const SizedBox(height: AppSpacing.s8),
                          const Text(
                            'Scansiona il codice QR con il tuo telefono per salvare il tuo scatto souvenir.',
                            style: AppTextStyles.header2,
                          ),
                          const SizedBox(height: AppSpacing.s24),
                          
                          // QR Code fittizio ad alta fedeltà
                          const Center(
                            child: QrCodePlaceholder(
                              size: 200.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.s24),

              // Pulsante "Fine" in basso
              Center(
                child: KioskButton(
                  text: 'Fine',
                  onPressed: onReset,
                  backgroundColor: AppColors.surface,
                  textColor: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
