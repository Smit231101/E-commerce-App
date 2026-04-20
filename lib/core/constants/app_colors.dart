import 'package:flutter/material.dart';

class AppColors {
  // --- LIGHT THEME COLORS ---
  static const Color lightBackground = Color(0xFFF9F9F9); // Alabaster white, soft on eyes
  static const Color lightSurface = Color(0xFFFFFFFF);    // Pure white for floating cards
  static const Color lightPrimary = Color(0xFF1A1A1A);    // Rich charcoal, not harsh pure black
  static const Color lightSecondary = Color(0xFF757575);  // Cool, elegant grey for subtitles
  static const Color lightAccent = Color(0xFFC5A880);     // Champagne Gold

  // --- DARK THEME COLORS ---
  static const Color darkBackground = Color(0xFF121212);  // Deep matte grey, industry standard
  static const Color darkSurface = Color(0xFF1E1E1E);     // Slightly elevated grey for cards
  static const Color darkPrimary = Color(0xFFFAFAFA);     // Soft snow white for text
  static const Color darkSecondary = Color(0xFFA0A0A0);   // Muted silver for subtitles
  static const Color darkAccent = Color(0xFFD4AF37);      // Metallic Gold (brighter for dark mode)

  // --- SEMANTIC COLORS (Shared) ---
  static const Color error = Color(0xFFD32F2F);           // Muted crimson
  static const Color success = Color(0xFF388E3C);         // Forest green
}