import 'package:flutter/material.dart';

class TextStyles {
  // Headings
  static const TextStyle heading1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    letterSpacing: -0.5,
  );
  
  static const TextStyle heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    letterSpacing: -0.3,
  );
  
  static const TextStyle heading3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
  
  // Body Text
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: Colors.white,
    height: 1.5,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: Colors.white,
    height: 1.5,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: Colors.white70,
    height: 1.5,
  );
  
  // Button Text
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    letterSpacing: 0.5,
  );
  
  static const TextStyle buttonSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    letterSpacing: 0.3,
  );
  
  // Caption
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: Colors.white54,
    letterSpacing: 0.3,
  );
  
  // Special Styles
  static const TextStyle emoji = TextStyle(
    fontSize: 30,
  );
  
  static const TextStyle emojiLarge = TextStyle(
    fontSize: 50,
  );
  
  static const TextStyle label = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: 0.5,
  );
}