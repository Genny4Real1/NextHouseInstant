import 'package:flutter/material.dart';
import 'dart:math';

class QrCodePlaceholder extends StatelessWidget {
  final double size;
  final Color qrColor;
  final Color backgroundColor;

  const QrCodePlaceholder({
    super.key,
    this.size = 260.0,
    this.qrColor = const Color(0xFF0F172A), // Slate Obsidian per il contrasto sul QR bianco
    this.backgroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: CustomPaint(
        size: Size(size - 32.0, size - 32.0),
        painter: QrCodePainter(
          color: qrColor,
        ),
      ),
    );
  }
}

class QrCodePainter extends CustomPainter {
  final Color color;

  QrCodePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    const int gridSize = 25;
    final double moduleSize = size.width / gridSize;

    void drawModule(int x, int y) {
      canvas.drawRect(
        Rect.fromLTWH(
          x * moduleSize,
          y * moduleSize,
          moduleSize,
          moduleSize,
        ),
        paint,
      );
    }

    void drawFinderPattern(int ox, int oy) {
      // Quadrato esterno 7x7
      for (int i = 0; i < 7; i++) {
        for (int j = 0; j < 7; j++) {
          if (i == 0 || i == 6 || j == 0 || j == 6) {
            drawModule(ox + i, oy + j);
          }
        }
      }
      // Quadrato interno 3x3
      for (int i = 2; i < 5; i++) {
        for (int j = 2; j < 5; j++) {
          drawModule(ox + i, oy + j);
        }
      }
    }

    // 1. Finder Patterns angolari
    drawFinderPattern(0, 0); // Top-Left
    drawFinderPattern(gridSize - 7, 0); // Top-Right
    drawFinderPattern(0, gridSize - 7); // Bottom-Left

    // 2. Alignment Pattern (basso a destra)
    const int ax = 16;
    const int ay = 16;
    for (int i = 0; i < 5; i++) {
      for (int j = 0; j < 5; j++) {
        if (i == 0 || i == 4 || j == 0 || j == 4 || (i == 2 && j == 2)) {
          drawModule(ax + i, ay + j);
        }
      }
    }

    // 3. Moduli dati casuali deterministici
    final Random random = Random(1337);

    bool isReservedArea(int x, int y) {
      if (x < 8 && y < 8) return true; // Top-Left Finder
      if (x >= gridSize - 8 && y < 8) return true; // Top-Right Finder
      if (x < 8 && y >= gridSize - 8) return true; // Bottom-Left Finder
      if (x >= ax && x < ax + 5 && y >= ay && y < ay + 5) return true; // Alignment
      if (x == 6 || y == 6) return true; // Linee di timing
      return false;
    }

    for (int x = 0; x < gridSize; x++) {
      for (int y = 0; y < gridSize; y++) {
        if (!isReservedArea(x, y)) {
          if (random.nextBool()) {
            drawModule(x, y);
          }
        }
      }
    }

    // 4. Linee di sincronia/timing
    for (int i = 8; i < gridSize - 8; i++) {
      if (i % 2 == 0) {
        drawModule(6, i);
        drawModule(i, 6);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
