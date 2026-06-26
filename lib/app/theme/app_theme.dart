import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const _seed = Color(0xFF4F46E5); // indigo

ThemeData _buildTheme(Brightness brightness) {
  final scheme = ColorScheme.fromSeed(seedColor: _seed, brightness: brightness);
  final base = ThemeData(useMaterial3: true, colorScheme: scheme, brightness: brightness);

  return base.copyWith(
    scaffoldBackgroundColor: scheme.surface,
    textTheme: GoogleFonts.interTextTheme(base.textTheme),
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 20, fontWeight: FontWeight.w600, color: scheme.onSurface),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: scheme.surfaceContainerLowest,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: scheme.outlineVariant),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surfaceContainerHighest,
      hintStyle: TextStyle(color: scheme.onSurfaceVariant),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: scheme.primary, width: 1.5)),
    ),
    chipTheme: ChipThemeData(
      side: BorderSide(color: scheme.outlineVariant),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: scheme.surface,
      elevation: 0,
      indicatorColor: scheme.primaryContainer,
      labelTextStyle: WidgetStatePropertyAll(
        GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500)),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: scheme.primary,
      foregroundColor: scheme.onPrimary,
      elevation: 2,
    ),
    dividerTheme: DividerThemeData(color: scheme.outlineVariant, space: 1),
  );
}

final lightTheme = _buildTheme(Brightness.light);
final darkTheme = _buildTheme(Brightness.dark);
