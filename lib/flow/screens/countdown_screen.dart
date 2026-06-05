import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/onboarding_overlay.dart';
import '../../widgets/record_button.dart';

/// Figma 29-4, 33-15, 53-85..112, 57-209, 131-144.
/// Full-bleed camera preview with phased overlays:
///   - intro 0.0-0.8s: "Say..." top-left (suspense, Figma 131-144)
///   - t=5,4: "I love hostels!" top-left + number bottom-center
///   - t=3,2,1: number only
///   - flash: full-screen white overlay (handled by CaptureScreen, not here)
class CountdownScreen extends StatefulWidget {
  final int countdownValue;
  final bool introActive;
  final CameraController? cameraController;
  final VoidCallback? onDismissOnboarding;

  const CountdownScreen({
    super.key,
    required this.countdownValue,
    required this.introActive,
    this.cameraController,
    this.onDismissOnboarding,
  });

  @override
  State<CountdownScreen> createState() => _CountdownScreenState();
}

class _CountdownScreenState extends State<CountdownScreen> {
  bool _showOnboarding = true;

  bool get _isCameraActive =>
      widget.cameraController != null &&
      widget.cameraController!.value.isInitialized;

  bool get _showTextOverlay => widget.introActive || widget.countdownValue >= 4;

  bool get _showNumberOverlay =>
      !widget.introActive &&
      widget.countdownValue >= 1 &&
      widget.countdownValue <= 5;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        // 1. Camera preview (full-bleed) or fallback
        Positioned.fill(
          child: ColoredBox(
            color: Colors.black,
            child: _isCameraActive
                ? CameraPreview(widget.cameraController!)
                : Image.asset(
                    'assets/images/processing_bg_sample.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) =>
                        const ColoredBox(color: Colors.black),
                  ),
          ),
        ),

        // 2. Top-left text overlay
        if (_showTextOverlay)
          Positioned(
            left: 293.5,
            top: 112.0,
            width: 693.0,
            child: Text(
              widget.introActive ? 'Say...' : 'I love hostels!',
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
                '${widget.countdownValue}',
                style: AppTextStyles.countdownNumber,
              ),
            ),
          ),

        // 4. Decorative record button (Figma 29-4, 135:139)
        Positioned(
          right: 0,
          top: 0,
          bottom: 0,
          child: const Center(
            child: Padding(
              padding: EdgeInsets.only(right: 7.0),
              child: RecordButton(),
            ),
          ),
        ),

        // 5. Onboarding overlay (first camera screen)
        if (_showOnboarding && widget.onDismissOnboarding != null)
          OnboardingOverlay(
            message: 'Get ready! Your photo will be taken in a few seconds.',
            onDismiss: () {
              setState(() => _showOnboarding = false);
              widget.onDismissOnboarding?.call();
            },
          ),
      ],
    );
  }
}
