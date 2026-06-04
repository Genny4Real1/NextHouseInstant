import 'package:flutter/material.dart';
import '../../widgets/are_you_sure_card.dart';

/// Figma 117-589 - "Are you sure" overlay for partial share selection.
class ShareConfirmScreen extends StatelessWidget {
  final VoidCallback onYes;
  final VoidCallback onNo;

  const ShareConfirmScreen({
    super.key,
    required this.onYes,
    required this.onNo,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: ColoredBox(
            color: Colors.black.withAlpha(128),
            child: Center(
              child: AreYouSureCard(
                title:
                    'The unselected images will be no longer available. Continue?',
                confirmLabel: 'Yes',
                cancelLabel: 'No',
                onConfirm: onYes,
                onCancel: onNo,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
