class AppDurations {
  AppDurations._();

  // Durate delle transizioni e micro-animazioni
  static const Duration pageTransition = Duration(milliseconds: 300);
  static const Duration buttonPress = Duration(milliseconds: 100);
  static const Duration flashFade = Duration(milliseconds: 150);

  // Durate logiche del chiosco
  static const int countdownStart = 5; // Countdown iniziale (secondi)
  static const Duration captureFeedback = Duration(
    seconds: 2,
  ); // Tempo anteprima scatto
  static const Duration processing = Duration(
    milliseconds: 2500,
  ); // Tempo elaborazione finta
  static const Duration resultAutoReset = Duration(
    minutes: 1,
  ); // Tempo reset inattività (1 minuto)

  // Figma: NextHouse_SpinningWheel (74:74) - un giro completo ogni 2s
  static const Duration processingRotation = Duration(seconds: 2);

  // Figma: flash frame (57:209) - 150ms overlay
  static const Duration countdownFlash = Duration(milliseconds: 150);

  // Figma: end frame (57:217) - 250ms hold before processing
  static const Duration captureEndHold = Duration(milliseconds: 250);

  // Figma: share uploading view (48:123) - 2s mock upload
  static const Duration shareUploading = Duration(seconds: 2);

  // Share QR auto-reset - bumped from 30s to 60s (UI shows only a thin progress bar, not a number)
  static const Duration shareQrAutoReset = Duration(seconds: 60);
}
