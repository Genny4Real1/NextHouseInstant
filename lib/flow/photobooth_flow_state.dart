import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:camera/camera.dart';
import '../theme/app_durations.dart';

enum PhotoboothState {
  idle,
  countdown,
  captureFeedback,
  processing,
  result,
}

class PhotoboothFlowState extends ChangeNotifier {
  PhotoboothState _state = PhotoboothState.idle;
  int _countdownValue = AppDurations.countdownStart;
  Timer? _countdownTimer;
  Timer? _autoResetTimer;

  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  String? _capturedImagePath;

  PhotoboothState get state => _state;
  int get countdownValue => _countdownValue;
  CameraController? get cameraController => _cameraController;
  bool get isCameraInitialized => _isCameraInitialized;
  String? get capturedImagePath => _capturedImagePath;

  // Inizializza la fotocamera (preferendo la camera frontale per il photobooth)
  Future<void> initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        debugPrint('Nessuna fotocamera trovata.');
        return;
      }

      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      _isCameraInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Errore inizializzazione fotocamera: $e');
    }
  }

  // Avvia il flusso: passa da Idle a Countdown
  void startFlow() {
    _cancelTimers();
    _state = PhotoboothState.countdown;
    _countdownValue = AppDurations.countdownStart;
    notifyListeners();

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdownValue > 1) {
        _countdownValue--;
        notifyListeners();
      } else {
        timer.cancel();
        _triggerCapture();
      }
    });
  }

  // Scatto ed acquisizione feedback reale
  Future<void> _triggerCapture() async {
    _cancelTimers();
    _state = PhotoboothState.captureFeedback;
    notifyListeners();

    if (_isCameraInitialized && _cameraController != null) {
      try {
        final XFile file = await _cameraController!.takePicture();
        _capturedImagePath = file.path;
        notifyListeners();
      } catch (e) {
        debugPrint('Errore durante lo scatto: $e');
      }
    }

    _autoResetTimer = Timer(AppDurations.captureFeedback, () {
      _startProcessing();
    });
  }

  // Finta elaborazione della foto
  void _startProcessing() {
    _cancelTimers();
    _state = PhotoboothState.processing;
    notifyListeners();

    _autoResetTimer = Timer(AppDurations.processing, () {
      _showResult();
    });
  }

  // Schermata finale del QR code
  void _showResult() {
    _cancelTimers();
    _state = PhotoboothState.result;
    notifyListeners();

    // Avvia il timer di auto-reset per inattività
    _autoResetTimer = Timer(AppDurations.resultAutoReset, () {
      resetToHome();
    });
  }

  // Ritorna subito alla home (reset manuale o timeout)
  void resetToHome() {
    _cancelTimers();
    _state = PhotoboothState.idle;
    _capturedImagePath = null;
    notifyListeners();
  }

  void _cancelTimers() {
    _countdownTimer?.cancel();
    _autoResetTimer?.cancel();
  }

  @override
  void dispose() {
    _cancelTimers();
    _cameraController?.dispose();
    super.dispose();
  }
}
