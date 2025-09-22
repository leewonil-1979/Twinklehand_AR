import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../main.dart';

class CameraProvider extends ChangeNotifier {
  CameraController? _controller;
  bool _isInitialized = false;
  bool _isProcessing = false;
  double _minZoom = 1.0;
  double _maxZoom = 1.0;
  double _currentZoom = 1.0;
  CameraDescription? _currentCamera;
  
  // Getters
  CameraController? get controller => _controller;
  bool get isInitialized => _isInitialized;
  bool get isProcessing => _isProcessing;
  double get minZoom => _minZoom;
  double get maxZoom => _maxZoom;
  double get currentZoom => _currentZoom;
  CameraDescription? get currentCamera => _currentCamera;
  bool get isBackCamera => _currentCamera?.lensDirection == CameraLensDirection.back;
  
  Future<void> initializeCamera() async {
    if (cameras.isEmpty) {
      debugPrint('No cameras available');
      return;
    }
    
    // Use rear camera as default
    final camera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );
    
    _currentCamera = camera;
    
    _controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.nv21, // ML Kit 호환성을 위한 형식
    );
    
    try {
      await _controller!.initialize();
      
      // 카메라 포커스 모드 설정 (오토포커스)
      try {
        await _controller!.setFocusMode(FocusMode.auto);
        debugPrint('오토포커스 설정 완료');
      } catch (e) {
        debugPrint('오토포커스 설정 실패: $e');
      }
      
      // 노출 모드 설정
      try {
        await _controller!.setExposureMode(ExposureMode.auto);
        debugPrint('오토 노출 설정 완료');
      } catch (e) {
        debugPrint('오토 노출 설정 실패: $e');
      }
      
      // Get zoom levels
      _minZoom = await _controller!.getMinZoomLevel();
      _maxZoom = await _controller!.getMaxZoomLevel();
      
      // Set custom zoom range: 0.5x to 2.0x
      _minZoom = 0.5; // 강제로 0.5부터 시작
      _maxZoom = 2.0; // 강제로 2.0까지 제한
      
      // Set default zoom to 1.0x
      _currentZoom = 1.0;
      await _controller!.setZoomLevel(_currentZoom);
      
      debugPrint('카메라 초기화 완료 - 줌 범위: ${_minZoom}x ~ ${_maxZoom}x, 현재: ${_currentZoom}x');
      
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing camera: $e');
      _isInitialized = false;
    }
  }
  
  Future<void> setZoomLevel(double zoom) async {
    if (_controller == null || !_isInitialized) return;
    
    // Clamp zoom value
    zoom = zoom.clamp(_minZoom, _maxZoom);
    
    try {
      await _controller!.setZoomLevel(zoom);
      _currentZoom = zoom;
      notifyListeners();
    } catch (e) {
      debugPrint('Error setting zoom: $e');
    }
  }
  
  Future<XFile?> takePicture() async {
    if (_controller == null || !_isInitialized || _isProcessing) {
      return null;
    }
    
    _isProcessing = true;
    notifyListeners();
    
    try {
      final XFile photo = await _controller!.takePicture();
      _isProcessing = false;
      notifyListeners();
      return photo;
    } catch (e) {
      debugPrint('Error taking picture: $e');
      _isProcessing = false;
      notifyListeners();
      return null;
    }
  }
  
  void startImageStream(void Function(CameraImage) onImage) {
    if (_controller == null || !_isInitialized) return;
    
    try {
      _controller!.startImageStream(onImage);
    } catch (e) {
      debugPrint('Error starting image stream: $e');
    }
  }
  
  void stopImageStream() {
    if (_controller == null || !_isInitialized) return;
    
    try {
      _controller!.stopImageStream();
    } catch (e) {
      debugPrint('Error stopping image stream: $e');
    }
  }
  
  /// 카메라 전환 (전면 <-> 후면)
  Future<void> switchCamera() async {
    if (cameras.length < 2) {
      debugPrint('카메라가 하나만 있어서 전환할 수 없습니다');
      return;
    }
    
    try {
      // 현재 이미지 스트림 중지
      stopImageStream();
      
      // 현재 컨트롤러 해제
      await _controller?.dispose();
      
      // 반대 카메라 찾기
      final targetDirection = _currentCamera?.lensDirection == CameraLensDirection.back
          ? CameraLensDirection.front
          : CameraLensDirection.back;
      
      final newCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == targetDirection,
        orElse: () => cameras.first,
      );
      
      _currentCamera = newCamera;
      
      // 새 컨트롤러 생성 및 초기화
      _controller = CameraController(
        newCamera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.nv21, // ML Kit 호환성
      );
      
      await _controller!.initialize();
      
      // 카메라 포커스 및 노출 모드 설정
      try {
        await _controller!.setFocusMode(FocusMode.auto);
        await _controller!.setExposureMode(ExposureMode.auto);
        debugPrint('카메라 전환 후 오토포커스/노출 설정 완료');
      } catch (e) {
        debugPrint('카메라 전환 후 포커스 설정 실패: $e');
      }
      
      // 줌 레벨 다시 설정
      _minZoom = 0.5; // 강제로 0.5부터 시작
      _maxZoom = 2.0; // 강제로 2.0까지 제한
      
      // 현재 줌을 유지하되, 새 카메라의 범위 내로 조정
      _currentZoom = _currentZoom.clamp(_minZoom, _maxZoom);
      await _controller!.setZoomLevel(_currentZoom);
      
      notifyListeners();
      debugPrint('카메라 전환 완료: ${targetDirection == CameraLensDirection.back ? "후면" : "전면"}');
      
    } catch (e) {
      debugPrint('카메라 전환 오류: $e');
      // 오류 발생 시 다시 초기화 시도
      _isInitialized = false;
      await initializeCamera();
    }
  }
  
  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}