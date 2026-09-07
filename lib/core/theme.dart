import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blueGrey,
        brightness: Brightness.light,
      ).copyWith(
        primary: Colors.black, // High contrast primary
        onPrimary: Colors.white,
        secondary: Colors.blueGrey.shade800,
        onSecondary: Colors.white,
        error: Colors.red.shade700,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blueGrey,
        brightness: Brightness.dark,
      ).copyWith(
        primary: Colors.white, // High contrast primary
        onPrimary: Colors.black,
        secondary: Colors.blueGrey.shade200,
        onSecondary: Colors.black,
        error: Colors.red.shade300,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
    );
  }
}
