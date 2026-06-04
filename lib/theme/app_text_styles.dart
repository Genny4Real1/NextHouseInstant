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

  // Figma: CameraScreenStartTimer (131:144) and CameraScreenTimer (33:15) - Inter Regular 96px white with subtle drop shadow
  static const TextStyle countdownTitle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 96.0,
    fontWeight: FontWeight.w400,
    color: Colors.white,
    shadows: <Shadow>[
      Shadow(color: Colors.black, blurRadius: 4, offset: Offset(0, 2)),
    ],
  );

  // Figma: Timer 5/4/3/2/1 (53:85..112) - Inter Regular 96px white, outlined
  static const TextStyle countdownNumber = TextStyle(
    fontFamily: 'Inter',
    fontSize: 96.0,
    fontWeight: FontWeight.w400,
    color: Colors.white,
    shadows: <Shadow>[
      Shadow(color: Colors.black, blurRadius: 6, offset: Offset(2, 2)),
    ],
  );

  // Figma: AreYouSure title (117:589) - Inter Regular 64px white, line-height 1.15
  static const TextStyle areYouSureTitle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 64.0,
    fontWeight: FontWeight.w400,
    color: Colors.white,
    height: 1.15,
  );

  // Figma: AskAnother title (69:62) - Inter Bold 36px white, line-height 1.2
  static const TextStyle askAnotherTitle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 36.0,
    fontWeight: FontWeight.w700,
    color: Colors.white,
    height: 1.2,
  );

  // Figma: AreYouSure Yes/No (117:589) - Inter Medium 40px orange
  static const TextStyle areYouSureChoice = TextStyle(
    fontFamily: 'Inter',
    fontSize: 40.0,
    fontWeight: FontWeight.w500,
    color: AppColors.nextHouseOrange,
  );

  // Figma: AskAnother Yes/No (69:62) - Inter Bold 28px orange
  static const TextStyle askAnotherChoice = TextStyle(
    fontFamily: 'Inter',
    fontSize: 28.0,
    fontWeight: FontWeight.w700,
    color: AppColors.nextHouseOrange,
  );

  // Figma: Scan me! (48:152) - Inter Regular 48px black
  static const TextStyle scanMe = TextStyle(
    fontFamily: 'Inter',
    fontSize: 48.0,
    fontWeight: FontWeight.w400,
    color: Colors.black,
  );

  // Figma: Tap to go back (48:152) - Inter Regular 32px white 72%
  static const TextStyle tapToGoBack = TextStyle(
    fontFamily: 'Inter',
    fontSize: 32.0,
    fontWeight: FontWeight.w400,
    color: Colors.white70,
  );

  // Figma: NextHouse_Done_Button (74:91) - Inter Medium 40px white
  static const TextStyle donePill = TextStyle(
    fontFamily: 'Inter',
    fontSize: 40.0,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );

  // Figma: Gallery button labels (112:195) - Inter Medium 14px white
  static const TextStyle galleryToolbarLabel = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );

  // Onboarding bubble message - Inter Medium 24px dark text
  static const TextStyle onboardingMessage = TextStyle(
    fontFamily: 'Inter',
    fontSize: 24.0,
    fontWeight: FontWeight.w500,
    color: Colors.black87,
  );
}
