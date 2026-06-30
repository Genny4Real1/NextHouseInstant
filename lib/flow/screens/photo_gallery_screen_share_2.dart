import 'dart:io';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../theme/app_colors.dart';
import '../photobooth_flow_state.dart';
import '../../network/backend_models.dart';
import 'package:nexthouse_instant/l10n/app_localizations.dart';
import '../../widgets/language_selector.dart';

class PhotoGalleryScreenShare2 extends StatefulWidget {
  final PhotoboothFlowState flowState;

  const PhotoGalleryScreenShare2({
    super.key,
    required this.flowState,
  });

  @override
  State<PhotoGalleryScreenShare2> createState() => _PhotoGalleryScreenShare2State();
}

class _PhotoGalleryScreenShare2State extends State<PhotoGalleryScreenShare2> {

  @override
  Widget build(BuildContext context) {
    final flowState = widget.flowState;
    final state = flowState.shareSessionState;
    final status = state.status;
    final String shareUrl = state.downloadUrl ?? flowState.shareUrl ?? '';

    // Trova l'immagine di sfondo: l'ultima foto scattata
    final String? bgImagePath = flowState.capturedImages.isNotEmpty
        ? flowState.capturedImages.last
        : null;
    final bool hasPhoto = bgImagePath != null && bgImagePath.isNotEmpty;

    // Gestione stati caricamento/fallimento
    if (status == ShareSessionStatus.uploadingPhotos ||
        status == ShareSessionStatus.creatingDownloadSession) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: _buildLoadingState(status, state),
        ),
      );
    }

    if (status == ShareSessionStatus.failed) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: _buildErrorState(context, state),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: FittedBox(
          fit: BoxFit.contain,
          child: SizedBox(
            width: 1280.0,
            height: 800.0,
            child: Stack(
              children: [
                // 1. FOTO SCATTATA COME SFONDO (x=34, y=0, width=1212, height=800)
                Positioned(
                  left: 34.0,
                  right: 34.0,
                  top: 0.0,
                  bottom: 0.0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.0),
                    child: hasPhoto
                        ? Image.file(
                            File(bgImagePath),
                            fit: BoxFit.cover,
                            )
                        : Container(color: Colors.grey[900]),
                  ),
                ),

                // Overlay scuro sopra la foto per contrasto
                Positioned(
                  left: 34.0,
                  right: 34.0,
                  top: 0.0,
                  bottom: 0.0,
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.35),
                  ),
                ),

                // 2. CARD ARANCIONE DI CONDIVISIONE (Al centro, larghezza 598, altezza 610)
                Center(
                  child: Container(
                    width: 598.0,
                    height: 610.0,
                    padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 30.0),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.nextHouseOrange,
                          Color(0xFFC74C13),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(60.0),
                      border: Border.all(
                        color: Colors.white.withAlpha(25),
                        width: 1.5,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black54,
                          blurRadius: 30.0,
                          offset: Offset(0, 15),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // A. QR CODE (Sfondo bianco per facilitare la scansione)
                        Container(
                          width: 416.0,
                          height: 416.0,
                          padding: const EdgeInsets.all(24.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          child: shareUrl.isNotEmpty
                              ? QrImageView(
                                  data: shareUrl,
                                  version: QrVersions.auto,
                                  gapless: false,
                                  eyeStyle: const QrEyeStyle(
                                    eyeShape: QrEyeShape.square,
                                    color: Colors.black,
                                  ),
                                  dataModuleStyle: const QrDataModuleStyle(
                                    dataModuleShape: QrDataModuleShape.square,
                                    color: Colors.black,
                                  ),
                                  backgroundColor: Colors.transparent,
                                )
                              : const Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.nextHouseOrange),
                                  ),
                                ),
                        ),

                        // B. BOX "Scan me!"
                        Container(
                          width: 250.0,
                          height: 58.0,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(29.0),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.scanMe,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                              color: AppColors.nextHouseOrange,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Pulsante Chiudi in alto a destra per tornare alla home
                Positioned(
                  top: 20.0,
                  right: 20.0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
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

                // Selettore lingua discreto in alto a destra (a sinistra del pulsante Chiudi)
                Positioned(
                  top: 20.0,
                  right: 80.0,
                  child: LanguageSelector(flowState: flowState),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState(ShareSessionStatus status, ShareSessionState state) {
    final String message = status == ShareSessionStatus.uploadingPhotos
        ? AppLocalizations.of(context)!.uploadingPhotoOf('${state.uploadedCount}', '${state.totalCount}')
        : AppLocalizations.of(context)!.creatingLink;

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
          Text(
            AppLocalizations.of(context)!.stayCloseMsg,
            style: const TextStyle(
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
      padding: const EdgeInsets.all(32.0),
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
          const SizedBox(height: 24.0),
          Text(
            AppLocalizations.of(context)!.sharingError,
            style: const TextStyle(
              fontFamily: 'Inter',
              color: Colors.white,
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12.0),
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
          const SizedBox(height: 32.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
                  onPressed: widget.flowState.goToShareSelection,
                  child: Text(
                    AppLocalizations.of(context)!.backToSelection,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16.0),
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
                  onPressed: () => widget.flowState.shareSelectedPhotos(
                    languageCode: Localizations.localeOf(context).languageCode,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.replay_rounded, size: 18.0),
                      const SizedBox(width: 8.0),
                      Text(
                        AppLocalizations.of(context)!.retry,
                        style: const TextStyle(
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
}
