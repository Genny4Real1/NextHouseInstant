import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class CameraPlaceholder extends StatelessWidget {
  final bool showGuides;
  final bool showBackground;

  const CameraPlaceholder({
    super.key,
    this.showGuides = true,
    this.showBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Sfondo camera simulato con gradiente naturale (opzionale)
        if (showBackground)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF1E293B), // Charcoal Gray
                  Color(0xFF0F172A), // Slate Obsidian
                ],
              ),
            ),
          ),

        // Silhouette stilizzata per posizionamento viso
        if (showGuides)
          Center(
            child: Opacity(
              opacity: 0.1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 130,
                    height: 170,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.textPrimary,
                        width: 2.0,
                      ),
                      borderRadius: const BorderRadius.all(Radius.elliptical(65, 85)),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s16),
                  Container(
                    width: 260,
                    height: 90,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.textPrimary,
                        width: 2.0,
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(80),
                        topRight: Radius.circular(80),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Mirini d'angolo disegnati a mano
        if (showGuides)
          Positioned.fill(
            child: CustomPaint(
              painter: CameraReticlePainter(),
            ),
          ),
        
        // Indicatore lente virtuale in alto al centro
        if (showBackground)
          Positioned(
            top: AppSpacing.s16,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 12.0,
                height: 12.0,
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(51),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withAlpha(153),
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class CameraReticlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.textSecondary.withAlpha(76)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    const double lineLength = 20.0;
    const double padding = 24.0;

    // Angolo Top-Left
    canvas.drawLine(
      const Offset(padding, padding),
      const Offset(padding + lineLength, padding),
      paint,
    );
    canvas.drawLine(
      const Offset(padding, padding),
      const Offset(padding, padding + lineLength),
      paint,
    );

    // Angolo Top-Right
    canvas.drawLine(
      Offset(size.width - padding, padding),
      Offset(size.width - padding - lineLength, padding),
      paint,
    );
    canvas.drawLine(
      Offset(size.width - padding, padding),
      Offset(size.width - padding, padding + lineLength),
      paint,
    );

    // Angolo Bottom-Left
    canvas.drawLine(
      Offset(padding, size.height - padding),
      Offset(padding + lineLength, size.height - padding),
      paint,
    );
    canvas.drawLine(
      Offset(padding, size.height - padding),
      Offset(padding, size.height - padding - lineLength),
      paint,
    );

    // Angolo Bottom-Right
    canvas.drawLine(
      Offset(size.width - padding, size.height - padding),
      Offset(size.width - padding - lineLength, size.height - padding),
      paint,
    );
    canvas.drawLine(
      Offset(size.width - padding, size.height - padding),
      Offset(size.width - padding, size.height - padding - lineLength),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
