import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/app_durations.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/qr_share_card.dart';

/// Figma 48-152 - QR share. Blurred photo background, white card with QR
/// code and "Scan me!", "Tap to go back" below.
/// Auto-reset bumped to 60s (D8). The visible countdown ring is replaced
/// by a thin LinearProgressIndicator inside the QrShareCard.
class PhotoGalleryScreenShare2 extends StatefulWidget {
  final Set<String> selectedImages;
  final VoidCallback onDone;

  const PhotoGalleryScreenShare2({
    super.key,
    required this.selectedImages,
    required this.onDone,
  });

  @override
  State<PhotoGalleryScreenShare2> createState() =>
      _PhotoGalleryScreenShare2State();
}

class _PhotoGalleryScreenShare2State extends State<PhotoGalleryScreenShare2> {
  Timer? _refreshTimer;
  double _progress = 1.0;
  static const Duration _refreshInterval = AppDurations.shareQrProgressRefresh;
  static const Duration _autoReset = AppDurations.shareQrAutoReset;
  DateTime? _deadline;

  @override
  void initState() {
    super.initState();
    _deadline = DateTime.now().add(_autoReset);
    _refreshTimer = Timer.periodic(_refreshInterval, (_) {
      if (_deadline == null || !mounted) return;
      final Duration remaining = _deadline!.difference(DateTime.now());
      if (remaining.isNegative) {
        widget.onDone();
        return;
      }
      setState(() {
        _progress = remaining.inMilliseconds / _autoReset.inMilliseconds;
      });
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  String get _stableUrl =>
      'https://nexthouse.it/share/gallery?count=${widget.selectedImages.length}';

  @override
  Widget build(BuildContext context) {
    final String shareUrl = _stableUrl;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Blurred photo background
            Positioned.fill(
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
                child: widget.selectedImages.isNotEmpty
                    ? Image.file(
                        File(widget.selectedImages.first),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const ColoredBox(color: Colors.black),
                      )
                    : const ColoredBox(color: Colors.black),
              ),
            ),
            // Centered QR card
            Center(
              child: QrShareCard(data: shareUrl, progress: _progress),
            ),
            // "Tap to go back" below the card
            Positioned(
              left: 0,
              right: 0,
              bottom: 24.0,
              child: const Center(
                child: Text('Tap to go back', style: AppTextStyles.tapToGoBack),
              ),
            ),
            // Top-right close
            Positioned(
              top: 16.0,
              right: 16.0,
              child: GestureDetector(
                onTap: widget.onDone,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(20),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(AppSpacing.s8),
                  child: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 24.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
