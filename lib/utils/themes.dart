import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppThemes {
  static final Color _primaryColor = const Color(0xFF6A8EAE);
  static final Color _secondaryColor = const Color(0xFFB5C8D5);
  static final Color _lightBackgroundColor = const Color(0xFFF0F4F8);
  static final Color _darkBackgroundColor = const Color(0xFF2C3E50);
  static final Color _lightTextColor = const Color(0xFF333333);
  static final Color _darkTextColor = const Color(0xFFECF0F1);

  static final ThemeData lightTheme = ThemeData(
    primaryColor: _primaryColor,
    scaffoldBackgroundColor: _lightBackgroundColor,
    colorScheme: ColorScheme.light(
      primary: _primaryColor,
      secondary: _secondaryColor,
      surface: Colors.white,
      onPrimary: Colors.white,
      onSecondary: _lightTextColor,
      onSurface: _lightTextColor,
      background: _lightBackgroundColor,
      error: Colors.redAccent,
    ),
    textTheme: GoogleFonts.latoTextTheme().apply(bodyColor: _lightTextColor),
    appBarTheme: AppBarTheme(
      backgroundColor: _primaryColor,
      elevation: 0,
      titleTextStyle: GoogleFonts.lato(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
      iconTheme: const IconThemeData(color: Colors.white),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      selectedItemColor: _primaryColor,
      unselectedItemColor: Colors.grey[600],
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    primaryColor: _primaryColor,
    scaffoldBackgroundColor: _darkBackgroundColor,
    colorScheme: ColorScheme.dark(
      primary: _primaryColor,
      secondary: _secondaryColor,
      surface: const Color(0xFF34495E),
      onPrimary: _darkTextColor,
      onSecondary: _darkTextColor,
      onSurface: _darkTextColor,
      background: _darkBackgroundColor,
      error: Colors.red,
    ),
    textTheme: GoogleFonts.latoTextTheme().apply(bodyColor: _darkTextColor),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF34495E),
      elevation: 0,
      titleTextStyle: GoogleFonts.lato(fontSize: 20, fontWeight: FontWeight.bold, color: _darkTextColor),
      iconTheme: IconThemeData(color: _darkTextColor),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      selectedItemColor: _secondaryColor,
      unselectedItemColor: Colors.grey[400],
      backgroundColor: const Color(0xFF34495E),
    ),
  );
}