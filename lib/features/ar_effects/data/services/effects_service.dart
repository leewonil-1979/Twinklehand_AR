import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../domain/entities/ar_effect.dart';
import '../../../../providers/app_state_provider.dart';

class EffectsService {
  final _random = math.Random();
  
  List<AREffect> generateEffects({
    required String icon,
    required int count,
    required AppMode mode,
    required Size screenSize,
  }) {
    final effects = <AREffect>[];
    
    for (int i = 0; i < count; i++) {
      effects.add(_createEffect(
        id: 'effect_${DateTime.now().millisecondsSinceEpoch}_$i',
        icon: icon,
        mode: mode,
        screenSize: screenSize,
      ));
    }
    
    return effects;
  }
  
  AREffect _createEffect({
    required String id,
    required String icon,
    required AppMode mode,
    required Size screenSize,
  }) {
    // Random position across the entire screen
    final position = Offset(
      _random.nextDouble() * screenSize.width,
      _random.nextDouble() * screenSize.height,
    );
    
    return AREffect(
      id: id,
      icon: icon,
      position: position,
      targetPosition: position,
      scale: 0.5 + _random.nextDouble() * 0.8,
      rotation: _random.nextDouble() * 2 * math.pi,
      velocity: Offset(
        (_random.nextDouble() - 0.5) * 3,
        (_random.nextDouble() - 0.5) * 3,
      ),
      type: mode == AppMode.clean ? EffectType.clean : EffectType.germ,
    );
  }
  
  void updateEffectPositions(
    List<AREffect> effects,
    List<Offset>? detectedPoints,
    Size screenSize,
  ) {
    if (detectedPoints == null || detectedPoints.isEmpty) {
      // No detection - effects float freely
      for (var effect in effects) {
        _updateFloatingPosition(effect, screenSize);
      }
    } else {
      // Detection found - effects gather around detected areas
      for (var effect in effects) {
        _updateTowardsDetection(effect, detectedPoints);
      }
    }
  }
  
  void _updateFloatingPosition(AREffect effect, Size screenSize) {
    // Update position with velocity
    effect.position = Offset(
      effect.position.dx + effect.velocity.dx,
      effect.position.dy + effect.velocity.dy,
    );
    
    // Bounce off screen edges
    if (effect.position.dx <= 0 || effect.position.dx >= screenSize.width) {
      effect.velocity = Offset(-effect.velocity.dx, effect.velocity.dy);
    }
    if (effect.position.dy <= 0 || effect.position.dy >= screenSize.height) {
      effect.velocity = Offset(effect.velocity.dx, -effect.velocity.dy);
    }
    
    // Keep within bounds
    effect.position = Offset(
      effect.position.dx.clamp(0, screenSize.width),
      effect.position.dy.clamp(0, screenSize.height),
    );
    
    // Slowly rotate while floating
    effect.rotation += 0.02;
  }
  
  void _updateTowardsDetection(AREffect effect, List<Offset> detectedPoints) {
    // Find nearest detected point
    Offset nearestPoint = detectedPoints.first;
    double minDistance = double.infinity;
    
    for (var point in detectedPoints) {
      final distance = (effect.position - point).distance;
      if (distance < minDistance) {
        minDistance = distance;
        nearestPoint = point;
      }
    }
    
    // Create cluster around detected points with more spread
    effect.targetPosition = nearestPoint + Offset(
      (_random.nextDouble() - 0.5) * 120, // Wider spread for baby-friendly view
      (_random.nextDouble() - 0.5) * 120,
    );
    
    // Smooth movement towards target
    effect.position = Offset.lerp(
      effect.position,
      effect.targetPosition,
      0.06, // Slower, smoother movement for babies
    )!;
    
    // Gentle rotation when near detection
    if (minDistance < 150) {
      effect.rotation += 0.03;
    }
  }
  
  void animateCleanEffects(List<AREffect> effects, double animationValue) {
    for (var effect in effects) {
      if (effect.type == EffectType.clean) {
        // Sparkle rotation
        effect.rotation = animationValue * 2 * math.pi;
        
        // Gentle pulse
        effect.scale = (0.7 + math.sin(animationValue * 2 * math.pi) * 0.3) * 
                      (0.5 + _random.nextDouble() * 0.8);
      }
    }
  }
  
  void animateDirtyEffects(List<AREffect> effects, double animationValue) {
    for (var effect in effects) {
      if (effect.type == EffectType.germ) {
        // Wiggle effect
        effect.rotation += math.sin(animationValue * 4 * math.pi) * 0.03;
        
        // Slight breathing effect
        effect.scale = (0.85 + math.sin(animationValue * math.pi) * 0.15) * 
                      (0.5 + _random.nextDouble() * 0.8);
      }
    }
  }
  
  // Special effect for photo capture
  void createCaptureEffect(List<AREffect> effects) {
    for (var effect in effects) {
      // Quick scale up
      effect.scale *= 1.3;
      // Spin
      effect.rotation += math.pi / 4;
    }
  }
  
  void resetCaptureEffect(List<AREffect> effects) {
    for (var effect in effects) {
      // Scale back down
      effect.scale /= 1.3;
    }
  }
}