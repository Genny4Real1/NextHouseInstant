import 'dart:io';
import 'package:flutter/material.dart';

/// Figma 48:123 share processing layout - two photos side-by-side.
/// Used by `ShareUploadingScreen`. Renders inside a black `ColoredBox`
/// wrapper that the caller provides.
class SharePhotoStrip extends StatelessWidget {
  final String? leftPhotoPath;
  final String? rightPhotoPath;

  const SharePhotoStrip({
    super.key,
    this.leftPhotoPath,
    this.rightPhotoPath,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          child: _photo(path: leftPhotoPath),
        ),
        const SizedBox(width: 32.0),
        Expanded(
          child: _photo(path: rightPhotoPath),
        ),
      ],
    );
  }

  Widget _photo({String? path}) {
    if (path != null && path.isNotEmpty) {
      final File file = File(path);
      if (file.existsSync()) {
        return Image.file(file, fit: BoxFit.cover, gaplessPlayback: true);
      }
    }
    return const ColoredBox(color: Colors.black);
  }
}
