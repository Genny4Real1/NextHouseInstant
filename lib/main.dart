import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'l10n/app_localizations.dart';
import 'theme/app_theme.dart';
import 'flow/photobooth_flow_screen.dart';
import 'flow/photobooth_flow_state.dart';

void main() {
  // Assicura l'inizializzazione dei servizi Flutter prima di configurare l'hardware
  WidgetsFlutterBinding.ensureInitialized();

  // Blocca l'orientamento in modalità orizzontale (Landscape) per tablet Android
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Nasconde barra di stato e navigazione per un'esperienza kiosk fullscreen (immersive sticky)
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final PhotoboothFlowState _flowState;

  @override
  void initState() {
    super.initState();
    _flowState = PhotoboothFlowState();
    _flowState.initializeCamera();
  }

  @override
  void dispose() {
    _flowState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _flowState,
      builder: (context, child) {
        return MaterialApp(
          title: 'NextHouse Instant Photobooth',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme,
          locale: Locale(_flowState.localeCode),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: PhotoboothFlowScreen(flowState: _flowState),
        );
      },
    );
  }
}
