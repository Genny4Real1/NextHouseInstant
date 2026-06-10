import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class KioskService {
  static const MethodChannel _channel = MethodChannel('com.nexthouse.instant/kiosk');

  /// Avvia la modalità Kiosk (Screen Pinning su Android)
  static Future<bool> startKioskMode() async {
    if (!Platform.isAndroid) {
      debugPrint('La modalità Kiosk è supportata solo su Android.');
      return false;
    }
    try {
      final bool? result = await _channel.invokeMethod<bool>('startKioskMode');
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint("Errore durante l'avvio della modalità Kiosk: ${e.message}");
      return false;
    }
  }

  /// Arresta la modalità Kiosk (Screen Pinning su Android)
  static Future<bool> stopKioskMode() async {
    if (!Platform.isAndroid) {
      debugPrint('La modalità Kiosk è supportata solo su Android.');
      return false;
    }
    try {
      final bool? result = await _channel.invokeMethod<bool>('stopKioskMode');
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint("Errore durante l'arresto della modalità Kiosk: ${e.message}");
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
      debugPrint("Errore durante la verifica della modalità Kiosk: ${e.message}");
      return false;
    }
  }
}
