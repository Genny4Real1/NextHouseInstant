import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../flow/photobooth_flow_state.dart';

class LanguageSelector extends StatefulWidget {
  final PhotoboothFlowState flowState;

  const LanguageSelector({
    super.key,
    required this.flowState,
  });

  @override
  State<LanguageSelector> createState() => _LanguageSelectorState();
}

class _LanguageSelectorState extends State<LanguageSelector> {
  bool _isLangMenuOpen = false;

  final List<Map<String, String>> _languages = [
    {'code': 'en', 'name': 'English', 'flag': '🇬🇧'},
    {'code': 'it', 'name': 'Italiano', 'flag': '🇮🇹'},
    {'code': 'fr', 'name': 'Français', 'flag': '🇫🇷'},
    {'code': 'es', 'name': 'Español', 'flag': '🇪🇸'},
    {'code': 'de', 'name': 'Deutsch', 'flag': '🇩🇪'},
    {'code': 'da', 'name': 'Dansk', 'flag': '🇩🇰'},
  ];

  @override
  Widget build(BuildContext context) {
    final currentLang = _languages.firstWhere(
      (lang) => lang['code'] == widget.flowState.localeCode,
      orElse: () => _languages[0],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _isLangMenuOpen = !_isLangMenuOpen;
            });
          },
          child: Container(
            width: 72.0,
            height: 72.0,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(25),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withAlpha(40),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(60),
                  blurRadius: 10.0,
                  offset: const Offset(0.0, 4.0),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              currentLang['flag']!,
              style: const TextStyle(fontSize: 36.0),
            ),
          ),
        ),
        if (_isLangMenuOpen) ...[
          const SizedBox(height: 12.0),
          ClipRRect(
            borderRadius: BorderRadius.circular(20.0),
            child: Container(
              width: 180.0,
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B).withAlpha(220),
                borderRadius: BorderRadius.circular(20.0),
                border: Border.all(
                  color: Colors.white.withAlpha(30),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(120),
                    blurRadius: 20.0,
                    offset: const Offset(0.0, 10.0),
                  ),
                ],
              ),
              child: ClipRect(
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: _languages.map((lang) {
                        final bool isActive = lang['code'] == widget.flowState.localeCode;
                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              widget.flowState.setLocale(lang['code']!);
                              setState(() {
                                _isLangMenuOpen = false;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 12.0,
                              ),
                              color: isActive ? Colors.white.withAlpha(20) : null,
                              child: Row(
                                children: [
                                  Text(
                                    lang['flag']!,
                                    style: const TextStyle(fontSize: 24.0),
                                  ),
                                  const SizedBox(width: 12.0),
                                  Expanded(
                                    child: Text(
                                      lang['name']!,
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        color: isActive ? const Color(0xFFF26721) : Colors.white,
                                        fontSize: 16.0,
                                        fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
