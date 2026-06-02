import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        surface: AppColors.surface,
        primary: AppColors.primary,
        onPrimary: AppColors.background,
        onSurface: AppColors.textPrimary,
      ),
      fontFamily: 'Inter',
      useMaterial3: true,
    );
  }
}
