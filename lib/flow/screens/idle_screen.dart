import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:video_player/video_player.dart';
import '../../theme/app_spacing.dart';
import '../photobooth_flow_state.dart';
import 'package:nexthouse_instant/l10n/app_localizations.dart';
import '../../widgets/language_selector.dart';

class IdleScreen extends StatefulWidget {
  final VoidCallback onStart;
  final PhotoboothFlowState flowState;

  const IdleScreen({
    super.key,
    required this.onStart,
    required this.flowState,
  });

  @override
  State<IdleScreen> createState() => _IdleScreenState();
}

class _IdleScreenState extends State<IdleScreen> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Inizializza il controller del video dalla cartella assets
    _controller = VideoPlayerController.asset(
      'assets/images/video_pagina_iniziale.mp4',
    )..initialize().then((_) {
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
          _controller.setLooping(true);
          _controller.setVolume(0.0); // Muta l'audio per consentire l'autoplay
          _controller.play();
        }
      }).catchError((error) {
        debugPrint('Errore caricamento video background: $error');
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Sfondo liquid gradient di fallback (mostrato finché il video carica)
          const Positioned.fill(
            child: LiquidBackground(),
          ),

          // 2. Video Player di sfondo (sfuma in entrata una volta pronto)
          Positioned.fill(
            child: AnimatedOpacity(
              opacity: _isInitialized ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 500),
              child: _isInitialized
                  ? FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _controller.value.size.width,
                        height: _controller.value.size.height,
                        child: VideoPlayer(_controller),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),

          // 3. Logo e Bottone centrali
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const NexthouseInstantLogo(),
                  const SizedBox(height: AppSpacing.s16),

                  // Pulsante "TAKE A SELFIE" con angoli asimmetrici
                  GestureDetector(
                    onTap: () {
                      if (_isInitialized) {
                        try {
                          _controller.pause();
                        } catch (e) {
                          debugPrint('Error pausing background video: $e');
                        }
                      }
                      widget.onStart();
                    },
                    child: Container(
                      width: 694.0,
                      height: 171.0,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Color(0xFF4D5358), // NextHouse Black (Charcoal)
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(80.0),
                          bottomLeft: Radius.circular(80.0),
                          bottomRight: Radius.circular(80.0),
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.takeSelfie,
                        style: const TextStyle(
                          fontFamily: 'Saira Stencil One',
                          fontSize: 84.0,
                          fontWeight: FontWeight.normal,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // 4. Selettore di lingua in alto a destra
          Positioned(
            top: 24.0,
            right: 24.0,
            child: LanguageSelector(flowState: widget.flowState),
          ),
        ],
      ),
    );
  }
}

/// Sfondo dinamico e organico a gradiente liquido con blur
class LiquidBackground extends StatelessWidget {
  const LiquidBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Sfondo indaco scuro di base
        Positioned.fill(
          child: Container(
            color: const Color(0xFF1E1A3C),
          ),
        ),
        // Cerchio arancione luminoso (in alto a destra)
        Positioned(
          right: -250.0,
          top: -100.0,
          width: 800.0,
          height: 800.0,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFFF26721).withValues(alpha: 0.55),
                  const Color(0xFFF26721).withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),
        // Cerchio azzurro/teal luminoso (in basso a sinistra)
        Positioned(
          left: -150.0,
          bottom: -150.0,
          width: 750.0,
          height: 750.0,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF3AB3CF).withValues(alpha: 0.5),
                  const Color(0xFF3AB3CF).withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),
        // Cerchio magenta luminoso (al centro)
        Positioned(
          left: 100.0,
          top: 100.0,
          width: 600.0,
          height: 600.0,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF8B2B79).withValues(alpha: 0.4),
                  const Color(0xFF8B2B79).withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),
        // Filtro di sfocatura per amalgamare i gradienti in un effetto liquido
        Positioned.fill(
          child: ClipRect(
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 80.0, sigmaY: 80.0),
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Logo NextHouse Instant strutturato esattamente come su Figma
class NexthouseInstantLogo extends StatelessWidget {
  const NexthouseInstantLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 719.0,
      height: 510.0,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Scritta corsiva nera "Next House"
          Positioned(
            top: 121.0, // 23.7% di 510
            bottom: 177.0, // 34.68% di 510
            left: 0.0,
            right: 0.0,
            child: SvgPicture.asset(
              'assets/images/nexthouse_logo_text.svg',
              fit: BoxFit.contain,
              colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
            ),
          ),
          // Scritta geometrica nera "INSTANT"
          Positioned(
            top: 317.0, // 62.22% di 510
            bottom: 149.0, // 29.25% di 510
            left: 160.0, // 22.26% di 719
            right: 178.0, // 24.76% di 719
            child: const FittedBox(
              fit: BoxFit.fitHeight,
              child: Text(
                'INSTANT',
                style: TextStyle(
                  fontFamily: 'Saira Stencil One',
                  fontWeight: FontWeight.normal,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
