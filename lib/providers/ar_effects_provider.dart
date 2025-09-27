import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../features/ar_effects/domain/entities/ar_effect.dart';
import 'app_state_provider.dart';

class AREffectsProvider extends ChangeNotifier {
  List<AREffect> _effects = [];
  final _random = math.Random();
  Size _screenSize = Size.zero;
  double _zoomLevel = 1.0; // 현재 줌 레벨
  
  // Animation values
  double _floatValue = 0.0;
  double _pulseValue = 1.0;
  double _rotationValue = 0.0;
  
  List<AREffect> get effects => _effects;
  double get floatValue => _floatValue;
  double get pulseValue => _pulseValue;
  double get rotationValue => _rotationValue;
  double get zoomLevel => _zoomLevel;
  
  void setScreenSize(Size size) {
    _screenSize = size;
  }
  
  void generateEffects({
    required String icon,
    required int count,
    required AppMode mode,
    List<Offset>? anchors,
  }) {
    _effects.clear();
    final anchorList = anchors ?? const <Offset>[];
    final hasAnchors = anchorList.isNotEmpty;

    for (int i = 0; i < count; i++) {
      final baseScale = 0.6 + _random.nextDouble() * 0.8;
      final spawnPosition = hasAnchors
          ? _jitteredAnchor(anchorList, i)
          : _getRandomPosition();
      _effects.add(
        AREffect(
          id: 'effect_$i',
          icon: icon,
          position: _clampToScreen(spawnPosition),
          targetPosition: _clampToScreen(spawnPosition),
          scale: getZoomAdjustedScale(baseScale),
          rotation: _random.nextDouble() * 2 * math.pi,
          velocity: Offset.zero,
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
      if (_effects.isEmpty) return;
      _effects.clear();
      notifyListeners();
      return;
    } else {
      // 감지된 포인트 주변으로 즉시 이동
      for (int i = 0; i < _effects.length; i++) {
        final effect = _effects[i];
        
        // 각 효과를 다른 감지 포인트에 할당
        final targetPointIndex = i % detectedPoints.length;
        final targetPoint = detectedPoints[targetPointIndex];
        
        // 타겟 포인트 주변에 약간의 랜덤 오프셋 추가 (손가락 주변에 분산)
        final randomOffset = Offset(
          (_random.nextDouble() - 0.5) * 80, // 80픽셀 반경 내에서 랜덤 배치
          (_random.nextDouble() - 0.5) * 80,
        );
        
        effect.targetPosition = _clampToScreen(targetPoint + randomOffset);
        
        // 매우 빠른 이동으로 실시간 추적 느낌
        effect.position = Offset.lerp(
          effect.position,
          effect.targetPosition,
          0.25, // 더 빠른 추적
        )!;
        
        // 화면 경계 확인
        effect.position = _clampToScreen(effect.position);
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
  
  /// 줌 레벨 업데이트 (AR 효과 크기는 화면 기준으로 유지)
  void updateZoomLevel(double zoomLevel) {
    if ((_zoomLevel - zoomLevel).abs() < 0.0001) return;

    _zoomLevel = zoomLevel;
    notifyListeners();
  }
  
  /// 줌 기반 효과 크기 계산 (새로 생성되는 효과용)
  double getZoomAdjustedScale(double baseScale) {
    return baseScale;
  }

  Offset _jitteredAnchor(List<Offset> anchors, int index) {
    if (anchors.isEmpty) {
      return _getRandomPosition();
    }
    final anchor = anchors[index % anchors.length];
    final jitter = Offset(
      (_random.nextDouble() - 0.5) * 60,
      (_random.nextDouble() - 0.5) * 60,
    );
    return anchor + jitter;
  }

  Offset _clampToScreen(Offset position) {
    if (_screenSize == Size.zero) {
      return position;
    }
    return Offset(
      position.dx.clamp(0, _screenSize.width),
      position.dy.clamp(0, _screenSize.height),
    );
  }
}