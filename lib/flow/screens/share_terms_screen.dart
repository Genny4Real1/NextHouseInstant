import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/camera_placeholder.dart';

import '../photobooth_flow_state.dart';
import 'package:nexthouse_instant/l10n/app_localizations.dart';

class ShareTermsScreen extends StatelessWidget {
  final String? lastCapturedImagePath;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final PhotoboothFlowState flowState;

  const ShareTermsScreen({
    super.key,
    required this.lastCapturedImagePath,
    required this.onAccept,
    required this.onDecline,
    required this.flowState,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasCapturedImage = lastCapturedImagePath != null && lastCapturedImagePath!.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Blurred background of the last captured photo
          Positioned.fill(
            child: hasCapturedImage
                ? Image.file(
                    File(lastCapturedImagePath!),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const CameraPlaceholder(showGuides: false),
                  )
                : const CameraPlaceholder(showGuides: false),
          ),

          // 2. Dark glassmorphism overlay / blur filter
          Positioned.fill(
            child: ClipRect(
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
                child: Container(
                  color: Colors.black.withAlpha(140),
                ),
              ),
            ),
          ),

          // 3. Central card with Terms & Conditions
          Center(
            child: SingleChildScrollView(
              child: Container(
                width: 600.0,
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.s32,
                  horizontal: AppSpacing.s48,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface.withAlpha(220),
                  borderRadius: BorderRadius.circular(32.0),
                  border: Border.all(
                    color: Colors.white.withAlpha(20),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(120),
                      blurRadius: 30.0,
                      offset: const Offset(0.0, 10.0),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Cloud security icon
                    Container(
                      padding: const EdgeInsets.all(24.0),
                      decoration: BoxDecoration(
                        color: AppColors.nextHouseOrange.withAlpha(25),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.cloud_done_rounded,
                        color: AppColors.nextHouseOrange,
                        size: 72.0,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s24),

                    // Title
                    Text(
                      AppLocalizations.of(context)!.cloudStorageTitle,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        color: Colors.white,
                        fontSize: 32.0,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.s16),

                    // Body details
                    Text(
                      AppLocalizations.of(context)!.cloudStorageDesc,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        color: AppColors.textPrimary,
                        fontSize: 16.0,
                        height: 1.5,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.s32),

                    // Action Buttons (Decline / Accept)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Decline Button
                        SizedBox(
                          width: 220.0,
                          height: 56.0,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: BorderSide(
                                color: Colors.white.withAlpha(60),
                                width: 2.0,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28.0),
                              ),
                            ),
                            onPressed: onDecline,
                            child: Text(
                              AppLocalizations.of(context)!.decline,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.s16),
                        // Accept Button
                        SizedBox(
                          width: 220.0,
                          height: 56.0,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.black,
                              backgroundColor: Colors.white,
                              elevation: 4.0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28.0),
                              ),
                            ),
                            onPressed: onAccept,
                            child: Text(
                              AppLocalizations.of(context)!.accept,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
