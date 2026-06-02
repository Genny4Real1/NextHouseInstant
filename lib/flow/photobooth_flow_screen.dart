import 'package:flutter/material.dart';
import 'photobooth_flow_state.dart';
import '../theme/app_durations.dart';
import 'screens/idle_screen.dart';
import 'screens/countdown_screen.dart';
import 'screens/capture_screen.dart';
import 'screens/processing_screen.dart';
import 'screens/result_screen.dart';

class PhotoboothFlowScreen extends StatefulWidget {
  const PhotoboothFlowScreen({super.key});

  @override
  State<PhotoboothFlowScreen> createState() => _PhotoboothFlowScreenState();
}

class _PhotoboothFlowScreenState extends State<PhotoboothFlowScreen> {
  late final PhotoboothFlowState _flowState;

  @override
  void initState() {
    super.initState();
    _flowState = PhotoboothFlowState();
    // Avvia l'inizializzazione asincrona della fotocamera reale all'avvio del chiosco
    _flowState.initializeCamera();
  }

  @override
  void dispose() {
    _flowState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _flowState,
        builder: (context, child) {
          return AnimatedSwitcher(
            duration: AppDurations.pageTransition,
            switchInCurve: Curves.easeInOut,
            switchOutCurve: Curves.easeInOut,
            child: _buildScreen(_flowState.state),
          );
        },
      ),
    );
  }

  Widget _buildScreen(PhotoboothState state) {
    switch (state) {
      case PhotoboothState.idle:
        return IdleScreen(
          key: const ValueKey('idle'),
          onStart: _flowState.startFlow,
        );
      case PhotoboothState.countdown:
        return CountdownScreen(
          key: const ValueKey('countdown'),
          countdownValue: _flowState.countdownValue,
          cameraController: _flowState.cameraController,
        );
      case PhotoboothState.captureFeedback:
        return CaptureScreen(
          key: const ValueKey('capture'),
          capturedImagePath: _flowState.capturedImagePath,
        );
      case PhotoboothState.processing:
        return ProcessingScreen(
          key: const ValueKey('processing'),
        );
      case PhotoboothState.result:
        return ResultScreen(
          key: const ValueKey('result'),
          onReset: _flowState.resetToHome,
          capturedImagePath: _flowState.capturedImagePath,
        );
    }
  }
}
