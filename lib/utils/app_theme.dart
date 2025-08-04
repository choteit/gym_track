import 'package:flutter/material.dart';

class AppTheme {
  // Gym-focused color palette with energy and motivation in mind
  static const Color _primarySeed =
      Color(0xFF00695C); // Deep teal - energy & focus

  // Generate Material 3 color scheme from seed colors
  static final ColorScheme _colorScheme = ColorScheme.fromSeed(
    seedColor: _primarySeed,
    brightness: Brightness.dark,
  );

  // Custom text theme for fitness app
  static const TextTheme _textTheme = TextTheme(
    displayLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      letterSpacing: -0.5,
    ),
    displayMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      letterSpacing: -0.5,
    ),
    displaySmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      letterSpacing: -0.5,
    ),
    headlineLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.25,
    ),
    headlineMedium: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.25,
    ),
    headlineSmall: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.25,
    ),
    titleLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.15,
    ),
    titleMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.15,
    ),
    titleSmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      letterSpacing: 0.5,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      letterSpacing: 0.25,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      letterSpacing: 0.4,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
    ),
    labelSmall: TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
    ),
  );

  // Main theme configuration (dark theme only)
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: _colorScheme,
      textTheme: _textTheme,

      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: _colorScheme.surface,
        foregroundColor: _colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        titleTextStyle: _textTheme.titleLarge?.copyWith(
          color: _colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(
          color: _colorScheme.onSurface,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: _colorScheme.surface,
        surfaceTintColor: _colorScheme.surfaceTint,
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _colorScheme.primary,
          foregroundColor: _colorScheme.onPrimary,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: _textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: _colorScheme.primary,
        foregroundColor: _colorScheme.onPrimary,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: _colorScheme.primaryContainer,
        labelStyle: _textTheme.labelMedium?.copyWith(
          color: _colorScheme.onPrimaryContainer,
        ),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: _colorScheme.surface,
        selectedItemColor: _colorScheme.primary,
        unselectedItemColor: _colorScheme.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 3,
        selectedLabelStyle: _textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: _textTheme.labelSmall,
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: _colorScheme.surface,
        surfaceTintColor: _colorScheme.surfaceTint,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        titleTextStyle: _textTheme.headlineSmall?.copyWith(
          color: _colorScheme.onSurface,
        ),
        contentTextStyle: _textTheme.bodyMedium?.copyWith(
          color: _colorScheme.onSurfaceVariant,
        ),
      ),

      // List Tile Theme
      listTileTheme: ListTileThemeData(
        titleTextStyle: _textTheme.bodyLarge?.copyWith(
          color: _colorScheme.onSurface,
        ),
        subtitleTextStyle: _textTheme.bodyMedium?.copyWith(
          color: _colorScheme.onSurfaceVariant,
        ),
        iconColor: _colorScheme.primary,
        dense: false,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _colorScheme.surfaceVariant.withOpacity(0.4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _colorScheme.primary, width: 2),
        ),
        labelStyle: _textTheme.bodyMedium?.copyWith(
          color: _colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
