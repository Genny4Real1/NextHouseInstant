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
              // Logo Next House Copenhagen da Figma
              Image.network(
                'http://localhost:3845/assets/e9108d7c9f046f4af4488df44bec74f286ab1109.png',
                height: 250.0,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback se il server locale non risponde
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

              // Pulsante "TAKE A SELFIE" con gli angoli asimmetrici
              GestureDetector(
                onTap: onStart,
                child: Container(
                  width: 620.0,
                  height: 140.0,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4D5358), // NextHouse Black (Charcoal)
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(70.0),
                      bottomLeft: Radius.circular(70.0),
                      bottomRight: Radius.circular(70.0),
                    ),
                  ),
                  child: const Text(
                    'TAKE A SELFIE',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 56.0,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 3.0,
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
