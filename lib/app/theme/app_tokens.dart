import 'package:flutter/material.dart';

/// Spacing, radius, and semantic status colors. Single source of truth for the
/// magic numbers used across screens. Status colors are fixed hexes (amber/red/
/// green) that read on both light and dark surfaces, paired with a soft bg.
class AppTokens {
  AppTokens._();

  // Spacing
  static const double space2 = 2;
  static const double space4 = 4;
  static const double space8 = 8;
  static const double space12 = 12;
  static const double space16 = 16;
  static const double space24 = 24;

  // Radius
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;

  // Status (foreground / soft background)
  static const Color lowFg = Color(0xFFB45309); // amber-700
  static const Color lowBg = Color(0x1FF59E0B); // amber @ ~12%
  static const Color outFg = Color(0xFFB91C1C); // red-700
  static const Color outBg = Color(0x1FEF4444); // red @ ~12%
  static const Color inFg = Color(0xFF15803D); // green-700
  static const Color inBg = Color(0x1F22C55E); // green @ ~12%
}
