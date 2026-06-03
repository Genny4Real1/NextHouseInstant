import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

class PhotoGalleryScreenShare2 extends StatelessWidget {
  final int countdownValue;
  final Set<String> selectedImages;
  final VoidCallback onDone;

  const PhotoGalleryScreenShare2({
    super.key,
    required this.countdownValue,
    required this.selectedImages,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    // Generiamo un URL mock basato sui file selezionati
    final String shareUrl = 'https://nexthouse.it/share/gallery?count=${selectedImages.length}&t=${DateTime.now().millisecondsSinceEpoch}';
    final double progress = countdownValue / 30.0;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Card centrale per il QR Code
                    Container(
                      width: 580.0,
                      padding: const EdgeInsets.all(AppSpacing.s32),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(32.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(100),
                            blurRadius: 25.0,
                            offset: const Offset(0.0, 10.0),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // QR Code Container (sfondo bianco per contrasto e scansione ottimale)
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.s16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(25),
                                  blurRadius: 10.0,
                                ),
                              ],
                            ),
                            child: QrImageView(
                              data: shareUrl,
                              version: QrVersions.auto,
                              size: 200.0,
                              gapless: false,
                              errorStateBuilder: (cxt, err) {
                                return const SizedBox(
                                  width: 200.0,
                                  height: 200.0,
                                  child: Center(
                                    child: Text(
                                      'Error generating QR Code',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: AppSpacing.s32),

                          // Testi e Istruzioni
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'Inquadra il QR Code',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    color: Colors.white,
                                    fontSize: 24.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.s8),
                                const Text(
                                  'Scansiona con il tuo telefono per visualizzare e salvare le foto selezionate sul tuo dispositivo.',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    color: AppColors.textSecondary,
                                    fontSize: 14.0,
                                    height: 1.4,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.s24),

                                // Area Timer
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 24.0,
                                      height: 24.0,
                                      child: CircularProgressIndicator(
                                        value: progress,
                                        strokeWidth: 3.0,
                                        backgroundColor: Colors.white.withAlpha(20),
                                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.s12),
                                    Text(
                                      'Scadenza tra $countdownValue secondi',
                                      style: const TextStyle(
                                        fontFamily: 'Inter',
                                        color: Colors.white,
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s32),

                    // Bottone Fatto / Chiudi
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
                        onPressed: onDone,
                        child: const Text(
                          'Fatto',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Pulsante di chiusura rapida anche in alto a destra
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
                  onPressed: onDone,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
