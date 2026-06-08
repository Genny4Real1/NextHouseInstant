import 'package:flutter/material.dart';
import 'photobooth_flow_state.dart';
import '../theme/app_durations.dart';
import 'screens/idle_screen.dart';
import 'screens/camera_screen.dart';
import 'screens/countdown_screen.dart';
import 'screens/capture_screen.dart';
import 'screens/capture_end_screen.dart';
import 'screens/processing_screen.dart';
import 'screens/ask_another_screen.dart';
import 'screens/result_screen.dart';
import 'screens/photo_selection_share_screen.dart';
import 'screens/photo_gallery_screen_share_2.dart';
import 'screens/share_confirm_screen.dart';
import 'screens/share_uploading_screen.dart';

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
      case PhotoboothState.camera:
        return CameraScreen(
          key: const ValueKey('camera'),
          cameraController: _flowState.cameraController,
          onRecord: _flowState.startCountdown,
          capturedImagePath: _flowState.capturedImagePath,
        );
      case PhotoboothState.countdown:
        return CountdownScreen(
          key: const ValueKey('countdown'),
          countdownValue: _flowState.countdownValue,
          introActive: _flowState.introActive,
          cameraController: _flowState.cameraController,
          capturedImagePath: _flowState.capturedImagePath,
        );
      case PhotoboothState.captureEnd:
        return CaptureEndScreen(
          key: const ValueKey('captureEnd'),
          capturedImagePath: _flowState.capturedImagePath,
        );
      case PhotoboothState.captureFeedback:
        return const CaptureScreen(key: ValueKey('capture'));
      case PhotoboothState.processing:
        return ProcessingScreen(
          key: ValueKey('processing_${_flowState.capturedImagePath}'),
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
          onEdit: _flowState.editPhoto,
          onPrint: _flowState.printPhoto,
          showDoneToolbar: _flowState.showDoneToolbar,
          capturedImages: _flowState.capturedImages,
          currentGalleryIndex: _flowState.currentGalleryIndex,
          onPrevious: _flowState.previousImage,
          onNext: _flowState.nextImage,
          onPageChanged: _flowState.setGalleryIndex,
          isFirstImage: _flowState.isFirstImage,
          isLastImage: _flowState.isLastImage,
        );
      case PhotoboothState.shareSelection:
        return PhotoSelectionShareScreen(
          key: const ValueKey('shareSelection'),
          capturedImages: _flowState.capturedImages,
          selectedImages: _flowState.selectedShareImages,
          onToggleSelection: _flowState.toggleImageSelection,
          onCancel: _flowState.cancelShareSelection,
          onDone: _flowState.confirmShareSelection,
        );
      case PhotoboothState.shareQr:
        return PhotoGalleryScreenShare2(
          key: const ValueKey('shareQr'),
          selectedImages: _flowState.selectedShareImages,
          onDone: _flowState.resetToHome,
        );
      case PhotoboothState.shareConfirm:
        return ShareConfirmScreen(
          key: const ValueKey('shareConfirm'),
          onYes: _flowState.proceedShareUpload,
          onNo: _flowState.cancelShareConfirm,
        );
      case PhotoboothState.shareUploading:
        return ShareUploadingScreen(
          key: const ValueKey('shareUploading'),
          capturedImages: _flowState.capturedImages,
        );
    }
  }
}
