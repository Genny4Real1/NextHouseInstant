import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../theme/app_colors.dart';
import '../photobooth_flow_state.dart';
import '../../network/backend_models.dart';

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
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleSendEmail(BuildContext context, String shareUrl) async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter your email address."),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a valid email address."),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final success = await widget.flowState.sendEmailShare(email);
    if (!context.mounted) return;
    if (success) {
      _emailController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Email registered for sharing: $email"),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Unable to register email at this moment."),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

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

                // 2. CARD ARANCIONE DI CONDIVISIONE (Al centro, larghezza 598, altezza 751)
                Center(
                  child: Container(
                    width: 598.0,
                    height: 751.0,
                    padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 30.0),
                    decoration: BoxDecoration(
                      color: AppColors.nextHouseOrange,
                      borderRadius: BorderRadius.circular(60.0),
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
                        // A. QR CODE (Trasparente su sfondo arancione)
                        Container(
                          width: 416.0,
                          height: 416.0,
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
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
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
                          child: const Text(
                            'Scan me!',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                              color: AppColors.nextHouseOrange,
                            ),
                          ),
                        ),

                        // C. ETICHETTA "Or enter your email:"
                        const Text(
                          'Or enter your email:',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 20.0,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        // D. CAMPO DI INSERIMENTO EMAIL CON STRUTTURA INVIO
                        Container(
                          width: 498.0,
                          height: 50.0,
                          padding: const EdgeInsets.only(left: 20.0, right: 6.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _emailController,
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 16.0,
                                    color: AppColors.nextHouseOrange,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'your@email.com',
                                    hintStyle: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 16.0,
                                      color: Colors.black26,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                              // Pulsante invio
                              GestureDetector(
                                onTap: () {
                                  _handleSendEmail(context, shareUrl);
                                },
                                child: Container(
                                  width: 38.0,
                                  height: 38.0,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF4D5358), // NextHouse Black
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: SvgPicture.asset(
                                    'assets/images/send_icon.svg',
                                    width: 18.0,
                                    height: 18.0,
                                    colorFilter: const ColorFilter.mode(
                                      Colors.white,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),
                              ),
                            ],
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
              ],
            ),
          ),
        ),
      ),
    );
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
                  onPressed: widget.flowState.shareSelectedPhotos,
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
}
