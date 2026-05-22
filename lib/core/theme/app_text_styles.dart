import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  static TextStyle get h1 => GoogleFonts.plusJakartaSans(
    fontSize: 28.0,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
  );

  static TextStyle get h2 => GoogleFonts.plusJakartaSans(
    fontSize: 22.0,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.3,
  );

  static TextStyle get bodyLarge => GoogleFonts.plusJakartaSans(
    fontSize: 16.0,
    fontWeight: FontWeight.normal,
  );

  static TextStyle get bodyMedium => GoogleFonts.plusJakartaSans(
    fontSize: 14.0,
    fontWeight: FontWeight.normal,
  );

  static TextStyle get buttonText => GoogleFonts.plusJakartaSans(
    fontSize: 16.0,
    fontWeight: FontWeight.w640,
    letterSpacing: 0.5,
  );
}
