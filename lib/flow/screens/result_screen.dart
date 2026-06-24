import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/camera_placeholder.dart';

import '../photobooth_flow_state.dart';
import 'package:nexthouse_instant/l10n/app_localizations.dart';

class ResultScreen extends StatefulWidget {
  final VoidCallback onReset;
  final VoidCallback onDone;
  final VoidCallback onDelete;
  final VoidCallback onShare;
  final VoidCallback onEdit;
  final bool showDoneToolbar;
  final List<String> capturedImages;
  final int currentGalleryIndex;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final ValueChanged<int> onPageChanged;
  final PhotoboothFlowState flowState;

  const ResultScreen({
    super.key,
    required this.onReset,
    required this.onDone,
    required this.onDelete,
    required this.onShare,
    required this.onEdit,
    required this.showDoneToolbar,
    required this.capturedImages,
    required this.currentGalleryIndex,
    required this.onPrevious,
    required this.onNext,
    required this.onPageChanged,
    required this.flowState,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late final PageController _pageController;

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
    // Sincronizza il controller se l'indice esterno cambia (es. tramite frecce)
    if (widget.currentGalleryIndex != oldWidget.currentGalleryIndex &&
        widget.currentGalleryIndex != _pageController.page?.round()) {
      _pageController.animateToPage(
        widget.currentGalleryIndex,
        duration: const Duration(milliseconds: 300),
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
            // Contenuto principale
            Column(
              children: [
                const SizedBox(height: AppSpacing.s24),
                // Indicatore contatore foto in alto (es. 2 / 3)
                if (hasImages && widget.capturedImages.length > 1)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20.0),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.s16,
                          vertical: AppSpacing.s8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(20),
                          borderRadius: BorderRadius.circular(20.0),
                          border: Border.all(
                            color: Colors.white.withAlpha(30),
                            width: 1.0,
                          ),
                        ),
                        child: Text(
                          '${widget.currentGalleryIndex + 1} / ${widget.capturedImages.length}',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            color: Colors.white,
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: AppSpacing.s16),

                // Contenitore della foto (Carousel con PageView)
                Expanded(
                  child: Center(
                    child: hasImages
                        ? PageView.builder(
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
                                    double page = _pageController.page ?? widget.currentGalleryIndex.toDouble();
                                    double diff = page - index;
                                    scale = (1 - (diff.abs() * 0.15)).clamp(0.8, 1.0);
                                  } else {
                                    scale = index == widget.currentGalleryIndex ? 1.0 : 0.85;
                                  }

                                  return Center(
                                    child: Transform.scale(
                                      scale: scale,
                                      child: AspectRatio(
                                        aspectRatio: 4 / 3,
                                        child: Container(
                                          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                                                  const CameraPlaceholder(showGuides: false),
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
                        : const CameraPlaceholder(showGuides: false),
                  ),
                ),
                const SizedBox(height: AppSpacing.s32),

                // Sezione inferiore animata (Pulsante Done vs. Toolbar con pulsanti disabilitati)
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: !widget.showDoneToolbar
                      ? Center(
                          key: const ValueKey('done_button_view'),
                          child: SizedBox(
                            width: 160.0,
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
                              onPressed: widget.onDone,
                              child: Text(
                                AppLocalizations.of(context)!.done,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        )
                      : Container(
                          key: const ValueKey('toolbar_view'),
                          width: 500.0,
                          height: 140.0,
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildActiveToolbarButton(
                                icon: Icons.edit_rounded,
                                label: AppLocalizations.of(context)!.edit,
                                onPressed: widget.onEdit,
                              ),
                              _buildActiveToolbarButton(
                                icon: Icons.share_rounded,
                                label: AppLocalizations.of(context)!.share,
                                onPressed: widget.onShare,
                              ),
                              _buildActiveToolbarButton(
                                icon: Icons.delete_rounded,
                                label: AppLocalizations.of(context)!.delete,
                                onPressed: widget.onDelete,
                              ),
                            ],
                          ),
                        ),
                ),
                const SizedBox(height: AppSpacing.s24),
              ],
            ),

            // Pulsante Freccia Sinistra (Precedente) con glassmorphism
            if (widget.showDoneToolbar && hasImages && widget.capturedImages.length > 1)
              Positioned(
                left: 24.0,
                child: ClipOval(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(20),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withAlpha(35),
                          width: 1.5,
                        ),
                      ),
                      child: IconButton(
                        iconSize: 40.0,
                        icon: Image.asset(
                          'assets/images/Instant_Gallery_LeftNavigation.png',
                          width: 40.0,
                          height: 40.0,
                          fit: BoxFit.contain,
                        ),
                        onPressed: widget.onPrevious,
                      ),
                    ),
                  ),
                ),
              ),

            // Pulsante Freccia Destra (Successiva) con glassmorphism
            if (widget.showDoneToolbar && hasImages && widget.capturedImages.length > 1)
              Positioned(
                right: 24.0,
                child: ClipOval(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(20),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withAlpha(35),
                          width: 1.5,
                        ),
                      ),
                      child: IconButton(
                        iconSize: 40.0,
                        icon: Image.asset(
                          'assets/images/Instant_Gallery_RightNavigation.png',
                          width: 40.0,
                          height: 40.0,
                          fit: BoxFit.contain,
                        ),
                        onPressed: widget.onNext,
                      ),
                    ),
                  ),
                ),
              ),

            // Pulsante Chiudi/Esci discreto in alto a destra
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
                  icon: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                  ),
                  onPressed: widget.onReset,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildActiveToolbarButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16.0),
        child: Container(
          width: 120.0,
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 76.0,
                height: 76.0,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(20),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withAlpha(30),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(30),
                      blurRadius: 10.0,
                      offset: const Offset(0.0, 4.0),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 36.0,
                  ),
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16.0,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
