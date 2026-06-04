import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Figma `NextHouse_Record_Button` Variant4 (filled) at 154x155.
/// Decorative — no tap handler. Used in the CountdownScreen right-center
/// (Figma coord 1141, 327.5 on the 1280x800 frame).
class RecordButton extends StatelessWidget {
  final double size;
  final Color color;

  const RecordButton({
    super.key,
    this.size = 154.0,
    this.color = AppColors.nextHouseOrange,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _RecordButtonPainter(color: color)),
    );
  }
}

class _RecordButtonPainter extends CustomPainter {
  final Color color;
  const _RecordButtonPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    final Paint outerPaint = Paint()..color = color;
    final Paint innerPaint = Paint()
      ..color = const Color(0xFF1A1A1A)
      ..style = PaintingStyle.fill;
    final Paint strokePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    final Offset center = Offset(w / 2, h / 2);
    final double outerRadius = (w < h ? w : h) / 2;

    canvas.drawCircle(center, outerRadius, outerPaint);
    canvas.drawCircle(center, outerRadius * 0.6, innerPaint);
    canvas.drawCircle(center, outerRadius * 0.6, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _RecordButtonPainter oldDelegate) =>
      oldDelegate.color != color;
}
