import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'spark_theme.dart';

/// Complete Material 3 Theme for SPARK App
class SparkAppTheme {
  SparkAppTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: SparkTypography.fontFamily,
      
      // Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: SparkColors.primary,
        onPrimary: SparkColors.textPrimary,
        primaryContainer: SparkColors.primaryDark,
        secondary: SparkColors.secondary,
        onSecondary: SparkColors.textPrimary,
        secondaryContainer: SparkColors.secondaryDark,
        tertiary: SparkColors.tertiary,
        surface: SparkColors.surface,
        onSurface: SparkColors.textPrimary,
        error: SparkColors.error,
        onError: SparkColors.textPrimary,
      ),
      
      // Scaffold
      scaffoldBackgroundColor: SparkColors.background,
      
      // App Bar
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: TextStyle(
          fontFamily: SparkTypography.fontFamily,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: SparkColors.textPrimary,
        ),
        iconTheme: IconThemeData(
          color: SparkColors.textPrimary,
        ),
      ),
      
      // Cards
      cardTheme: CardTheme(
        color: SparkColors.cardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: SparkRadius.cardRadius,
          side: const BorderSide(
            color: SparkColors.cardBorder,
            width: 1,
          ),
        ),
      ),
      
      // Elevated Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: SparkColors.primary,
          foregroundColor: SparkColors.textPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: SparkRadius.buttonRadius,
          ),
          textStyle: SparkTypography.button,
        ),
      ),
      
      // Outlined Buttons
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: SparkColors.textPrimary,
          side: const BorderSide(color: SparkColors.cardBorder, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: SparkRadius.buttonRadius,
          ),
          textStyle: SparkTypography.button,
        ),
      ),
      
      // Text Buttons
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: SparkColors.primary,
          textStyle: SparkTypography.labelLarge,
        ),
      ),
      
      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: SparkColors.surfaceLight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: SparkRadius.buttonRadius,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: SparkRadius.buttonRadius,
          borderSide: const BorderSide(color: SparkColors.cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: SparkRadius.buttonRadius,
          borderSide: const BorderSide(color: SparkColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: SparkRadius.buttonRadius,
          borderSide: const BorderSide(color: SparkColors.error),
        ),
        hintStyle: SparkTypography.bodyMedium.copyWith(
          color: SparkColors.textTertiary,
        ),
        labelStyle: SparkTypography.bodyMedium.copyWith(
          color: SparkColors.textSecondary,
        ),
      ),
      
      // Bottom Navigation
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: SparkColors.surface,
        selectedItemColor: SparkColors.primary,
        unselectedItemColor: SparkColors.textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      
      // Floating Action Button
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: SparkColors.primary,
        foregroundColor: SparkColors.textPrimary,
        elevation: 4,
      ),
      
      // Dialogs
      dialogTheme: DialogThemeData(
        backgroundColor: SparkColors.surface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: SparkRadius.modalRadius,
        ),
      ),
      
      // Bottom Sheets
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: SparkColors.surface,
        modalBackgroundColor: SparkColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
      ),
      
      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: SparkColors.surfaceLighter,
        contentTextStyle: SparkTypography.bodyMedium.copyWith(
          color: SparkColors.textPrimary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: SparkRadius.buttonRadius,
        ),
        behavior: SnackBarBehavior.floating,
      ),
      
      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: SparkColors.surfaceLight,
        selectedColor: SparkColors.primary.withOpacity(0.2),
        labelStyle: SparkTypography.labelMedium,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: SparkRadius.chipRadius,
        ),
      ),
      
      // Divider
      dividerTheme: const DividerThemeData(
        color: SparkColors.cardBorder,
        thickness: 1,
        space: 1,
      ),
      
      // Progress Indicator
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: SparkColors.primary,
        linearTrackColor: SparkColors.surfaceLight,
      ),
      
      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return SparkColors.primary;
          }
          return SparkColors.textTertiary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return SparkColors.primary.withOpacity(0.3);
          }
          return SparkColors.surfaceLight;
        }),
      ),
      
      // Text Theme
      textTheme: TextTheme(
        displayLarge: SparkTypography.displayLarge.copyWith(color: SparkColors.textPrimary),
        displayMedium: SparkTypography.displayMedium.copyWith(color: SparkColors.textPrimary),
        displaySmall: SparkTypography.displaySmall.copyWith(color: SparkColors.textPrimary),
        headlineLarge: SparkTypography.headlineLarge.copyWith(color: SparkColors.textPrimary),
        headlineMedium: SparkTypography.headlineMedium.copyWith(color: SparkColors.textPrimary),
        headlineSmall: SparkTypography.headlineSmall.copyWith(color: SparkColors.textPrimary),
        bodyLarge: SparkTypography.bodyLarge.copyWith(color: SparkColors.textPrimary),
        bodyMedium: SparkTypography.bodyMedium.copyWith(color: SparkColors.textSecondary),
        bodySmall: SparkTypography.bodySmall.copyWith(color: SparkColors.textTertiary),
        labelLarge: SparkTypography.labelLarge.copyWith(color: SparkColors.textPrimary),
        labelMedium: SparkTypography.labelMedium.copyWith(color: SparkColors.textSecondary),
        labelSmall: SparkTypography.labelSmall.copyWith(color: SparkColors.textTertiary),
      ),
    );
  }
}
