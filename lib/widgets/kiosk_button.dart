import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_durations.dart';

class KioskButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;

  const KioskButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor = AppColors.primary,
    this.textColor = AppColors.background,
  });

  @override
  State<KioskButton> createState() => _KioskButtonState();
}

class _KioskButtonState extends State<KioskButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
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
          height: 88.0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s48,
          ),
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: AppRadius.buttonBorder,
          ),
          alignment: Alignment.center,
          child: Text(
            widget.text,
            style: AppTextStyles.buttonText.copyWith(color: widget.textColor),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
