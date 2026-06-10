import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:camera/camera.dart';
import '../theme/app_durations.dart';
import '../network/backend_config.dart';
import '../network/backend_models.dart';
import '../network/backend_service.dart';

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

  // Nuovo stato di condivisione integrato
  String _backendUrl = BackendConfig.defaultBaseUrl;
  late BackendConfig _backendConfig;
  late BackendService _backendService;
  final List<SessionPhotoItem> _sessionPhotos = [];
  ShareSessionState _shareSessionState = const ShareSessionState();

  final Set<String> _selectedShareImages =
      {}; // mantenuto per retrocompatibilità opzionale
  int _shareCountdownValue = 300;

  bool _isUploading = false;
  String? _uploadError;
  String? _shareUrl;

  PhotoboothFlowState() {
    _backendConfig = BackendConfig(baseUrl: _backendUrl);
    _backendService = BackendService(config: _backendConfig);
  }

  PhotoboothState get state => _state;
  int get countdownValue => _countdownValue;
  CameraController? get cameraController => _cameraController;
  bool get isCameraInitialized => _isCameraInitialized;
  String? get capturedImagePath => _capturedImagePath;
  List<String> get capturedImages => _capturedImages;
  int get currentGalleryIndex => _currentGalleryIndex;
  bool get showDoneToolbar => _showDoneToolbar;

  // Ritorna le foto selezionate ricavandole dal nuovo modello di sessione se valorizzato,
  // altrimenti fa fallback sul Set legacy per preservare la compatibilità.
  Set<String> get selectedShareImages {
    if (_sessionPhotos.isNotEmpty) {
      return _sessionPhotos
          .where((item) => item.isSelected)
          .map((item) => item.localPath)
          .toSet();
    }
    return _selectedShareImages;
  }

  List<SessionPhotoItem> get sessionPhotos => _sessionPhotos;
  ShareSessionState get shareSessionState => _shareSessionState;
  int get shareCountdownValue => _shareCountdownValue;
  bool get isUploading => _isUploading;
  String? get uploadError => _uploadError;
  String? get shareUrl => _shareUrl;

  // Inizializza la fotocamera (preferendo la camera frontale per il photobooth)
  // Inizializza la fotocamera con un meccanismo di fallback a cascata per evitare crash su hardware non supportato.
  Future<void> initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        debugPrint('Nessuna fotocamera trovata.');
        return;
      }

      // 1. Identifica la fotocamera frontale
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      // Lista dei preset da provare
      final presets = [
        ResolutionPreset.medium,
        ResolutionPreset.low,
        ResolutionPreset.high,
      ];

      // Tenta prima con la fotocamera frontale
      for (final preset in presets) {
        try {
          debugPrint('Tentativo inizializzazione camera frontale con preset: $preset');
          
          if (_cameraController != null) {
            await _cameraController!.dispose();
          }

          _cameraController = CameraController(
            frontCamera,
            preset,
            enableAudio: false,
          );

          await _cameraController!.initialize();
          _isCameraInitialized = true;
          debugPrint('Camera frontale inizializzata con successo con preset: $preset');
          notifyListeners();
          return; // Successo! Esci dalla funzione.
        } catch (e) {
          debugPrint('Inizializzazione fallita per camera frontale con preset $preset: $e');
        }
      }

      // 2. Fallback: Se la fotocamera frontale ha fallito su tutti i preset, tenta con la prima camera disponibile (solitamente posteriore)
      final fallbackCamera = cameras.first;
      if (fallbackCamera.name != frontCamera.name) {
        for (final preset in presets) {
          try {
            debugPrint('Fallback: Tentativo inizializzazione camera alternativa (${fallbackCamera.name}) con preset: $preset');
            
            if (_cameraController != null) {
              await _cameraController!.dispose();
            }

            _cameraController = CameraController(
              fallbackCamera,
              preset,
              enableAudio: false,
            );

            await _cameraController!.initialize();
            _isCameraInitialized = true;
            debugPrint('Camera alternativa inizializzata con successo con preset: $preset');
            notifyListeners();
            return; // Successo! Esci dalla funzione.
          } catch (e) {
            debugPrint('Inizializzazione fallita per camera alternativa con preset $preset: $e');
          }
        }
      }

      debugPrint('Impossibile inizializzare qualsiasi fotocamera con i preset disponibili.');
    } catch (e) {
      debugPrint('Errore critico durante l\'inizializzazione della fotocamera: $e');
    }
  }

  // Avvia il flusso: passa da Idle a Countdown
  void startFlow() {
    _cancelTimers();
    resetShareFlow();
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
    _currentGalleryIndex = _capturedImages.isNotEmpty
        ? _capturedImages.length - 1
        : 0;
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
    resetShareFlow();
    _state = PhotoboothState.idle;
    _capturedImagePath = null;
    _capturedImages.clear();
    _currentGalleryIndex = 0;
    _showDoneToolbar = false;
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
    _sessionPhotos.removeWhere((item) => item.localPath == pathToDelete);

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

  // Va direttamente alla schermata di selezione condivisione senza svuotare le selezioni esistenti
  void goToShareSelection() {
    _cancelTimers();
    // Resetta l'errore e lo stato di upload per consentire un nuovo tentativo pulito
    _isUploading = false;
    _uploadError = null;
    _shareSessionState = _shareSessionState.copyWith(
      status: ShareSessionStatus.idle,
      errorMessage: null,
    );
    _state = PhotoboothState.shareSelection;
    notifyListeners();
  }

  // Configura il backend base URL in modo modificabile
  void setBackendBaseUrl(String value) {
    _backendUrl = value;
    _backendConfig = BackendConfig(baseUrl: _backendUrl);
    _backendService.dispose();
    _backendService = BackendService(config: _backendConfig);
    notifyListeners();
  }

  // Prepara la selezione di condivisione con le foto correnti
  void prepareShareSelection() {
    _cancelTimers();
    _sessionPhotos.clear();
    for (final path in _capturedImages) {
      _sessionPhotos.add(
        SessionPhotoItem(
          localPath: path,
          isSelected: true,
          uploadState: PhotoUploadState.pending,
        ),
      );
    }
    _state = PhotoboothState.shareSelection;
    notifyListeners();
  }

  // Seleziona/deseleziona una foto
  void togglePhotoSelection(String localPath) {
    final index = _sessionPhotos.indexWhere(
      (item) => item.localPath == localPath,
    );
    if (index != -1) {
      final item = _sessionPhotos[index];
      _sessionPhotos[index] = item.copyWith(isSelected: !item.isSelected);
      notifyListeners();
    }
  }

  // Condivide le foto caricate tramite upload seriale e creazione sessione
  Future<void> shareSelectedPhotos() async {
    debugPrint('PhotoboothFlowState: shareSelectedPhotos avviato');
    // Evita chiamate parallele
    if (_shareSessionState.status == ShareSessionStatus.uploadingPhotos ||
        _shareSessionState.status == ShareSessionStatus.creatingDownloadSession) {
      debugPrint('PhotoboothFlowState: Upload o creazione sessione già in corso. Ignoro.');
      return;
    }

    final selectedItems = _sessionPhotos
        .where((item) => item.isSelected)
        .toList();
    if (selectedItems.isEmpty) {
      debugPrint('PhotoboothFlowState: Nessuna foto selezionata');
      _uploadError = "Nessuna foto selezionata per la condivisione.";
      _shareSessionState = ShareSessionState(
        status: ShareSessionStatus.failed,
        errorMessage: _uploadError,
      );
      notifyListeners();
      return;
    }

    _cancelTimers();
    _isUploading = true;
    _uploadError = null;
    _shareUrl = null;
    _shareSessionState = ShareSessionState(
      status: ShareSessionStatus.uploadingPhotos,
      uploadedCount: 0,
      totalCount: selectedItems.length,
    );
    notifyListeners();

    try {
      // 1. Upload seriale delle foto con progresso
      for (final item in selectedItems) {
        final index = _sessionPhotos.indexWhere((p) => p.localPath == item.localPath);
        if (index != -1) {
          _sessionPhotos[index] = _sessionPhotos[index].copyWith(
            uploadState: PhotoUploadState.uploading,
          );
        }
        notifyListeners();

        try {
          final file = File(item.localPath);
          debugPrint('PhotoboothFlowState: Carico file singolo: ${file.path}');
          final response = await _backendService.uploadPhoto(file);
          debugPrint('PhotoboothFlowState: Risposta upload singolo: $response');

          final backendPhotoId =
              response['id']?.toString() ??
              response['session_id']?.toString() ??
              (response['files'] as List?)?.first?.toString();

          if (index != -1) {
            _sessionPhotos[index] = _sessionPhotos[index].copyWith(
              uploadState: PhotoUploadState.uploaded,
              backendPhotoId: backendPhotoId,
            );
          }

          _shareSessionState = _shareSessionState.copyWith(
            uploadedCount: _shareSessionState.uploadedCount + 1,
          );
          notifyListeners();
        } catch (e) {
          if (index != -1) {
            _sessionPhotos[index] = _sessionPhotos[index].copyWith(
              uploadState: PhotoUploadState.failed,
              errorMessage: e.toString(),
            );
          }
          rethrow;
        }
      }

      // 2. Creazione della sessione di download
      debugPrint('PhotoboothFlowState: Creazione sessione di download...');
      _shareSessionState = _shareSessionState.copyWith(
        status: ShareSessionStatus.creatingDownloadSession,
      );
      notifyListeners();

      final List<int> photoIds = [];
      for (int i = 0; i < selectedItems.length; i++) {
        final localItem = _sessionPhotos.firstWhere(
          (p) => p.localPath == selectedItems[i].localPath,
        );
        final idInt = int.tryParse(localItem.backendPhotoId ?? '');
        photoIds.add(idInt ?? i);
      }

      debugPrint('PhotoboothFlowState: photoIds per la sessione: $photoIds');
      final shareState = await _backendService.createDownloadSession(photoIds);
      debugPrint('PhotoboothFlowState: Risposta sessione download: $shareState');

      // 3. Costruisce il downloadUrl finale puntando alla webapp (porta 5173 anziché 8080)
      final token = shareState.downloadToken ?? '';
      String webappUrl = _backendUrl;
      try {
        final uri = Uri.parse(_backendUrl);
        if (uri.port == 8080) {
          webappUrl = uri.replace(port: 5173).toString();
        } else if (webappUrl.contains(':8080')) {
          webappUrl = webappUrl.replaceAll(':8080', ':5173');
        }
      } catch (e) {
        if (webappUrl.contains(':8080')) {
          webappUrl = webappUrl.replaceAll(':8080', ':5173');
        }
      }

      final baseUrlNormalized = webappUrl.endsWith('/')
          ? webappUrl.substring(0, webappUrl.length - 1)
          : webappUrl;
      
      final String finalDownloadUrl = '$baseUrlNormalized/download/$token';

      _shareSessionState = shareState.copyWith(
        status: ShareSessionStatus.ready,
        downloadUrl: finalDownloadUrl,
      );
      _shareUrl = finalDownloadUrl;
      _isUploading = false;
      _state = PhotoboothState.shareQr;
      _shareCountdownValue = 300;
      debugPrint('PhotoboothFlowState: Condivisione completata con successo. finalDownloadUrl=$finalDownloadUrl');
      notifyListeners();

      // Avvia timer di condivisione per QR code
      _shareTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_shareCountdownValue > 1) {
          _shareCountdownValue--;
          notifyListeners();
        } else {
          timer.cancel();
          resetToHome();
        }
      });
    } catch (e, stack) {
      debugPrint('PhotoboothFlowState: Errore durante la condivisione delle foto: $e\n$stack');
      _isUploading = false;
      _uploadError = "Impossibile completare la condivisione: $e";
      _shareSessionState = _shareSessionState.copyWith(
        status: ShareSessionStatus.failed,
        errorMessage: _uploadError,
      );

      // Ripristina lo stato per gli elementi falliti
      for (final item in selectedItems) {
        final index = _sessionPhotos.indexWhere((p) => p.localPath == item.localPath);
        if (index != -1 && _sessionPhotos[index].uploadState == PhotoUploadState.uploading) {
          _sessionPhotos[index] = _sessionPhotos[index].copyWith(
            uploadState: PhotoUploadState.failed,
            errorMessage: e.toString(),
          );
        }
      }
      notifyListeners();
    }
  }

  // Resetta lo stato del flusso di condivisione
  void resetShareFlow() {
    _shareTimer?.cancel();
    _shareSessionState = const ShareSessionState();
    _sessionPhotos.clear();
    _selectedShareImages.clear();
    _isUploading = false;
    _uploadError = null;
    _shareUrl = null;
    _shareCountdownValue = 300;
  }

  // --- Wrapper/Metodi Legacy per piena retrocompatibilità con la UI corrente ---

  void startShareFlow() {
    prepareShareSelection();
  }

  void toggleImageSelection(String path) {
    togglePhotoSelection(path);
  }

  Future<void> completeShareSelection() async {
    await shareSelectedPhotos();
  }

  void cancelShareSelection() {
    _cancelTimers();
    resetShareFlow();
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
  }

  @override
  void dispose() {
    _cancelTimers();
    _cameraController?.dispose();
    _backendService.dispose();
    super.dispose();
  }
}
