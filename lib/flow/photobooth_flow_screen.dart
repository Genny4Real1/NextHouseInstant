import 'package:flutter/material.dart';
import 'photobooth_flow_state.dart';
import '../theme/app_durations.dart';
import 'screens/idle_screen.dart';
import 'screens/countdown_screen.dart';
import 'screens/capture_screen.dart';
import 'screens/processing_screen.dart';
import 'screens/ask_another_screen.dart';
import 'screens/result_screen.dart';
import 'screens/photo_selection_share_screen.dart';
import 'screens/photo_gallery_screen_share_2.dart';

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
          capturedImagePath: _flowState.capturedImagePath,
        );
      case PhotoboothState.askAnother:
        return AskAnotherScreen(
          key: const ValueKey('askAnother'),
          capturedImagePath: _flowState.capturedImagePath,
          onYes: _flowState.takeAnotherPhoto,
          onNo: _flowState.showGallery,
        );
      case PhotoboothState.result:
        return ResultScreen(
          key: const ValueKey('result'),
          onReset: _flowState.resetToHome,
          onDone: _flowState.handleDoneClick,
          onDelete: _flowState.deletePhotos,
          onShare: _flowState.startShareFlow,
          showDoneToolbar: _flowState.showDoneToolbar,
          capturedImages: _flowState.capturedImages,
          currentGalleryIndex: _flowState.currentGalleryIndex,
          onPrevious: _flowState.previousImage,
          onNext: _flowState.nextImage,
        );
      case PhotoboothState.shareSelection:
        return PhotoSelectionShareScreen(
          key: const ValueKey('shareSelection'),
          capturedImages: _flowState.capturedImages,
          selectedImages: _flowState.selectedShareImages,
          onToggleSelection: _flowState.toggleImageSelection,
          onCancel: _flowState.cancelShareSelection,
          onDone: _flowState.completeShareSelection,
        );
      case PhotoboothState.shareQr:
        return PhotoGalleryScreenShare2(
          key: const ValueKey('shareQr'),
          countdownValue: _flowState.shareCountdownValue,
          selectedImages: _flowState.selectedShareImages,
          onDone: _flowState.resetToHome,
        );
    }
  }
}
