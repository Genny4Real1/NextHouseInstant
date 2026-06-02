import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';

class ProcessingScreen extends StatelessWidget {
  const ProcessingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.s64),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Loader circolare minimale
              SizedBox(
                width: 64.0,
                height: 64.0,
                child: CircularProgressIndicator(
                  strokeWidth: 3.0,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  backgroundColor: AppColors.surface,
                ),
              ),
              SizedBox(height: AppSpacing.s32),

              // Testo di stato essenziale
              Text(
                'Elaborazione foto...',
                style: AppTextStyles.header2,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
