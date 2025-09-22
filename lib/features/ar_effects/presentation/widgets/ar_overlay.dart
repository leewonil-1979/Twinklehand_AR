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
      final appState = context.read<AppStateProvider>();
      
      // MediaPipe에서 실제 손 랜드마크 데이터 가져오기
      final handLandmarks = mediapipeProvider.handLandmarks;
      final screenSize = MediaQuery.of(context).size;
      
      if (handLandmarks.isNotEmpty) {
        // 손 랜드마크를 화면 좌표로 변환
        final screenLandmarks = handLandmarks.map((landmark) {
          return landmark.toScreenOffset(screenSize);
        }).toList();
        
        // 손가락 끝과 손바닥 중심 위치 가져오기
        final fingerTips = mediapipeProvider.getFingerTips()
            .map((tip) => tip.toScreenOffset(screenSize))
            .toList();
        
        final palmCenter = mediapipeProvider.getPalmCenter(screenSize);
        
        // AR 효과 위치 업데이트
        if (palmCenter != null) {
          arProvider.updateEffectPositions([palmCenter, ...fingerTips]);
        } else {
          arProvider.updateEffectPositions(screenLandmarks);
        }
        
        // 청결도 모드에 따른 효과 생성
        final isCleanMode = mediapipeProvider.isCleanMode;
        if (appState.currentMode != (isCleanMode ? AppMode.clean : AppMode.dirty)) {
          // 감지된 청결도에 따라 모드 변경
          appState.setMode(isCleanMode ? AppMode.clean : AppMode.dirty);
          
          // 새로운 모드에 맞는 효과 생성
          arProvider.generateEffects(
            icon: appState.currentIcon,
            count: isCleanMode ? 12 : 20,
            mode: appState.currentMode,
          );
        }
      } else {
        // 손이 감지되지 않으면 기본 위치에 효과 생성
        arProvider.updateEffectPositions(null);
      }
      
      // Continue loop
      _startEffectUpdateLoop();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Consumer3<AREffectsProvider, AppStateProvider, MediaPipeProvider>(
      builder: (context, arProvider, appState, mediapipe, child) {
        return Stack(
          children: [
            // Hand Landmark Visualization (실제 손 랜드마크 표시)
            CustomPaint(
              size: Size.infinite,
              painter: _HandLandmarkPainter(
                landmarks: mediapipe.handLandmarks,
                screenSize: MediaQuery.of(context).size,
                isCleanMode: mediapipe.isCleanMode,
                leftHandTrail: mediapipe.leftHandTrail,
                rightHandTrail: mediapipe.rightHandTrail,
              ),
            ),
            
            // AR Effects (파티클 효과)
            ...arProvider.effects.map((effect) {
              return _AREffectWidget(
                key: ValueKey(effect.id),
                effect: effect,
                floatValue: arProvider.floatValue,
                pulseValue: arProvider.pulseValue,
                rotationValue: arProvider.rotationValue,
                isCleanMode: mediapipe.isCleanMode,
                cleanlinessScore: mediapipe.cleanlinessScore,
              );
            }).toList(),
            
            // Cleanliness Score Indicator
            if (mediapipe.hasDetectedHands())
              Positioned(
                top: 120,
                left: 20,
                child: _CleanlinessIndicator(
                  score: mediapipe.cleanlinessScore,
                  isCleanMode: mediapipe.isCleanMode,
                ),
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
  final double cleanlinessScore;
  
  const _AREffectWidget({
    Key? key,
    required this.effect,
    required this.floatValue,
    required this.pulseValue,
    required this.rotationValue,
    required this.isCleanMode,
    required this.cleanlinessScore,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    // 청결도 점수에 따른 투명도 및 크기 조절
    final opacity = math.max(0.3, cleanlinessScore);
    final sizeMultiplier = 0.5 + (cleanlinessScore * 0.5);
    
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 100),
      left: effect.position.dx - 20,
      top: effect.position.dy + floatValue - 20,
      child: Transform.rotate(
        angle: isCleanMode
            ? rotationValue + effect.rotation
            : effect.rotation + math.sin(floatValue / 10) * 0.2,
        child: Transform.scale(
          scale: effect.scale * sizeMultiplier * (isCleanMode ? pulseValue : 1.0),
          child: Opacity(
            opacity: opacity,
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
                            color: Colors.yellow.withValues(alpha: 0.7 * cleanlinessScore),
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
                            color: Colors.purple.withValues(alpha: 0.6 * (1 - cleanlinessScore)),
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
                              ? Colors.yellow.withValues(alpha: 0.8 * cleanlinessScore)
                              : Colors.black.withValues(alpha: 0.5 * (1 - cleanlinessScore)),
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
      ),
    );
  }
}

/// 실제 손 랜드마크를 시각화하는 페인터
class _HandLandmarkPainter extends CustomPainter {
  final List<dynamic> landmarks; // HandLandmark 타입
  final Size screenSize;
  final bool isCleanMode;
  final List<Offset> leftHandTrail;
  final List<Offset> rightHandTrail;
  
  _HandLandmarkPainter({
    required this.landmarks,
    required this.screenSize,
    required this.isCleanMode,
    required this.leftHandTrail,
    required this.rightHandTrail,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    // 손 트레일 그리기
  _drawHandTrail(canvas, leftHandTrail, Colors.blue.withValues(alpha: 0.5));
  _drawHandTrail(canvas, rightHandTrail, Colors.red.withValues(alpha: 0.5));
    
    // 손 랜드마크 점들 그리기
    final landmarkPaint = Paint()
      ..style = PaintingStyle.fill;
    
    final connectionPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
    ..color = isCleanMode 
      ? Colors.green.withValues(alpha: 0.6)
      : Colors.orange.withValues(alpha: 0.6);
    
    // 랜드마크 간의 연결선 그리기 (손의 구조)
    _drawHandConnections(canvas, connectionPaint);
    
    // 각 랜드마크 점 그리기
    for (var landmark in landmarks) {
      final screenPos = Offset(
        landmark.x * screenSize.width,
        landmark.y * screenSize.height,
      );
      
      // 랜드마크 타입에 따른 색상 결정
      Color pointColor;
      double pointSize;
      
      switch (landmark.index) {
        case 0: // 손목
          pointColor = Colors.red;
          pointSize = 8;
          break;
        case 4: case 8: case 12: case 16: case 20: // 손가락 끝
          pointColor = isCleanMode ? Colors.green : Colors.orange;
          pointSize = 6;
          break;
        default: // 기타 관절
          pointColor = Colors.blue;
          pointSize = 4;
          break;
      }
      
  landmarkPaint.color = pointColor.withValues(alpha: 0.8);
      canvas.drawCircle(screenPos, pointSize, landmarkPaint);
    }
  }
  
  void _drawHandTrail(Canvas canvas, List<Offset> trail, Color color) {
    if (trail.length < 2) return;
    
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    final path = Path();
    path.moveTo(trail.first.dx, trail.first.dy);
    
    for (int i = 1; i < trail.length; i++) {
      path.lineTo(trail[i].dx, trail[i].dy);
    }
    
    canvas.drawPath(path, paint);
  }
  
  void _drawHandConnections(Canvas canvas, Paint paint) {
    if (landmarks.length < 21) return;
    
    // 손목에서 각 손가락 기저부로의 연결 (손목 위치는 참조만 함)
    
    // 엄지 (1-4)
    for (int i = 1; i < 4; i++) {
      final current = Offset(landmarks[i].x * screenSize.width, landmarks[i].y * screenSize.height);
      final next = Offset(landmarks[i + 1].x * screenSize.width, landmarks[i + 1].y * screenSize.height);
      canvas.drawLine(current, next, paint);
    }
    
    // 검지 (5-8)
    for (int i = 5; i < 8; i++) {
      final current = Offset(landmarks[i].x * screenSize.width, landmarks[i].y * screenSize.height);
      final next = Offset(landmarks[i + 1].x * screenSize.width, landmarks[i + 1].y * screenSize.height);
      canvas.drawLine(current, next, paint);
    }
    
    // 중지 (9-12)
    for (int i = 9; i < 12; i++) {
      final current = Offset(landmarks[i].x * screenSize.width, landmarks[i].y * screenSize.height);
      final next = Offset(landmarks[i + 1].x * screenSize.width, landmarks[i + 1].y * screenSize.height);
      canvas.drawLine(current, next, paint);
    }
    
    // 약지 (13-16)
    for (int i = 13; i < 16; i++) {
      final current = Offset(landmarks[i].x * screenSize.width, landmarks[i].y * screenSize.height);
      final next = Offset(landmarks[i + 1].x * screenSize.width, landmarks[i + 1].y * screenSize.height);
      canvas.drawLine(current, next, paint);
    }
    
    // 새끼 (17-20)
    for (int i = 17; i < 20; i++) {
      final current = Offset(landmarks[i].x * screenSize.width, landmarks[i].y * screenSize.height);
      final next = Offset(landmarks[i + 1].x * screenSize.width, landmarks[i + 1].y * screenSize.height);
      canvas.drawLine(current, next, paint);
    }
  }
  
  @override
  bool shouldRepaint(_HandLandmarkPainter oldDelegate) {
    return landmarks != oldDelegate.landmarks ||
           isCleanMode != oldDelegate.isCleanMode ||
           leftHandTrail != oldDelegate.leftHandTrail ||
           rightHandTrail != oldDelegate.rightHandTrail;
  }
}

/// 청결도 점수 표시 위젯
class _CleanlinessIndicator extends StatelessWidget {
  final double score;
  final bool isCleanMode;
  
  const _CleanlinessIndicator({
    required this.score,
    required this.isCleanMode,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
  color: (isCleanMode ? Colors.green : Colors.orange).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isCleanMode ? Icons.cleaning_services : Icons.wash,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            '${(score * 100).toInt()}%',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}