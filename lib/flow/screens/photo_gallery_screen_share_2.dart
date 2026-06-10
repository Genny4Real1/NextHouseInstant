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
        ? "Caricamento foto ${state.uploadedCount} di ${state.totalCount}..."
        : "Creazione link di download...";

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
            "Rimani vicino al chiosco mentre completiamo l'operazione.",
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
    final String errorMessage = state.errorMessage ?? "Impossibile collegarsi al server locale.";

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
            "Errore di Condivisione",
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
                    'Torna alla selezione',
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
                        'Riprova',
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
    final String token = state.downloadToken ?? (shareUrl.isNotEmpty ? shareUrl.split('/').last : '------');

    // Scadenza sessione: mostriamo l'ora di scadenza se disponibile
    String expiresText = '';
    if (state.expiresAt != null) {
      final localExpires = state.expiresAt!.toLocal();
      final minutesStr = localExpires.minute < 10 ? '0${localExpires.minute}' : '${localExpires.minute}';
      final hourStr = localExpires.hour < 10 ? '0${localExpires.hour}' : '${localExpires.hour}';
      expiresText = "Scade alle $hourStr:$minutesStr";
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 580.0,
          padding: const EdgeInsets.all(AppSpacing.s32),
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // QR Code Container (sfondo bianco per contrasto e scansione)
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
                child: shareUrl.isNotEmpty
                    ? QrImageView(
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
                      )
                    : const SizedBox(
                        width: 200.0,
                        height: 200.0,
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
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
                    const SizedBox(height: AppSpacing.s16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(10),
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(color: Colors.white.withAlpha(15)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TOKEN: $token',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              color: AppColors.primary,
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            shareUrl,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              color: AppColors.textSecondary,
                              fontSize: 11.0,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (expiresText.isNotEmpty) ...[
                            const SizedBox(height: 4.0),
                            Text(
                              expiresText,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                color: AppColors.success,
                                fontSize: 11.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
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
                  'Fatto',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            if (shareUrl.isNotEmpty) ...[
              const SizedBox(width: 20.0),
              SizedBox(
                width: 220.0,
                height: 56.0,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: AppColors.primary,
                    elevation: 2.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28.0),
                    ),
                  ),
                  icon: const Icon(Icons.open_in_browser_rounded),
                  label: const Text(
                    'Apri / Copia Link',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () async {
                    // Copia negli appunti
                    await Clipboard.setData(ClipboardData(text: shareUrl));
                    
                    // Mostra feedback visivo
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Link copiato negli appunti: $shareUrl'),
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    }

                    // Tenta l'apertura se su PC
                    try {
                      if (Platform.isWindows) {
                        await Process.run('explorer', [shareUrl]);
                      } else if (Platform.isMacOS) {
                        await Process.run('open', [shareUrl]);
                      } else if (Platform.isLinux) {
                        await Process.run('xdg-open', [shareUrl]);
                      }
                    } catch (e) {
                      debugPrint('Impossibile aprire il browser direttamente: $e');
                    }
                  },
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
