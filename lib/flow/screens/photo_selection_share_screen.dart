import 'dart:io';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/camera_placeholder.dart';
import '../../widgets/kiosk_button.dart';
import '../../widgets/thumbnail_checkmark.dart';

/// Figma 74-91 - Photo selection grid.
/// - Shows only actual photos (no placeholder blanks)
/// - Max 4 columns x 3 rows per page
/// - Paginates if > 12 photos
/// - Done button at bottom center
class PhotoSelectionShareScreen extends StatefulWidget {
  final List<String> capturedImages;
  final Set<String> selectedImages;
  final Function(String) onToggleSelection;
  final VoidCallback onCancel;
  final VoidCallback onDone;

  const PhotoSelectionShareScreen({
    super.key,
    required this.capturedImages,
    required this.selectedImages,
    required this.onToggleSelection,
    required this.onCancel,
    required this.onDone,
  });

  @override
  State<PhotoSelectionShareScreen> createState() =>
      _PhotoSelectionShareScreenState();
}

class _PhotoSelectionShareScreenState
    extends State<PhotoSelectionShareScreen> {
  static const int _columns = 4;
  static const int _rows = 3;
  int _currentPage = 0;

  int get _photosPerPage => _columns * _rows;
  int get _totalPages =>
      (widget.capturedImages.length / _photosPerPage).ceil().clamp(1, 999);

  List<String> get _currentPagePhotos {
    final int start = _currentPage * _photosPerPage;
    if (start >= widget.capturedImages.length) return [];
    final int end = (start + _photosPerPage).clamp(0, widget.capturedImages.length);
    return widget.capturedImages.sublist(start, end);
  }

  @override
  Widget build(BuildContext context) {
    final bool hasSelection = widget.selectedImages.isNotEmpty;
    final int totalPages = _totalPages;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Title bar with close button
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s24,
                vertical: AppSpacing.s16,
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Select your photos to share',
                      style: AppTextStyles.header1,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Container(
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
                      onPressed: widget.onCancel,
                    ),
                  ),
                ],
              ),
            ),

            // Photo grid
            Expanded(
              child: Center(
                child: _buildGrid(totalPages),
              ),
            ),

            // Done button at bottom center
            Padding(
              padding: const EdgeInsets.only(
                bottom: AppSpacing.s32,
                top: AppSpacing.s16,
              ),
              child: KioskButton(
                text: 'Done',
                onPressed: hasSelection ? widget.onDone : () {},
                backgroundColor: AppColors.nextHouseOrange,
                textColor: Colors.white,
                width: 240.0,
                height: 100.0,
                borderRadius: BorderRadius.circular(50.0),
                textStyle: AppTextStyles.donePill,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(int totalPages) {
    final List<String> pagePhotos = _currentPagePhotos;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Grid rows
        ...List<Widget>.generate(_rows, (row) {
          final List<Widget> rowCells = [];
          for (int col = 0; col < _columns; col++) {
            final int index = row * _columns + col;
            if (index < pagePhotos.length) {
              rowCells.add(_buildPhotoCell(pagePhotos[index]));
            } else {
              rowCells.add(_buildEmptyCell());
            }
            if (col < _columns - 1) {
              rowCells.add(const SizedBox(width: 6.0));
            }
          }
          return Padding(
            padding: EdgeInsets.only(bottom: row < _rows - 1 ? 6.0 : 0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: rowCells,
            ),
          );
        }),

        // Page indicator (only if > 12 photos)
        if (totalPages > 1)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.s16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left_rounded,
                      color: Colors.white, size: 32.0),
                  onPressed: _currentPage > 0
                      ? () => setState(() => _currentPage--)
                      : null,
                ),
                Text(
                  '${_currentPage + 1} / $totalPages',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right_rounded,
                      color: Colors.white, size: 32.0),
                  onPressed: _currentPage < totalPages - 1
                      ? () => setState(() => _currentPage++)
                      : null,
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildPhotoCell(String path) {
    final bool isSelected = widget.selectedImages.contains(path);
    final File file = File(path);
    // Use a responsive cell size based on screen width
    final double cellSize =
        (MediaQuery.of(context).size.width - 120.0) / _columns;

    return GestureDetector(
      onTap: () => widget.onToggleSelection(path),
      child: SizedBox(
        width: cellSize,
        height: cellSize / 1.5,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (file.existsSync())
              Image.file(file, fit: BoxFit.cover, gaplessPlayback: true)
            else
              const CameraPlaceholder(showGuides: false),
            // Checkmark at bottom-right
            Positioned(
              right: 8.0,
              bottom: 8.0,
              child: ThumbnailCheckmark(
                isSelected: isSelected,
                onTap: () => widget.onToggleSelection(path),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCell() {
    final double cellSize =
        (MediaQuery.of(context).size.width - 120.0) / _columns;
    return SizedBox(
      width: cellSize,
      height: cellSize / 1.5,
    );
  }
}
