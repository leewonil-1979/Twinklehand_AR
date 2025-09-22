import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'text_styles.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: Colors.white,
    
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.accent,
      error: AppColors.error,
      surface: Colors.white,
    ),
    
    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.transparent,
      titleTextStyle: TextStyles.heading2.copyWith(color: Colors.black),
      iconTheme: const IconThemeData(color: Colors.black),
    ),
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 4,
      ),
    ),
    
    textTheme: TextTheme(
      displayLarge: TextStyles.heading1.copyWith(color: Colors.black),
      displayMedium: TextStyles.heading2.copyWith(color: Colors.black),
      displaySmall: TextStyles.heading3.copyWith(color: Colors.black),
      bodyLarge: TextStyles.bodyLarge.copyWith(color: Colors.black87),
      bodyMedium: TextStyles.bodyMedium.copyWith(color: Colors.black87),
      bodySmall: TextStyles.bodySmall.copyWith(color: Colors.black54),
    ),
  );
  
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.background,
    
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.accent,
      error: AppColors.error,
      surface: AppColors.surface,
    ),
    
    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.transparent,
      titleTextStyle: TextStyles.heading2,
      iconTheme: const IconThemeData(color: Colors.white),
    ),
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 4,
      ),
    ),
    
    sliderTheme: const SliderThemeData(
      activeTrackColor: AppColors.primary,
      inactiveTrackColor: AppColors.textDisabled,
      thumbColor: AppColors.primary,
      overlayColor: AppColors.primaryLight,
    ),
    
    textTheme: TextTheme(
      displayLarge: TextStyles.heading1,
      displayMedium: TextStyles.heading2,
      displaySmall: TextStyles.heading3,
      bodyLarge: TextStyles.bodyLarge,
      bodyMedium: TextStyles.bodyMedium,
      bodySmall: TextStyles.bodySmall,
    ),
  );
}