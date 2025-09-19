import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class MediaPipeProvider extends ChangeNotifier {
  // 모든 감지된 포인트들 (신체 부위 구분 없이)
  List<Offset> _detectedPoints = [];
  bool _isProcessing = false;
  
  // Getters
  List<Offset> get detectedPoints => _detectedPoints;
  bool get isProcessing => _isProcessing;
  
  Future<void> processImage(CameraImage image) async {
    if (_isProcessing) return;
    
    _isProcessing = true;
    notifyListeners();
    
    try {
      // TODO: 실제 MediaPipe 처리
      // 현재는 테스트용 mock 데이터
      await _processMockImage(image);
    } catch (e) {
      debugPrint('Error processing image: $e');
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }
  
  // Mock processing - 실제로는 MediaPipe가 신체 부위를 자동 감지
  Future<void> _processMockImage(CameraImage image) async {
    // 처리 시간 시뮬레이션
    await Future.delayed(const Duration(milliseconds: 50));
    
    // Mock 감지 포인트 생성 (신체 부위 자동 감지 시뮬레이션)
    _detectedPoints.clear();
    
    // 랜덤하게 감지된 포인트들 생성 (실제로는 MediaPipe가 자동으로 감지)
    final random = DateTime.now().millisecondsSinceEpoch % 3;
    
    if (random == 0) {
      // 손 영역 감지
      _detectedPoints = List.generate(5, (index) {
        return Offset(
          200 + (index % 3) * 30.0,
          300 + (index ~/ 3) * 30.0,
        );
      });
    } else if (random == 1) {
      // 얼굴 영역 감지
      _detectedPoints = List.generate(5, (index) {
        return Offset(
          180 + (index % 3) * 40.0,
          150 + (index ~/ 3) * 40.0,
        );
      });
    } else {
      // 전신 영역 감지
      _detectedPoints = List.generate(10, (index) {
        return Offset(
          150 + (index % 4) * 50.0,
          100 + (index ~/ 4) * 80.0,
        );
      });
    }
  }
  
  void updateDetectedPoints(List<Offset> points) {
    _detectedPoints = points;
    notifyListeners();
  }
  
  void clearDetectedPoints() {
    _detectedPoints.clear();
    notifyListeners();
  }
  
  // 정규화된 좌표를 화면 좌표로 변환
  List<Offset> normalizedToScreen(List<Offset> normalized, Size screenSize) {
    return normalized.map((point) {
      return Offset(
        point.dx * screenSize.width,
        point.dy * screenSize.height,
      );
    }).toList();
  }
  
  // 감지된 영역이 있는지 확인
  bool hasDetectedBody() {
    return _detectedPoints.isNotEmpty;
  }
  
  // 감지된 영역의 중심점 계산
  Offset? getDetectedCenter() {
    if (_detectedPoints.isEmpty) return null;
    
    double sumX = 0;
    double sumY = 0;
    for (var point in _detectedPoints) {
      sumX += point.dx;
      sumY += point.dy;
    }
    
    return Offset(
      sumX / _detectedPoints.length,
      sumY / _detectedPoints.length,
    );
  }
}