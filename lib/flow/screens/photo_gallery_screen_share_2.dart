import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

  Widget _buildPhotoStack(List<String> images) {
    if (images.isEmpty) {
      return Container(
        width: 580.0,
        height: 435.0,
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(24.0),
        ),
        child: const Icon(
          Icons.image_not_supported_rounded,
          color: Colors.white30,
          size: 64.0,
        ),
      );
    }

    // Mostriamo al massimo le ultime 3 foto per evitare congestione visiva
    const int maxPhotos = 3;
    final List<String> displayImages = images.length > maxPhotos
        ? images.sublist(images.length - maxPhotos)
        : images;

    return SizedBox(
      width: 580.0,
      height: 520.0, // altezza del box contenitore
      child: Stack(
        alignment: Alignment.center,
        children: List.generate(displayImages.length, (index) {
          final String path = displayImages[index];
          final bool isTop = index == displayImages.length - 1;

          // Calcoliamo rotazione e offset per creare l'effetto mazzo sfalsato
          double rotation = 0.0;
          double offsetX = 0.0;
          double offsetY = 0.0;
          double scale = 1.0;
          double opacity = 1.0;

          if (!isTop) {
            if (displayImages.length == 3) {
              if (index == 0) {
                rotation = -0.06; // ~ -3.5 gradi
                offsetX = -24.0;
                offsetY = -12.0;
                scale = 0.92;
                opacity = 0.6;
              } else if (index == 1) {
                rotation = 0.05; // ~ +3 gradi
                offsetX = 16.0;
                offsetY = 12.0;
                scale = 0.96;
                opacity = 0.8;
              }
            } else if (displayImages.length == 2) {
              rotation = -0.05;
              offsetX = -16.0;
              offsetY = -8.0;
              scale = 0.95;
              opacity = 0.75;
            }
          }

          return Transform.translate(
            offset: Offset(offsetX, offsetY),
            child: Transform.rotate(
              angle: rotation,
              child: Transform.scale(
                scale: scale,
                child: Opacity(
                  opacity: opacity,
                  child: Container(
                    constraints: const BoxConstraints(
                      maxWidth: 500.0,
                    ),
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isTop ? 0.4 : 0.25),
                          blurRadius: isTop ? 25.0 : 15.0,
                          spreadRadius: 1.0,
                          offset: Offset(0, isTop ? 12.0 : 6.0),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14.0),
                      child: AspectRatio(
                        aspectRatio: 4 / 3,
                        child: Image.file(
                          File(path),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final flowState = widget.flowState;
    final state = flowState.shareSessionState;
    final status = state.status;
    final String shareUrl = state.downloadUrl ?? flowState.shareUrl ?? '';

    // Trova l'immagine di sfondo: l'ultima foto selezionata, altrimenti l'ultima foto scattata
    final String? bgImagePath = flowState.selectedShareImages.isNotEmpty
        ? flowState.selectedShareImages.last
        : (flowState.capturedImages.isNotEmpty
            ? flowState.capturedImages.last
            : null);
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
                // 1. SFONDO SFOCATO PER COPRIRE I BORDI NERI
                Positioned.fill(
                  child: hasPhoto
                      ? Image.file(
                          File(bgImagePath),
                          fit: BoxFit.cover,
                        )
                      : Container(color: Colors.grey[900]),
                ),
                if (hasPhoto)
                  Positioned.fill(
                    child: ClipRect(
                      child: BackdropFilter(
                        filter: ui.ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
                        child: Container(
                          color: Colors.black.withValues(alpha: 0.2),
                        ),
                      ),
                    ),
                  ),

                // Overlay scuro sopra l'intera area di sfondo per contrasto
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.35),
                  ),
                ),

                // 2. LOGO DI BRANDING IN ALTO A SINISTRA
                Positioned(
                  top: 30.0,
                  left: 50.0,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        'Next House',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 22.0,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Text(
                        'INSTANT',
                        style: const TextStyle(
                          fontFamily: 'Saira Stencil One',
                          color: AppColors.nextHouseOrange,
                          fontSize: 16.0,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),

                // 3. CONTENUTO PRINCIPALE IN LAYOUT BILANCIATO (SPLIT-SCREEN)
                Positioned(
                  left: 60.0,
                  right: 60.0,
                  top: 100.0,
                  bottom: 50.0,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Colonna Sinistra: Cornice della Foto Scattata
                        Expanded(
                          flex: 6,
                          child: Center(
                            child: _buildPhotoStack(flowState.selectedShareImages.toList()),
                          ),
                        ),

                        const SizedBox(width: 48.0),

                        // Colonna Destra: Card di Condivisione Glassmorphic
                        Expanded(
                          flex: 5,
                          child: Center(
                            child: Container(
                              width: 440.0,
                              padding: const EdgeInsets.all(32.0),
                              decoration: BoxDecoration(
                                color: AppColors.surface.withValues(alpha: 0.85),
                                borderRadius: BorderRadius.circular(36.0),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.45),
                                    blurRadius: 25.0,
                                    offset: const Offset(0, 15),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Icona QR Code Superiore
                                  Container(
                                    padding: const EdgeInsets.all(12.0),
                                    decoration: BoxDecoration(
                                      color: AppColors.nextHouseOrange.withValues(alpha: 0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.qr_code_scanner_rounded,
                                      color: AppColors.nextHouseOrange,
                                      size: 32.0,
                                    ),
                                  ),
                                  const SizedBox(height: 16.0),

                                  // Titolo
                                  Text(
                                    AppLocalizations.of(context)!.sharePhotosTitle,
                                    style: GoogleFonts.inter(
                                      fontSize: 24.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: -0.5,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8.0),

                                  // Sottotitolo
                                  Text(
                                    AppLocalizations.of(context)!.sharePhotosSubtitle,
                                    style: GoogleFonts.inter(
                                      fontSize: 14.0,
                                      color: AppColors.textSecondary,
                                      height: 1.3,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 24.0),

                                  // Card bianca unificata QR Code + Badge Scan me!
                                  Container(
                                    padding: const EdgeInsets.all(16.0),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(24.0),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.15),
                                          blurRadius: 15.0,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // QR CODE
                                        SizedBox(
                                          width: 190.0,
                                          height: 190.0,
                                          child: shareUrl.isNotEmpty
                                              ? QrImageView(
                                                  data: shareUrl,
                                                  version: QrVersions.auto,
                                                  gapless: false,
                                                  eyeStyle: const QrEyeStyle(
                                                    eyeShape: QrEyeShape.circle,
                                                    color: Colors.black,
                                                  ),
                                                  dataModuleStyle: const QrDataModuleStyle(
                                                    dataModuleShape: QrDataModuleShape.circle,
                                                    color: Colors.black,
                                                  ),
                                                  backgroundColor: Colors.transparent,
                                                )
                                              : const Center(
                                                  child: CircularProgressIndicator(
                                                    valueColor: AlwaysStoppedAnimation<Color>(
                                                      AppColors.nextHouseOrange,
                                                    ),
                                                  ),
                                                ),
                                        ),
                                        const SizedBox(height: 12.0),

                                        // Badge "SCAN ME!" integrato
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20.0,
                                            vertical: 8.0,
                                          ),
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [
                                                AppColors.nextHouseOrange,
                                                Color(0xFFC74C13),
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            borderRadius: BorderRadius.circular(12.0),
                                            boxShadow: [
                                              BoxShadow(
                                                color: AppColors.nextHouseOrange.withValues(alpha: 0.3),
                                                blurRadius: 8.0,
                                                offset: const Offset(0, 3),
                                              ),
                                            ],
                                          ),
                                          child: Text(
                                            AppLocalizations.of(context)!.scanMe.toUpperCase(),
                                            style: GoogleFonts.inter(
                                              fontSize: 13.0,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              letterSpacing: 1.2,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 24.0),

                                  // Messaggio informativo di prossimità
                                  Text(
                                    AppLocalizations.of(context)!.stayCloseMsg,
                                    style: GoogleFonts.inter(
                                      fontSize: 12.0,
                                      color: AppColors.textSecondary,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
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
