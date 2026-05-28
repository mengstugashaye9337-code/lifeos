// lib/src/core/theme.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppTheme {
  final ThemeData light;
  final ThemeData dark;

  const AppTheme({required this.light, required this.dark});
}

final themeProvider = Provider<AppTheme>((ref) {
  return AppTheme(
    light: ThemeData(
      useMaterial3: true,
      colorSchemeSeed: Colors.blueAccent,
      brightness: Brightness.light,
    ),
    dark: ThemeData(
      useMaterial3: true,
      colorSchemeSeed: Colors.blueAccent,
      brightness: Brightness.dark,
    ),
  );
});
