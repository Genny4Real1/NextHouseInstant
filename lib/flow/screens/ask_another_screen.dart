import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/camera_placeholder.dart';

class AskAnotherScreen extends StatelessWidget {
  final String? capturedImagePath;
  final VoidCallback onYes;
  final VoidCallback onNo;

  const AskAnotherScreen({
    super.key,
    required this.capturedImagePath,
    required this.onYes,
    required this.onNo,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasCapturedImage = capturedImagePath != null && capturedImagePath!.isNotEmpty;

    return Stack(
      children: [
        // Sfondo con la foto scattata sfocata
        Positioned.fill(
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(
              color: Colors.black,
              child: Opacity(
                opacity: 0.7,
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

        // Sfondo semitrasparente scuro per concentrare l'attenzione
        Positioned.fill(
          child: Container(
            color: Colors.black.withAlpha(50),
          ),
        ),

        // Dialogo di richiesta al centro
        Center(
          child: Container(
            width: 540.0,
            height: 380.0,
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.s32,
              horizontal: AppSpacing.s48,
            ),
            decoration: BoxDecoration(
              color: AppColors.nextHouseOrange,
              borderRadius: BorderRadius.circular(40.0),
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
                const Expanded(
                  child: Center(
                    child: Text(
                      'Do you want to take another picture?',
                      style: TextStyle(
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
                      text: 'Yes',
                      onPressed: onYes,
                    ),
                    
                    // Pulsante No
                    _buildDialogButton(
                      text: 'No',
                      onPressed: onNo,
                    ),
                  ],
                ),
              ],
            ),
          ),
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
