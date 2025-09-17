import 'package:flutter/material.dart';

/// 반짝손AR 앱의 색상 테마 시스템
/// 더러운 모드와 깨끗한 모드에 따라 색상이 전환됩니다.
class AppColors {
  // 기본 앱 색상
  static const Color primaryColor = Color(0xFF4FC3F7); // 밝은 파란색 (깨끗함의 상징)
  static const Color secondaryColor = Color(0xFF81C784); // 연한 초록색 (자연스러움)
  
  /// 더러운 모드 색상 팔레트
  static const Color dirtyPrimary = Color(0xFF6D4C41); // 갈색 톤
  static const Color dirtySecondary = Color(0xFF8D6E63); // 어두운 갈색
  static const Color dirtyAccent = Color(0xFFBCAAA4); // 회갈색
  static const Color dirtyBackground = Color(0xFFF5F5DC); // 베이지
  static const Color dirtyIconColor = Color(0xFF5D4037); // 진한 갈색
  
  /// 깨끗한 모드 색상 팔레트  
  static const Color cleanPrimary = Color(0xFF4FC3F7); // 밝은 파란색
  static const Color cleanSecondary = Color(0xFF81C784); // 연한 초록색
  static const Color cleanAccent = Color(0xFFFFD54F); // 밝은 노란색 (반짝임)
  static const Color cleanBackground = Color(0xFFF0F9FF); // 아주 연한 파란색
  static const Color cleanIconColor = Color(0xFF0277BD); // 진한 파란색
  
  /// 공통 색상
  static const Color textPrimary = Color(0xFF212121); // 진한 회색
  static const Color textSecondary = Color(0xFF757575); // 중간 회색
  static const Color white = Color(0xFFFFFFFF);
  static const Color shadow = Color(0x1A000000); // 투명한 검은색
  
  /// 상태별 색상
  static const Color success = Color(0xFF4CAF50); // 성공 (초록)
  static const Color warning = Color(0xFFFF9800); // 경고 (주황)
  static const Color error = Color(0xFFF44336); // 오류 (빨강)
  
  /// 모드별 ColorScheme 생성 함수
  static ColorScheme getDirtyModeColorScheme() {
    return ColorScheme.light(
      primary: dirtyPrimary,
      secondary: dirtySecondary,
      tertiary: dirtyAccent,
      surface: dirtyBackground,
      onPrimary: white,
      onSecondary: white,
      onSurface: textPrimary,
    );
  }
  
  static ColorScheme getCleanModeColorScheme() {
    return ColorScheme.light(
      primary: cleanPrimary,
      secondary: cleanSecondary,
      tertiary: cleanAccent,
      surface: cleanBackground,
      onPrimary: white,
      onSecondary: white,
      onSurface: textPrimary,
    );
  }
}