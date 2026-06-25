import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/camera_placeholder.dart';

import '../photobooth_flow_state.dart';
import 'package:nexthouse_instant/l10n/app_localizations.dart';
import '../../widgets/language_selector.dart';

class AskAnotherScreen extends StatelessWidget {
  final String? capturedImagePath;
  final VoidCallback onYes;
  final VoidCallback onNo;
  final PhotoboothFlowState flowState;

  const AskAnotherScreen({
    super.key,
    required this.capturedImagePath,
    required this.onYes,
    required this.onNo,
    required this.flowState,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasCapturedImage = capturedImagePath != null && capturedImagePath!.isNotEmpty;

    return Stack(
      children: [
        // Sfondo con la foto scattata (senza sfocatura e a piena luminosità)
        Positioned.fill(
          child: hasCapturedImage
              ? Image.file(
                  File(capturedImagePath!),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const CameraPlaceholder(showGuides: false),
                )
              : const CameraPlaceholder(showGuides: false),
        ),

        // Dialogo di richiesta al centro con glassmorphism
        Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(40.0),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(
                width: 540.0,
                height: 380.0,
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.s32,
                  horizontal: AppSpacing.s48,
                ),
                decoration: BoxDecoration(
                  color: AppColors.nextHouseOrange.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(40.0),
                  border: Border.all(
                    color: Colors.white.withAlpha(25),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(76),
                      blurRadius: 30.0,
                      offset: const Offset(0.0, 15.0),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Domanda
                    Expanded(
                      child: Center(
                        child: Text(
                          AppLocalizations.of(context)!.takeAnotherQuestion,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 36.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s24),

                    // Pulsanti Sì / No
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Pulsante Sì
                        _buildDialogButton(
                          text: AppLocalizations.of(context)!.yes,
                          onPressed: onYes,
                        ),
                        
                        // Pulsante No
                        _buildDialogButton(
                          text: AppLocalizations.of(context)!.no,
                          onPressed: onNo,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Selettore della lingua in alto a destra
        Positioned(
          top: 24.0,
          right: 24.0,
          child: LanguageSelector(flowState: flowState),
        ),
      ],
    );
  }

  Widget _buildDialogButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 180.0,
      height: 72.0,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: AppColors.nextHouseOrange,
          backgroundColor: Colors.white,
          elevation: 4.0,
          shadowColor: Colors.black.withAlpha(50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(36.0),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 28.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
