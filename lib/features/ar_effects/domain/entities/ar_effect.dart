import 'package:flutter/material.dart';

enum EffectType { germ, clean }

class AREffect {
  final String id;
  final String icon;
  Offset position;
  Offset targetPosition;
  double scale;
  double rotation;
  Offset velocity;
  final EffectType type;
  
  AREffect({
    required this.id,
    required this.icon,
    required this.position,
    required this.targetPosition,
    required this.scale,
    required this.rotation,
    required this.velocity,
    required this.type,
  });
  
  AREffect copyWith({
    String? id,
    String? icon,
    Offset? position,
    Offset? targetPosition,
    double? scale,
    double? rotation,
    Offset? velocity,
    EffectType? type,
  }) {
    return AREffect(
      id: id ?? this.id,
      icon: icon ?? this.icon,
      position: position ?? this.position,
      targetPosition: targetPosition ?? this.targetPosition,
      scale: scale ?? this.scale,
      rotation: rotation ?? this.rotation,
      velocity: velocity ?? this.velocity,
      type: type ?? this.type,
    );
  }
}