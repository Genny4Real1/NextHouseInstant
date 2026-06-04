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
}
