import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ModernTheme {
  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF1E1E1E);
  static const Color accent = Color(0xFF6C63FF);
  static const Color secondary = Color(0xFF03DAC6);
  static const List<Color> moodColors = [
    Colors.transparent,
    Color(0xFFFFD700),
    Color(0xFF4CAF50),
    Color(0xFF2196F3),
    Color(0xFFFF9800),
    Color(0xFFF44336),
  ];
  static TextStyle get header => GoogleFonts.poppins(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: Colors.white
  );
  static TextStyle get title => GoogleFonts.poppins(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: Colors.white
  );
  static TextStyle get body => GoogleFonts.poppins(
      fontSize: 14,
      color: Colors.white70
  );
  static BoxDecoration glassDecoration = BoxDecoration(
    color: surface.withValues(alpha: 0.8),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.3),
        blurRadius: 20,
        offset: const Offset(0, 10),
      ),
    ],
  );
}