import 'dart:ui';
import 'package:flutter/material.dart';

/// Figma 57-217 - blurred photo, no UI. Holds 250ms between the flash
/// and the Processing screen.
class CaptureEndScreen extends StatelessWidget {
  const CaptureEndScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: ColoredBox(
            color: Colors.black,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
              child: Image.asset(
                'assets/images/processing_bg_sample.png',
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) =>
                    const ColoredBox(color: Colors.black),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
