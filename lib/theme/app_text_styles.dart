import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const TextStyle countdownDisplay = TextStyle(
    fontFamily: 'Inter',
    fontSize: 120.0,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle header1 = TextStyle(
    fontFamily: 'Inter',
    fontSize: 36.0,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  static const TextStyle header2 = TextStyle(
    fontFamily: 'Inter',
    fontSize: 24.0,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  static const TextStyle buttonText = TextStyle(
    fontFamily: 'Inter',
    fontSize: 20.0,
    fontWeight: FontWeight.w500,
    color: AppColors.background,
  );

  static const TextStyle body = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16.0,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  // Figma: NextHouse_SpinningProcessing text node (74:76) - Inter Regular 96px white
  static const TextStyle processingTitle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 96.0,
    fontWeight: FontWeight.w400,
    color: Colors.white,
  );

  // Figma: NextHouse_Selfie_Button text node (I28:236;25:18) - Saira Stencil One 96px white
  static const TextStyle kioskCta = TextStyle(
    fontFamily: 'Saira Stencil One',
    fontSize: 96.0,
    fontWeight: FontWeight.normal,
    color: Colors.white,
  );
}
