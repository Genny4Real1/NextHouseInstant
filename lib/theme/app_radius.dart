import 'package:flutter/material.dart';

class AppRadius {
  AppRadius._();

  static const double button = 16.0;
  static const double card = 24.0;
  static const double container = 20.0;

  static BorderRadius get buttonBorder => BorderRadius.circular(button);
  static BorderRadius get cardBorder => BorderRadius.circular(card);
  static BorderRadius get containerBorder => BorderRadius.circular(container);
}
