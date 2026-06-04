import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_durations.dart';

/// Primary CTA used across the kiosk flow. Implements a 0.96 scale press
/// animation. Defaults preserve the original one-size-fits-all look; pass
/// `width`/`height`/`borderRadius`/`textStyle` to match one-off Figma frames
/// (e.g. the asymmetric 694x171 `NextHouse_Selfie_Button`, Figma node 28:236).
class KioskButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final TextStyle? textStyle;

  const KioskButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor = AppColors.primary,
    this.textColor = AppColors.background,
    this.width,
    this.height,
    this.borderRadius,
    this.textStyle,
  });

  @override
  State<KioskButton> createState() => _KioskButtonState();
}

class _KioskButtonState extends State<KioskButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final TextStyle effectiveTextStyle =
        (widget.textStyle ?? AppTextStyles.buttonText).copyWith(
          color: widget.textColor,
        );

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: AppDurations.buttonPress,
        curve: Curves.easeInOut,
        child: Container(
          width: widget.width,
          height: widget.height ?? 88.0,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s48),
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: widget.borderRadius ?? AppRadius.buttonBorder,
          ),
          alignment: Alignment.center,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              widget.text,
              style: effectiveTextStyle,
              textAlign: TextAlign.center,
              maxLines: 1,
              softWrap: false,
            ),
          ),
        ),
      ),
    );
  }
}
