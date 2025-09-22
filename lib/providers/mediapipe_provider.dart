import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../features/mediapipe/data/services/mediapipe_service.dart';

class MediaPipeProvider extends ChangeNotifier {
  final MediaPipeService _mediaPipeService = MediaPipeService();
  
  // 모든 감지된 손 랜드마크들
  List<HandLandmark> _handLandmarks = [];
  bool _isProcessing = false;
  bool _isInitialized = false;
  
  // 청결도 상태
  bool _isCleanMode = true;
  double _cleanlinessScore = 1.0;
  
  // 손 트레일 데이터
  List<Offset> _leftHandTrail = [];
  List<Offset> _rightHandTrail = [];
  
  // Getters
  List<HandLandmark> get handLandmarks => _handLandmarks;
  bool get isProcessing => _isProcessing;
  bool get isInitialized => _isInitialized;
  bool get isCleanMode => _isCleanMode;
  double get cleanlinessScore => _cleanlinessScore;
  List<Offset> get leftHandTrail => _leftHandTrail;
  List<Offset> get rightHandTrail => _rightHandTrail;
  
  /// MediaPipe 초기화
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      await _mediaPipeService.initialize();
      _isInitialized = true;
      notifyListeners();
      debugPrint('MediaPipeProvider 초기화 완료');
    } catch (e) {
      debugPrint('MediaPipeProvider 초기화 실패: $e');
      throw e;
    }
  }
  
  /// 카메라 이미지 처리
  Future<void> processImage(CameraImage image) async {
    if (_isProcessing || !_isInitialized) return;
    
    _isProcessing = true;
    notifyListeners();
    
    try {
      await _mediaPipeService.processImage(image);
      
      // MediaPipe 서비스에서 데이터 가져오기
      _handLandmarks = _mediaPipeService.handLandmarks;
      _isCleanMode = _mediaPipeService.isCleanMode;
      _cleanlinessScore = _mediaPipeService.cleanlinessScore;
      _leftHandTrail = _mediaPipeService.leftHandTrail;
      _rightHandTrail = _mediaPipeService.rightHandTrail;
      
    } catch (e) {
      debugPrint('이미지 처리 오류: $e');
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }
  
  /// 손 감지 상태 확인
  bool hasDetectedHands() {
    return _mediaPipeService.handsDetected;
  }
  
  /// 감지된 신체 부위 확인 (기존 호환성 유지)
  bool hasDetectedBody() {
    return hasDetectedHands();
  }
  
  /// 손 랜드마크를 화면 좌표로 변환
  List<Offset> getHandLandmarksAsOffsets(Size screenSize) {
    return _handLandmarks.map((landmark) {
      return landmark.toScreenOffset(screenSize);
    }).toList();
  }
  
  /// 특정 손가락 끝 랜드마크 가져오기
  List<HandLandmark> getFingerTips() {
    return _handLandmarks.where((landmark) {
      return landmark.type == HandLandmarkType.thumbTip ||
             landmark.type == HandLandmarkType.indexFingerTip ||
             landmark.type == HandLandmarkType.middleFingerTip ||
             landmark.type == HandLandmarkType.ringFingerTip ||
             landmark.type == HandLandmarkType.pinkyTip;
    }).toList();
  }
  
  /// 손목 랜드마크 가져오기
  List<HandLandmark> getWrists() {
    return _handLandmarks.where((landmark) {
      return landmark.type == HandLandmarkType.wrist;
    }).toList();
  }
  
  /// 손바닥 중심 계산
  Offset? getPalmCenter(Size screenSize) {
    final wrists = getWrists();
    if (wrists.isEmpty) return null;
    
    // 손목과 중지 MCP의 중점을 손바닥 중심으로 계산
    final middleFingerMcp = _handLandmarks.where((landmark) {
      return landmark.type == HandLandmarkType.middleFingerMcp;
    }).toList();
    
    if (middleFingerMcp.isEmpty) {
      return wrists.first.toScreenOffset(screenSize);
    }
    
    final wrist = wrists.first;
    final middleMcp = middleFingerMcp.first;
    
    return Offset(
      (wrist.x + middleMcp.x) / 2 * screenSize.width,
      (wrist.y + middleMcp.y) / 2 * screenSize.height,
    );
  }
  
  /// 감지된 영역의 중심점 계산 (기존 호환성 유지)
  Offset? getDetectedCenter() {
    if (_handLandmarks.isEmpty) return null;
    
    double sumX = 0;
    double sumY = 0;
    for (var landmark in _handLandmarks) {
      sumX += landmark.x;
      sumY += landmark.y;
    }
    
    return Offset(
      sumX / _handLandmarks.length,
      sumY / _handLandmarks.length,
    );
  }
  
  /// 정규화된 좌표를 화면 좌표로 변환 (기존 호환성 유지)
  List<Offset> normalizedToScreen(List<Offset> normalized, Size screenSize) {
    return normalized.map((point) {
      return Offset(
        point.dx * screenSize.width,
        point.dy * screenSize.height,
      );
    }).toList();
  }
  
  /// 감지된 포인트들 업데이트 (기존 호환성 유지)
  void updateDetectedPoints(List<Offset> points) {
    // 이 메서드는 더 이상 사용되지 않지만 호환성을 위해 유지
    notifyListeners();
  }
  
  /// 감지된 포인트들 지우기
  void clearDetectedPoints() {
    _handLandmarks.clear();
    _leftHandTrail.clear();
    _rightHandTrail.clear();
    notifyListeners();
  }
  
  /// 리소스 정리
  @override
  void dispose() {
    _mediaPipeService.dispose();
    super.dispose();
  }
}