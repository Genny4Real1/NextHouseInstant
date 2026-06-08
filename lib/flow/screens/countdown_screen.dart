import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../../theme/app_text_styles.dart';

/// Figma 29-4, 33-15, 53-85..112, 57-209, 131-144.
/// Full-bleed camera preview with phased overlays:
///   - intro 0.0-0.8s: "Say..." top-left (suspense, Figma 131-144)
///   - t=5,4: "I love hostels!" top-left + number bottom-center
///   - t=3,2,1: number only
///   - flash: full-screen white overlay (handled by CaptureScreen, not here)
class CountdownScreen extends StatelessWidget {
  final int countdownValue;
  final bool introActive;
  final CameraController? cameraController;
  final String? capturedImagePath;

  const CountdownScreen({
    super.key,
    required this.countdownValue,
    required this.introActive,
    this.cameraController,
    this.capturedImagePath,
  });

  bool get _isCameraActive =>
      cameraController != null &&
      cameraController!.value.isInitialized;

  bool get _showTextOverlay => introActive || countdownValue >= 4;

  bool get _showNumberOverlay =>
      !introActive &&
      countdownValue >= 1 &&
      countdownValue <= 5;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        // 1. Camera preview (full-bleed) or fallback
        Positioned.fill(
          child: ColoredBox(
            color: Colors.black,
            child: _isCameraActive
                ? CameraPreview(cameraController!)
                : (capturedImagePath != null &&
                        capturedImagePath!.isNotEmpty)
                    ? Image.file(
                        File(capturedImagePath!),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const ColoredBox(color: Colors.black),
                      )
                    : const ColoredBox(color: Colors.black),
          ),
        ),

        // 2. Top-left text overlay
        if (_showTextOverlay)
          Positioned(
            left: 293.5,
            top: 112.0,
            width: 693.0,
            child: Text(
              introActive ? 'Say...' : 'I love hostels!',
              style: AppTextStyles.countdownTitle,
              textAlign: TextAlign.center,
            ),
          ),

        // 3. Centered number overlay
        if (_showNumberOverlay)
          Positioned(
            left: 0,
            right: 0,
            top: 342.0,
            child: Center(
              child: Text(
                '${countdownValue}',
                style: AppTextStyles.countdownNumber,
              ),
            ),
          ),
      ],
    );
  }
}
