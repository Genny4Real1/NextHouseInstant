import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';

/// Figma 57-217 - blurred photo, no UI. Holds 250ms between the flash
/// and the Processing screen.
class CaptureEndScreen extends StatelessWidget {
  final String? capturedImagePath;

  const CaptureEndScreen({super.key, this.capturedImagePath});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: ColoredBox(
            color: Colors.black,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
              child: (capturedImagePath != null && capturedImagePath!.isNotEmpty)
                  ? Image.file(
                      File(capturedImagePath!),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const ColoredBox(color: Colors.black),
                    )
                  : const ColoredBox(color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }
}
