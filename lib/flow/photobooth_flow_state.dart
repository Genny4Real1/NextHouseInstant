import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:camera/camera.dart';
import '../theme/app_durations.dart';
import '../network/backend_config.dart';
import '../network/backend_models.dart';
import '../network/backend_service.dart';

enum PhotoboothState {
  idle,
  countdown, // Schermata camera (anteprima e countdown)
  captureFeedback,
  processing,
  askAnother,
  result,
  edit,
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

  // Nuovi stati per i filtri pre-scatto
  String? _activeFilter; // null (nessuno/originale), grayscale, sepia, cool, warm
  bool _isCountingDown = false; // Indica se il countdown per lo scatto è attivo

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

  // Getters/Setters per filtri e countdown manuale
  String? get activeFilter => _activeFilter;
  bool get isCountingDown => _isCountingDown;

  void setActiveFilter(String? filter) {
    _activeFilter = filter;
    notifyListeners();
  }

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
  String get backendUrl => _backendUrl.trim().replaceAll(' ', '');


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

  // Avvia il flusso: passa da Idle alla schermata Camera in modalità Anteprima (nessun countdown automatico)
  void startFlow() {
    _cancelTimers();
    resetShareFlow();
    _activeFilter = null; // Resetta i filtri all'avvio
    _isCountingDown = false;
    _state = PhotoboothState.countdown;
    _countdownValue = AppDurations.countdownStart;
    notifyListeners();
  }

  // Avvia manualmente il countdown per scattare la foto
  void startCountdown() {
    if (_isCountingDown) return;
    _isCountingDown = true;
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
    _isCountingDown = false;
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

  // Elaborazione reale del filtro + finta attesa
  Future<void> _startProcessing() async {
    _cancelTimers();
    _state = PhotoboothState.processing;
    notifyListeners();

    final stopwatch = Stopwatch()..start();

    // Applica il filtro in-memory se selezionato
    if (_activeFilter != null && _capturedImagePath != null) {
      debugPrint('PhotoboothFlowState: Applicazione filtro $_activeFilter al file $_capturedImagePath');
      final matrix = _getColorMatrixForFilter(_activeFilter);
      final filteredPath = await _applyFilterToImageFile(_capturedImagePath!, matrix);
      _capturedImagePath = filteredPath;
      if (_capturedImages.isNotEmpty) {
        _capturedImages[_capturedImages.length - 1] = filteredPath;
      }
      notifyListeners();
    }

    stopwatch.stop();
    // Calcola il tempo rimanente rispetto ai 2.5 secondi finti di processing
    final elapsed = stopwatch.elapsed;
    final remaining = AppDurations.processing - elapsed;
    final delay = remaining.isNegative ? Duration.zero : remaining;

    _autoResetTimer = Timer(delay, () {
      _askAnother();
    });
  }

  void _askAnother() {
    _cancelTimers();
    _state = PhotoboothState.askAnother;
    notifyListeners();
  }

  // Avvia lo scatto di un'altra foto: torna in anteprima per far cambiare filtri
  void takeAnotherPhoto() {
    _cancelTimers();
    _activeFilter = null; // Resetta filtri per il prossimo scatto
    _isCountingDown = false;
    _state = PhotoboothState.countdown;
    _countdownValue = AppDurations.countdownStart;
    notifyListeners();
  }

  // Helper per applicare il ColorFilter della matrice all'immagine su disco in-memory
  Future<String> _applyFilterToImageFile(String inputPath, List<double> matrix) async {
    try {
      final File file = File(inputPath);
      if (!await file.exists()) {
        return inputPath;
      }
      final Uint8List bytes = await file.readAsBytes();

      // Decode image
      final ui.Codec codec = await ui.instantiateImageCodec(bytes);
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      final ui.Image image = frameInfo.image;

      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final ui.Canvas canvas = ui.Canvas(recorder);

      final ui.Paint paint = ui.Paint()
        ..colorFilter = ui.ColorFilter.matrix(matrix);

      // Disegna l'immagine sul canvas applicando la matrice di colore
      canvas.drawImage(image, ui.Offset.zero, paint);

      final ui.Picture picture = recorder.endRecording();
      final ui.Image filteredImage = await picture.toImage(image.width, image.height);

      final ByteData? byteData = await filteredImage.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        return inputPath;
      }

      final Uint8List filteredBytes = byteData.buffer.asUint8List();
      final String directory = file.parent.path;
      final String outputPath = '$directory/filtered_${DateTime.now().millisecondsSinceEpoch}.png';

      await File(outputPath).writeAsBytes(filteredBytes, flush: true);

      // Cancella file originale non filtrato
      try {
        await file.delete();
      } catch (e) {
        debugPrint('Errore cancellazione file originale: $e');
      }

      return outputPath;
    } catch (e) {
      debugPrint('Errore applicazione filtro in-memory: $e');
      return inputPath;
    }
  }

  // Ritorna le matrici dei filtri esattamente come in edit_screen.dart
  List<double> _getColorMatrixForFilter(String? filter) {
    switch (filter) {
      case 'grayscale':
        return [
          0.2126, 0.7152, 0.0722, 0.0, 0.0,
          0.2126, 0.7152, 0.0722, 0.0, 0.0,
          0.2126, 0.7152, 0.0722, 0.0, 0.0,
          0.0,    0.0,    0.0,    1.0, 0.0,
        ];
      case 'sepia':
        return [
          0.393, 0.769, 0.189, 0.0, 0.0,
          0.349, 0.686, 0.168, 0.0, 0.0,
          0.272, 0.534, 0.131, 0.0, 0.0,
          0.0,   0.0,   0.0,   1.0, 0.0,
        ];
      case 'cool':
        return [
          0.9, 0.0, 0.1, 0.0, 0.0,
          0.0, 0.9, 0.1, 0.0, 0.0,
          0.0, 0.0, 1.2, 0.0, 0.0,
          0.0, 0.0, 0.0, 1.0, 0.0,
        ];
      case 'warm':
        return [
          1.2, 0.0, 0.0, 0.0, 0.0,
          0.0, 1.0, 0.0, 0.0, 0.0,
          0.0, 0.0, 0.8, 0.0, 0.0,
          0.0, 0.0, 0.0, 1.0, 0.0,
        ];
      default:
        return [
          1.0, 0.0, 0.0, 0.0, 0.0,
          0.0, 1.0, 0.0, 0.0, 0.0,
          0.0, 0.0, 1.0, 0.0, 0.0,
          0.0, 0.0, 0.0, 1.0, 0.0,
        ];
    }
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

  // Entra in modalità di modifica (Edit) per la foto corrente
  void enterEditMode() {
    if (_capturedImages.isEmpty) return;
    _cancelTimers(); // Disattiva l'auto-reset della galleria durante la modifica attiva
    _state = PhotoboothState.edit;
    notifyListeners();
  }

  // Esce dalla modalità di modifica salvando o scartando i cambiamenti
  void exitEditMode({bool save = false, String? editedImagePath}) {
    _cancelTimers();
    if (save && editedImagePath != null && _capturedImages.isNotEmpty) {
      final oldPath = _capturedImages[_currentGalleryIndex];
      // Elimina fisicamente la vecchia versione modificata o originale se diversa per evitare orfani
      try {
        final oldFile = File(oldPath);
        if (oldFile.existsSync()) {
          oldFile.deleteSync();
        }
      } catch (e) {
        debugPrint('Errore durante la cancellazione del vecchio file modificato: $e');
      }

      _capturedImages[_currentGalleryIndex] = editedImagePath;
    }
    
    _state = PhotoboothState.result;
    notifyListeners();

    // Riavvia il timer di auto-reset per inattività nella galleria
    _autoResetTimer = Timer(AppDurations.resultAutoReset, () {
      resetToHome();
    });
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
      _uploadError = "No photos selected for sharing.";
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
      _uploadError = "Unable to complete sharing: $e";
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

  /// Stub for registering email sharing on the backend
  Future<bool> sendEmailShare(String email) async {
    final String token = _shareSessionState.downloadToken ?? '';
    debugPrint('PhotoboothFlowState: sendEmailShare stub called for session $token, email $email');
    try {
      final success = await _backendService.registerSessionEmail(token, email);
      return success;
    } catch (e) {
      debugPrint('Errore durante la registrazione email: $e');
      return false;
    }
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
