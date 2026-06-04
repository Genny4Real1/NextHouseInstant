import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum GalleryAction { edit, share, delete, print }

/// Figma `NextHouse_Gallery_Button` (4 variants) at ~50x66.
/// Used in the Result screen bottom toolbar (Figma 112:195).
class GalleryButton extends StatelessWidget {
  final GalleryAction action;
  final VoidCallback? onPressed;
  final double iconSize;
  final double width;
  final bool disabled;

  const GalleryButton({
    super.key,
    required this.action,
    this.onPressed,
    this.iconSize = 32.0,
    this.width = 50.0,
    this.disabled = false,
  });

  IconData get _icon {
    switch (action) {
      case GalleryAction.edit:
        return Icons.edit_rounded;
      case GalleryAction.share:
        return Icons.ios_share_rounded;
      case GalleryAction.delete:
        return Icons.delete_outline_rounded;
      case GalleryAction.print:
        return Icons.print_rounded;
    }
  }

  String get _label {
    switch (action) {
      case GalleryAction.edit:
        return 'Edit';
      case GalleryAction.share:
        return 'Share';
      case GalleryAction.delete:
        return 'Delete';
      case GalleryAction.print:
        return 'Print';
    }
  }

  Color get _iconColor {
    if (disabled) return Colors.white;
    switch (action) {
      case GalleryAction.share:
        return AppColors.primary;
      case GalleryAction.delete:
        return AppColors.error;
      case GalleryAction.edit:
      case GalleryAction.print:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget icon = Icon(_icon, color: _iconColor, size: iconSize);
    final Widget label = Text(_label, style: AppTextStyles.galleryToolbarLabel);

    final Widget body = Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[icon, const SizedBox(height: 4.0), label],
    );

    if (disabled) {
      return Opacity(opacity: 0.4, child: SizedBox(width: width, child: body));
    }

    return SizedBox(
      width: width,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: body,
          ),
        ),
      ),
    );
  }
}
