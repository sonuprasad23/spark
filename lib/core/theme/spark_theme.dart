import 'package:flutter/material.dart';

/// SPARK Design System - Color Palette
/// Premium, modern dating app aesthetic with vibrant gradients
class SparkColors {
  SparkColors._();

  // Primary Brand Colors
  static const Color primary = Color(0xFFFF6B6B);
  static const Color primaryDark = Color(0xFFEE5A5A);
  static const Color primaryLight = Color(0xFFFF8A8A);
  
  // Secondary / Accent
  static const Color secondary = Color(0xFF845EC2);
  static const Color secondaryDark = Color(0xFF6B4AA0);
  static const Color secondaryLight = Color(0xFFA178DF);
  
  // Tertiary - For highlights
  static const Color tertiary = Color(0xFFFFB86C);
  static const Color tertiaryDark = Color(0xFFE8A55A);
  static const Color tertiaryLight = Color(0xFFFFCB8F);
  
  // Success / Connection Made
  static const Color success = Color(0xFF2ECC71);
  static const Color successLight = Color(0xFF58D68D);
  
  // Error / Warning
  static const Color error = Color(0xFFE74C3C);
  static const Color errorLight = Color(0xFFEC7063);
  static const Color warning = Color(0xFFF39C12);
  
  // Neutral - Dark Theme Optimized
  static const Color background = Color(0xFF0D0D0F);
  static const Color surface = Color(0xFF1A1A1E);
  static const Color surfaceLight = Color(0xFF252529);
  static const Color surfaceLighter = Color(0xFF303036);
  
  // Card backgrounds with glassmorphism
  static const Color cardBackground = Color(0xFF1E1E24);
  static const Color cardBorder = Color(0xFF2D2D35);
  
  // Text Colors
  static const Color textPrimary = Color(0xFFFAFAFA);
  static const Color textSecondary = Color(0xFFB0B0B8);
  static const Color textTertiary = Color(0xFF6C6C78);
  static const Color textDisabled = Color(0xFF4A4A54);
  
  // Overlay
  static const Color overlay = Color(0x80000000);
  static const Color overlayLight = Color(0x40000000);
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, Color(0xFFFF8E53)],
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondary, Color(0xFFD65DB1)],
  );
  
  static const LinearGradient matchGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53), Color(0xFFFFB86C)],
  );
  
  static const LinearGradient premiumGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
  );
  
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1A1A2E), Color(0xFF0D0D0F)],
  );
}

/// Typography System
class SparkTypography {
  SparkTypography._();
  
  static const String fontFamily = 'Outfit';
  
  // Display
  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 48,
    fontWeight: FontWeight.w700,
    letterSpacing: -1.5,
    height: 1.1,
  );
  
  static const TextStyle displayMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 36,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.2,
  );
  
  static const TextStyle displaySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.2,
  );
  
  // Headlines
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.3,
  );
  
  static const TextStyle headlineMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    height: 1.3,
  );
  
  static const TextStyle headlineSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    height: 1.3,
  );
  
  // Body
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    height: 1.5,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.5,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.5,
  );
  
  // Labels
  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.4,
  );
  
  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.4,
  );
  
  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.4,
  );
  
  // Button
  static const TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.2,
  );
}

/// Spacing & Dimensions
class SparkSpacing {
  SparkSpacing._();
  
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  static const double xxxl = 64;
  
  // Screen padding
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(horizontal: 20);
  static const EdgeInsets screenPaddingWithTop = EdgeInsets.fromLTRB(20, 16, 20, 0);
}

/// Border Radius
class SparkRadius {
  SparkRadius._();
  
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double full = 999;
  
  static BorderRadius get cardRadius => BorderRadius.circular(lg);
  static BorderRadius get buttonRadius => BorderRadius.circular(md);
  static BorderRadius get chipRadius => BorderRadius.circular(full);
  static BorderRadius get modalRadius => BorderRadius.circular(xl);
}

/// Shadows
class SparkShadows {
  SparkShadows._();
  
  static List<BoxShadow> get small => [
    BoxShadow(
      color: Colors.black.withOpacity(0.15),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];
  
  static List<BoxShadow> get medium => [
    BoxShadow(
      color: Colors.black.withOpacity(0.2),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> get large => [
    BoxShadow(
      color: Colors.black.withOpacity(0.25),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];
  
  static List<BoxShadow> get glow => [
    BoxShadow(
      color: SparkColors.primary.withOpacity(0.3),
      blurRadius: 20,
      spreadRadius: 2,
    ),
  ];
}

/// Animation Durations
class SparkDurations {
  SparkDurations._();
  
  static const Duration fastest = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration slower = Duration(milliseconds: 700);
  static const Duration slowest = Duration(milliseconds: 1000);
}

/// Animation Curves
class SparkCurves {
  SparkCurves._();
  
  static const Curve defaultCurve = Curves.easeOutCubic;
  static const Curve bounce = Curves.elasticOut;
  static const Curve smooth = Curves.easeInOutCubic;
  static const Curve snappy = Curves.easeOutBack;
}
