import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  final SharedPreferences _prefs;
  
  StorageService(this._prefs);
  
  // Keys - TwinkleHands 전용
  static const String keyIsPremium = 'twinkle_is_premium';
  static const String keySoundEnabled = 'twinkle_sound_enabled';
  static const String keyVibrationEnabled = 'twinkle_vibration_enabled';
  static const String keyFirstLaunch = 'twinkle_first_launch';
  static const String keyPhotoCount = 'twinkle_photo_count';
  static const String keyLastAdShown = 'twinkle_last_ad_shown';
  static const String keySelectedLanguage = 'twinkle_selected_language';
  static const String keyTotalCleanTime = 'twinkle_total_clean_time';
  
  // Premium status
  bool get isPremium => _prefs.getBool(keyIsPremium) ?? false;
  Future<void> setPremium(bool value) => _prefs.setBool(keyIsPremium, value);
  
  // Sound settings
  bool get soundEnabled => _prefs.getBool(keySoundEnabled) ?? true;
  Future<void> setSoundEnabled(bool value) => _prefs.setBool(keySoundEnabled, value);
  
  // Vibration settings
  bool get vibrationEnabled => _prefs.getBool(keyVibrationEnabled) ?? true;
  Future<void> setVibrationEnabled(bool value) => _prefs.setBool(keyVibrationEnabled, value);
  
  // First launch
  bool get isFirstLaunch => _prefs.getBool(keyFirstLaunch) ?? true;
  Future<void> setFirstLaunch(bool value) => _prefs.setBool(keyFirstLaunch, value);
  
  // Photo count
  int get photoCount => _prefs.getInt(keyPhotoCount) ?? 0;
  Future<void> incrementPhotoCount() async {
    final current = photoCount;
    await _prefs.setInt(keyPhotoCount, current + 1);
  }
  
  // Total clean time (in seconds)
  int get totalCleanTime => _prefs.getInt(keyTotalCleanTime) ?? 0;
  Future<void> addCleanTime(int seconds) async {
    final current = totalCleanTime;
    await _prefs.setInt(keyTotalCleanTime, current + seconds);
  }
  
  // Ad timing
  DateTime? get lastAdShown {
    final timestamp = _prefs.getInt(keyLastAdShown);
    return timestamp != null ? DateTime.fromMillisecondsSinceEpoch(timestamp) : null;
  }
  
  Future<void> setLastAdShown(DateTime time) async {
    await _prefs.setInt(keyLastAdShown, time.millisecondsSinceEpoch);
  }
  
  bool shouldShowAd() {
    final last = lastAdShown;
    if (last == null) return true;
    
    // Show ad every 5 photos or every 3 minutes
    final timePassed = DateTime.now().difference(last).inMinutes >= 3;
    final photosPassed = photoCount % 5 == 0;
    
    return timePassed || photosPassed;
  }
  
  // Language
  String get selectedLanguage => _prefs.getString(keySelectedLanguage) ?? 'ko';
  Future<void> setSelectedLanguage(String lang) => _prefs.setString(keySelectedLanguage, lang);
  
  // Clear all data
  Future<void> clearAll() => _prefs.clear();
}