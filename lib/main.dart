import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'flow/photobooth_flow_screen.dart';

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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NextHouse Instant Photobooth',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const PhotoboothFlowScreen(),
    );
  }
}
