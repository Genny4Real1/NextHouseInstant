import 'dart:io';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/camera_placeholder.dart';

class ResultScreen extends StatelessWidget {
  final VoidCallback onReset;
  final VoidCallback onDone;
  final VoidCallback onDelete;
  final VoidCallback onShare;
  final bool showDoneToolbar;
  final List<String> capturedImages;
  final int currentGalleryIndex;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const ResultScreen({
    super.key,
    required this.onReset,
    required this.onDone,
    required this.onDelete,
    required this.onShare,
    required this.showDoneToolbar,
    required this.capturedImages,
    required this.currentGalleryIndex,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasImages = capturedImages.isNotEmpty;
    final String currentImagePath = hasImages ? capturedImages[currentGalleryIndex] : '';

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Contenuto principale
            Column(
              children: [
                const SizedBox(height: AppSpacing.s24),
                // Indicatore contatore foto in alto (es. 2 / 3)
                if (hasImages && capturedImages.length > 1)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.s16,
                      vertical: AppSpacing.s8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(25),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Text(
                      '${currentGalleryIndex + 1} / ${capturedImages.length}',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        color: Colors.white,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const SizedBox(height: AppSpacing.s16),

                // Contenitore della foto
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s64),
                      child: AspectRatio(
                        aspectRatio: 4 / 3,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(24.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(127),
                                blurRadius: 25.0,
                                spreadRadius: 2.0,
                              ),
                            ],
                          ),
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onHorizontalDragEnd: (details) {
                              if (!showDoneToolbar) return; // Disabilita lo scorrimento prima di premere Done
                              if (details.primaryVelocity == null) return;
                              if (details.primaryVelocity! > 0) {
                                // Trascina verso destra -> foto precedente
                                onPrevious();
                              } else if (details.primaryVelocity! < 0) {
                                // Trascina verso sinistra -> foto successiva
                                onNext();
                              }
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24.0),
                              child: hasImages
                                  ? AnimatedSwitcher(
                                      duration: const Duration(milliseconds: 250),
                                      transitionBuilder: (child, animation) {
                                        return FadeTransition(
                                          opacity: animation,
                                          child: child,
                                        );
                                      },
                                      child: Image.file(
                                        File(currentImagePath),
                                        key: ValueKey<int>(currentGalleryIndex),
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                        errorBuilder: (context, error, stackTrace) =>
                                            const CameraPlaceholder(showGuides: false),
                                      ),
                                    )
                                  : const CameraPlaceholder(showGuides: false),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.s32),

                // Sezione inferiore animata (Pulsante Done vs. Toolbar con pulsanti disabilitati)
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: !showDoneToolbar
                      ? Center(
                          key: const ValueKey('done_button_view'),
                          child: SizedBox(
                            width: 160.0,
                            height: 56.0,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.black,
                                backgroundColor: Colors.white,
                                elevation: 2.0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28.0),
                                ),
                              ),
                              onPressed: onDone,
                              child: const Text(
                                'Done',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        )
                      : Container(
                          key: const ValueKey('toolbar_view'),
                          width: 600.0,
                          height: 72.0,
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s32),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildDisabledToolbarButton(
                                icon: Icons.edit_rounded,
                                label: 'Edit',
                              ),
                              _buildActiveToolbarButton(
                                icon: Icons.ios_share_rounded,
                                label: 'Share',
                                onPressed: onShare,
                                iconColor: AppColors.primary,
                              ),
                              _buildActiveToolbarButton(
                                icon: Icons.delete_outline_rounded,
                                label: 'Delete',
                                onPressed: onDelete,
                                iconColor: AppColors.error,
                              ),
                              _buildDisabledToolbarButton(
                                icon: Icons.print_rounded,
                                label: 'Print',
                              ),
                            ],
                          ),
                        ),
                ),
                const SizedBox(height: AppSpacing.s24),
              ],
            ),

            // Pulsante Freccia Sinistra (Precedente)
            if (showDoneToolbar && hasImages && capturedImages.length > 1)
              Positioned(
                left: 24.0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(25),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    iconSize: 40.0,
                    icon: const Icon(
                      Icons.chevron_left_rounded,
                      color: Colors.white,
                    ),
                    onPressed: onPrevious,
                  ),
                ),
              ),

            // Pulsante Freccia Destra (Successiva)
            if (showDoneToolbar && hasImages && capturedImages.length > 1)
              Positioned(
                right: 24.0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(25),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    iconSize: 40.0,
                    icon: const Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.white,
                    ),
                    onPressed: onNext,
                  ),
                ),
              ),

            // Pulsante Chiudi/Esci discreto in alto a destra
            Positioned(
              top: 16.0,
              right: 16.0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  iconSize: 24.0,
                  icon: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                  ),
                  onPressed: onReset,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisabledToolbarButton({
    required IconData icon,
    required String label,
  }) {
    return Opacity(
      opacity: 0.4, // Mostra i pulsanti chiaramente disabilitati/non cliccabili
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 32.0,
          ),
          const SizedBox(height: 4.0),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Inter',
              color: Colors.white,
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveToolbarButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    Color iconColor = Colors.white,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: iconColor,
                size: 32.0,
              ),
              const SizedBox(height: 4.0),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  color: Colors.white,
                  fontSize: 14.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
