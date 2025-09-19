import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../features/ar_effects/domain/entities/ar_effect.dart';
import 'app_state_provider.dart';

class AREffectsProvider extends ChangeNotifier {
  List<AREffect> _effects = [];
  final _random = math.Random();
  Size _screenSize = Size.zero;
  
  // Animation values
  double _floatValue = 0.0;
  double _pulseValue = 1.0;
  double _rotationValue = 0.0;
  
  List<AREffect> get effects => _effects;
  double get floatValue => _floatValue;
  double get pulseValue => _pulseValue;
  double get rotationValue => _rotationValue;
  
  void setScreenSize(Size size) {
    _screenSize = size;
  }
  
  void generateEffects({
    required String icon,
    required int count,
    required AppMode mode,
  }) {
    _effects.clear();
    
    for (int i = 0; i < count; i++) {
      _effects.add(
        AREffect(
          id: 'effect_$i',
          icon: icon,
          position: _getRandomPosition(),
          targetPosition: _getRandomPosition(),
          scale: 0.6 + _random.nextDouble() * 0.8,
          rotation: _random.nextDouble() * 2 * math.pi,
          velocity: Offset(
            (_random.nextDouble() - 0.5) * 2,
            (_random.nextDouble() - 0.5) * 2,
          ),
          type: mode == AppMode.clean ? EffectType.clean : EffectType.germ,
        ),
      );
    }
    
    notifyListeners();
  }
  
  Offset _getRandomPosition() {
    if (_screenSize == Size.zero) {
      return const Offset(100, 100);
    }
    
    // 화면 전체에 랜덤하게 배치
    return Offset(
      _random.nextDouble() * _screenSize.width,
      _random.nextDouble() * _screenSize.height,
    );
  }
  
  void updateEffectPositions(List<Offset>? detectedPoints) {
    if (detectedPoints == null || detectedPoints.isEmpty) {
      // 감지된 포인트가 없으면 자유롭게 떠다님
      for (var effect in _effects) {
        effect.position = Offset(
          effect.position.dx + effect.velocity.dx,
          effect.position.dy + effect.velocity.dy,
        );
        
        // 화면 가장자리에서 반사
        if (effect.position.dx < 0 || effect.position.dx > _screenSize.width) {
          effect.velocity = Offset(-effect.velocity.dx, effect.velocity.dy);
        }
        if (effect.position.dy < 0 || effect.position.dy > _screenSize.height) {
          effect.velocity = Offset(effect.velocity.dx, -effect.velocity.dy);
        }
      }
    } else {
      // 감지된 포인트 주변으로 모임
      for (var effect in _effects) {
        // 가장 가까운 감지 포인트 찾기
        Offset nearestPoint = detectedPoints.first;
        double minDistance = double.infinity;
        
        for (var point in detectedPoints) {
          final distance = (effect.position - point).distance;
          if (distance < minDistance) {
            minDistance = distance;
            nearestPoint = point;
          }
        }
        
        // 감지 포인트 주변으로 이동
        effect.targetPosition = nearestPoint + Offset(
          (_random.nextDouble() - 0.5) * 100,
          (_random.nextDouble() - 0.5) * 100,
        );
        
        // 부드러운 이동
        effect.position = Offset.lerp(
          effect.position,
          effect.targetPosition,
          0.1,
        )!;
      }
    }
    
    notifyListeners();
  }
  
  void updateAnimationValues({
    required double float,
    required double pulse,
    required double rotation,
  }) {
    _floatValue = float;
    _pulseValue = pulse;
    _rotationValue = rotation;
    notifyListeners();
  }
  
  void addEffect(AREffect effect) {
    _effects.add(effect);
    notifyListeners();
  }
  
  void removeEffect(String id) {
    _effects.removeWhere((effect) => effect.id == id);
    notifyListeners();
  }
  
  void clearEffects() {
    _effects.clear();
    notifyListeners();
  }
  
  void scaleAllEffects(double scale) {
    for (var effect in _effects) {
      effect.scale *= scale;
    }
    notifyListeners();
  }
}