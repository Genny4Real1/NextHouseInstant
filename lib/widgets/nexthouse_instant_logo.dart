import 'package:flutter/material.dart';

/// Figma node 257:209 — Nexthouseinstant_logo.
/// Composes a star icon, the Next House vector logo, and the "INSTANT" wordmark.
class NexthouseInstantLogo extends StatelessWidget {
  final double height;
  final double width;

  const NexthouseInstantLogo({
    super.key,
    this.height = 509.322,
    this.width = 719.0,
  });

  @override
  Widget build(BuildContext context) {
    final double logoScale = width / 719.0;

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          // Star icon (top center)
          Positioned(
            left: width * 0.14,
            right: width * 0.14,
            top: 0,
            child: Icon(
              Icons.star_rounded,
              size: 60.0 * logoScale,
              color: Colors.black,
            ),
          ),
          // Vector logo (middle)
          Positioned(
            left: 0,
            right: 0,
            top: height * 0.237,
            bottom: height * 0.3468,
            child: ClipRect(
              child: Image.asset(
                'assets/images/nexthouse_logo.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const SizedBox(),
              ),
            ),
          ),
          // "INSTANT" wordmark (bottom)
          Positioned(
            left: width * 0.2476,
            right: width * 0.2226,
            bottom: height * 0.2925,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'INSTANT',
                style: TextStyle(
                  fontFamily: 'Saira Stencil One',
                  fontSize: 64.0 * logoScale,
                  fontWeight: FontWeight.normal,
                  color: Colors.black,
                  height: 1.0,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
