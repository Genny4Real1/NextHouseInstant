import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';

/// Self-dismissing onboarding hint bubble (D11).
///
/// Behavior:
///   - Auto-dismisses after [autoDismiss] (default 5s).
///   - Tap anywhere on the backdrop dismisses immediately.
///   - Small "X" close button on the card itself.
///
/// Visual:
///   - Translucent black backdrop (alpha 0.35) over the whole screen.
///   - White rounded card (r=24) with a soft shadow, dark Inter 24px w500
///     text, padded 24h/16v.
///   - Card floats at the top by default (24px top margin), tap-through
///     outside the card area fires the backdrop dismiss.
class OnboardingOverlay extends StatefulWidget {
  final String message;
  final VoidCallback onDismiss;
  final Duration autoDismiss;
  final EdgeInsetsGeometry margin;
  final bool showCloseButton;

  const OnboardingOverlay({
    super.key,
    required this.message,
    required this.onDismiss,
    this.autoDismiss = const Duration(seconds: 5),
    this.margin = const EdgeInsets.only(top: 24.0, left: 24.0, right: 24.0),
    this.showCloseButton = true,
  });

  @override
  State<OnboardingOverlay> createState() => _OnboardingOverlayState();
}

class _OnboardingOverlayState extends State<OnboardingOverlay> {
  Timer? _autoDismissTimer;

  @override
  void initState() {
    super.initState();
    _autoDismissTimer = Timer(widget.autoDismiss, widget.onDismiss);
  }

  @override
  void dispose() {
    _autoDismissTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        // Backdrop: tap anywhere to dismiss.
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onDismiss,
            child: ColoredBox(color: Colors.black.withAlpha(89)),
          ),
        ),
        // Hint card. Tapping the card itself also dismisses.
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Padding(
              padding: widget.margin,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: widget.onDismiss,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 16.0,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24.0),
                      boxShadow: const <BoxShadow>[
                        BoxShadow(
                          color: Color(0x40000000),
                          blurRadius: 20.0,
                          offset: Offset(0.0, 8.0),
                        ),
                      ],
                    ),
                    child: Row(
                      children: <Widget>[
                        const Icon(
                          Icons.info_outline_rounded,
                          color: Colors.black54,
                          size: 28.0,
                        ),
                        const SizedBox(width: 12.0),
                        Expanded(
                          child: Text(
                            widget.message,
                            style: AppTextStyles.onboardingMessage,
                          ),
                        ),
                        if (widget.showCloseButton) ...<Widget>[
                          const SizedBox(width: 8.0),
                          InkResponse(
                            onTap: widget.onDismiss,
                            radius: 18.0,
                            child: const Icon(
                              Icons.close_rounded,
                              color: Colors.black54,
                              size: 24.0,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
