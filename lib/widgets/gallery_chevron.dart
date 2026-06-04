import 'package:flutter/material.dart';

/// Figma `NextHouse_Gallery_Left` / `NextHouse_Gallery_Right` chevron at 100x100.
/// Circular white-translucent bg with chevron icon. Used in the Result screen
/// (Figma 112:195). Set `isLeft: true` for the left-pointing variant.
class GalleryChevron extends StatelessWidget {
  final bool isLeft;
  final VoidCallback? onPressed;
  final double size;

  const GalleryChevron({
    super.key,
    required this.isLeft,
    this.onPressed,
    this.size = 100.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
        onPressed: onPressed,
      ),
    );
  }
}
