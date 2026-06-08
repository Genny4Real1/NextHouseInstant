import 'package:flutter/material.dart';

/// Figma `NextHouse_Gallery_Left` / `NextHouse_Gallery_Right` chevron at 100x100.
/// Circular white-translucent bg with chevron icon. Used in the Result screen
/// (Figma 112:195). Set `isLeft: true` for the left-pointing variant.
/// When [disabled] is true, the chevron is grayed out and [onPressed] is not called.
class GalleryChevron extends StatelessWidget {
  final bool isLeft;
  final VoidCallback? onPressed;
  final double size;
  final bool disabled;

  const GalleryChevron({
    super.key,
    required this.isLeft,
    this.onPressed,
    this.size = 100.0,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: disabled ? 0.3 : 1.0,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(25),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          iconSize: 40.0,
          icon: Icon(
            isLeft ? Icons.chevron_left_rounded : Icons.chevron_right_rounded,
            color: Colors.white,
          ),
          onPressed: disabled ? null : onPressed,
        ),
      ),
    );
  }
}
