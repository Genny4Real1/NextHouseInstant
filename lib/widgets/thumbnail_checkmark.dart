import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Figma `NextHouser_Checkmark_Button` (~89x141 white pill with check).
/// Rendered at the bottom-right corner of each populated tile in the share
/// selection grid (Figma 74:91).
class ThumbnailCheckmark extends StatelessWidget {
  final bool isSelected;
  final VoidCallback? onTap;

  const ThumbnailCheckmark({super.key, required this.isSelected, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(70.5),
        child: Container(
          width: 89.0,
          height: 141.0,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4.0),
          ),
          child: Icon(
            Icons.check_rounded,
            size: 60.0,
            color: isSelected ? Colors.white : Colors.transparent,
          ),
        ),
      ),
    );
  }
}
