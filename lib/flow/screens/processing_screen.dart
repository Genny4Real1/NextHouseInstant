import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/camera_placeholder.dart';

import '../photobooth_flow_state.dart';
import 'package:nexthouse_instant/l10n/app_localizations.dart';

class ProcessingScreen extends StatefulWidget {
  final String? capturedImagePath;
  final String? activeFilter;
  final PhotoboothFlowState flowState;

  const ProcessingScreen({
    super.key,
    this.capturedImagePath,
    this.activeFilter,
    required this.flowState,
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
          0.2126,
          0.7152,
          0.0722,
          0.0,
          0.0,
          0.2126,
          0.7152,
          0.0722,
          0.0,
          0.0,
          0.2126,
          0.7152,
          0.0722,
          0.0,
          0.0,
          0.0,
          0.0,
          0.0,
          1.0,
          0.0,
        ];
      case 'sepia':
        return [
          0.393,
          0.769,
          0.189,
          0.0,
          0.0,
          0.349,
          0.686,
          0.168,
          0.0,
          0.0,
          0.272,
          0.534,
          0.131,
          0.0,
          0.0,
          0.0,
          0.0,
          0.0,
          1.0,
          0.0,
        ];
      case 'cool':
        return [
          0.9,
          0.0,
          0.1,
          0.0,
          0.0,
          0.0,
          0.9,
          0.1,
          0.0,
          0.0,
          0.0,
          0.0,
          1.2,
          0.0,
          0.0,
          0.0,
          0.0,
          0.0,
          1.0,
          0.0,
        ];
      case 'warm':
        return [
          1.2,
          0.0,
          0.0,
          0.0,
          0.0,
          0.0,
          1.0,
          0.0,
          0.0,
          0.0,
          0.0,
          0.0,
          0.8,
          0.0,
          0.0,
          0.0,
          0.0,
          0.0,
          1.0,
          0.0,
        ];
      default:
        return [
          1.0,
          0.0,
          0.0,
          0.0,
          0.0,
          0.0,
          1.0,
          0.0,
          0.0,
          0.0,
          0.0,
          0.0,
          1.0,
          0.0,
          0.0,
          0.0,
          0.0,
          0.0,
          1.0,
          0.0,
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasCapturedImage =
        widget.capturedImagePath != null &&
        widget.capturedImagePath!.isNotEmpty;

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
                        colorFilter: ColorFilter.matrix(
                          _getColorMatrix(widget.activeFilter),
                        ),
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
        Positioned.fill(child: Container(color: Colors.black.withAlpha(50))),

        // Box arancione centrale di elaborazione con glassmorphism
        Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(60.0),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
              child: Container(
                width: 600.0,
                height: 440.0,
                 padding: const EdgeInsets.symmetric(
                  vertical: 28.0,
                  horizontal: AppSpacing.s48,
                ),
                decoration: BoxDecoration(
                  color: AppColors.nextHouseOrange.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(60.0),
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
                    // Testo "Processing" (FittedBox previene overflow da traduzione)
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        AppLocalizations.of(context)!.processing,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 72.0,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 1.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 20.0),

                    // Premium custom vector-based loader (prevents freezes & pixelation)
                    PremiumLoader(animation: _rotationController),
                  ],
                ),
              ),
            ),
          ),
        ),

      ],
    );
  }
}

class PremiumLoader extends StatelessWidget {
  final Animation<double> animation;
  final double size;

  const PremiumLoader({
    super.key,
    required this.animation,
    this.size = 180.0,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer Track & Sweeping Arc (Orange, clockwise)
              CustomPaint(
                size: Size(size, size),
                painter: ClassicArcPainter(
                  progress: animation.value,
                  strokeWidth: 3.5,
                  trackColor: Colors.white.withValues(alpha: 0.08),
                  arcColor: AppColors.nextHouseOrange,
                  isClockwise: true,
                ),
              ),
              
              // Inner Track & Sweeping Arc (Cyan, counter-clockwise)
              CustomPaint(
                size: Size(size * 0.78, size * 0.78),
                painter: ClassicArcPainter(
                  progress: animation.value,
                  strokeWidth: 2.5,
                  trackColor: Colors.white.withValues(alpha: 0.05),
                  arcColor: AppColors.primary.withValues(alpha: 0.7),
                  isClockwise: false,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ClassicArcPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color trackColor;
  final Color arcColor;
  final bool isClockwise;

  ClassicArcPainter({
    required this.progress,
    required this.strokeWidth,
    required this.trackColor,
    required this.arcColor,
    required this.isClockwise,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final Paint trackPaint = Paint()
      ..color = trackColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    // Draw the full background track circle
    canvas.drawCircle(rect.center, (size.width - strokeWidth) / 2, trackPaint);

    // Compute animated angle
    final double rotationAngle = (isClockwise ? progress : -progress) * 2 * math.pi;

    // Gradient Sweep Paint
    final Paint arcPaint = Paint()
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        colors: [
          arcColor.withValues(alpha: 0.0),
          arcColor,
        ],
        stops: const [0.0, 1.0],
        transform: GradientRotation(rotationAngle - math.pi / 2),
      ).createShader(rect);

    // Draw a 240-degree sweeping arc (4.18879 radians)
    canvas.drawArc(
      rect.deflate(strokeWidth / 2),
      rotationAngle - 1.57079632679, // rotate starting point with animation
      4.18879020479, // 240 degrees
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(covariant ClassicArcPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.arcColor != arcColor ||
        oldDelegate.isClockwise != isClockwise;
  }
}
