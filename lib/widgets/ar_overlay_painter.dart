import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/app_icon.dart';
import '../utils/app_colors.dart';

/// AR ?�버?�이�?그리??CustomPainter
/// ?�택???�이콘을 ?�면 중앙???�시?�고 반짝???�과 추�?
class AROverlayPainter extends CustomPainter {
  final AppIcon icon;
  final bool isCleanMode;
  final double animationValue;

  AROverlayPainter({
    required this.icon,
    required this.isCleanMode,
    this.animationValue = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // 배경 ??그리�?(반투�?
    final backgroundPaint = Paint()
      ..color = (isCleanMode ? AppColors.cleanAccent : AppColors.dirtyAccent)
          .withOpacity(0.3 * animationValue)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, backgroundPaint);

    // ?�두�???그리�?
    final borderPaint = Paint()
      ..color = (isCleanMode ? AppColors.cleanPrimary : AppColors.dirtyPrimary)
          .withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    canvas.drawCircle(center, radius - 1.5, borderPaint);

    // ?�이�?모양 그리�?(?�시�?기본 ?�형 ?�용)
    _drawIconShape(canvas, center, radius * 0.6);

    // 반짝???�과 (깨끗??모드???�만)
    if (isCleanMode && animationValue > 0.5) {
      _drawSparkleEffect(canvas, center, radius);
    }
  }

  /// ?�이�?모양??그리??메서??
  void _drawIconShape(Canvas canvas, Offset center, double size) {
    final iconPaint = Paint()
      ..color = isCleanMode ? AppColors.cleanIconColor : AppColors.dirtyIconColor
      ..style = PaintingStyle.fill;

    switch (icon.name) {
      case 'bacteria_1':
      case 'bacteria_2':
        _drawBacteriaShape(canvas, center, size, iconPaint);
        break;
      case 'virus_1':
        _drawVirusShape(canvas, center, size, iconPaint);
        break;
      case 'germs_1':
        _drawGermsShape(canvas, center, size, iconPaint);
        break;
      case 'sparkle_1':
      case 'sparkle_2':
        _drawSparkleShape(canvas, center, size, iconPaint);
        break;
      case 'star_1':
        _drawStarShape(canvas, center, size, iconPaint);
        break;
      case 'bubble_1':
        _drawBubbleShape(canvas, center, size, iconPaint);
        break;
      case 'heart_1':
        _drawHeartShape(canvas, center, size, iconPaint);
        break;
      default:
        canvas.drawCircle(center, size / 2, iconPaint);
    }
  }

  /// ?�균 모양 그리�?
  void _drawBacteriaShape(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    path.addOval(Rect.fromCenter(center: center, width: size, height: size * 0.7));
    canvas.drawPath(path, paint);
    
    // ?�균???�기??
    for (int i = 0; i < 8; i++) {
      final angle = (i * 45) * (3.14159 / 180);
      final x = center.dx + (size / 2 + 8) * cos(angle);
      final y = center.dy + (size / 2 + 8) * sin(angle);
      canvas.drawCircle(Offset(x, y), 3, paint);
    }
  }

  /// 바이?�스 모양 그리�?
  void _drawVirusShape(Canvas canvas, Offset center, double size, Paint paint) {
    canvas.drawCircle(center, size / 2, paint);
    
    // 바이?�스???�파?�크
    final spikePaint = Paint()
      ..color = paint.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
      
    for (int i = 0; i < 12; i++) {
      final angle = (i * 30) * (3.14159 / 180);
      final startX = center.dx + (size / 2) * cos(angle);
      final startY = center.dy + (size / 2) * sin(angle);
      final endX = center.dx + (size / 2 + 12) * cos(angle);
      final endY = center.dy + (size / 2 + 12) * sin(angle);
      
      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), spikePaint);
    }
  }

  /// �?모양 그리�?
  void _drawGermsShape(Canvas canvas, Offset center, double size, Paint paint) {
    for (int i = 0; i < 5; i++) {
      final offset = Offset(
        center.dx + (i - 2) * (size / 6),
        center.dy + (i % 2 == 0 ? -5 : 5),
      );
      canvas.drawCircle(offset, size / 8, paint);
    }
  }

  /// 반짝??모양 그리�?
  void _drawSparkleShape(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    
    // 4개의 뾰족???�이 ?�는 �?모양
    for (int i = 0; i < 4; i++) {
      final angle = (i * 90) * (3.14159 / 180);
      final x = center.dx + (size / 2) * cos(angle);
      final y = center.dy + (size / 2) * sin(angle);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      
      // 중간??
      final midAngle = ((i * 90) + 45) * (3.14159 / 180);
      final midX = center.dx + (size / 4) * cos(midAngle);
      final midY = center.dy + (size / 4) * sin(midAngle);
      path.lineTo(midX, midY);
    }
    
    path.close();
    canvas.drawPath(path, paint);
  }

  /// �?모양 그리�?
  void _drawStarShape(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    final outerRadius = size / 2;
    final innerRadius = size / 4;
    
    for (int i = 0; i < 10; i++) {
      final angle = (i * 36) * (3.14159 / 180);
      final radius = i % 2 == 0 ? outerRadius : innerRadius;
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    
    path.close();
    canvas.drawPath(path, paint);
  }

  /// 거품 모양 그리�?
  void _drawBubbleShape(Canvas canvas, Offset center, double size, Paint paint) {
    // ??거품
    canvas.drawCircle(center, size / 2, paint);
    
    // ?��? 거품??
    canvas.drawCircle(
      Offset(center.dx - size / 3, center.dy - size / 4), 
      size / 6, 
      paint,
    );
    canvas.drawCircle(
      Offset(center.dx + size / 4, center.dy - size / 3), 
      size / 8, 
      paint,
    );
  }

  /// ?�트 모양 그리�?
  void _drawHeartShape(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    
    // ?�트 모양 경로
    path.moveTo(center.dx, center.dy + size / 4);
    
    path.cubicTo(
      center.dx - size / 2, center.dy - size / 4,
      center.dx - size / 2, center.dy - size / 2,
      center.dx, center.dy - size / 8,
    );
    
    path.cubicTo(
      center.dx + size / 2, center.dy - size / 2,
      center.dx + size / 2, center.dy - size / 4,
      center.dx, center.dy + size / 4,
    );
    
    canvas.drawPath(path, paint);
  }

  /// 반짝???�과 그리�?
  void _drawSparkleEffect(Canvas canvas, Offset center, double radius) {
    final sparklePaint = Paint()
      ..color = AppColors.cleanAccent.withOpacity(0.8 * animationValue)
      ..style = PaintingStyle.fill;

    // ?��? 반짝?�들
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60 + animationValue * 360) * (3.14159 / 180);
      final distance = radius * 0.8;
      final x = center.dx + distance * cos(angle);
      final y = center.dy + distance * sin(angle);
      
      canvas.drawCircle(Offset(x, y), 3 * animationValue, sparklePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate != this;
  }
}

// Helper functions for trigonometry
double cos(double radians) => math.cos(radians);
double sin(double radians) => math.sin(radians);
