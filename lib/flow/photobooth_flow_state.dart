import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:camera/camera.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_durations.dart';
import '../network/backend_config.dart';
import '../network/backend_models.dart';
import '../network/backend_service.dart';

enum PhotoboothState {
  idle,
  countdown, // Schermata camera (anteprima e countdown)
  captureFeedback,
  processing,
  result,
  edit,
  shareTerms,
  shareSelection,
  shareQr,
}

class PhotoboothFlowState extends ChangeNotifier {
  PhotoboothState _state = PhotoboothState.idle;
  String _localeCode = 'en';
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
  String get localeCode => _localeCode;

  void setLocale(String value) {
    if (_localeCode != value) {
      _localeCode = value;
      notifyListeners();
    }
  }

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
  String get privacyPolicyUrl => _backendConfig.privacyPolicyUrl;


  // Inizializza la fotocamera (preferendo la camera frontale per il photobooth)
  // Inizializza la fotocamera con un meccanismo di fallback a cascata per evitare crash su hardware non supportato.
  Future<void> initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        debugPrint('No cameras found.');
        return;
      }

      // 1. Identifica la fotocamera frontale
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      // Lista dei preset da provare (in debug usiamo una risoluzione inferiore per non sovraccaricare la connessione ADB)
      final presets = kDebugMode
          ? [
              ResolutionPreset.medium,
              ResolutionPreset.low,
            ]
          : [
              ResolutionPreset.max,
              ResolutionPreset.ultraHigh,
              ResolutionPreset.veryHigh,
              ResolutionPreset.high,
              ResolutionPreset.medium,
              ResolutionPreset.low,
            ];

      // Tenta prima con la fotocamera frontale
      for (final preset in presets) {
        try {
          debugPrint('Attempting front camera initialization with preset: $preset');
          
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
          debugPrint('Front camera initialized successfully with preset: $preset');
          notifyListeners();
          return; // Successo! Esci dalla funzione.
        } catch (e) {
          debugPrint('Initialization failed for front camera with preset $preset: $e');
        }
      }

      // 2. Fallback: Se la fotocamera frontale ha fallito su tutti i preset, tenta con la prima camera disponibile (solitamente posteriore)
      final fallbackCamera = cameras.first;
      if (fallbackCamera.name != frontCamera.name) {
        for (final preset in presets) {
          try {
            debugPrint('Fallback: Attempting alternative camera initialization (${fallbackCamera.name}) with preset: $preset');
            
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
            debugPrint('Alternative camera initialized successfully with preset: $preset');
            notifyListeners();
            return; // Successo! Esci dalla funzione.
          } catch (e) {
            debugPrint('Initialization failed for alternative camera with preset $preset: $e');
          }
        }
      }

      debugPrint('Unable to initialize any camera with available presets.');
    } catch (e) {
      debugPrint('Critical error during camera initialization: $e');
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
      if (_countdownValue > 0) {
        _countdownValue--;
        notifyListeners();
        if (_countdownValue == 0) {
          timer.cancel();
          _triggerCapture();
        }
      }
    });
  }

  // Scatto ed acquisizione feedback reale
  Future<void> _triggerCapture() async {
    _cancelTimers();
    _isCountingDown = false;

    if (_isCameraInitialized && _cameraController != null) {
      try {
        final XFile file = await _cameraController!.takePicture();
        _capturedImagePath = file.path;
        _capturedImages.add(file.path);
      } catch (e) {
        debugPrint('Error during capture: $e');
      }
    }

    _state = PhotoboothState.captureFeedback;
    notifyListeners();

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

    if (_capturedImagePath != null) {
      String processedPath = _capturedImagePath!;

      // 1. Applica il filtro in-memory se selezionato
      if (_activeFilter != null) {
        debugPrint('PhotoboothFlowState: Applying filter $_activeFilter to file $processedPath');
        final matrix = _getColorMatrixForFilter(_activeFilter);
        processedPath = await _applyFilterToImageFile(processedPath, matrix);
      }

      // 2. Applica sempre la filigrana
      debugPrint('PhotoboothFlowState: Applying watermark to file $processedPath');
      processedPath = await _applyWatermarkToImageFile(processedPath);

      _capturedImagePath = processedPath;
      if (_capturedImages.isNotEmpty) {
        _capturedImages[_capturedImages.length - 1] = processedPath;
      }
      notifyListeners();
    }

    stopwatch.stop();
    // Calcola il tempo rimanente rispetto ai 2.5 secondi finti di processing
    final elapsed = stopwatch.elapsed;
    final remaining = AppDurations.processing - elapsed;
    final delay = remaining.isNegative ? Duration.zero : remaining;

    _autoResetTimer = Timer(delay, () {
      showGallery();
    });
  }

  // Helper per applicare la filigrana nexthouse_logo_text.svg in basso a sinistra
  Future<String> _applyWatermarkToImageFile(String inputPath) async {
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

      // Disegna l'immagine originale
      canvas.drawImage(image, ui.Offset.zero, ui.Paint());

      // Tenta il caricamento e disegno dell'SVG filigrana
      try {
        final PictureInfo pictureInfo = await vg.loadPicture(
          const SvgAssetLoader('assets/images/nexthouse_logo_text.svg'),
          null,
        );

        final double svgWidth = pictureInfo.size.width;
        final double svgHeight = pictureInfo.size.height;
        final double aspectRatio = svgHeight / svgWidth;

        // Larghezza filigrana pari al 15% della larghezza dell'immagine
        final double watermarkWidth = image.width * 0.15;
        final double watermarkHeight = watermarkWidth * aspectRatio;

        // Margine proporzionale per asse X (spostato più a destra) e Y (spostato leggermente più in basso)
        final double marginX = image.width * 0.07;
        final double marginY = image.width * 0.025;
        final double targetX = marginX;
        final double targetY = image.height - watermarkHeight - marginY;

        canvas.save();
        canvas.translate(targetX, targetY);
        canvas.scale(watermarkWidth / svgWidth, watermarkHeight / svgHeight);
        
        canvas.drawPicture(pictureInfo.picture);
        canvas.restore();

        pictureInfo.picture.dispose();
      } catch (svgError) {
        debugPrint('Warning: Could not load SVG watermark during processing: $svgError');
      }

      final ui.Picture picture = recorder.endRecording();
      final ui.Image watermarkedImage = await picture.toImage(image.width, image.height);

      final ByteData? byteData = await watermarkedImage.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        return inputPath;
      }

      final Uint8List watermarkedBytes = byteData.buffer.asUint8List();
      final String directory = file.parent.path;
      final String outputPath = '$directory/watermarked_${DateTime.now().millisecondsSinceEpoch}.png';

      await File(outputPath).writeAsBytes(watermarkedBytes, flush: true);

      // Pulisce l'immagine precedente
      try {
        await file.delete();
      } catch (e) {
        debugPrint('Error deleting file: $e');
      }

      return outputPath;
    } catch (e) {
      debugPrint('Error applying watermark: $e');
      return inputPath;
    }
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
        debugPrint('Error deleting original file: $e');
      }

      return outputPath;
    } catch (e) {
      debugPrint('Error applying filter in-memory: $e');
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
    _localeCode = 'en';
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
      debugPrint('Error while deleting file $pathToDelete: $e');
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
        debugPrint('Error while deleting old modified file: $e');
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
  Future<void> shareSelectedPhotos({String? languageCode}) async {
    debugPrint('PhotoboothFlowState: shareSelectedPhotos started with languageCode=$languageCode');
    // Evita chiamate parallele
    if (_shareSessionState.status == ShareSessionStatus.uploadingPhotos ||
        _shareSessionState.status == ShareSessionStatus.creatingDownloadSession) {
      debugPrint('PhotoboothFlowState: Upload or session creation already in progress. Ignoring.');
      return;
    }

    final selectedItems = _sessionPhotos
        .where((item) => item.isSelected)
        .toList();
    if (selectedItems.isEmpty) {
      debugPrint('PhotoboothFlowState: No photos selected');
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
          debugPrint('PhotoboothFlowState: Uploading single file: ${file.path}');
          final response = await _backendService.uploadPhoto(file);
          debugPrint('PhotoboothFlowState: Single upload response: $response');

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
      debugPrint('PhotoboothFlowState: Creating download session...');
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

      debugPrint('PhotoboothFlowState: photoIds for session: $photoIds');
      final shareState = await _backendService.createDownloadSession(photoIds);
      debugPrint('PhotoboothFlowState: Download session response: $shareState');

      // 3. Costruisce il downloadUrl finale puntando alla webapp
      final token = shareState.downloadToken ?? '';
      String webappUrl = _backendUrl;
      if (webappUrl.endsWith('/api')) {
        webappUrl = webappUrl.substring(0, webappUrl.length - 4);
      } else if (webappUrl.endsWith('/api/')) {
        webappUrl = webappUrl.substring(0, webappUrl.length - 5);
      } else {
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
      }

      final baseUrlNormalized = webappUrl.endsWith('/')
          ? webappUrl.substring(0, webappUrl.length - 1)
          : webappUrl;
      
      final String finalDownloadUrl = (languageCode != null && languageCode.isNotEmpty)
          ? '$baseUrlNormalized/download/$token?lang=$languageCode'
          : '$baseUrlNormalized/download/$token';

      _shareSessionState = shareState.copyWith(
        status: ShareSessionStatus.ready,
        downloadUrl: finalDownloadUrl,
      );
      _shareUrl = finalDownloadUrl;
      _isUploading = false;
      _state = PhotoboothState.shareQr;
      _shareCountdownValue = 300;
      debugPrint('PhotoboothFlowState: Sharing completed successfully. finalDownloadUrl=$finalDownloadUrl');
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
      debugPrint('PhotoboothFlowState: Error during photo sharing: $e\n$stack');
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
    _cancelTimers();
    _state = PhotoboothState.shareTerms;
    notifyListeners();

    _autoResetTimer = Timer(AppDurations.resultAutoReset, () {
      resetToHome();
    });
  }

  void acceptTermsAndProceed() {
    prepareShareSelection();
  }

  void declineTerms() {
    _cancelTimers();
    _state = PhotoboothState.result;
    notifyListeners();

    _autoResetTimer = Timer(AppDurations.resultAutoReset, () {
      resetToHome();
    });
  }

  void toggleImageSelection(String path) {
    togglePhotoSelection(path);
  }

  Future<void> completeShareSelection({String? languageCode}) async {
    await shareSelectedPhotos(languageCode: languageCode);
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
      debugPrint('Error during email registration: $e');
      return false;
    }
  }

  @visibleForTesting
  Future<String> applyWatermarkToImageFileTest(String inputPath) => _applyWatermarkToImageFile(inputPath);

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
