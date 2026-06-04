import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:camera/camera.dart';
import '../theme/app_durations.dart';

enum PhotoboothState {
  idle,
  countdown,
  captureEnd,
  captureFeedback,
  processing,
  askAnother,
  result,
  shareSelection,
  shareConfirm,
  shareUploading,
  shareQr,
}

class PhotoboothFlowState extends ChangeNotifier {
  PhotoboothState _state = PhotoboothState.idle;
  int _countdownValue = AppDurations.countdownStart;
  Timer? _countdownTimer;
  Timer? _autoResetTimer;
  Timer? _shareTimer;
  Timer? _captureEndTimer;
  Timer? _shareUploadingTimer;
  DateTime? _shareQrDeadline;

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

  double get shareQrProgress {
    if (_shareQrDeadline == null) return 0.0;
    final Duration remaining = _shareQrDeadline!.difference(DateTime.now());
    if (remaining.isNegative) return 0.0;
    return remaining.inMilliseconds /
        AppDurations.shareQrAutoReset.inMilliseconds;
  }

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
        _triggerFlashAndCapture();
      }
    });
  }

  Future<void> _triggerFlashAndCapture() async {
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

    Timer(AppDurations.countdownFlash, () {
      _startCaptureEnd();
    });
  }

  void _startCaptureEnd() {
    _cancelTimers();
    _state = PhotoboothState.captureEnd;
    notifyListeners();

    _captureEndTimer = Timer(AppDurations.captureEndHold, () {
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
        _triggerFlashAndCapture();
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

  // Gestisce il click sul pulsante Fine nella galleria
  void handleDoneClick() {
    _cancelTimers();
    _showDoneToolbar = true;
    notifyListeners();

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
    _shareQrDeadline = null;
    notifyListeners();
  }

  // Cancella fisicamente solo la foto corrente e aggiorna la galleria
  Future<void> deletePhotos() async {
    if (_capturedImages.isEmpty) return;
    _cancelTimers();

    final String pathToDelete = _capturedImages[_currentGalleryIndex];

    try {
      final file = File(pathToDelete);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('Errore durante la cancellazione del file $pathToDelete: $e');
    }

    _capturedImages.removeAt(_currentGalleryIndex);
    _selectedShareImages.remove(pathToDelete);

    if (_capturedImages.isEmpty) {
      resetToHome();
    } else {
      if (_currentGalleryIndex >= _capturedImages.length) {
        _currentGalleryIndex = _capturedImages.length - 1;
      }
      notifyListeners();

      _autoResetTimer = Timer(AppDurations.resultAutoReset, () {
        resetToHome();
      });
    }
  }

  // Stub per Edit (out of scope, v3 D6)
  void editPhoto() {
    debugPrint('editPhoto: out of scope for v3');
  }

  // Stub per Print (out of scope, v3 D6)
  void printPhoto() {
    debugPrint('printPhoto: out of scope for v3');
  }

  // Inizia il flusso di condivisione
  void startShareFlow() {
    _cancelTimers();
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

  // Conferma la selezione: se tutte le foto sono selezionate vai diretto
  // all'upload, altrimenti mostra l'overlay di conferma.
  void confirmShareSelection() {
    _cancelTimers();
    if (_selectedShareImages.length == _capturedImages.length) {
      _startShareUploading();
    } else {
      _state = PhotoboothState.shareConfirm;
      notifyListeners();
    }
  }

  void cancelShareConfirm() {
    _cancelTimers();
    _state = PhotoboothState.shareSelection;
    notifyListeners();
  }

  void proceedShareUpload() => _startShareUploading();

  void _startShareUploading() {
    _cancelTimers();
    _state = PhotoboothState.shareUploading;
    notifyListeners();

    _shareUploadingTimer = Timer(AppDurations.shareUploading, () {
      _showShareQr();
    });
  }

  void _showShareQr() {
    _cancelTimers();
    _state = PhotoboothState.shareQr;
    _shareQrDeadline = DateTime.now().add(AppDurations.shareQrAutoReset);
    notifyListeners();

    _shareTimer = Timer(AppDurations.shareQrAutoReset, () {
      resetToHome();
    });
  }

  // Torna alla schermata dei risultati dal flusso di condivisione
  void cancelShareSelection() {
    _cancelTimers();
    _state = PhotoboothState.result;
    notifyListeners();

    _autoResetTimer = Timer(AppDurations.resultAutoReset, () {
      resetToHome();
    });
  }

  void _cancelTimers() {
    _countdownTimer?.cancel();
    _autoResetTimer?.cancel();
    _shareTimer?.cancel();
    _captureEndTimer?.cancel();
    _shareUploadingTimer?.cancel();
  }

  @override
  void dispose() {
    _cancelTimers();
    _cameraController?.dispose();
    super.dispose();
  }
}
