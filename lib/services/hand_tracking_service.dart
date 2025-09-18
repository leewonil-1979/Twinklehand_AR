import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

/// 실제 Google ML Kit 손 추적 서비스
class HandTrackingService {
  // ML Kit 디텍터들
  late PoseDetector _poseDetector;
  late FaceDetector _faceDetector;
  
  // 초기화 상태
  bool _isInitialized = false;
  
  // 감지된 위치들
  List<Offset> _handPositions = [];
  List<Offset> _facePositions = [];
  
  /// 서비스 초기화
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // 포즈 디텍터 초기화(목/어깨 감지)
      _poseDetector = PoseDetector(
        options: PoseDetectorOptions(
          mode: PoseDetectionMode.stream,
          model: PoseDetectionModel.accurate,
        ),
      );
      
      // 얼굴 디텍터 초기화
      _faceDetector = FaceDetector(
        options: FaceDetectorOptions(
          enableClassification: false,
          enableLandmarks: true,
          enableContours: false,
          enableTracking: true,
        ),
      );
      
      _isInitialized = true;
      debugPrint('✅ Google ML Kit 손 추적 서비스 초기화 완료');
    } catch (e) {
      debugPrint('❌ ML Kit 초기화 오류: $e');
    }
  }
  
  /// 카메라 이미지에서 실제 손과 얼굴 위치 감지
  Future<Map<String, List<Offset>>> detectHandsAndFaces(CameraImage image) async {
    if (!_isInitialized) {
      debugPrint('🔄 ML Kit 초기화 중...');
      await initialize();
    }
    
    try {
      debugPrint('📸 이미지 처리 시작 - 크기: ${image.width}x${image.height}');
      
      // CameraImage를 InputImage로 변환
      final inputImage = _cameraImageToInputImage(image);
      if (inputImage == null) {
        debugPrint('❌ InputImage 변환 실패');
        return {'hands': [], 'faces': []};
      }
      
      debugPrint('✅ InputImage 변환 성공');
      
      // 손과 얼굴 동시 감지
      final results = await Future.wait([
        _detectHandPoses(inputImage),
        _detectFaces(inputImage),
      ]);
      
      _handPositions = results[0];
      _facePositions = results[1];
      
      debugPrint('🔍 감지 결과 - 손: ${_handPositions.length}개, 얼굴: ${_facePositions.length}개');
      
      return {
        'hands': _handPositions,
        'faces': _facePositions,
      };
    } catch (e) {
      debugPrint('🔍 감지 오류: $e');
      return {'hands': [], 'faces': []};
    }
  }
  
  /// 손 위치 감지 (손목, 검지, 엄지)
  Future<List<Offset>> _detectHandPoses(InputImage inputImage) async {
    try {
      final poses = await _poseDetector.processImage(inputImage);
      final handPositions = <Offset>[];
      
      for (final pose in poses) {
        final landmarks = pose.landmarks;
        
        // 왼손 위치들
        _addHandLandmark(landmarks, PoseLandmarkType.leftWrist, handPositions);
        _addHandLandmark(landmarks, PoseLandmarkType.leftIndex, handPositions);
        _addHandLandmark(landmarks, PoseLandmarkType.leftThumb, handPositions);
        
        // 오른손 위치들
        _addHandLandmark(landmarks, PoseLandmarkType.rightWrist, handPositions);
        _addHandLandmark(landmarks, PoseLandmarkType.rightIndex, handPositions);
        _addHandLandmark(landmarks, PoseLandmarkType.rightThumb, handPositions);
      }
      
      debugPrint('✋ 감지된 손 위치: ${handPositions.length}개');
      return handPositions;
    } catch (e) {
      debugPrint('👋 손 감지 오류: $e');
      return [];
    }
  }
  
  /// 손 랜드마크 추가 헬퍼
  void _addHandLandmark(Map<PoseLandmarkType, PoseLandmark> landmarks, 
                       PoseLandmarkType type, List<Offset> positions) {
    final landmark = landmarks[type];
    if (landmark != null && landmark.likelihood > 0.5) { // 50% 이상 신뢰도
      positions.add(Offset(landmark.x, landmark.y));
    }
  }
  
  /// 얼굴 위치 감지
  Future<List<Offset>> _detectFaces(InputImage inputImage) async {
    try {
      final faces = await _faceDetector.processImage(inputImage);
      final facePositions = <Offset>[];
      
      for (final face in faces) {
        final box = face.boundingBox;
        final centerX = box.left + (box.width / 2);
        final centerY = box.top + (box.height / 2);
        facePositions.add(Offset(centerX, centerY));
      }
      
      debugPrint('😀 감지된 얼굴: ${facePositions.length}개');
      return facePositions;
    } catch (e) {
      debugPrint('😵 얼굴 감지 오류: $e');
      return [];
    }
  }
  
  /// CameraImage를 InputImage로 변환
  InputImage? _cameraImageToInputImage(CameraImage cameraImage) {
    try {
      // 이미지 메타데이터 생성
      final metadata = InputImageMetadata(
        size: Size(cameraImage.width.toDouble(), cameraImage.height.toDouble()),
        rotation: InputImageRotation.rotation0deg,
        format: InputImageFormat.nv21,
        bytesPerRow: cameraImage.planes[0].bytesPerRow,
      );
      
      // InputImage 생성
      return InputImage.fromBytes(
        bytes: cameraImage.planes[0].bytes,
        metadata: metadata,
      );
    } catch (e) {
      debugPrint('📷 이미지 변환 오류: $e');
      return null;
    }
  }
  
  /// 현재 감지된 손 위치들 반환
  List<Offset> get currentHandPositions => List.from(_handPositions);
  
  /// 현재 감지된 얼굴 위치들 반환
  List<Offset> get currentFacePositions => List.from(_facePositions);
  
  /// 서비스 종료
  Future<void> dispose() async {
    if (_isInitialized) {
      await _poseDetector.close();
      await _faceDetector.close();
      _isInitialized = false;
      debugPrint('🛑 ML Kit 서비스 종료');
    }
  }
}
