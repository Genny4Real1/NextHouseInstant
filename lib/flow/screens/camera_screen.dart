import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../../widgets/record_button.dart';

/// Figma 29-4, 33-6 — Full-bleed camera preview with a record button.
/// Pressing the record button triggers an animation (scale down + fade out)
/// and then calls [onRecord] to start the countdown.
class CameraScreen extends StatefulWidget {
  final CameraController? cameraController;
  final VoidCallback onRecord;
  final String? capturedImagePath;

  const CameraScreen({
    super.key,
    this.cameraController,
    required this.onRecord,
    this.capturedImagePath,
  });

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _buttonAnimController;
  late final Animation<double> _buttonScale;
  late final Animation<double> _buttonOpacity;
  bool _isButtonVisible = true;

  bool get _isCameraActive =>
      widget.cameraController != null &&
      widget.cameraController!.value.isInitialized;

  @override
  void initState() {
    super.initState();
    _buttonAnimController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _buttonScale = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _buttonAnimController, curve: Curves.easeInOut),
    );
    _buttonOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _buttonAnimController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _buttonAnimController.dispose();
    super.dispose();
  }

  void _onRecordPressed() {
    if (!_isButtonVisible) return;
    _buttonAnimController.forward().then((_) {
      if (mounted) {
        setState(() => _isButtonVisible = false);
        widget.onRecord();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Full-bleed camera preview
        Positioned.fill(
          child: ColoredBox(
            color: Colors.black,
            child: _isCameraActive
                ? CameraPreview(widget.cameraController!)
                : (widget.capturedImagePath != null &&
                        widget.capturedImagePath!.isNotEmpty)
                    ? Image.file(
                        File(widget.capturedImagePath!),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const ColoredBox(color: Colors.black),
                      )
                    : const ColoredBox(color: Colors.black),
          ),
        ),

        // Record button (Figma: left 1141, top 327.5 on 1280x800)
        if (_isButtonVisible)
          Positioned(
            right: 139.0,
            top: 0,
            bottom: 0,
            child: Center(
              child: AnimatedBuilder(
                animation: _buttonAnimController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _buttonOpacity.value,
                    child: Transform.scale(
                      scale: _buttonScale.value,
                      child: GestureDetector(
                        onTap: _onRecordPressed,
                        child: const RecordButton(),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}
