import 'package:flutter/material.dart';

/// Design tokens and styling for MZ Calculator.
class CalculatorColors {
  // Brand Primary (#19B5FE - Electric Cyan / Blue)
  static const Color primaryCyan = Color(0xFF19B5FE);
  static const Color primaryCyanLight = Color(0xFF4AC7FF);
  static const Color primaryCyanDark = Color(0xFF0288D1);
  static const Color cyanGlow = Color(0x6619B5FE);
  static const Color cyanBorder = Color(0x5519B5FE);

  // App Canvas Background - Full Pure Black
  static const Color canvasBackground = Color(0xFF000000);
  static const Color background = Color(0xFF000000);

  // Glass Display Panel (Minimalist Black with Blue Stroke)
  static const Color displayBackground = Color(0xFF070B11);
  static const Color displayBorder = Color(0x6619B5FE);
  static const Color glassBorder = Color(0x6619B5FE);
  static const Color glassBorderSubtle = Color(0x3319B5FE);

  // Button Surfaces (Minimalist Black with Blue Stroke & Glass)
  static const Color numberButtonGlass = Color(0xFF090D14);
  static const Color numberButtonBorder = Color(0x3519B5FE);
  static const Color numberText = Color(0xFFFFFFFF);

  // Utility Buttons (AC, ±, %, DEL)
  static const Color utilityButtonGlass = Color(0xFF0C141F);
  static const Color utilityButtonBorder = Color(0x5519B5FE);
  static const Color utilityText = Color(0xFFE0F2FE);

  // Operator Buttons (÷, ×, −, +)
  static const Color operatorButtonGlass = Color(0xFF0E1A29);
  static const Color operatorButtonBorder = Color(0x8819B5FE);
  static const Color operatorSymbol = Color(0xFF19B5FE);

  // Equals Button (=)
  static const Color equalsButtonGradientStart = Color(0xFF42C8FF);
  static const Color equalsButtonGradientEnd = Color(0xFF19B5FE);
  static const Color equalsText = Color(0xFF030D16);

  // Modal / History Sheets
  static const Color sheetBackground = Color(0xFF070B11);
  static const Color sheetCardBackground = Color(0x2419B5FE);
  static const Color sheetBorder = Color(0x5519B5FE);
  static const Color dividerColor = Color(0x2219B5FE);

  // Typography
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textCyanAccent = Color(0xFF19B5FE);

  // Compatibility alias
  static const Color accentLime = primaryCyan;
}

class CalculatorAssets {
  static const String logo = 'assets/logo/logo.png';
  static const String fallbackLogo = 'assets/logo/mzkalkulator.png';
}

class CalculatorSpacing {
  static const double buttonRadius = 18.0;
  static const double displayRadius = 24.0;
  static const double buttonGap = 12.0;
}
