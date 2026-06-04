import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/app_durations.dart';
import '../../widgets/processing_card.dart';

/// Figma node 33:23 — `Camera Screen Processing` (1280x800, black bg).
/// The screen renders a blurred background photo (Figma 33:24) and the
/// orange `ProcessingCard` (Figma 74:86) positioned at the Figma frame's
/// absolute coordinates.
class ProcessingScreen extends StatefulWidget {
  final String? capturedImagePath;

  const ProcessingScreen({super.key, this.capturedImagePath});

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: AppDurations.processingRotation,
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool hasCapturedImage =
        widget.capturedImagePath != null &&
        widget.capturedImagePath!.isNotEmpty;

    return Stack(
      children: [
        // 1. Sfondo nero a tutto schermo
        Container(color: Colors.black),

        // 2. Foto sfocata di sfondo, posizionata come da Figma (33:24)
        Positioned(
          left: 29.0,
          top: 1.0,
          width: 1212.0,
          height: 808.0,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 3.5, sigmaY: 3.5),
            child: hasCapturedImage
                ? Image.file(
                    File(widget.capturedImagePath!),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Image.asset(
                      'assets/images/processing_bg_sample.png',
                      fit: BoxFit.cover,
                    ),
                  )
                : Image.asset(
                    'assets/images/processing_bg_sample.png',
                    fit: BoxFit.cover,
                  ),
          ),
        ),

        // 3. Card arancione "Processing" (Figma 74:86)
        Positioned(
          left: 334.56,
          top: 178.02,
          child: ProcessingCard(rotation: _rotationController),
        ),
      ],
    );
  }
}
