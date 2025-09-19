import 'package:flutter/services.dart';

enum SoundEffect {
  capture,
  modeSwitch,
  success,
  error,
  bubble,
  sparkle,
  germ,
  clean,
}

class AudioService {
  bool _enabled = true;
  
  bool get enabled => _enabled;
  set enabled(bool value) => _enabled = value;
  
  Future<void> initialize() async {
    // TODO: Initialize audio players if using audio packages
    // For now, we'll use system sounds
  }
  
  Future<void> playSound(SoundEffect effect) async {
    if (!_enabled) return;
    
    // Use system sounds for now
    switch (effect) {
      case SoundEffect.capture:
        await SystemSound.play(SystemSoundType.click);
        break;
      case SoundEffect.modeSwitch:
        HapticFeedback.lightImpact();
        break;
      case SoundEffect.success:
        HapticFeedback.heavyImpact();
        break;
      case SoundEffect.error:
        HapticFeedback.vibrate();
        break;
      case SoundEffect.bubble:
      case SoundEffect.sparkle:
      case SoundEffect.germ:
      case SoundEffect.clean:
        // TODO: Implement custom sounds
        await SystemSound.play(SystemSoundType.click);
        break;
    }
  }
  
  void dispose() {
    // TODO: Dispose audio players if using audio packages
  }
}