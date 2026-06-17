import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/camera_placeholder.dart';

class ProcessingScreen extends StatefulWidget {
  final String? capturedImagePath;
  final String? activeFilter;

  const ProcessingScreen({
    super.key,
    this.capturedImagePath,
    this.activeFilter,
  });

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    // Animazione di rotazione continua (1 giro completo ogni 2 secondi)
    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  List<double> _getColorMatrix(String? filter) {
    switch (filter) {
      case 'grayscale':
        return [
          0.2126, 0.7152, 0.0722, 0.0, 0.0,
          0.2126, 0.7152, 0.0722, 0.0, 0.0,
          0.2126, 0.7152, 0.0722, 0.0, 0.0,
          0.0,    0.0,    0.0,    1.0, 0.0,
        ];
      case 'sepia':
        return [
          0.393, 0.769, 0.189, 0.0, 0.0,
          0.349, 0.686, 0.168, 0.0, 0.0,
          0.272, 0.534, 0.131, 0.0, 0.0,
          0.0,   0.0,   0.0,   1.0, 0.0,
        ];
      case 'cool':
        return [
          0.9, 0.0, 0.1, 0.0, 0.0,
          0.0, 0.9, 0.1, 0.0, 0.0,
          0.0, 0.0, 1.2, 0.0, 0.0,
          0.0, 0.0, 0.0, 1.0, 0.0,
        ];
      case 'warm':
        return [
          1.2, 0.0, 0.0, 0.0, 0.0,
          0.0, 1.0, 0.0, 0.0, 0.0,
          0.0, 0.0, 0.8, 0.0, 0.0,
          0.0, 0.0, 0.0, 1.0, 0.0,
        ];
      default:
        return [
          1.0, 0.0, 0.0, 0.0, 0.0,
          0.0, 1.0, 0.0, 0.0, 0.0,
          0.0, 0.0, 1.0, 0.0, 0.0,
          0.0, 0.0, 0.0, 1.0, 0.0,
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasCapturedImage = widget.capturedImagePath != null && widget.capturedImagePath!.isNotEmpty;

    return Stack(
      children: [
        // Sfondo sfocato dell'ultima foto scattata con il filtro applicato
        Positioned.fill(
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(
              color: Colors.black,
              child: Opacity(
                opacity: 0.7,
                child: hasCapturedImage
                    ? ColorFiltered(
                        colorFilter: ColorFilter.matrix(_getColorMatrix(widget.activeFilter)),
                        child: Image.file(
                          File(widget.capturedImagePath!),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const CameraPlaceholder(showGuides: false),
                        ),
                      )
                    : const CameraPlaceholder(showGuides: false),
              ),
            ),
          ),
        ),

        // Sfondo semitrasparente
        Positioned.fill(
          child: Container(
            color: Colors.black.withAlpha(50),
          ),
        ),

        // Box arancione centrale di elaborazione
        Center(
          child: Container(
            width: 600.0,
            height: 440.0,
            padding: const EdgeInsets.symmetric(
              vertical: 40.0,
              horizontal: AppSpacing.s48,
            ),
            decoration: BoxDecoration(
              color: AppColors.nextHouseOrange.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(60.0),
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
                // Testo "Processing"
                const Text(
                  'Processing',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 72.0,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 1.0,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40.0),

                // Ruota di caricamento che gira da Figma
                RotationTransition(
                  turns: _rotationController,
                  child: Image.network(
                    'http://localhost:3845/assets/d8785036d17612960f0b02a9176166b7c5010ebc.png',
                    width: 220.0,
                    height: 220.0,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback se il server locale non risponde
                      return const SizedBox(
                        width: 100.0,
                        height: 100.0,
                        child: CircularProgressIndicator(
                          strokeWidth: 6.0,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
