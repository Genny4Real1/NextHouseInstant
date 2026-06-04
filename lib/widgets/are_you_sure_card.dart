import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Figma `NextHouse_Areyousure_Button` (117:589) - 691x620 orange card,
/// r=40, with a centered title (Inter 64px white) and a Yes/No pill row.
/// Used by `ShareConfirmScreen`.
class AreYouSureCard extends StatelessWidget {
  final String title;
  final String confirmLabel;
  final String cancelLabel;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const AreYouSureCard({
    super.key,
    required this.title,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 691.0,
      height: 620.0,
      padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 56.0),
      decoration: BoxDecoration(
        color: AppColors.nextHouseOrange,
        borderRadius: BorderRadius.circular(40.0),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x4C000000),
            blurRadius: 30.0,
            offset: Offset(0.0, 15.0),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Center(
              child: Text(
                title,
                style: AppTextStyles.areYouSureTitle,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 32.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              _buildPill(label: confirmLabel, onPressed: onConfirm),
              _buildPill(label: cancelLabel, onPressed: onCancel),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPill({required String label, required VoidCallback onPressed}) {
    return SizedBox(
      width: 180.0,
      height: 90.0,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: AppColors.nextHouseOrange,
          backgroundColor: Colors.white,
          elevation: 4.0,
          shadowColor: Colors.black.withAlpha(50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(45.0),
          ),
        ),
        onPressed: onPressed,
        child: Text(label, style: AppTextStyles.areYouSureChoice),
      ),
    );
  }
}
