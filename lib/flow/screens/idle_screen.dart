import 'package:flutter/material.dart';
import '../../theme/app_spacing.dart';

class IdleScreen extends StatelessWidget {
  final VoidCallback onStart;

  const IdleScreen({
    super.key,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo Next House Copenhagen da Figma (local asset)
              Image.asset(
                'assets/images/nexthouse_logo.png',
                height: 250.0,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback se il file locale non viene caricato
                  return const Text(
                    'Next House\nCOPENHAGEN',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 48.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      letterSpacing: 2.0,
                    ),
                    textAlign: TextAlign.center,
                  );
                },
              ),
              const SizedBox(height: AppSpacing.s48),

              // Pulsante "TAKE A SELFIE" con gli angoli asimmetrici e font Saira Stencil One da Figma
              GestureDetector(
                onTap: onStart,
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
                  child: const Text(
                    'TAKE A SELFIE',
                    style: TextStyle(
                      fontFamily: 'Saira Stencil One',
                      fontSize: 84.0, // Utilizziamo 84.0 anziché 96.0 per prevenire eventuali overflow in Flutter
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
    );
  }
}
