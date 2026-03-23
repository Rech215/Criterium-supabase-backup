import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Paleta de Colores Refinada ──
  static const Color navyBlue = Color(0xFF0F172A); // Más profundo
  static const Color electricBlue = Color(0xFF3B82F6); // Azul moderno
  static const Color orange = Color(0xFFF59E0B); // Ámbar refinado
  static const Color white = Colors.white;
  static const Color lightGray = Color(0xFFE2E8F0);
  static const Color green = Color(0xFF22C55E); // Verde moderno
  static const Color textDark = Color(0xFF1E293B);
  static const Color scaffoldBg = Color(0xFFF8FAFC); // Gris azulado sutil
  static const Color inputFill = Color(0xFFF1F5F9); // Fondo de inputs

  // ── Sombra reutilizable ──
  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: const Color(0xFF0F172A).withValues(alpha: 0.08),
      blurRadius: 20,
      offset: const Offset(0, 10),
    ),
  ];

  static List<BoxShadow> get subtleShadow => [
    BoxShadow(
      color: const Color(0xFF0F172A).withValues(alpha: 0.05),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  // ─────────────────────────── LIGHT THEME ───────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: navyBlue,
      scaffoldBackgroundColor: scaffoldBg,
      cardColor: Colors.white,
      colorScheme: ColorScheme.fromSeed(
        brightness: Brightness.light,
        seedColor: navyBlue,
        primary: navyBlue,
        secondary: orange,
        surface: Colors.white,
      ),
      useMaterial3: true,

      // ── Tipografía con Google Fonts ──
      textTheme: GoogleFonts.interTextTheme(
        const TextTheme(
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: navyBlue,
          ),
          titleLarge: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: navyBlue,
          ),
          bodyLarge: TextStyle(fontSize: 16, color: textDark),
          bodyMedium: TextStyle(fontSize: 14, color: textDark),
        ),
      ),

      // ── Botones ──
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: green,
          foregroundColor: white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ── AppBar ──
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: navyBlue,
        ),
        iconTheme: const IconThemeData(color: navyBlue),
      ),

      // ── Input Decoration ──
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: electricBlue, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 18,
        ),
      ),

      // ── Card Theme ──
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        color: Colors.white,
      ),
    );
  }

  // ─────────────────────────── DARK THEME ───────────────────────────
  static ThemeData get darkTheme {
    const Color darkBg = Color(0xFF0F172A);
    const Color darkCard = Color(0xFF1E293B);
    const Color darkInput = Color(0xFF334155);
    const Color darkText = Color(0xFFF1F5F9);

    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: electricBlue,
      scaffoldBackgroundColor: darkBg,
      cardColor: darkCard,
      colorScheme: ColorScheme.fromSeed(
        brightness: Brightness.dark,
        seedColor: electricBlue,
        primary: electricBlue,
        secondary: orange,
        surface: darkCard,
      ),
      useMaterial3: true,

      // ── Tipografía ──
      textTheme: GoogleFonts.interTextTheme(
        TextTheme(
          displayLarge: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: darkText,
          ),
          titleLarge: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: darkText,
          ),
          bodyLarge: TextStyle(fontSize: 16, color: darkText.withOpacity(0.87)),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: darkText.withOpacity(0.87),
          ),
        ),
      ),

      // ── Botones ──
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ── AppBar ──
      appBarTheme: AppBarTheme(
        backgroundColor: darkCard,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: darkText,
        ),
        iconTheme: const IconThemeData(color: darkText),
      ),

      // ── Input Decoration ──
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkInput,
        hintStyle: TextStyle(color: darkText.withOpacity(0.4)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: electricBlue, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 18,
        ),
      ),

      // ── Card Theme ──
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        color: darkCard,
      ),
    );
  }
}
