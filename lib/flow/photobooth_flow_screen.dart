import 'package:flutter/material.dart';
import 'photobooth_flow_state.dart';
import '../services/kiosk_service.dart';
import '../theme/app_durations.dart';
import 'screens/idle_screen.dart';
import 'screens/countdown_screen.dart';
import 'screens/capture_screen.dart';
import 'screens/processing_screen.dart';
import 'screens/ask_another_screen.dart';
import 'screens/result_screen.dart';
import 'screens/edit_screen.dart';
import 'screens/share_terms_screen.dart';
import 'screens/photo_selection_share_screen.dart';
import 'screens/photo_gallery_screen_share_2.dart';

class PhotoboothFlowScreen extends StatefulWidget {
  final PhotoboothFlowState flowState;

  const PhotoboothFlowScreen({
    super.key,
    required this.flowState,
  });

  @override
  State<PhotoboothFlowScreen> createState() => _PhotoboothFlowScreenState();
}

class _PhotoboothFlowScreenState extends State<PhotoboothFlowScreen> {
  PhotoboothFlowState get _flowState => widget.flowState;

  @override
  void initState() {
    super.initState();

    // Avvia la modalità Kiosk protetta su Android al completamento del layout
    WidgetsBinding.instance.addPostFrameCallback((_) {
      KioskService.startKioskMode();
    });
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
          flowState: _flowState,
        );
      case PhotoboothState.countdown:
        return CountdownScreen(
          key: const ValueKey('countdown'),
          flowState: _flowState,
        );
      case PhotoboothState.captureFeedback:
        return CaptureScreen(
          key: const ValueKey('capture'),
          capturedImagePath: _flowState.capturedImagePath,
          activeFilter: _flowState.activeFilter,
        );
      case PhotoboothState.processing:
        return ProcessingScreen(
          key: const ValueKey('processing'),
          capturedImagePath: _flowState.capturedImagePath,
          activeFilter: _flowState.activeFilter,
          flowState: _flowState,
        );
      case PhotoboothState.askAnother:
        return AskAnotherScreen(
          key: const ValueKey('askAnother'),
          capturedImagePath: _flowState.capturedImagePath,
          onYes: _flowState.takeAnotherPhoto,
          onNo: _flowState.showGallery,
          flowState: _flowState,
        );
      case PhotoboothState.result:
        return ResultScreen(
          key: const ValueKey('result'),
          onReset: _flowState.resetToHome,
          onDone: _flowState.handleDoneClick,
          onDelete: _flowState.deletePhotos,
          onShare: _flowState.startShareFlow,
          onEdit: _flowState.enterEditMode,
          showDoneToolbar: _flowState.showDoneToolbar,
          capturedImages: _flowState.capturedImages,
          currentGalleryIndex: _flowState.currentGalleryIndex,
          onPrevious: _flowState.previousImage,
          onNext: _flowState.nextImage,
          onPageChanged: _flowState.setGalleryIndex,
          flowState: _flowState,
        );
      case PhotoboothState.edit:
        return EditScreen(
          key: ValueKey(_flowState.capturedImages[_flowState.currentGalleryIndex]),
          imagePath: _flowState.capturedImages[_flowState.currentGalleryIndex],
          capturedImages: _flowState.capturedImages,
          currentGalleryIndex: _flowState.currentGalleryIndex,
          onPreviousImage: _flowState.previousImage,
          onNextImage: _flowState.nextImage,
          baseUrl: _flowState.backendUrl,
          onSave: (newPath) {
            _flowState.exitEditMode(save: true, editedImagePath: newPath);
          },
          onCancel: () {
            _flowState.exitEditMode(save: false);
          },
          flowState: _flowState,
        );
      case PhotoboothState.shareTerms:
        return ShareTermsScreen(
          key: const ValueKey('shareTerms'),
          lastCapturedImagePath: _flowState.capturedImages.isNotEmpty
              ? _flowState.capturedImages[_flowState.currentGalleryIndex]
              : null,
          onAccept: _flowState.acceptTermsAndProceed,
          onDecline: _flowState.declineTerms,
          flowState: _flowState,
        );
      case PhotoboothState.shareSelection:
        return PhotoSelectionShareScreen(
          key: const ValueKey('shareSelection'),
          capturedImages: _flowState.capturedImages,
          selectedImages: _flowState.selectedShareImages,
          onToggleSelection: _flowState.toggleImageSelection,
          onCancel: _flowState.cancelShareSelection,
          onDone: _flowState.completeShareSelection,
          isUploading: _flowState.isUploading,
          uploadError: _flowState.uploadError,
          flowState: _flowState,
        );
      case PhotoboothState.shareQr:
        return PhotoGalleryScreenShare2(
          key: const ValueKey('shareQr'),
          flowState: _flowState,
        );
    }
  }
}
