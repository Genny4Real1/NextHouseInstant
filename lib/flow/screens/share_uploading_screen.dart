import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/app_durations.dart';
import '../../widgets/processing_card.dart';

/// Figma 48-123 - share uploading mock.
/// If only one photo: shows it blurred in the background.
/// If multiple photos: endless auto-scrolling animation of all photos.
/// Centered spinning wheel overlay. Holds 2s, then advances to the QR screen.
class ShareUploadingScreen extends StatefulWidget {
  final List<String> capturedImages;

  const ShareUploadingScreen({super.key, required this.capturedImages});

  @override
  State<ShareUploadingScreen> createState() => _ShareUploadingScreenState();
}

class _ShareUploadingScreenState extends State<ShareUploadingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rotationController;
  late final AnimationController _scrollController;
  late final Animation<double> _scrollAnimation;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: AppDurations.processingRotation,
    )..repeat();

    if (widget.capturedImages.length > 1) {
      _scrollController = AnimationController(
        vsync: this,
        duration: Duration(
          seconds: widget.capturedImages.length * 3,
        ),
      );
      _scrollAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _scrollController,
          curve: Curves.linear,
        ),
      );
      _scrollController.repeat();
    } else {
      _scrollController = AnimationController(vsync: this);
      _scrollAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _scrollController, curve: Curves.linear),
      );
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: Stack(
        children: <Widget>[
          // Background photos
          Positioned.fill(
            child: _buildBackground(),
          ),
          // Centered spinner
          Center(child: ProcessingCard(rotation: _rotationController)),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    if (widget.capturedImages.isEmpty) {
      return const ColoredBox(color: Colors.black);
    }

    if (widget.capturedImages.length == 1) {
      // Single photo: show it blurred in the background
      return ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 3.5, sigmaY: 3.5),
        child: Image.file(
          File(widget.capturedImages[0]),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              const ColoredBox(color: Colors.black),
        ),
      );
    }

    // Multiple photos: endless auto-scrolling animation
    return AnimatedBuilder(
      animation: _scrollAnimation,
      builder: (context, child) {
        final double totalWidth =
            MediaQuery.of(context).size.width * widget.capturedImages.length;
        final double offset = -_scrollAnimation.value * totalWidth;

        return ClipRect(
          child: Stack(
            children: List<Widget>.generate(
              widget.capturedImages.length * 2,
              (index) {
                final int imageIndex = index % widget.capturedImages.length;
                return Positioned(
                  left: offset +
                      index * MediaQuery.of(context).size.width,
                  top: 0,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: Image.file(
                    File(widget.capturedImages[imageIndex]),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const ColoredBox(color: Colors.black),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
