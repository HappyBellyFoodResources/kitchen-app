import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData light = ThemeData(
  fontFamily: GoogleFonts.roboto().fontFamily,
  primaryColor: const Color(0xFFFFCC00),
  secondaryHeaderColor: const Color.fromARGB(255, 233, 171, 3),
  disabledColor: const Color(0xFFBABFC4),
  brightness: Brightness.light,
  highlightColor: const Color(0xFFF4F6FA),
  hintColor: const Color(0xFF9F9F9F),
  cardColor: Colors.white,
  textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: const Color(0xff1c1c1c))),
  colorScheme: const ColorScheme.light(
          primary: Color(0xFFFFCC00),
          secondary: Color(0xff6ca6f8),
          tertiary: Color(0xFFF4F6FA))
      .copyWith(surface: const Color(0xFFF3F3F3))
      .copyWith(error: const Color(0xFFE84D4F)),
);
