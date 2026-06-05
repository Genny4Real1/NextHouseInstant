import 'package:flutter/material.dart';
import '../../theme/app_durations.dart';

/// Figma 57-209 - 150ms full-screen white flash overlay between the countdown
/// and the captureEnd state.
class CaptureScreen extends StatefulWidget {
  const CaptureScreen({super.key});

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  bool _showFlash = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future<void>.delayed(AppDurations.countdownFlash, () {
        if (mounted) {
          setState(() => _showFlash = false);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !_showFlash,
      child: AnimatedOpacity(
        opacity: _showFlash ? 1.0 : 0.0,
        duration: AppDurations.flashOpacity,
        curve: Curves.easeOut,
        child: const ColoredBox(color: Colors.white),
      ),
    );
  }
}
