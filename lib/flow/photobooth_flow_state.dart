import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:camera/camera.dart';
import '../theme/app_durations.dart';

enum PhotoboothState {
  idle,
  countdown,
  captureFeedback,
  processing,
  askAnother,
  result,
  shareSelection,
  shareQr,
}

class PhotoboothFlowState extends ChangeNotifier {
  PhotoboothState _state = PhotoboothState.idle;
  int _countdownValue = AppDurations.countdownStart;
  Timer? _countdownTimer;
  Timer? _autoResetTimer;
  Timer? _shareTimer;

  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  String? _capturedImagePath;
  final List<String> _capturedImages = [];
  int _currentGalleryIndex = 0;
  bool _showDoneToolbar = false;

  // Stato per la condivisione
  final Set<String> _selectedShareImages = {};
  int _shareCountdownValue = 30;

  PhotoboothState get state => _state;
  int get countdownValue => _countdownValue;
  CameraController? get cameraController => _cameraController;
  bool get isCameraInitialized => _isCameraInitialized;
  String? get capturedImagePath => _capturedImagePath;
  List<String> get capturedImages => _capturedImages;
  int get currentGalleryIndex => _currentGalleryIndex;
  bool get showDoneToolbar => _showDoneToolbar;
  Set<String> get selectedShareImages => _selectedShareImages;
  int get shareCountdownValue => _shareCountdownValue;

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
        _capturedImages.add(file.path);
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
      _askAnother();
    });
  }

  void _askAnother() {
    _cancelTimers();
    _state = PhotoboothState.askAnother;
    notifyListeners();
  }

  // Avvia lo scatto di un'altra foto
  void takeAnotherPhoto() {
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

  // Passa alla galleria finale
  void showGallery() {
    _cancelTimers();
    _state = PhotoboothState.result;
    _currentGalleryIndex = _capturedImages.isNotEmpty ? _capturedImages.length - 1 : 0;
    _showDoneToolbar = true;
    notifyListeners();

    // Avvia il timer di auto-reset per inattività nella galleria
    _autoResetTimer = Timer(AppDurations.resultAutoReset, () {
      resetToHome();
    });
  }

  // Imposta l'indice corrente della galleria direttamente
  void setGalleryIndex(int index) {
    if (_capturedImages.isEmpty) return;
    if (index < 0 || index >= _capturedImages.length) return;
    _cancelTimers();
    _currentGalleryIndex = index;
    notifyListeners();

    _autoResetTimer = Timer(AppDurations.resultAutoReset, () {
      resetToHome();
    });
  }

  // Navigazione galleria: foto precedente
  void previousImage() {
    if (_capturedImages.isEmpty) return;
    _cancelTimers();
    if (_currentGalleryIndex > 0) {
      _currentGalleryIndex--;
    } else {
      _currentGalleryIndex = _capturedImages.length - 1;
    }
    notifyListeners();

    _autoResetTimer = Timer(AppDurations.resultAutoReset, () {
      resetToHome();
    });
  }

  // Navigazione galleria: foto successiva
  void nextImage() {
    if (_capturedImages.isEmpty) return;
    _cancelTimers();
    if (_currentGalleryIndex < _capturedImages.length - 1) {
      _currentGalleryIndex++;
    } else {
      _currentGalleryIndex = 0;
    }
    notifyListeners();

    _autoResetTimer = Timer(AppDurations.resultAutoReset, () {
      resetToHome();
    });
  }

  // Gestisce il click sul pulsante Fine nella galleria: mostra i pulsanti toolbar disabilitati
  void handleDoneClick() {
    _cancelTimers();
    _showDoneToolbar = true;
    notifyListeners();

    // Riavvia il timer di auto-reset di inattività da 1 minuto
    _autoResetTimer = Timer(AppDurations.resultAutoReset, () {
      resetToHome();
    });
  }

  // Ritorna subito alla home (reset manuale o timeout)
  void resetToHome() {
    _cancelTimers();
    _state = PhotoboothState.idle;
    _capturedImagePath = null;
    _capturedImages.clear();
    _currentGalleryIndex = 0;
    _showDoneToolbar = false;
    _selectedShareImages.clear();
    _shareCountdownValue = 30;
    notifyListeners();
  }

  // Cancella fisicamente solo la foto corrente e aggiorna la galleria
  Future<void> deletePhotos() async {
    if (_capturedImages.isEmpty) return;
    _cancelTimers();

    final String pathToDelete = _capturedImages[_currentGalleryIndex];

    // Elimina fisicamente il file per liberare spazio e garantire la privacy
    try {
      final file = File(pathToDelete);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('Errore durante la cancellazione del file $pathToDelete: $e');
    }

    // Rimuove la foto dalle liste interne
    _capturedImages.removeAt(_currentGalleryIndex);
    _selectedShareImages.remove(pathToDelete);

    if (_capturedImages.isEmpty) {
      // Se non ci sono più foto, torna alla home
      resetToHome();
    } else {
      // Regola l'indice per rimanere nei limiti
      if (_currentGalleryIndex >= _capturedImages.length) {
        _currentGalleryIndex = _capturedImages.length - 1;
      }
      notifyListeners();

      // Riavvia il timer di auto-reset per inattività
      _autoResetTimer = Timer(AppDurations.resultAutoReset, () {
        resetToHome();
      });
    }
  }

  // Inizia il flusso di condivisione
  void startShareFlow() {
    _cancelTimers();
    // Seleziona tutte le foto di default
    _selectedShareImages.clear();
    _selectedShareImages.addAll(_capturedImages);
    _state = PhotoboothState.shareSelection;
    notifyListeners();
  }

  // Seleziona/deseleziona una foto
  void toggleImageSelection(String path) {
    if (_selectedShareImages.contains(path)) {
      _selectedShareImages.remove(path);
    } else {
      _selectedShareImages.add(path);
    }
    notifyListeners();
  }

  // Conferma la selezione e mostra la schermata col QR Code
  void completeShareSelection() {
    _cancelTimers();
    _state = PhotoboothState.shareQr;
    _shareCountdownValue = 30; // 30 secondi temporanei
    notifyListeners();

    _shareTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_shareCountdownValue > 1) {
        _shareCountdownValue--;
        notifyListeners();
      } else {
        timer.cancel();
        // Torna a home dopo la scadenza del qr code
        resetToHome();
      }
    });
  }

  // Annulla il flusso di condivisione e torna alla schermata dei risultati
  void cancelShareSelection() {
    _cancelTimers();
    _state = PhotoboothState.result;
    notifyListeners();

    // Riavvia il timer di auto-reset dei risultati
    _autoResetTimer = Timer(AppDurations.resultAutoReset, () {
      resetToHome();
    });
  }

  void _cancelTimers() {
    _countdownTimer?.cancel();
    _autoResetTimer?.cancel();
    _shareTimer?.cancel();
  }

  @override
  void dispose() {
    _cancelTimers();
    _cameraController?.dispose();
    super.dispose();
  }
}
