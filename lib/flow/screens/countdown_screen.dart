import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../photobooth_flow_state.dart';
import '../../theme/app_colors.dart';
import '../../widgets/camera_placeholder.dart';

class CountdownScreen extends StatefulWidget {
  final PhotoboothFlowState flowState;

  const CountdownScreen({
    super.key,
    required this.flowState,
  });

  @override
  State<CountdownScreen> createState() => _CountdownScreenState();
}

class _CountdownScreenState extends State<CountdownScreen> {
  bool _isFiltersOpen = false;

  List<double> _getColorMatrix(String? filter) {
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

  @override
  Widget build(BuildContext context) {
    final state = widget.flowState;
    final cameraController = state.cameraController;
    final bool isCameraActive = cameraController != null && cameraController.value.isInitialized;
    final bool isCountingDown = state.isCountingDown;
    final int countdownValue = state.countdownValue;
    final String? activeFilter = state.activeFilter;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: FittedBox(
          fit: BoxFit.contain,
          child: SizedBox(
            width: 1280.0,
            height: 800.0,
            child: Stack(
              children: [
                // 1. ANTEPRIMA CAMERA (1212x808 centered)
                Positioned(
                  left: 29.0,
                  top: 0.0,
                  width: 1212.0,
                  height: 800.0,
                  child: ClipRect(
                    child: ColorFiltered(
                      colorFilter: ColorFilter.matrix(_getColorMatrix(activeFilter)),
                      child: isCameraActive
                          ? CameraPreview(cameraController)
                          : const CameraPlaceholder(showGuides: false),
                    ),
                  ),
                ),

                // 2. RETICOLO D'ANGOLO DELLA CAMERA (sovrapposto)
                Positioned(
                  left: 29.0,
                  top: 0.0,
                  width: 1212.0,
                  height: 800.0,
                  child: const CameraPlaceholder(
                    showGuides: true,
                    showBackground: false,
                  ),
                ),

                // 3. BARRA DEI FILTRI E PULSANTE BACCHETTA (se non in countdown)
                if (!isCountingDown) ...[
                  // Contenitore Pulsante Bacchetta Magica
                  Positioned(
                    left: 29.0,
                    top: 625.0,
                    width: 198.0,
                    height: 175.0,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isFiltersOpen = !_isFiltersOpen;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: _isFiltersOpen ? const Color(0x994D5358) : Colors.transparent,
                        ),
                        alignment: Alignment.center,
                        child: SvgPicture.asset(
                          'assets/images/filters_icon.svg',
                          width: 80.0,
                          height: 80.0,
                          colorFilter: const ColorFilter.mode(
                            AppColors.nextHouseOrange,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Overlay dei filtri (Slide-in)
                  if (_isFiltersOpen)
                    Positioned(
                      left: 227.0,
                      top: 625.0,
                      width: 1014.0,
                      height: 175.0,
                      child: Container(
                        color: const Color(0x964D5358),
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _buildFilterItem(null, "No Filter", state),
                            _buildFilterItem("grayscale", "Grayscale", state),
                            _buildFilterItem("sepia", "Sepia", state),
                            _buildFilterItem("cool", "Cool", state),
                            _buildFilterItem("warm", "Warm", state),
                          ],
                        ),
                      ),
                    ),
                ],

                // 4. PULSANTE DI SCATTO RECORD (a destra, sovrapposto, nascosto in countdown)
                if (!isCountingDown)
                  Positioned(
                    left: 1080.0,
                    top: 322.5,
                    width: 154.0,
                    height: 155.0,
                    child: GestureDetector(
                      onTap: () {
                        // Chiude il cassetto filtri e avvia lo scatto
                        setState(() {
                          _isFiltersOpen = false;
                        });
                        state.startCountdown();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.nextHouseOrange,
                            width: 10.0,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black54,
                              blurRadius: 15.0,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Container(
                            width: 84.0,
                            height: 84.0,
                            decoration: const BoxDecoration(
                              color: AppColors.nextHouseOrange,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                // 5. CONTEGGIO ALLA ROVESCIA (Visualizzazione numero gigante)
                if (isCountingDown)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.25),
                      child: Center(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          transitionBuilder: (child, animation) {
                            return ScaleTransition(
                              scale: Tween<double>(begin: 0.6, end: 1.0).animate(
                                CurvedAnimation(
                                  parent: animation,
                                  curve: Curves.easeOutBack,
                                ),
                              ),
                              child: FadeTransition(
                                opacity: animation,
                                child: child,
                              ),
                            );
                          },
                          child: Text(
                            '$countdownValue',
                            key: ValueKey<int>(countdownValue),
                            style: const TextStyle(
                              fontFamily: 'Saira Stencil One',
                              fontSize: 220.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black54,
                                  blurRadius: 25.0,
                                  offset: Offset(0, 10),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterItem(String? filterKey, String label, PhotoboothFlowState state) {
    final bool isActive = state.activeFilter == filterKey;
    final List<double> matrix = _getColorMatrix(filterKey);

    return GestureDetector(
      onTap: () {
        state.setActiveFilter(filterKey);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Anteprima immagine stock filtrata
          Container(
            width: 108.0,
            height: 72.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(
                color: isActive ? AppColors.nextHouseOrange : Colors.white30,
                width: isActive ? 3.0 : 1.5,
              ),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: AppColors.nextHouseOrange.withValues(alpha: 0.4),
                        blurRadius: 8.0,
                        spreadRadius: 1.0,
                      )
                    ]
                  : null,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(9.0),
              child: ColorFiltered(
                colorFilter: ColorFilter.matrix(matrix),
                child: Image.asset(
                  'assets/images/filter_preview.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6.0),
          // Nome filtro
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14.0,
              color: isActive ? AppColors.nextHouseOrange : Colors.white70,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
