import 'package:flutter/material.dart';
import '../core/constants/app_icons.dart';

enum AppMode { dirty, clean }

class AppStateProvider extends ChangeNotifier {
  // Current state
  AppMode _currentMode = AppMode.dirty;
  String _selectedDirtyIcon = AppIcons.dirtyIcons[0];
  String _selectedCleanIcon = AppIcons.cleanIcons[0];
  bool _isCapturing = false;
  double _zoomLevel = 1.0;
  
  // User preferences
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _isPremium = false;
  
  // Getters
  AppMode get currentMode => _currentMode;
  String get selectedDirtyIcon => _selectedDirtyIcon;
  String get selectedCleanIcon => _selectedCleanIcon;
  bool get isCapturing => _isCapturing;
  double get zoomLevel => _zoomLevel;
  bool get soundEnabled => _soundEnabled;
  bool get vibrationEnabled => _vibrationEnabled;
  bool get isPremium => _isPremium;
  
  // Get current icon based on mode
  String get currentIcon {
    return _currentMode == AppMode.clean ? _selectedCleanIcon : _selectedDirtyIcon;
  }
  
  // Get icon list based on mode
  List<String> get currentIconList {
    return _currentMode == AppMode.dirty ? AppIcons.dirtyIcons : AppIcons.cleanIcons;
  }
  
  // Actions
  void toggleMode() {
    _currentMode = _currentMode == AppMode.clean ? AppMode.dirty : AppMode.clean;
    notifyListeners();
  }
  
  void selectDirtyIcon(String icon) {
    _selectedDirtyIcon = icon;
    notifyListeners();
  }
  
  void selectCleanIcon(String icon) {
    _selectedCleanIcon = icon;
    notifyListeners();
  }
  
  void setCapturing(bool capturing) {
    _isCapturing = capturing;
    notifyListeners();
  }
  
  void setZoomLevel(double level) {
    _zoomLevel = level;
    notifyListeners();
  }
  
  void toggleSound() {
    _soundEnabled = !_soundEnabled;
    notifyListeners();
  }
  
  void toggleVibration() {
    _vibrationEnabled = !_vibrationEnabled;
    notifyListeners();
  }
  
  void setPremium(bool premium) {
    _isPremium = premium;
    notifyListeners();
  }
  
  // Get current mode label
  String getModeLabel() {
    return _currentMode == AppMode.clean ? '깨끗' : '더러움';
  }
}