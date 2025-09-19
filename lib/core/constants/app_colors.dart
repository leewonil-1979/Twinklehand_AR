import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF9C27B0);
  static const Color primaryDark = Color(0xFF7B1FA2);
  static const Color primaryLight = Color(0xFFE1BEE7);
  
  // Mode Colors
  static const Color cleanMode = Color(0xFF4CAF50);
  static const Color cleanModeLight = Color(0xFF81C784);
  static const Color cleanModeDark = Color(0xFF388E3C);
  
  static const Color dirtyMode = Color(0xFFFF9800);
  static const Color dirtyModeLight = Color(0xFFFFB74D);
  static const Color dirtyModeDark = Color(0xFFF57C00);
  
  // Accent Colors
  static const Color accent = Color(0xFFFFEB3B);
  static const Color error = Color(0xFFF44336);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  
  // Neutral Colors
  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF1E1E1E);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Colors.white70;
  static const Color textDisabled = Colors.white38;
  
  // Overlay Colors
  static const Color overlayDark = Color(0x99000000);
  static const Color overlayLight = Color(0x33FFFFFF);
  
  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );
  
  static const LinearGradient cleanGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [cleanMode, cleanModeLight],
  );
  
  static const LinearGradient dirtyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [dirtyMode, dirtyModeDark],
  );
}