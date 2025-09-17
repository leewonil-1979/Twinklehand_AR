/// 반짝손AR 앱의 상수 정의
class AppConstants {
  // 앱 정보
  static const String appName = '반짝손AR';
  static const String appNameEn = 'SparkleHand AR';
  static const String appVersion = '1.0.0';
  
  // AR 오버레이 설정
  static const double arIconSize = 80.0; // AR 아이콘 크기
  static const double arIconOpacity = 0.8; // AR 아이콘 투명도
  
  // UI 설정
  static const double iconGridHeight = 180.0; // 아이콘 그리드 높이 (높게)
  static const int iconsPerRow = 4; // 한 줄당 아이콘 개수 (모바일에 맞게)
  static const double captureButtonSize = 80.0; // 촬영 버튼 크기
  static const double borderRadius = 12.0; // 기본 모서리 둥글기
  
  // 카메라 설정
  static const double aspectRatio = 9.0 / 16.0; // 화면 비율 (9:16)
  static const int cameraFps = 30; // 프레임 레이트
  
  // 더러운 모드 아이콘 이름들(assets/images/dirty-icons/)
  static const List<String> dirtyIconNames = [
    'bacteria_1',
    'bacteria_2', 
    'virus_1',
    'virus_2',
    'germs_1',
    'dirt_1',
    'mud_1',
    'stain_1',
  ];
  
  // 깨끗한 모드 아이콘 이름들(assets/images/clean-icons/)
  static const List<String> cleanIconNames = [
    'sparkle_1',
    'sparkle_2',
    'star_1',
    'star_2',
    'bubble_1',
    'bubble_2',
    'heart_1',
    'shine_1',
  ];
  
  // 수익화 설정
  static const int freeUsageLimit = 10; // 무료 사용 한도 (10회)
  static const int adAfterCleanUsage = 1; // 깨끗한 상태에서 광고 표시 간격
  static const double premiumPrice = 1.0; // 프리미엄 가격($1)
  
  // 권한 요청 메시지
  static const String cameraPermissionMessage = 
      '손씻기 동영상을 촬영하기 위해 카메라 권한이 필요합니다';
  static const String storagePermissionMessage = 
      '촬영한 사진을 저장하기 위해 저장소 권한이 필요합니다';
  
  // 파일 경로
  static const String dirtyIconsPath = 'assets/images/dirty-icons/';
  static const String cleanIconsPath = 'assets/images/clean-icons/';
  static const String soundsPath = 'assets/sounds/';
  
  // SharedPreferences 키값들
  static const String keyUsageCount = 'usage_count';
  static const String keyIsPremium = 'is_premium';
  static const String keySelectedDirtyIcon = 'selected_dirty_icon';
  static const String keySelectedCleanIcon = 'selected_clean_icon';
  static const String keyIsCleanMode = 'is_clean_mode';
}
