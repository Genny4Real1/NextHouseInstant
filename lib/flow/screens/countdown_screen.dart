import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/camera_placeholder.dart';
import '../../widgets/kiosk_container.dart';

class CountdownScreen extends StatelessWidget {
  final int countdownValue;
  final CameraController? cameraController;

  const CountdownScreen({
    super.key,
    required this.countdownValue,
    this.cameraController,
  });

  @override
  Widget build(BuildContext context) {
    final bool isCameraActive = cameraController != null && cameraController!.value.isInitialized;

    return Container(
      color: AppColors.background,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.s24,
            horizontal: AppSpacing.s64,
          ),
          child: Column(
            children: [
              // Intestazione
              const Text(
                'Preparati...',
                style: AppTextStyles.header1,
              ),
              const SizedBox(height: AppSpacing.s16),

              // Contenitore inquadratura con numero countdown sovrapposto
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 4 / 3,
                    child: KioskContainer(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Feed reale della camera (se attiva) oppure Placeholder di fallback
                          Positioned.fill(
                            child: isCameraActive
                                ? CameraPreview(cameraController!)
                                : const CameraPlaceholder(showGuides: false),
                          ),

                          // Silhouette stilizzata e guide disegnate sopra (senza sfondo coprente)
                          const Positioned.fill(
                            child: CameraPlaceholder(
                              showGuides: true,
                              showBackground: false,
                            ),
                          ),

                          // Leggera sfumatura scura per aumentare il contrasto del numero
                          Container(
                            color: const Color(0x26000000),
                          ),

                          // Numero countdown gigante animato ad ogni secondo
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            transitionBuilder: (child, animation) {
                              return ScaleTransition(
                                scale: Tween<double>(begin: 0.7, end: 1.0).animate(
                                  CurvedAnimation(
                                    parent: animation,
                                    curve: Curves.easeOutBack,
                                  ),
                                ),
                                child: FadeTransition(
                                  opacity: animation,
                                  child: child,
                                ),
                              );
                            },
                            child: Text(
                              '$countdownValue',
                              key: ValueKey<int>(countdownValue),
                              style: AppTextStyles.countdownDisplay,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.s16),

              // Istruzione in basso
              const Text(
                'Sorridi all\'obiettivo',
                style: AppTextStyles.header2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
