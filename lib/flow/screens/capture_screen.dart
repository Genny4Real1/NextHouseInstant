import 'dart:io';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_durations.dart';
import '../../widgets/camera_placeholder.dart';
import '../../widgets/kiosk_container.dart';

class CaptureScreen extends StatefulWidget {
  final String? capturedImagePath;
  final String? activeFilter;

  const CaptureScreen({
    super.key,
    this.capturedImagePath,
    this.activeFilter,
  });

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  bool _showFlash = true;

  @override
  void initState() {
    super.initState();
    // Esegue il flash e lo dissolve rapidamente
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(AppDurations.flashFade, () {
        if (mounted) {
          setState(() {
            _showFlash = false;
          });
        }
      });
    });
  }

  List<double> _getColorMatrix(String? filter) {
    switch (filter) {
      case 'grayscale':
        return [
          0.2126, 0.7152, 0.0722, 0.0, 0.0,
          0.2126, 0.7152, 0.0722, 0.0, 0.0,
          0.2126, 0.7152, 0.0722, 0.0, 0.0,
          0.0,    0.0,    0.0,    1.0, 0.0,
        ];
      case 'sepia':
        return [
          0.393, 0.769, 0.189, 0.0, 0.0,
          0.349, 0.686, 0.168, 0.0, 0.0,
          0.272, 0.534, 0.131, 0.0, 0.0,
          0.0,   0.0,   0.0,   1.0, 0.0,
        ];
      case 'cool':
        return [
          0.9, 0.0, 0.1, 0.0, 0.0,
          0.0, 0.9, 0.1, 0.0, 0.0,
          0.0, 0.0, 1.2, 0.0, 0.0,
          0.0, 0.0, 0.0, 1.0, 0.0,
        ];
      case 'warm':
        return [
          1.2, 0.0, 0.0, 0.0, 0.0,
          0.0, 1.0, 0.0, 0.0, 0.0,
          0.0, 0.0, 0.8, 0.0, 0.0,
          0.0, 0.0, 0.0, 1.0, 0.0,
        ];
      default:
        return [
          1.0, 0.0, 0.0, 0.0, 0.0,
          0.0, 1.0, 0.0, 0.0, 0.0,
          0.0, 0.0, 1.0, 0.0, 0.0,
          0.0, 0.0, 0.0, 1.0, 0.0,
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasCapturedImage = widget.capturedImagePath != null && widget.capturedImagePath!.isNotEmpty;

    return Stack(
      children: [
        // Sfondo e interfaccia anteprima foto scattata
        Container(
          color: AppColors.background,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.s24,
                horizontal: AppSpacing.s64,
              ),
              child: Column(
                children: [
                  const Text(
                    'Photo captured',
                    style: AppTextStyles.header1,
                  ),
                  const SizedBox(height: AppSpacing.s16),

                  // Foto scattata reale o Placeholder statico di fallback
                  Expanded(
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: 4 / 3,
                        child: KioskContainer(
                          child: hasCapturedImage
                              ? ColorFiltered(
                                  colorFilter: ColorFilter.matrix(_getColorMatrix(widget.activeFilter)),
                                  child: Image.file(
                                    File(widget.capturedImagePath!),
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        const CameraPlaceholder(showGuides: false),
                                  ),
                                )
                              : const CameraPlaceholder(showGuides: false),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s16),

                  // Mantiene bilanciamento spaziale
                  const Opacity(
                    opacity: 0.0,
                    child: Text('', style: AppTextStyles.header2),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Overlay di flash bianco temporaneo
        IgnorePointer(
          ignoring: !_showFlash,
          child: AnimatedOpacity(
            opacity: _showFlash ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            child: Container(
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
