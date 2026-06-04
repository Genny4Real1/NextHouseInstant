import 'dart:io';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/camera_placeholder.dart';
import '../../widgets/kiosk_button.dart';
import '../../widgets/thumbnail_checkmark.dart';

/// Figma 74-91 - 4x3 grid of photo thumbnails. Row 1 shows captured photos;
/// rows 2-4 are empty placeholders. Last cell of row 4 = orange "Done" pill.
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

class _PhotoSelectionShareScreenState extends State<PhotoSelectionShareScreen> {
  static const int _columns = 4;
  static const int _rows = 3;
  static const double _cellSize = 288.5;
  static const double _cellGap = 4.0;
  static const double _gridLeft = 48.0;
  static const double _gridTop = 48.0;

  @override
  Widget build(BuildContext context) {
    final bool hasSelection = widget.selectedImages.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Small English title (D10)
            const Positioned(
              top: 8.0,
              left: 0,
              right: 0,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  'Select your photos to share',
                  style: AppTextStyles.header1,
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            // 4x3 grid
            Positioned(
              left: _gridLeft,
              top: _gridTop,
              child: Column(
                children: List<Widget>.generate(_rows, (row) {
                  final List<Widget> cells = <Widget>[];
                  for (int col = 0; col < _columns; col++) {
                    if (col > 0) {
                      cells.add(const SizedBox(width: _cellGap));
                    }
                    final int index = row * _columns + col;
                    final bool isDoneCell =
                        row == _rows - 1 && col == _columns - 1;
                    if (isDoneCell) {
                      cells.add(_buildDoneCell(hasSelection: hasSelection));
                    } else if (index < widget.capturedImages.length) {
                      cells.add(_buildPhotoCell(widget.capturedImages[index]));
                    } else {
                      cells.add(_buildEmptyCell());
                    }
                  }
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: row < _rows - 1 ? _cellGap : 0,
                    ),
                    child: Row(children: cells),
                  );
                }),
              ),
            ),

            // Top-right close
            Positioned(
              top: 16.0,
              right: 16.0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  iconSize: 28.0,
                  icon: const Icon(Icons.close_rounded, color: Colors.white),
                  onPressed: widget.onCancel,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoCell(String path) {
    final bool isSelected = widget.selectedImages.contains(path);
    final File file = File(path);

    return GestureDetector(
      onTap: () => widget.onToggleSelection(path),
      child: SizedBox(
        width: _cellSize,
        height: _cellSize / 1.71, // 4:3 ratio -> 288.5 x ~168.5
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (file.existsSync())
              Image.file(file, fit: BoxFit.cover, gaplessPlayback: true)
            else
              const CameraPlaceholder(showGuides: false),
            // Bottom-right checkmark pill
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
    return Container(
      width: _cellSize,
      height: _cellSize / 1.71,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: const Center(
        child: Icon(
          Icons.image_outlined,
          color: Colors.white24,
          size: 48.0,
        ),
      ),
    );
  }

  Widget _buildDoneCell({required bool hasSelection}) {
    return SizedBox(
      width: _cellSize,
      height: _cellSize / 1.71,
      child: Center(
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
    );
  }
}
