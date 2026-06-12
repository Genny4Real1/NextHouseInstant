import 'dart:io' show Platform, Process;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:qr_flutter/qr_flutter.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../photobooth_flow_state.dart';
import '../../network/backend_models.dart';

class PhotoGalleryScreenShare2 extends StatelessWidget {
  final PhotoboothFlowState flowState;

  const PhotoGalleryScreenShare2({
    super.key,
    required this.flowState,
  });

  @override
  Widget build(BuildContext context) {
    final state = flowState.shareSessionState;
    final status = state.status;
    final countdownValue = flowState.shareCountdownValue;
    final double progress = countdownValue / 300.0;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                child: _buildContent(context, status, state, countdownValue, progress),
              ),
            ),

            // Pulsante di chiusura rapida anche in alto a destra (solo se non siamo nella schermata finale con QR code)
            if (status != ShareSessionStatus.ready)
              Positioned(
                top: 20.0,
                right: 20.0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(20),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    iconSize: 28.0,
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                    ),
                    onPressed: flowState.resetToHome,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ShareSessionStatus status,
    ShareSessionState state,
    int countdownValue,
    double progress,
  ) {
    switch (status) {
      case ShareSessionStatus.uploadingPhotos:
      case ShareSessionStatus.creatingDownloadSession:
        return _buildLoadingState(status, state);
      case ShareSessionStatus.failed:
        return _buildErrorState(context, state);
      case ShareSessionStatus.ready:
      case ShareSessionStatus.idle:
        return _buildReadyState(context, state, countdownValue, progress);
    }
  }

  Widget _buildLoadingState(ShareSessionStatus status, ShareSessionState state) {
    final String message = status == ShareSessionStatus.uploadingPhotos
        ? "Uploading photo ${state.uploadedCount} of ${state.totalCount}..."
        : "Creating download link...";

    return Container(
      width: 580.0,
      padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 48.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(32.0),
        border: Border.all(color: Colors.white.withAlpha(15), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(100),
            blurRadius: 25.0,
            offset: const Offset(0.0, 10.0),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            strokeWidth: 4.0,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.nextHouseOrange),
          ),
          const SizedBox(height: 32.0),
          Text(
            message,
            style: const TextStyle(
              fontFamily: 'Inter',
              color: Colors.white,
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12.0),
          const Text(
            "Stay close to the kiosk while we complete the operation.",
            style: TextStyle(
              fontFamily: 'Inter',
              color: AppColors.textSecondary,
              fontSize: 14.0,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, ShareSessionState state) {
    final String errorMessage = state.errorMessage ?? "Unable to connect to the local server.";

    return Container(
      width: 580.0,
      padding: const EdgeInsets.all(AppSpacing.s32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(32.0),
        border: Border.all(color: AppColors.error.withAlpha(120), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(100),
            blurRadius: 25.0,
            offset: const Offset(0.0, 10.0),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: AppColors.error,
            size: 64.0,
          ),
          const SizedBox(height: AppSpacing.s24),
          const Text(
            "Sharing Error",
            style: TextStyle(
              fontFamily: 'Inter',
              color: Colors.white,
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.s12),
          Text(
            errorMessage,
            style: const TextStyle(
              fontFamily: 'Inter',
              color: AppColors.textSecondary,
              fontSize: 15.0,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.s32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Pulsante Torna alla selezione
              SizedBox(
                height: 50.0,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(color: Colors.white.withAlpha(50)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  ),
                  onPressed: flowState.goToShareSelection,
                  child: const Text(
                    'Back to selection',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.s16),
              // Pulsante Riprova
              SizedBox(
                height: 50.0,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  ),
                  onPressed: flowState.shareSelectedPhotos,
                  child: const Row(
                    children: [
                      Icon(Icons.replay_rounded, size: 18.0),
                      SizedBox(width: 8.0),
                      Text(
                        'Retry',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReadyState(BuildContext context, ShareSessionState state, int countdownValue, double progress) {
    final String shareUrl = state.downloadUrl ?? flowState.shareUrl ?? '';

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // QR Code Container (sfondo bianco per contrasto e scansione)
        Container(
          padding: const EdgeInsets.all(AppSpacing.s24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(50),
                blurRadius: 20.0,
                spreadRadius: 2.0,
              ),
            ],
          ),
          child: shareUrl.isNotEmpty
              ? QrImageView(
                  data: shareUrl,
                  version: QrVersions.auto,
                  size: 260.0,
                  gapless: false,
                  errorStateBuilder: (cxt, err) {
                    return const SizedBox(
                      width: 260.0,
                      height: 260.0,
                      child: Center(
                        child: Text(
                          'Error generating QR Code',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    );
                  },
                )
              : const SizedBox(
                  width: 260.0,
                  height: 260.0,
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.nextHouseOrange),
                    ),
                  ),
                ),
        ),
        const SizedBox(height: 48.0),

        // Bottoni di controllo
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 180.0,
              height: 56.0,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.white,
                  elevation: 2.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28.0),
                  ),
                ),
                onPressed: flowState.resetToHome,
                child: const Text(
                  'Done',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20.0),
            SizedBox(
              width: 240.0,
              height: 56.0,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white60,
                  backgroundColor: Colors.white.withAlpha(20),
                  elevation: 0.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28.0),
                    side: BorderSide(color: Colors.white.withAlpha(15)),
                  ),
                ),
                icon: const Icon(Icons.email_outlined, color: Colors.white60),
                label: const Text(
                  'Send via Email',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white60,
                  ),
                ),
                onPressed: null, // Non cliccabile per ora
              ),
            ),
          ],
        ),
      ],
    );
  }
}
