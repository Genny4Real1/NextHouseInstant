import 'dart:io';
import 'package:flutter/material.dart';

/// Figma 48:123 share processing layout - two photos side-by-side.
/// Used by `ShareUploadingScreen`. Renders inside a black `ColoredBox`
/// wrapper that the caller provides.
class SharePhotoStrip extends StatelessWidget {
  final String? leftPhotoPath;
  final String? rightPhotoPath;
  final String leftFallbackAsset;
  final String rightFallbackAsset;

  const SharePhotoStrip({
    super.key,
    this.leftPhotoPath,
    this.rightPhotoPath,
    this.leftFallbackAsset = 'assets/images/processing_bg_sample.png',
    this.rightFallbackAsset = 'assets/images/processing_bg_sample.png',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          child: _photo(path: leftPhotoPath, asset: leftFallbackAsset),
        ),
        const SizedBox(width: 32.0),
        Expanded(
          child: _photo(path: rightPhotoPath, asset: rightFallbackAsset),
        ),
      ],
    );
  }

  Widget _photo({String? path, required String asset}) {
    if (path != null && path.isNotEmpty) {
      final File file = File(path);
      if (file.existsSync()) {
        return Image.file(file, fit: BoxFit.cover, gaplessPlayback: true);
      }
    }
    return Image.asset(asset, fit: BoxFit.cover, gaplessPlayback: true);
  }
}
