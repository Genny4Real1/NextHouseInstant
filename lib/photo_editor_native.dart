import 'package:flutter/services.dart';

class PhotoEditorNative {
  static const MethodChannel _channel = MethodChannel('nexthouse/photo_editor');

  /// Opens the native PhotoEditor. Pass an image path (file:// or absolute path).
  /// Returns the edited file path on success, or throws a PlatformException.
  static Future<String?> openEditor(String? imagePath) async {
    final result = await _channel.invokeMethod('openEditor', {'imagePath': imagePath});
    return result as String?;
  }
}
