import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

class CameraService {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  
  CameraController? get controller => _controller;
  bool get isInitialized => _isInitialized;
  List<CameraDescription>? get cameras => _cameras;
  
  Future<void> initialize() async {
    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        debugPrint('No cameras available');
        return;
      }
      
      // Use front camera if available
      final camera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras!.first,
      );
      
      await initializeCamera(camera);
    } catch (e) {
      debugPrint('Error initializing camera service: $e');
    }
  }
  
  Future<void> initializeCamera(CameraDescription camera) async {
    _controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: defaultTargetPlatform == TargetPlatform.iOS
          ? ImageFormatGroup.bgra8888
          : ImageFormatGroup.yuv420,
    );
    
    try {
      await _controller!.initialize();
      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing camera controller: $e');
      _isInitialized = false;
    }
  }
  
  Future<void> switchCamera() async {
    if (_cameras == null || _cameras!.length < 2 || _controller == null) {
      return;
    }
    
    final currentDirection = _controller!.description.lensDirection;
    final newCamera = _cameras!.firstWhere(
      (camera) => camera.lensDirection != currentDirection,
      orElse: () => _cameras!.first,
    );
    
    await _controller!.dispose();
    await initializeCamera(newCamera);
  }
  
  Future<XFile?> takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return null;
    }
    
    try {
      final XFile file = await _controller!.takePicture();
      return file;
    } catch (e) {
      debugPrint('Error taking picture: $e');
      return null;
    }
  }
  
  Future<void> startVideoRecording() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }
    
    try {
      await _controller!.startVideoRecording();
    } catch (e) {
      debugPrint('Error starting video recording: $e');
    }
  }
  
  Future<XFile?> stopVideoRecording() async {
    if (_controller == null || !_controller!.value.isRecordingVideo) {
      return null;
    }
    
    try {
      final XFile file = await _controller!.stopVideoRecording();
      return file;
    } catch (e) {
      debugPrint('Error stopping video recording: $e');
      return null;
    }
  }
  
  Future<double> getMaxZoomLevel() async {
    if (_controller == null) return 1.0;
    return await _controller!.getMaxZoomLevel();
  }
  
  Future<double> getMinZoomLevel() async {
    if (_controller == null) return 1.0;
    return await _controller!.getMinZoomLevel();
  }
  
  Future<void> setZoomLevel(double zoom) async {
    if (_controller == null) return;
    await _controller!.setZoomLevel(zoom);
  }
  
  void dispose() {
    _controller?.dispose();
    _isInitialized = false;
  }
}