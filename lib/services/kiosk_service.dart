import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class KioskService {
  static const MethodChannel _channel = MethodChannel('com.nexthouse.instant/kiosk');

  /// Starts Kiosk mode (Screen Pinning on Android)
  static Future<bool> startKioskMode() async {
    if (!Platform.isAndroid) {
      debugPrint('Kiosk mode is only supported on Android.');
      return false;
    }
    try {
      final bool? result = await _channel.invokeMethod<bool>('startKioskMode');
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint("Error starting Kiosk mode: ${e.message}");
      return false;
    }
  }

  /// Stops Kiosk mode (Screen Pinning on Android)
  static Future<bool> stopKioskMode() async {
    if (!Platform.isAndroid) {
      debugPrint('Kiosk mode is only supported on Android.');
      return false;
    }
    try {
      final bool? result = await _channel.invokeMethod<bool>('stopKioskMode');
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint("Error stopping Kiosk mode: ${e.message}");
      return false;
    }
  }

  /// Verifica se la modalità Kiosk è attualmente attiva
  static Future<bool> isKioskMode() async {
    if (!Platform.isAndroid) return false;
    try {
      final bool? result = await _channel.invokeMethod<bool>('isKioskMode');
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint("Error checking Kiosk mode: ${e.message}");
      return false;
    }
  }
}
