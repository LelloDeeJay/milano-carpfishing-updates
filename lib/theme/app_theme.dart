import 'package:flutter/material.dart';

class AppTheme {
  static const Color nero = Color(0xFF0D0D0D);
  static const Color neroCard = Color(0xFF1A1A1A);
  static const Color oro = Color(0xFFD4AF37);
  static const Color oroChiaro = Color(0xFFE6C76A);
  static const Color oroScuro = Color(0xFF9C7A2D);
  static const Color verde = Color(0xFF2E8B57);
  static const Color bianco = Color(0xFFF5F5F5);
  static const Color grigio = Color(0xFF9E9E9E);
  static const Color crema = Color(0xFFFFF8EC);
  static const Color cremaCard = Color(0xFFFAF1DD);
  static const Color testoScuro = Color(0xFF222222);

  static const TextStyle titoloGrande = TextStyle(
    color: oro,
    fontSize: 30,
    fontWeight: FontWeight.bold,
    fontFamily: 'serif',
    letterSpacing: 1.2,
  );

  static const TextStyle titoloMedio = TextStyle(
    color: oro,
    fontSize: 20,
    fontWeight: FontWeight.bold,
    fontFamily: 'serif',
    letterSpacing: 1,
  );

  static const TextStyle sottotitolo = TextStyle(
    color: oroChiaro,
    fontSize: 15,
    fontFamily: 'serif',
  );

  static const TextStyle testoBianco = TextStyle(color: bianco, fontSize: 15);

  static const TextStyle valori = TextStyle(
    color: Colors.white,
    fontSize: 12,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.8,
  );

  static ThemeData scuro() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: nero,
      primaryColor: oro,
      colorScheme: const ColorScheme.dark(
        primary: oro,
        secondary: verde,
        surface: neroCard,
      ),
      useMaterial3: false,
    );
  }

  static ThemeData chiaro() {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: crema,
      primaryColor: oroScuro,
      colorScheme: const ColorScheme.light(
        primary: oroScuro,
        secondary: verde,
        surface: cremaCard,
      ),
      useMaterial3: false,
    );
  }
}
