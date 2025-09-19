import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../../../../providers/ar_effects_provider.dart';
import '../../../../providers/app_state_provider.dart';
import '../../../../providers/mediapipe_provider.dart';
import '../../domain/entities/ar_effect.dart';

class AROverlay extends StatefulWidget {
  const AROverlay({Key? key}) : super(key: key);

  @override
  State<AROverlay> createState() => _AROverlayState();
}

class _AROverlayState extends State<AROverlay>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    _startEffectUpdateLoop();
  }
  
  void _startEffectUpdateLoop() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      
      final mediapipeProvider = context.read<MediaPipeProvider>();
      final arProvider = context.read<AREffectsProvider>();
      
      // MediaPipe가 자동으로 감지한 신체 부위 포인트들 가져오기
      final detectedPoints = mediapipeProvider.detectedPoints;
      
      // 감지된 포인트 주변으로 효과 업데이트
      arProvider.updateEffectPositions(
        detectedPoints.isEmpty ? null : detectedPoints,
      );
      
      // Continue loop
      _startEffectUpdateLoop();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Consumer2<AREffectsProvider, AppStateProvider>(
      builder: (context, arProvider, appState, child) {
        return Stack(
          children: [
            // AR Effects
            ...arProvider.effects.map((effect) {
              return _AREffectWidget(
                key: ValueKey(effect.id),
                effect: effect,
                floatValue: arProvider.floatValue,
                pulseValue: arProvider.pulseValue,
                rotationValue: arProvider.rotationValue,
                isCleanMode: appState.currentMode == AppMode.clean,
              );
            }).toList(),
            
            // Detection visualization (optional - for debugging)
            if (false) // Set to true to see detection points
              Consumer<MediaPipeProvider>(
                builder: (context, mediapipe, child) {
                  return CustomPaint(
                    size: Size.infinite,
                    painter: _DetectionPainter(
                      points: mediapipe.detectedPoints,
                    ),
                  );
                },
              ),
          ],
        );
      },
    );
  }
}

class _AREffectWidget extends StatelessWidget {
  final AREffect effect;
  final double floatValue;
  final double pulseValue;
  final double rotationValue;
  final bool isCleanMode;
  
  const _AREffectWidget({
    Key? key,
    required this.effect,
    required this.floatValue,
    required this.pulseValue,
    required this.rotationValue,
    required this.isCleanMode,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 100),
      left: effect.position.dx - 20,
      top: effect.position.dy + floatValue - 20,
      child: Transform.rotate(
        angle: isCleanMode
            ? rotationValue + effect.rotation
            : effect.rotation + math.sin(floatValue / 10) * 0.2,
        child: Transform.scale(
          scale: effect.scale * (isCleanMode ? pulseValue : 1.0),
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Glow effect for clean mode
                if (isCleanMode)
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.yellow.withOpacity(0.7),
                          blurRadius: 25,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                  ),
                // Shadow effect for dirty mode
                if (!isCleanMode)
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.purple.withOpacity(0.6),
                          blurRadius: 15,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                  ),
                // Main icon
                Text(
                  effect.icon,
                  style: TextStyle(
                    fontSize: 32,
                    shadows: [
                      Shadow(
                        color: isCleanMode
                            ? Colors.yellow.withOpacity(0.8)
                            : Colors.black.withOpacity(0.5),
                        blurRadius: isCleanMode ? 20 : 10,
                        offset: isCleanMode ? Offset.zero : const Offset(2, 2),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Optional: Painter to visualize detection points (for debugging)
class _DetectionPainter extends CustomPainter {
  final List<Offset> points;
  
  _DetectionPainter({required this.points});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green.withOpacity(0.5)
      ..strokeWidth = 2
      ..style = PaintingStyle.fill;
    
    for (var point in points) {
      canvas.drawCircle(point, 5, paint);
    }
  }
  
  @override
  bool shouldRepaint(_DetectionPainter oldDelegate) {
    return points != oldDelegate.points;
  }
}