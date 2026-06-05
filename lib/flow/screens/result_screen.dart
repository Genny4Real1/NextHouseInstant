import 'dart:io';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_durations.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/camera_placeholder.dart';
import '../../widgets/gallery_button.dart';
import '../../widgets/gallery_chevron.dart';
import '../../widgets/onboarding_overlay.dart';

/// Figma 112-195 / 113-286 / 113-325 - full-bleed photo carousel with
/// Edit/Share/Delete/Print toolbar and L/R navigation chevrons.
class ResultScreen extends StatefulWidget {
  final VoidCallback onReset;
  final VoidCallback onDone;
  final VoidCallback onDelete;
  final VoidCallback onShare;
  final VoidCallback onEdit;
  final VoidCallback onPrint;
  final bool showDoneToolbar;
  final List<String> capturedImages;
  final int currentGalleryIndex;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final ValueChanged<int> onPageChanged;

  const ResultScreen({
    super.key,
    required this.onReset,
    required this.onDone,
    required this.onDelete,
    required this.onShare,
    required this.onEdit,
    required this.onPrint,
    required this.showDoneToolbar,
    required this.capturedImages,
    required this.currentGalleryIndex,
    required this.onPrevious,
    required this.onNext,
    required this.onPageChanged,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late final PageController _pageController;
  bool _showOnboarding = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: widget.currentGalleryIndex,
      viewportFraction: 0.65,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ResultScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentGalleryIndex != oldWidget.currentGalleryIndex &&
        widget.currentGalleryIndex != _pageController.page?.round()) {
      _pageController.animateToPage(
        widget.currentGalleryIndex,
        duration: AppDurations.pageTransition,
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasImages = widget.capturedImages.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Carousel
            if (hasImages)
              PageView.builder(
                controller: _pageController,
                itemCount: widget.capturedImages.length,
                onPageChanged: widget.onPageChanged,
                physics: widget.showDoneToolbar
                    ? const BouncingScrollPhysics()
                    : const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final String path = widget.capturedImages[index];
                  return AnimatedBuilder(
                    animation: _pageController,
                    builder: (context, child) {
                      double scale = 1.0;
                      if (_pageController.position.haveDimensions) {
                        double page =
                            _pageController.page ??
                            widget.currentGalleryIndex.toDouble();
                        double diff = page - index;
                        scale = (1 - (diff.abs() * 0.15)).clamp(0.8, 1.0);
                      } else {
                        scale = index == widget.currentGalleryIndex
                            ? 1.0
                            : 0.85;
                      }
                      return Center(
                        child: Transform.scale(
                          scale: scale,
                          child: AspectRatio(
                            aspectRatio: 4 / 3,
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 8.0,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(24.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(127),
                                    blurRadius: 15.0,
                                    spreadRadius: 1.0,
                                    offset: const Offset(0.0, 6.0),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(24.0),
                                child: Image.file(
                                  File(path),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const CameraPlaceholder(
                                        showGuides: false,
                                      ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              )
            else
              const Center(child: CameraPlaceholder(showGuides: false)),

            // Top-right close button
            Positioned(
              top: 16.0,
              right: 16.0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  iconSize: 24.0,
                  icon: const Icon(Icons.close_rounded, color: Colors.white),
                  onPressed: widget.onReset,
                ),
              ),
            ),

            // Top center: counter badge
            if (hasImages && widget.capturedImages.length > 1)
              Positioned(
                top: 16.0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s16,
                    vertical: AppSpacing.s8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(25),
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Text(
                    '${widget.currentGalleryIndex + 1} / ${widget.capturedImages.length}',
                    style: AppTextStyles.buttonText.copyWith(
                      color: Colors.white,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

            // Left chevron
            if (widget.showDoneToolbar &&
                hasImages &&
                widget.capturedImages.length > 1)
              Positioned(
                left: 7.76,
                child: Center(
                  child: GalleryChevron(
                    isLeft: true,
                    onPressed: widget.onPrevious,
                  ),
                ),
              ),

            // Right chevron
            if (widget.showDoneToolbar &&
                hasImages &&
                widget.capturedImages.length > 1)
              Positioned(
                right: 7.76,
                child: Center(
                  child: GalleryChevron(
                    isLeft: false,
                    onPressed: widget.onNext,
                  ),
                ),
              ),

            // Bottom toolbar (Edit / Share / Delete / Print)
            if (widget.showDoneToolbar && hasImages)
              Positioned(
                left: 225.5,
                right: 225.5,
                bottom: 28.0,
                height: 66.0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GalleryButton(
                        action: GalleryAction.edit,
                        onPressed: widget.onEdit,
                        disabled: true,
                      ),
                      GalleryButton(
                        action: GalleryAction.share,
                        onPressed: widget.onShare,
                      ),
                      GalleryButton(
                        action: GalleryAction.delete,
                        onPressed: widget.onDelete,
                      ),
                      GalleryButton(
                        action: GalleryAction.print,
                        onPressed: widget.onPrint,
                        disabled: true,
                      ),
                    ],
                  ),
                ),
              ),

            // Onboarding overlay
            if (_showOnboarding)
              OnboardingOverlay(
                message: 'Swipe to view your photos. Tap Share to share them.',
                onDismiss: () => setState(() => _showOnboarding = false),
              ),
          ],
        ),
      ),
    );
  }
}
