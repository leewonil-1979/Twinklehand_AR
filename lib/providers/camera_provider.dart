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
  
  // Getters
  CameraController? get controller => _controller;
  bool get isInitialized => _isInitialized;
  bool get isProcessing => _isProcessing;
  double get minZoom => _minZoom;
  double get maxZoom => _maxZoom;
  double get currentZoom => _currentZoom;
  
  Future<void> initializeCamera() async {
    if (cameras.isEmpty) {
      debugPrint('No cameras available');
      return;
    }
    
    // Use front camera if available
    final camera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );
    
    _controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
    );
    
    try {
      await _controller!.initialize();
      
      // Get zoom levels
      _minZoom = await _controller!.getMinZoomLevel();
      _maxZoom = await _controller!.getMaxZoomLevel();
      
      // Limit max zoom to reasonable level
      if (_maxZoom > 5.0) _maxZoom = 5.0;
      
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
  
  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}