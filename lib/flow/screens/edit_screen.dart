import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../theme/app_colors.dart';
import '../../network/backend_config.dart';
import '../../network/backend_models.dart';
import '../../network/backend_service.dart';


enum EditTool {
  none,
  rotate,
  adjust,
  filter,
  doodle,
  text,
  sticker,
  emoji
}

enum AdjustSubTool {
  brightness,
  contrast,
  saturation,
  sharpness,
  hue,
  bw
}

enum ElementType {
  text,
  sticker,
  emoji
}

// Classe per rappresentare un elemento posizionato sulla foto (testo, sticker o emoji)
class PlacedElement {
  final String id;
  final ElementType type;
  final String content; // testo, emoji o percorso dell'asset dello sticker
  final Offset position; // posizione relativa (percentuale 0.0 - 1.0 rispetto alle dimensioni del canvas)
  final double scale;
  final double rotation; // in radianti
  final Color color; // Colore per il testo

  PlacedElement({
    required this.id,
    required this.type,
    required this.content,
    required this.position,
    this.scale = 1.0,
    this.rotation = 0.0,
    this.color = Colors.white,
  });

  PlacedElement copyWith({
    Offset? position,
    double? scale,
    double? rotation,
    String? content,
    Color? color,
  }) {
    return PlacedElement(
      id: id,
      type: type,
      content: content ?? this.content,
      position: position ?? this.position,
      scale: scale ?? this.scale,
      rotation: rotation ?? this.rotation,
      color: color ?? this.color,
    );
  }
}

// Classe per rappresentare una linea disegnata a mano libera (Doodle)
class DoodleStroke {
  final List<Offset> points;
  final Color color;
  final double width;

  DoodleStroke({
    required this.points,
    required this.color,
    required this.width,
  });
}

// Stato di editing corrente per la cronologia Undo/Redo
class EditState {
  final int rotationAngle; // 0, 90, 180, 270
  final Map<AdjustSubTool, double> adjustments; // valori da -50 a 50
  final String? activeFilter; // null, 'grayscale', 'sepia', 'cool', 'warm'
  final List<DoodleStroke> doodles;
  final List<PlacedElement> placedElements;

  EditState({
    this.rotationAngle = 0,
    Map<AdjustSubTool, double>? adjustments,
    this.activeFilter,
    this.doodles = const [],
    this.placedElements = const [],
  }) : adjustments = adjustments ?? {
          AdjustSubTool.brightness: 0.0,
          AdjustSubTool.contrast: 0.0,
          AdjustSubTool.saturation: 0.0,
          AdjustSubTool.sharpness: 0.0,
          AdjustSubTool.hue: 0.0,
          AdjustSubTool.bw: 0.0,
        };

  EditState copy() {
    return EditState(
      rotationAngle: rotationAngle,
      adjustments: Map<AdjustSubTool, double>.from(adjustments),
      activeFilter: activeFilter,
      doodles: List<DoodleStroke>.from(doodles),
      placedElements: List<PlacedElement>.from(placedElements),
    );
  }
}

class EditScreen extends StatefulWidget {
  final String imagePath;
  final List<String> capturedImages;
  final int currentGalleryIndex;
  final VoidCallback onPreviousImage;
  final VoidCallback onNextImage;
  final ValueChanged<String> onSave;
  final VoidCallback onCancel;
  final String baseUrl;

  const EditScreen({
    super.key,
    required this.imagePath,
    required this.capturedImages,
    required this.currentGalleryIndex,
    required this.onPreviousImage,
    required this.onNextImage,
    required this.onSave,
    required this.onCancel,
    required this.baseUrl,
  });

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  final GlobalKey _repaintBoundaryKey = GlobalKey();
  
  // Centralized network service
  late final BackendService _backendService;
  List<StickerItem>? _stickers;
  bool _isLoadingStickers = false;
  String? _stickersError;

  // Cronologia per Undo/Redo
  final List<EditState> _history = [];
  final List<EditState> _redoHistory = [];
  
  // Stato corrente (riferimento all'ultimo elemento di _history)
  late EditState _currentState;

  // Stato UI dell'editor
  EditTool _activeTool = EditTool.none;
  AdjustSubTool _activeAdjustSubTool = AdjustSubTool.brightness;
  
  // Impostazioni Doodle
  Color _selectedDoodleColor = Colors.white;
  double _selectedDoodleWidth = 8.0;

  // Elemento attualmente selezionato nell'area di lavoro
  String? _selectedElementId;

  // Gestione caricamento salvataggio immagine
  bool _isSaving = false;

  // Stato per l'editing del testo inline (evita i bug della tastiera virtuale nei dialoghi in Kiosk Mode)
  bool _isEditingText = false;
  PlacedElement? _editingTextElement;
  late TextEditingController _textController;
  Color _selectedTextColor = Colors.white;

  // Campi per memorizzare lo stato iniziale dei gesti di drag & pinch-to-zoom
  late Offset _dragStartFocalPoint;
  late Offset _dragBasePosition;
  late double _dragBaseScale;
  late double _dragBaseRotation;

  @override
  void initState() {
    super.initState();
    _backendService = BackendService(config: BackendConfig(baseUrl: widget.baseUrl));
    // Stato iniziale
    _currentState = EditState();
    _history.add(_currentState);
    _textController = TextEditingController();
    _loadStickers();
  }

  Future<void> _loadStickers() async {
    if (!mounted) return;
    setState(() {
      _isLoadingStickers = true;
      _stickersError = null;
    });
    try {
      final list = await _backendService.fetchStickers();
      if (mounted) {
        setState(() {
          _stickers = list;
          _isLoadingStickers = false;
        });
      }
    } catch (e) {
      debugPrint("Errore caricamento sticker: $e");
      if (mounted) {
        setState(() {
          _stickersError = "Impossibile caricare gli sticker dal server.";
          _isLoadingStickers = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  // Aggiunge un nuovo stato alla cronologia per l'Undo/Redo
  void _commitState(EditState newState) {
    setState(() {
      _currentState = newState;
      _history.add(_currentState);
      _redoHistory.clear(); // Pulisce la cronologia di ripristino ad ogni nuova azione
    });
  }

  // Esegue l'Undo
  void _undo() {
    if (_history.length > 1) {
      setState(() {
        final popped = _history.removeLast();
        _redoHistory.add(popped);
        _currentState = _history.last;
        _selectedElementId = null; // deseleziona elementi attivi per sicurezza
      });
    }
  }

  // Esegue il Redo
  void _redo() {
    if (_redoHistory.isNotEmpty) {
      setState(() {
        final nextState = _redoHistory.removeLast();
        _history.add(nextState);
        _currentState = nextState;
        _selectedElementId = null;
      });
    }
  }

  // Moltiplica due matrici di colore 4x5
  List<double> _multiplyMatrices(List<double> a, List<double> b) {
    final List<double> result = List.filled(20, 0.0);
    
    // Row 0
    result[0] = a[0]*b[0] + a[1]*b[5] + a[2]*b[10] + a[3]*b[15];
    result[1] = a[0]*b[1] + a[1]*b[6] + a[2]*b[11] + a[3]*b[16];
    result[2] = a[0]*b[2] + a[1]*b[7] + a[2]*b[12] + a[3]*b[17];
    result[3] = a[0]*b[3] + a[1]*b[8] + a[2]*b[13] + a[3]*b[18];
    result[4] = a[0]*b[4] + a[1]*b[9] + a[2]*b[14] + a[3]*b[19] + a[4];
    
    // Row 1
    result[5] = a[5]*b[0] + a[6]*b[5] + a[7]*b[10] + a[8]*b[15];
    result[6] = a[5]*b[1] + a[6]*b[6] + a[7]*b[11] + a[8]*b[16];
    result[7] = a[5]*b[2] + a[6]*b[7] + a[7]*b[12] + a[8]*b[17];
    result[8] = a[5]*b[3] + a[6]*b[8] + a[7]*b[13] + a[8]*b[18];
    result[9] = a[5]*b[4] + a[6]*b[9] + a[7]*b[14] + a[8]*b[19] + a[9];
    
    // Row 2
    result[10] = a[10]*b[0] + a[11]*b[5] + a[12]*b[10] + a[13]*b[15];
    result[11] = a[10]*b[1] + a[11]*b[6] + a[12]*b[11] + a[13]*b[16];
    result[12] = a[10]*b[2] + a[11]*b[7] + a[12]*b[12] + a[13]*b[17];
    result[13] = a[10]*b[3] + a[11]*b[8] + a[12]*b[13] + a[13]*b[18];
    result[14] = a[10]*b[4] + a[11]*b[9] + a[12]*b[14] + a[13]*b[19] + a[14];
    
    // Row 3
    result[15] = a[15]*b[0] + a[16]*b[5] + a[17]*b[10] + a[18]*b[15];
    result[16] = a[15]*b[1] + a[16]*b[6] + a[17]*b[11] + a[18]*b[16];
    result[17] = a[15]*b[2] + a[16]*b[7] + a[17]*b[12] + a[18]*b[17];
    result[18] = a[15]*b[3] + a[16]*b[8] + a[17]*b[13] + a[18]*b[18];
    result[19] = a[15]*b[4] + a[16]*b[9] + a[17]*b[14] + a[18]*b[19] + a[19];
    
    return result;
  }

  // Genera la matrice combinata di filtri ed adjustments
  List<double> _generateColorMatrix(EditState state) {
    List<double> matrix = [
      1, 0, 0, 0, 0,
      0, 1, 0, 0, 0,
      0, 0, 1, 0, 0,
      0, 0, 0, 1, 0,
    ];

    if (state.activeFilter != null) {
      List<double> filterMatrix = [];
      switch (state.activeFilter) {
        case 'grayscale':
          filterMatrix = [
            0.2126, 0.7152, 0.0722, 0, 0,
            0.2126, 0.7152, 0.0722, 0, 0,
            0.2126, 0.7152, 0.0722, 0, 0,
            0,      0,      0,      1, 0,
          ];
          break;
        case 'sepia':
          filterMatrix = [
            0.393, 0.769, 0.189, 0, 0,
            0.349, 0.686, 0.168, 0, 0,
            0.272, 0.534, 0.131, 0, 0,
            0,     0,     0,     1, 0,
          ];
          break;
        case 'cool':
          filterMatrix = [
            0.9, 0,   0.1, 0, 0,
            0,   0.9, 0.1, 0, 0,
            0,   0,   1.2, 0, 0,
            0,   0,   0,   1, 0,
          ];
          break;
        case 'warm':
          filterMatrix = [
            1.2, 0,   0,   0, 0,
            0,   1.0, 0,   0, 0,
            0,   0,   0.8, 0, 0,
            0,   0,   0,   1, 0,
          ];
          break;
        default:
          filterMatrix = [
            1, 0, 0, 0, 0,
            0, 1, 0, 0, 0,
            0, 0, 1, 0, 0,
            0, 0, 0, 1, 0,
          ];
      }
      matrix = _multiplyMatrices(matrix, filterMatrix);
    }

    final double brightness = state.adjustments[AdjustSubTool.brightness] ?? 0.0;
    if (brightness != 0.0) {
      final double offset = (brightness / 50.0) * 80.0;
      final List<double> brightnessMatrix = [
        1, 0, 0, 0, offset,
        0, 1, 0, 0, offset,
        0, 0, 1, 0, offset,
        0, 0, 0, 1, 0,
      ];
      matrix = _multiplyMatrices(matrix, brightnessMatrix);
    }

    final double contrast = state.adjustments[AdjustSubTool.contrast] ?? 0.0;
    if (contrast != 0.0) {
      final double factor = 1.0 + (contrast / 100.0);
      final double translate = 128.0 * (1.0 - factor);
      final List<double> contrastMatrix = [
        factor, 0,      0,      0, translate,
        0,      factor, 0,      0, translate,
        0,      0,      factor, 0, translate,
        0,      0,      0,      1, 0,
      ];
      matrix = _multiplyMatrices(matrix, contrastMatrix);
    }

    final double saturation = state.adjustments[AdjustSubTool.saturation] ?? 0.0;
    if (saturation != 0.0) {
      final double factor = 1.0 + (saturation / 50.0);
      final double invSat = 1.0 - factor;
      final double r = 0.2126 * invSat;
      final double g = 0.7152 * invSat;
      final double b = 0.0722 * invSat;
      final List<double> saturationMatrix = [
        r + factor, g,          b,          0, 0,
        r,          g + factor, b,          0, 0,
        r,          g,          b + factor, 0, 0,
        0,          0,          0,          1, 0,
      ];
      matrix = _multiplyMatrices(matrix, saturationMatrix);
    }

    final double hue = state.adjustments[AdjustSubTool.hue] ?? 0.0;
    if (hue != 0.0) {
      final double angle = (hue / 50.0) * math.pi;
      final double cosVal = math.cos(angle);
      final double sinVal = math.sin(angle);
      final double lumR = 0.213;
      final double lumG = 0.715;
      final double lumB = 0.072;
      
      final List<double> hueMatrix = [
        lumR + cosVal * (1 - lumR) + sinVal * (-lumR),
        lumG + cosVal * (-lumG) + sinVal * (-lumG),
        lumB + cosVal * (-lumB) + sinVal * (1 - lumB),
        0, 0,
        lumR + cosVal * (-lumR) + sinVal * (0.143),
        lumG + cosVal * (1 - lumG) + sinVal * (0.140),
        lumB + cosVal * (-lumB) + sinVal * (-0.283),
        0, 0,
        lumR + cosVal * (-lumR) + sinVal * (-(1 - lumR)),
        lumG + cosVal * (-lumG) + sinVal * (lumG),
        lumB + cosVal * (1 - lumB) + sinVal * (lumB),
        0, 0,
        0, 0, 0, 1, 0,
      ];
      matrix = _multiplyMatrices(matrix, hueMatrix);
    }

    final double sharpness = state.adjustments[AdjustSubTool.sharpness] ?? 0.0;
    if (sharpness != 0.0) {
      final double factor = 1.0 + (sharpness / 120.0);
      final double translate = 128.0 * (1.0 - factor);
      final List<double> sharpnessMatrix = [
        factor, 0,      0,      0, translate,
        0,      factor, 0,      0, translate,
        0,      0,      factor, 0, translate,
        0,      0,      0,      1, 0,
      ];
      matrix = _multiplyMatrices(matrix, sharpnessMatrix);
    }

    final double bw = state.adjustments[AdjustSubTool.bw] ?? 0.0;
    if (bw != 0.0) {
      final double intensity = bw / 50.0;
      final double invIntensity = 1.0 - intensity;
      final double factor = 1.5;
      final double translate = -64.0;
      
      final List<double> bwMatrix = [
        (0.299 * factor) * intensity + invIntensity, (0.587 * factor) * intensity, (0.114 * factor) * intensity, 0, translate * intensity,
        (0.299 * factor) * intensity, (0.587 * factor) * intensity + invIntensity, (0.114 * factor) * intensity, 0, translate * intensity,
        (0.299 * factor) * intensity, (0.587 * factor) * intensity, (0.114 * factor) * intensity + invIntensity, 0, translate * intensity,
        0, 0, 0, 1, 0,
      ];
      matrix = _multiplyMatrices(matrix, bwMatrix);
    }

    return matrix;
  }

  // Cattura ed esportazione dell'immagine composita
  Future<String?> _captureCanvasBytes() async {
    try {
      final boundary = _repaintBoundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return null;

      final Uint8List pngBytes = byteData.buffer.asUint8List();
      final File originalFile = File(widget.imagePath);
      final String directory = originalFile.parent.path;
      final String newPath = '$directory/edited_${DateTime.now().millisecondsSinceEpoch}.png';

      await File(newPath).writeAsBytes(pngBytes, flush: true);
      return newPath;
    } catch (e) {
      debugPrint("Errore cattura canvas: $e");
      return null;
    }
  }

  // Esegue il salvataggio definitivo dell'immagine
  Future<void> _saveImage() async {
    if (_isSaving) return;
    setState(() {
      _isSaving = true;
      _selectedElementId = null; // Rimuove i bordi interattivi prima dello scatto
    });

    await WidgetsBinding.instance.endOfFrame;

    final String? newPath = await _captureCanvasBytes();
    if (newPath != null) {
      widget.onSave(newPath);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Impossibile salvare l'immagine."),
            backgroundColor: AppColors.error,
          ),
        );
      }
      setState(() {
        _isSaving = false;
      });
    }
  }

  // Gestore per salvare e navigare tra le immagini (Frecce in alto)
  Future<void> _navigateAndSave(bool isNext) async {
    if (_isSaving) return;

    String? savedPath;
    // Se l'utente ha modificato l'immagine corrente (cronologia > 1), la salviamo prima di scorrere
    if (_history.length > 1) {
      setState(() {
        _isSaving = true;
        _selectedElementId = null;
      });
      await WidgetsBinding.instance.endOfFrame;
      savedPath = await _captureCanvasBytes();
      if (savedPath != null) {
        widget.onSave(savedPath);
      }
    }

    if (isNext) {
      widget.onNextImage();
    } else {
      widget.onPreviousImage();
    }
  }

  // Gestore per i click del pannello inferiore principale
  void _onToolSelected(EditTool tool) {
    if (tool == EditTool.rotate) {
      // Rotazione di 90°
      final currentRotation = _currentState.rotationAngle;
      final nextRotation = (currentRotation + 90) % 360;
      
      final newState = _currentState.copy();
      final updatedState = EditState(
        rotationAngle: nextRotation,
        adjustments: newState.adjustments,
        activeFilter: newState.activeFilter,
        doodles: newState.doodles,
        placedElements: newState.placedElements,
      );
      _commitState(updatedState);
    } else {
      setState(() {
        _activeTool = tool;
        _selectedElementId = null;
      });
    }
  }

  // Metodo per tornare indietro (se in sottomenu torna al principale, altrimenti annulla)
  void _onBackTapped() {
    if (_activeTool != EditTool.none) {
      setState(() {
        _activeTool = EditTool.none;
      });
    } else {
      widget.onCancel();
    }
  }

  // Aggiunge un nuovo elemento (testo, sticker o emoji) nel centro del canvas
  void _addPlacedElement(ElementType type, String content, {Color textColor = Colors.white}) {
    final newElement = PlacedElement(
      id: 'element_${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      content: content,
      position: const Offset(0.5, 0.5), // Centro relativo del canvas
      scale: type == ElementType.sticker ? 1.5 : 1.0,
      rotation: 0.0,
      color: textColor,
    );

    final newState = _currentState.copy();
    final updatedElements = List<PlacedElement>.from(newState.placedElements)..add(newElement);
    
    final updatedState = EditState(
      rotationAngle: newState.rotationAngle,
      adjustments: newState.adjustments,
      activeFilter: newState.activeFilter,
      doodles: newState.doodles,
      placedElements: updatedElements,
    );
    _commitState(updatedState);
    
    setState(() {
      _selectedElementId = newElement.id;
    });
  }

  // Metodi per l'inserimento o la modifica del testo inline (evita showDialog per garanzia tastiera in Kiosk)
  void _startTextEditing({PlacedElement? existingText}) {
    setState(() {
      _isEditingText = true;
      _editingTextElement = existingText;
      _textController.text = existingText != null ? existingText.content : '';
      _selectedTextColor = existingText != null ? existingText.color : Colors.white;
    });
  }

  void _cancelTextEditing() {
    setState(() {
      _isEditingText = false;
      _editingTextElement = null;
      _textController.clear();
    });
  }

  void _applyTextEditing() {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      if (_editingTextElement != null) {
        final newState = _currentState.copy();
        final updatedElements = newState.placedElements.map((el) {
          if (el.id == _editingTextElement!.id) {
            return el.copyWith(
              content: text,
              color: _selectedTextColor,
            );
          }
          return el;
        }).toList();

        final updatedState = EditState(
          rotationAngle: newState.rotationAngle,
          adjustments: newState.adjustments,
          activeFilter: newState.activeFilter,
          doodles: newState.doodles,
          placedElements: updatedElements,
        );
        _commitState(updatedState);
      } else {
        _addPlacedElement(ElementType.text, text, textColor: _selectedTextColor);
      }
    }
    _cancelTextEditing();
  }

  Widget _buildTextEditingOverlay() {
    final List<Color> textColors = [
      Colors.white,
      Colors.black,
      const Color(0xFFF26721), // NextHouse Orange
      Colors.yellow,
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.pink,
      Colors.purple,
    ];

    return Positioned.fill(
      child: Container(
        color: Colors.black.withAlpha(200),
        child: Center(
          child: Container(
            width: 500.0,
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 15.0,
                  spreadRadius: 2.0,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _editingTextElement != null ? "Modifica Testo" : "Aggiungi Testo",
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Inter',
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: _textController,
                  autofocus: true,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Inter',
                    fontSize: 18.0,
                  ),
                  decoration: const InputDecoration(
                    hintText: "Scrivi qualcosa...",
                    hintStyle: TextStyle(
                      color: Colors.white38,
                      fontFamily: 'Inter',
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white24),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFF26721)),
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),
                const Text(
                  "Colore del testo:",
                  style: TextStyle(
                    color: Colors.white70,
                    fontFamily: 'Inter',
                    fontSize: 14.0,
                  ),
                ),
                const SizedBox(height: 8.0),
                SizedBox(
                  height: 40.0,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: textColors.length,
                    itemBuilder: (context, idx) {
                      final color = textColors[idx];
                      final isSel = _selectedTextColor == color;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedTextColor = color;
                          });
                        },
                        child: Container(
                          width: 32.0,
                          height: 32.0,
                          margin: const EdgeInsets.only(right: 8.0),
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSel ? const Color(0xFFF26721) : Colors.white24,
                              width: isSel ? 3.0 : 1.0,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _cancelTextEditing,
                      child: const Text(
                        "Annulla",
                        style: TextStyle(color: Colors.white70, fontFamily: 'Inter'),
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF26721),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      onPressed: _applyTextEditing,
                      child: const Text(
                        "Applica",
                        style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Costruisce il wrapper interattivo posizionato all'interno dello Stack principale.
  // Nota: Questo metodo fa parte di _EditScreenState ed è una funzione helper. Restituisce direttamente Positioned.
  // In questo modo, l'elemento è figlio diretto dello Stack principale e si evita qualsiasi eccezione di layout.
  Widget _buildPlacedElementWrapper(PlacedElement element, double canvasWidth, double canvasHeight) {
    final bool isSelected = _selectedElementId == element.id;
    
    // Dimensione di base del contenuto
    double baseSize = element.type == ElementType.sticker ? 120.0 : 80.0;
    double contentSize = baseSize * element.scale;
    
    // Padding per contenere i controlli (x, resize, edit) all'interno dei limiti del widget
    double padding = 32.0;
    double widgetSize = contentSize + (padding * 2);

    final double left = (element.position.dx * canvasWidth) - (widgetSize / 2);
    final double top = (element.position.dy * canvasHeight) - (widgetSize / 2);

    Widget contentWidget;
    if (element.type == ElementType.text) {
      contentWidget = Text(
        element.content,
        style: TextStyle(
          color: element.color,
          fontFamily: 'Inter',
          fontSize: 24.0,
          fontWeight: FontWeight.bold,
          shadows: const [
            Shadow(
              color: Colors.black87,
              blurRadius: 8.0,
              offset: Offset(0, 2),
            ),
          ],
        ),
        textAlign: TextAlign.center,
      );
    } else if (element.type == ElementType.sticker) {
      contentWidget = Image.network(
        element.content,
        width: contentSize,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.broken_image, size: 60, color: Colors.red);
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const SizedBox(
            width: 60,
            height: 60,
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2.0,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF26721)),
              ),
            ),
          );
        },
      );
    } else {
      contentWidget = Text(
        element.content,
        style: const TextStyle(fontSize: 60.0),
      );
    }

    return Positioned(
      key: ValueKey(element.id),
      left: left,
      top: top,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          setState(() {
            _selectedElementId = isSelected ? null : element.id;
          });
        },
        // Supporto per drag a 1 dito e zoom/rotazione a 2 dita (pinch-to-zoom)
        onScaleStart: (details) {
          // Utilizziamo le coordinate globali (focalPoint) per evitare jitter derivanti dallo spostamento del widget
          _dragStartFocalPoint = details.focalPoint;
          _dragBasePosition = element.position;
          _dragBaseScale = element.scale;
          _dragBaseRotation = element.rotation;
        },
        onScaleUpdate: (details) {
          double newScale = _dragBaseScale;
          double newRotation = _dragBaseRotation;

          if (details.pointerCount >= 2) {
            newScale = (_dragBaseScale * details.scale).clamp(0.5, 4.0);
            newRotation = _dragBaseRotation + details.rotation;
          }

          // Calcola il drag cumulativo basato sullo spostamento del focal point globale rispetto all'inizio del gesto
          final double deltaX = canvasWidth > 0 ? (details.focalPoint.dx - _dragStartFocalPoint.dx) / canvasWidth : 0.0;
          final double deltaY = canvasHeight > 0 ? (details.focalPoint.dy - _dragStartFocalPoint.dy) / canvasHeight : 0.0;

          final index = _currentState.placedElements.indexWhere((el) => el.id == element.id);
          if (index != -1) {
            setState(() {
              _currentState.placedElements[index] = element.copyWith(
                position: Offset(
                  (_dragBasePosition.dx + deltaX).clamp(0.05, 0.95),
                  (_dragBasePosition.dy + deltaY).clamp(0.05, 0.95),
                ),
                scale: newScale,
                rotation: newRotation,
              );
            });
          }
        },
        onScaleEnd: (details) {
          _commitState(_currentState.copy());
        },
        child: Container(
          width: widgetSize,
          height: widgetSize,
          alignment: Alignment.center,
          color: Colors.transparent, // Permette di ricevere il tocco in tutta l'area
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              if (isSelected)
                Container(
                  width: contentSize + 4.0,
                  height: contentSize + 4.0,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFFF26721),
                      width: 2.0,
                    ),
                  ),
                ),

              Transform.rotate(
                angle: element.rotation,
                child: contentWidget,
              ),

              // Pulsante CANCELLA (x rossa in alto a destra)
              if (isSelected)
                Positioned(
                  top: padding - 18.0,
                  right: padding - 18.0,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      debugPrint("Cancellazione sticker/testo richiamata.");
                      final newState = _currentState.copy();
                      final updatedElements = List<PlacedElement>.from(newState.placedElements)
                        ..removeWhere((el) => el.id == element.id);
                      
                      final updatedState = EditState(
                        rotationAngle: newState.rotationAngle,
                        adjustments: newState.adjustments,
                        activeFilter: newState.activeFilter,
                        doodles: newState.doodles,
                        placedElements: updatedElements,
                      );
                      _commitState(updatedState);
                      setState(() {
                        _selectedElementId = null;
                      });
                    },
                    child: Container(
                      width: 32.0,
                      height: 32.0,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 20.0,
                      ),
                    ),
                  ),
                ),

              // Pulsante EDIT (arancione in basso a sinistra)
              if (isSelected && element.type == ElementType.text)
                Positioned(
                  bottom: padding - 18.0,
                  left: padding - 18.0,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _startTextEditing(existingText: element),
                    child: Container(
                      width: 32.0,
                      height: 32.0,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF26721),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit_rounded,
                        color: Colors.white,
                        size: 20.0,
                      ),
                    ),
                  ),
                ),

              // Pulsante RIDIMENSIONAMENTO / ROTAZIONE MANUALE (blu in basso a destra)
              if (isSelected)
                Positioned(
                  bottom: padding - 18.0,
                  right: padding - 18.0,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onPanStart: (details) {
                      _dragBaseScale = element.scale;
                      _dragBaseRotation = element.rotation;
                    },
                    onPanUpdate: (details) {
                      final double deltaX = details.delta.dx * 0.01;
                      final double deltaY = details.delta.dy * 0.02;
                      final index = _currentState.placedElements.indexWhere((el) => el.id == element.id);
                      if (index != -1) {
                        setState(() {
                          _currentState.placedElements[index] = element.copyWith(
                            scale: (_dragBaseScale + deltaX).clamp(0.5, 4.0),
                            rotation: _dragBaseRotation + deltaY,
                          );
                        });
                      }
                    },
                    onPanEnd: (_) {
                      _commitState(_currentState.copy());
                    },
                    child: Container(
                      width: 32.0,
                      height: 32.0,
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.crop_rotate_rounded,
                        color: Colors.white,
                        size: 20.0,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double scaleXForRedo = -1.0;
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // 1. TOP BAR (Altezza ~100px per rispecchiare figma)
                _buildTopBar(scaleXForRedo),

                // 2. AREA DI LAVORO CENTRALE (Dinamica ed espandibile senza overflow)
                Expanded(
                  child: Center(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // Impedisce che la larghezza e l'altezza vadano a 0 o valori negativi a causa del ridimensionamento indotto dalla tastiera soft
                        double maxWidth = math.max(10.0, constraints.maxWidth - 48.0);
                        double maxHeight = math.max(10.0, constraints.maxHeight - 48.0);
                        
                        double width = maxWidth;
                        double height = width * (3 / 4);

                        if (height > maxHeight) {
                          height = maxHeight;
                          width = height * (4 / 3);
                        }

                        return Container(
                          width: width,
                          height: height,
                          decoration: const BoxDecoration(
                            color: Colors.black,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white10,
                                blurRadius: 10.0,
                                spreadRadius: 1.0,
                              ),
                            ],
                          ),
                          child: RepaintBoundary(
                            key: _repaintBoundaryKey,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Positioned.fill(
                                  child: Container(color: Colors.black),
                                ),
                                
                                // IMMAGINE CON REGOLAZIONI, FILTRI E ROTAZIONE
                                Positioned.fill(
                                  child: RotatedBox(
                                    quarterTurns: (_currentState.rotationAngle ~/ 90),
                                    child: ColorFiltered(
                                      colorFilter: ColorFilter.matrix(_generateColorMatrix(_currentState)),
                                      child: Image.file(
                                        File(widget.imagePath),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),

                                // STRATO DOODLE (DISEGNO A MANO LIBERA)
                                Positioned.fill(
                                  child: DoodleCanvas(
                                    strokes: _currentState.doodles,
                                    currentColor: _selectedDoodleColor,
                                    currentWidth: _selectedDoodleWidth,
                                    isEnabled: _activeTool == EditTool.doodle,
                                    onStrokeComplete: (stroke) {
                                      final newState = _currentState.copy();
                                      final updatedDoodles = List<DoodleStroke>.from(newState.doodles)..add(stroke);
                                      
                                      final updatedState = EditState(
                                        rotationAngle: newState.rotationAngle,
                                        adjustments: newState.adjustments,
                                        activeFilter: newState.activeFilter,
                                        doodles: updatedDoodles,
                                        placedElements: newState.placedElements,
                                      );
                                      _commitState(updatedState);
                                    },
                                  ),
                                ),

                                // STRATO DEGLI ELEMENTI POSIZIONATI (TESTO, STICKER, EMOJI)
                                if (_activeTool != EditTool.doodle)
                                  ..._currentState.placedElements.map((element) {
                                    return _buildPlacedElementWrapper(element, width, height);
                                  }),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // 3. BARRA STRUMENTI INFERIORE (Dinamica ed espandibile senza overflow)
                _buildBottomToolbarArea(),
              ],
            ),
            
            // Indicatore di salvataggio in corso sovrapposto in Stack per tenere il canvas nel tree
            if (_isSaving)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withAlpha(150),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF26721)),
                        ),
                        SizedBox(height: 16.0),
                        Text(
                          "Salvataggio in corso...",
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Inter',
                            fontSize: 18.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Overlay per l'editing del testo (inline per garantire l'attivazione della tastiera)
            if (_isEditingText)
              _buildTextEditingOverlay(),
          ],
        ),
      ),
    );
  }

  // Barra Superiore (Top Bar)
  Widget _buildTopBar(double scaleXForRedo) {
    return Container(
      height: 100.0,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Indietro (come su Figma, 100x100 di box cliccabile)
          GestureDetector(
            onTap: _onBackTapped,
            child: Container(
              width: 100.0,
              height: 100.0,
              alignment: Alignment.center,
              child: SvgPicture.asset(
                'assets/images/Instant_Edit_Back_icon.svg',
                width: 60.0,
                height: 60.0,
                colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                fit: BoxFit.contain,
              ),
            ),
          ),
          
          // Frecce per scorrere tra le immagini al centro
          if (widget.capturedImages.length > 1)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () => _navigateAndSave(false),
                  child: Container(
                    width: 80.0,
                    height: 80.0,
                    alignment: Alignment.center,
                    child: Image.asset(
                      'assets/images/Instant_Gallery_LeftNavigation.png',
                      width: 50.0,
                      height: 50.0,
                      color: Colors.white,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                Text(
                  '${widget.currentGalleryIndex + 1} / ${widget.capturedImages.length}',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    color: Colors.white,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8.0),
                GestureDetector(
                  onTap: () => _navigateAndSave(true),
                  child: Container(
                    width: 80.0,
                    height: 80.0,
                    alignment: Alignment.center,
                    child: Image.asset(
                      'assets/images/Instant_Gallery_RightNavigation.png',
                      width: 50.0,
                      height: 50.0,
                      color: Colors.white,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            )
          else
            const SizedBox(width: 10.0),

          // Undo/Redo e Save allineati a destra
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Undo
              GestureDetector(
                onTap: _history.length > 1 ? _undo : null,
                child: Container(
                  width: 80.0,
                  height: 80.0,
                  alignment: Alignment.center,
                  child: SvgPicture.asset(
                    'assets/images/Instant_Edit_Undo_icon.svg',
                    width: 50.0,
                    height: 50.0,
                    colorFilter: ColorFilter.mode(
                      _history.length > 1 ? Colors.white : Colors.white24,
                      BlendMode.srcIn,
                    ),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              // Redo
              GestureDetector(
                onTap: _redoHistory.isNotEmpty ? _redo : null,
                child: Container(
                  width: 80.0,
                  height: 80.0,
                  alignment: Alignment.center,
                  child: SvgPicture.asset(
                    'assets/images/Instant_Edit_Redo_icon.svg',
                    width: 50.0,
                    height: 50.0,
                    colorFilter: ColorFilter.mode(
                      _redoHistory.isNotEmpty ? Colors.white : Colors.white24,
                      BlendMode.srcIn,
                    ),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(width: 16.0),
              // Pulsante Save
              GestureDetector(
                onTap: _isSaving ? null : _saveImage,
                child: Container(
                  width: 120.0,
                  height: 48.0,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF26721),
                    borderRadius: BorderRadius.circular(24.0),
                  ),
                  child: const Text(
                    'Save',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Costruisce la sezione degli strumenti in basso in base allo stato UI
  Widget _buildBottomToolbarArea() {
    if (_activeTool == EditTool.adjust) {
      return _buildAdjustToolbar();
    } else if (_activeTool == EditTool.filter) {
      return _buildFilterToolbar();
    } else if (_activeTool == EditTool.doodle) {
      return _buildDoodleToolbar();
    } else if (_activeTool == EditTool.text) {
      return _buildTextToolbar();
    } else if (_activeTool == EditTool.sticker) {
      return _buildStickerToolbar();
    } else if (_activeTool == EditTool.emoji) {
      return _buildEmojiToolbar();
    }
    return _buildMainToolbar();
  }

  // Toolbar Principale (Rotate, Adjust, Filter, Doodle, Text, Sticker, Emoji)
  Widget _buildMainToolbar() {
    return Container(
      height: 150.0,
      color: Colors.black.withAlpha(200),
      child: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildMainToolbarButton(
                icon: const Icon(Icons.rotate_right_rounded, color: Colors.white, size: 40.0),
                label: "Rotate",
                onTap: () => _onToolSelected(EditTool.rotate),
              ),
              _buildMainToolbarButton(
                icon: const Icon(Icons.tune_rounded, color: Colors.white, size: 40.0),
                label: "Adjust",
                onTap: () => _onToolSelected(EditTool.adjust),
              ),
              _buildMainToolbarButton(
                icon: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 40.0),
                label: "Filter",
                onTap: () => _onToolSelected(EditTool.filter),
              ),
              _buildMainToolbarButton(
                icon: const Icon(Icons.gesture_rounded, color: Colors.white, size: 40.0),
                label: "Doodle",
                onTap: () => _onToolSelected(EditTool.doodle),
              ),
              _buildMainToolbarButton(
                icon: Image.asset(
                  'assets/images/instant_Edit_Text_icon.png',
                  width: 40.0,
                  height: 40.0,
                  color: Colors.white,
                  fit: BoxFit.contain,
                ),
                label: "Text",
                onTap: () => _onToolSelected(EditTool.text),
              ),
              _buildMainToolbarButton(
                icon: Image.asset(
                  'assets/images/Instant_Edit_Sticker_icon.png',
                  width: 40.0,
                  height: 40.0,
                  color: Colors.white,
                  fit: BoxFit.contain,
                ),
                label: "Sticker",
                onTap: () => _onToolSelected(EditTool.sticker),
              ),
              _buildMainToolbarButton(
                icon: const Icon(Icons.sentiment_satisfied_alt_rounded, color: Colors.white, size: 40.0),
                label: "Emoji",
                onTap: () => _onToolSelected(EditTool.emoji),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainToolbarButton({
    required Widget icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140.0,
        height: 140.0,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 76.0,
              height: 76.0,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: Center(child: icon),
            ),
            const SizedBox(height: 8.0),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 18.0,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Toolbar secondaria: Regolazioni (Adjust)
  Widget _buildAdjustToolbar() {
    final double currentValue = _currentState.adjustments[_activeAdjustSubTool] ?? 0.0;
    
    double minVal = -50.0;
    double maxVal = 50.0;
    if (_activeAdjustSubTool == AdjustSubTool.bw) {
      minVal = 0.0;
      maxVal = 50.0;
    }

    return Container(
      height: 200.0,
      color: Colors.black.withAlpha(220),
      child: Column(
        children: [
          Container(
            height: 70.0,
            padding: const EdgeInsets.symmetric(horizontal: 48.0),
            child: Row(
              children: [
                Text(
                  minVal.round().toString(),
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    color: Colors.white60,
                    fontSize: 16.0,
                  ),
                ),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: const Color(0xFFF26721),
                      inactiveTrackColor: Colors.white24,
                      thumbColor: const Color(0xFFF26721),
                      overlayColor: const Color(0xFFF26721).withAlpha(51),
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10.0),
                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 20.0),
                      showValueIndicator: ShowValueIndicator.onDrag,
                      valueIndicatorColor: const Color(0xFFF26721),
                      valueIndicatorTextStyle: const TextStyle(
                        fontFamily: 'Inter',
                        color: Colors.white,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: Slider(
                      value: currentValue,
                      min: minVal,
                      max: maxVal,
                      divisions: (maxVal - minVal).toInt(),
                      label: currentValue.round().toString(),
                      onChanged: (value) {
                        setState(() {
                          _currentState.adjustments[_activeAdjustSubTool] = value;
                        });
                      },
                      onChangeEnd: (value) {
                        final newState = _currentState.copy();
                        newState.adjustments[_activeAdjustSubTool] = value;
                        _commitState(newState);
                      },
                    ),
                  ),
                ),
                Text(
                  maxVal.round().toString(),
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    color: Colors.white60,
                    fontSize: 16.0,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _buildAdjustSubToolButton(
                    subTool: AdjustSubTool.brightness,
                    icon: const Icon(Icons.light_mode_rounded, size: 32.0),
                    label: "Brightness",
                  ),
                  _buildAdjustSubToolButton(
                    subTool: AdjustSubTool.contrast,
                    icon: const Icon(Icons.contrast_rounded, size: 32.0),
                    label: "Contrast",
                  ),
                  _buildAdjustSubToolButton(
                    subTool: AdjustSubTool.saturation,
                    icon: const Icon(Icons.opacity_rounded, size: 32.0),
                    label: "Saturation",
                  ),
                  _buildAdjustSubToolButton(
                    subTool: AdjustSubTool.sharpness,
                    icon: Image.asset(
                      'assets/images/Instant_Edit_Sharpness_icon.png',
                      width: 32.0,
                      height: 32.0,
                      color: Colors.white,
                      fit: BoxFit.contain,
                    ),
                    label: "Sharpness",
                  ),
                  _buildAdjustSubToolButton(
                    subTool: AdjustSubTool.hue,
                    icon: const Icon(Icons.color_lens_rounded, size: 32.0),
                    label: "Hue",
                  ),
                  _buildAdjustSubToolButton(
                    subTool: AdjustSubTool.bw,
                    icon: const Icon(Icons.tonality_rounded, size: 32.0),
                    label: "BW",
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdjustSubToolButton({
    required AdjustSubTool subTool,
    required Widget icon,
    required String label,
  }) {
    final bool isActive = _activeAdjustSubTool == subTool;
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeAdjustSubTool = subTool;
        });
      },
      child: Container(
        width: 140.0,
        height: 100.0,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? Colors.white.withAlpha(25) : Colors.transparent,
          border: Border(
            top: BorderSide(
              color: isActive ? const Color(0xFFF26721) : Colors.transparent,
              width: 3.0,
            ),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Theme(
              data: ThemeData(iconTheme: IconThemeData(color: isActive ? const Color(0xFFF26721) : Colors.white)),
              child: icon,
            ),
            const SizedBox(height: 4.0),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16.0,
                color: isActive ? const Color(0xFFF26721) : Colors.white,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Toolbar secondaria: Filtri (Filter)
  Widget _buildFilterToolbar() {
    return Container(
      height: 150.0,
      color: Colors.black.withAlpha(220),
      child: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildFilterThumbnailButton(
                filterKey: null,
                label: "Original",
              ),
              _buildFilterThumbnailButton(
                filterKey: "grayscale",
                label: "Grayscale",
              ),
              _buildFilterThumbnailButton(
                filterKey: "sepia",
                label: "Sepia",
              ),
              _buildFilterThumbnailButton(
                filterKey: "cool",
                label: "Cool",
              ),
              _buildFilterThumbnailButton(
                filterKey: "warm",
                label: "Warm",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterThumbnailButton({
    required String? filterKey,
    required String label,
  }) {
    final bool isActive = _currentState.activeFilter == filterKey;
    final EditState tempStateForThumbnail = EditState(activeFilter: filterKey);
    final List<double> matrix = _generateColorMatrix(tempStateForThumbnail);

    return GestureDetector(
      onTap: () {
        final newState = _currentState.copy();
        final updatedState = EditState(
          rotationAngle: newState.rotationAngle,
          adjustments: newState.adjustments,
          activeFilter: filterKey,
          doodles: newState.doodles,
          placedElements: newState.placedElements,
        );
        _commitState(updatedState);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120.0,
              height: 80.0,
              decoration: BoxDecoration(
                border: Border.all(
                  color: isActive ? const Color(0xFFF26721) : Colors.white24,
                  width: isActive ? 3.0 : 1.5,
                ),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(9.0),
                child: ColorFiltered(
                  colorFilter: ColorFilter.matrix(matrix),
                  child: Image.file(
                    File(widget.imagePath),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6.0),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16.0,
                color: isActive ? const Color(0xFFF26721) : Colors.white70,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Toolbar secondaria: Disegno (Doodle)
  Widget _buildDoodleToolbar() {
    final List<Color> colors = [
      Colors.white,
      Colors.black,
      const Color(0xFFF26721),
      Colors.yellow,
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.pink,
    ];

    final List<double> brushSizes = [4.0, 8.0, 16.0, 24.0];

    return Container(
      height: 150.0,
      color: Colors.black.withAlpha(220),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: colors.map((color) {
                final bool isSelected = _selectedDoodleColor == color;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDoodleColor = color;
                    });
                  },
                  child: Container(
                    width: 40.0,
                    height: 40.0,
                    margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? const Color(0xFFF26721) : Colors.white54,
                        width: isSelected ? 3.0 : 1.0,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: brushSizes.map((size) {
              final bool isSelected = _selectedDoodleWidth == size;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDoodleWidth = size;
                  });
                },
                child: Container(
                  width: 60.0,
                  height: 40.0,
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white24 : Colors.transparent,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Container(
                    width: size,
                    height: size,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // Toolbar secondaria: Aggiungi Testo
  Widget _buildTextToolbar() {
    return Container(
      height: 150.0,
      color: Colors.black.withAlpha(220),
      child: Center(
        child: GestureDetector(
          onTap: () => _startTextEditing(),
          child: Container(
            width: 320.0,
            height: 70.0,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFF26721),
              borderRadius: BorderRadius.circular(35.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.add_rounded, color: Colors.white, size: 28.0),
                SizedBox(width: 8.0),
                Text(
                  "Aggiungi Testo",
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Toolbar secondaria: Sticker
  Widget _buildStickerToolbar() {
    if (_isLoadingStickers) {
      return Container(
        height: 150.0,
        color: Colors.black.withAlpha(220),
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF26721)),
          ),
        ),
      );
    }

    if (_stickersError != null || _stickers == null) {
      return Container(
        height: 150.0,
        color: Colors.black.withAlpha(220),
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _stickersError ?? "Errore caricamento sticker",
                style: const TextStyle(color: Colors.white70, fontFamily: 'Inter'),
              ),
              const SizedBox(height: 8.0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF26721),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                onPressed: _loadStickers,
                child: const Text("Riprova", style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      );
    }

    if (_stickers!.isEmpty) {
      return Container(
        height: 150.0,
        color: Colors.black.withAlpha(220),
        child: const Center(
          child: Text(
            "Nessuno sticker disponibile sul server.",
            style: TextStyle(color: Colors.white70, fontFamily: 'Inter'),
          ),
        ),
      );
    }

    return Container(
      height: 150.0,
      color: Colors.black.withAlpha(220),
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _stickers!.map((sticker) {
              final stickerImageUrl = '${widget.baseUrl}/api/stickers/${sticker.id}/image';
              return GestureDetector(
                onTap: () => _addPlacedElement(ElementType.sticker, stickerImageUrl),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(20),
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Image.network(
                    stickerImageUrl,
                    width: 150.0,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const SizedBox(
                        width: 150.0,
                        child: Center(
                          child: Icon(Icons.broken_image, color: Colors.red, size: 40.0),
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const SizedBox(
                        width: 150.0,
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF26721)),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  // Toolbar secondaria: Emoji
  Widget _buildEmojiToolbar() {
    final List<String> emojis = [
      '😎', '😍', '😂', '😜', '👍', '💖', '🎉', '🌟', 
      '📸', '🍕', '🍦', '🎈', '🎁', '🚀', '🔥', '👑'
    ];

    // Dividiamo gli emoji in colonne da 2 per formare una griglia orizzontale a 2 righe
    final List<Widget> columns = [];
    for (int i = 0; i < emojis.length; i += 2) {
      final String emoji1 = emojis[i];
      final String emoji2 = (i + 1 < emojis.length) ? emojis[i + 1] : '';
      
      columns.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildEmojiButton(emoji1),
              if (emoji2.isNotEmpty) _buildEmojiButton(emoji2),
            ],
          ),
        ),
      );
    }

    return Container(
      height: 150.0,
      color: Colors.black.withAlpha(220),
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: columns,
          ),
        ),
      ),
    );
  }

  Widget _buildEmojiButton(String emoji) {
    return GestureDetector(
      onTap: () => _addPlacedElement(ElementType.emoji, emoji),
      child: Container(
        width: 54.0,
        height: 54.0,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(15),
          shape: BoxShape.circle,
        ),
        child: Text(
          emoji,
          style: const TextStyle(fontSize: 32.0),
        ),
      ),
    );
  }
}

// Widget dedicato DoodleCanvas con stato locale per garantire il disegno 60 FPS fluida in tempo reale.
// NOTA: Questo widget NON restituisce Positioned al suo root per evitare crash "RenderBox was not laid out".
class DoodleCanvas extends StatefulWidget {
  final List<DoodleStroke> strokes;
  final Color currentColor;
  final double currentWidth;
  final ValueChanged<DoodleStroke> onStrokeComplete;
  final bool isEnabled;

  const DoodleCanvas({
    super.key,
    required this.strokes,
    required this.currentColor,
    required this.currentWidth,
    required this.onStrokeComplete,
    required this.isEnabled,
  });

  @override
  State<DoodleCanvas> createState() => _DoodleCanvasState();
}

class _DoodleCanvasState extends State<DoodleCanvas> {
  List<Offset> _currentPoints = [];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            size: Size.infinite,
            painter: DoodlePainter(
              strokes: widget.strokes,
              currentPoints: _currentPoints,
              currentColor: widget.currentColor,
              currentWidth: widget.currentWidth,
            ),
            child: const SizedBox.expand(),
          ),
        ),
        if (widget.isEnabled)
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanStart: (details) {
                setState(() {
                  _currentPoints = [details.localPosition];
                });
              },
              onPanUpdate: (details) {
                setState(() {
                  _currentPoints = List<Offset>.from(_currentPoints)..add(details.localPosition);
                });
              },
              onPanEnd: (details) {
                if (_currentPoints.isNotEmpty) {
                  final stroke = DoodleStroke(
                    points: List<Offset>.from(_currentPoints),
                    color: widget.currentColor,
                    width: widget.currentWidth,
                  );
                  widget.onStrokeComplete(stroke);
                  setState(() {
                    _currentPoints = [];
                  });
                }
              },
            ),
          ),
      ],
    );
  }
}

// Custom Painter per disegnare tratti di Doodle sull'immagine
class DoodlePainter extends CustomPainter {
  final List<DoodleStroke> strokes;
  final List<Offset> currentPoints;
  final Color currentColor;
  final double currentWidth;

  DoodlePainter({
    required this.strokes,
    required this.currentPoints,
    required this.currentColor,
    required this.currentWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    // 1. Disegna i tratti storici
    for (final stroke in strokes) {
      paint.color = stroke.color;
      paint.strokeWidth = stroke.width;
      
      final points = stroke.points;
      if (points.isEmpty) continue;
      
      if (points.length == 1) {
        canvas.drawPoints(ui.PointMode.points, [points.first], paint);
      } else {
        final path = Path()..moveTo(points.first.dx, points.first.dy);
        for (int i = 1; i < points.length; i++) {
          path.lineTo(points[i].dx, points[i].dy);
        }
        canvas.drawPath(path, paint);
      }
    }

    // 2. Disegna il tratto corrente in tempo reale
    if (currentPoints.isNotEmpty) {
      paint.color = currentColor;
      paint.strokeWidth = currentWidth;
      
      if (currentPoints.length == 1) {
        canvas.drawPoints(ui.PointMode.points, [currentPoints.first], paint);
      } else {
        final path = Path()..moveTo(currentPoints.first.dx, currentPoints.first.dy);
        for (int i = 1; i < currentPoints.length; i++) {
          path.lineTo(currentPoints[i].dx, currentPoints[i].dy);
        }
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant DoodlePainter oldDelegate) {
    return true; // Sempre repaint per garantire rendering immediato
  }
}
