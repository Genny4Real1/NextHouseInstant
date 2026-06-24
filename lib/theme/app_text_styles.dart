import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle get countdownDisplay => GoogleFonts.inter(
    fontSize: 120.0,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static TextStyle get header1 => GoogleFonts.inter(
    fontSize: 36.0,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  static TextStyle get header2 => GoogleFonts.inter(
    fontSize: 24.0,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  static TextStyle get buttonText => GoogleFonts.inter(
    fontSize: 20.0,
    fontWeight: FontWeight.w500,
    color: AppColors.background,
  );

  static TextStyle get body => GoogleFonts.inter(
    fontSize: 16.0,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );
}

