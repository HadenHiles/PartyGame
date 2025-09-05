import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light() {
    // Neon playground palette
    const neonPink = Color(0xFFFF1F8F);
    const neonYellow = Color(0xFFFFF30A);
    const neonCyan = Color(0xFF00F0FF);
    const deepPurple = Color(0xFF6A00F4);
    const ink = Color(0xFF0A0A0A);

    final scheme = const ColorScheme(
      brightness: Brightness.dark,
      primary: neonPink,
      onPrimary: ink,
      secondary: neonCyan,
      onSecondary: ink,
      tertiary: deepPurple,
      onTertiary: Colors.white,
      error: Colors.redAccent,
      onError: Colors.white,
      surface: ink,
      onSurface: Colors.white,
      surfaceContainerHighest: Color(0xFF121212),
      onSurfaceVariant: Colors.white70,
      outline: neonYellow,
      shadow: Colors.black,
      scrim: Colors.black54,
      inverseSurface: Colors.white,
      onInverseSurface: Colors.black,
      inversePrimary: neonYellow,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: ink,
      splashFactory: InkRipple.splashFactory,
      visualDensity: VisualDensity.standard,
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 56, fontWeight: FontWeight.w900, letterSpacing: -1.0),
        displayMedium: TextStyle(fontSize: 44, fontWeight: FontWeight.w900, letterSpacing: -0.5),
        headlineLarge: TextStyle(fontSize: 36, fontWeight: FontWeight.w800),
        headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
        titleLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
        bodyLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        bodyMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        labelLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: 0.5),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          minimumSize: const Size(200, 64),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
          elevation: 8,
          shadowColor: scheme.primary.withValues(alpha: 0.4),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.secondary,
          foregroundColor: scheme.onSecondary,
          minimumSize: const Size(200, 60),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: neonYellow,
          textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest,
        labelStyle: TextStyle(color: scheme.onSurfaceVariant),
        hintStyle: TextStyle(color: scheme.onSurfaceVariant.withValues(alpha: 0.8)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.outline.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: neonPink, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainerHighest,
        selectedColor: neonPink.withValues(alpha: 0.2),
        labelStyle: const TextStyle(fontWeight: FontWeight.w800),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: ink,
        elevation: 0,
        titleTextStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white),
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainerHighest,
        shadowColor: Colors.black87,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );

    return base;
  }
}
