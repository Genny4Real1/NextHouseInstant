import 'dart:io';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/camera_placeholder.dart';

class PhotoSelectionShareScreen extends StatelessWidget {
  final List<String> capturedImages;
  final Set<String> selectedImages;
  final Function(String) onToggleSelection;
  final VoidCallback onCancel;
  final VoidCallback onDone;

  const PhotoSelectionShareScreen({
    super.key,
    required this.capturedImages,
    required this.selectedImages,
    required this.onToggleSelection,
    required this.onCancel,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasSelection = selectedImages.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.s24),
                // Titolo della pagina
                const Text(
                  'Condividi le tue foto',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: Colors.white,
                    fontSize: 32.0,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4.0),
                const Text(
                  'Seleziona le immagini che desideri salvare',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: AppColors.textSecondary,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.s24),

                // Lista orizzontale di foto
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 280.0),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s48),
                        itemCount: capturedImages.length,
                        itemBuilder: (context, index) {
                          final String path = capturedImages[index];
                          final bool isSelected = selectedImages.contains(path);

                          return GestureDetector(
                            onTap: () => onToggleSelection(path),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.s12),
                              width: 320.0,
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(24.0),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : Colors.white.withAlpha(20),
                                  width: 3.0,
                                ),
                                boxShadow: [
                                  if (isSelected)
                                    BoxShadow(
                                      color: AppColors.primary.withAlpha(50),
                                      blurRadius: 15.0,
                                      spreadRadius: 1.0,
                                    )
                                  else
                                    BoxShadow(
                                      color: Colors.black.withAlpha(50),
                                      blurRadius: 10.0,
                                    ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(21.0),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    // La Foto
                                    Image.file(
                                      File(path),
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) =>
                                          const CameraPlaceholder(showGuides: false),
                                    ),
                                    // Overlay oscurante se non selezionata
                                    AnimatedOpacity(
                                      opacity: isSelected ? 0.0 : 0.4,
                                      duration: const Duration(milliseconds: 200),
                                      child: Container(
                                        color: Colors.black,
                                      ),
                                    ),
                                    // Indicatore di selezione (Checkmark) in alto a destra
                                    Positioned(
                                      top: 16.0,
                                      right: 16.0,
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        padding: const EdgeInsets.all(4.0),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? AppColors.primary
                                              : Colors.black.withAlpha(100),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 2.0,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.check_rounded,
                                          size: 24.0,
                                          color: isSelected ? Colors.black : Colors.transparent,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.s32),

                // Barra dei pulsanti inferiore
                Center(
                  child: SizedBox(
                    width: 200.0,
                    height: 56.0,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.black,
                        backgroundColor: hasSelection ? Colors.white : Colors.white.withAlpha(50),
                        elevation: hasSelection ? 4.0 : 0.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28.0),
                        ),
                      ),
                      onPressed: hasSelection ? onDone : null,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Condividi',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: hasSelection ? Colors.black : Colors.white.withAlpha(80),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.s8),
                          Icon(
                            Icons.arrow_forward_rounded,
                            color: hasSelection ? Colors.black : Colors.white.withAlpha(80),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.s24),
              ],
            ),

            // Pulsante Chiudi/Annulla in alto a destra
            Positioned(
              top: 20.0,
              right: 20.0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  iconSize: 28.0,
                  icon: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                  ),
                  onPressed: onCancel,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
