// lib/src/core/theme/theme.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Your existing provider setup
final themeProvider = Provider((ref) => AppThemeData());

class AppThemeData {
  // Common design tokens used by BOTH light and dark themes
  static final _borderRadius = BorderRadius.circular(12);
  static const _seedColor = Colors.deepPurple;

  ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _seedColor,
        brightness: Brightness.light,
        surface: Colors.grey.shade50,
      ),

      // ── Standardize Inputs Globally ──
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: _borderRadius),
        filled: true,
        fillColor: Colors.grey.shade100,
      ),

      // ── Standardize Button Shapes Globally ──
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: _borderRadius),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: _borderRadius),
        ),
      ),

      // ── Segmented Controls (Like your Task Filter Bar) ──
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: _borderRadius),
        ),
      ),
    );
  }

  ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _seedColor,
        brightness: Brightness.dark,
      ),

      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: _borderRadius),
        filled: true,
        fillColor: Colors.grey.shade900,
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: _borderRadius),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: _borderRadius),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: _borderRadius),
        ),
      ),
    );
  }
}
