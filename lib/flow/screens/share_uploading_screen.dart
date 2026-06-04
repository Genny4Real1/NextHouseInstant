import 'package:flutter/material.dart';
import '../../widgets/processing_card.dart';
import '../../widgets/share_photo_strip.dart';

/// Figma 48-123 - share uploading mock. Two photos side-by-side and a
/// centered spinning wheel. Holds 2s, then advances to the QR screen.
class ShareUploadingScreen extends StatefulWidget {
  final List<String> capturedImages;

  const ShareUploadingScreen({
    super.key,
    required this.capturedImages,
  });

  @override
  State<ShareUploadingScreen> createState() => _ShareUploadingScreenState();
}

class _ShareUploadingScreenState extends State<ShareUploadingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String? left = widget.capturedImages.isNotEmpty
        ? widget.capturedImages[0]
        : null;
    final String? right = widget.capturedImages.length > 1
        ? widget.capturedImages[1]
        : null;

    return ColoredBox(
      color: Colors.black,
      child: Stack(
        children: <Widget>[
          // Photo strip behind the spinner
          Positioned.fill(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: SharePhotoStrip(
                  leftPhotoPath: left,
                  rightPhotoPath: right,
                ),
              ),
            ),
          ),
          // Centered spinner
          Center(
            child: ProcessingCard(rotation: _rotationController),
          ),
        ],
      ),
    );
  }
}
