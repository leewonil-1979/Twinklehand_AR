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
  void Function(CameraImage, CameraDescription)? _imageStreamListener;

  Offset? _lastFocusPointRaw;

  CameraController? get controller => _controller;
  bool get isInitialized => _isInitialized;
  bool get isProcessing => _isProcessing;
  double get minZoom => _minZoom;
  double get maxZoom => _maxZoom;
  double get currentZoom => _currentZoom;
  CameraDescription? get currentCamera => _currentCamera;
  bool get isBackCamera =>
      _currentCamera?.lensDirection == CameraLensDirection.back;
  Offset? get lastFocusPoint => _lastFocusPointRaw;

  Future<void> initializeCamera() async {
    if (cameras.isEmpty) {
      debugPrint('No cameras available');
      return;
    }

    final camera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );

    _currentCamera = camera;

    _controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.nv21,
    );

    try {
      await _controller!.initialize();

      await _controller!.setFocusMode(FocusMode.auto);
      debugPrint('오토포커스 설정 완료');

      await _applyCenterFocus();

      await _controller!.setExposureMode(ExposureMode.auto);
      debugPrint('오토 노출 설정 완료');

      _minZoom = await _controller!.getMinZoomLevel();
      _maxZoom = await _controller!.getMaxZoomLevel();

      _minZoom = 0.5;
      _maxZoom = 2.0;

      _currentZoom = 1.0;
      await _controller!.setZoomLevel(_currentZoom);

      debugPrint(
        '카메라 초기화 완료 - 줌 범위: ${_minZoom}x ~ ${_maxZoom}x, 현재: ${_currentZoom}x',
      );

      _isInitialized = true;
      notifyListeners();

      await _restartImageStreamIfNeeded();
    } catch (e) {
      debugPrint('Error initializing camera: $e');
      _isInitialized = false;
    }
  }

  Future<void> setZoomLevel(double zoom) async {
    if (_controller == null || !_isInitialized) return;

    zoom = zoom.clamp(_minZoom, _maxZoom);

    try {
      await _controller!.setZoomLevel(zoom);
      _currentZoom = zoom;
      await _reapplyFocusPoint();
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

  Future<void> startImageStream(
    void Function(CameraImage, CameraDescription) onImage,
  ) async {
    _imageStreamListener = onImage;
    await _startImageStreamInternal();
  }

  Future<void> _startImageStreamInternal() async {
    final controller = _controller;
    if (controller == null || !_isInitialized) return;
    if (controller.value.isStreamingImages) return;

    try {
      await controller.startImageStream((CameraImage image) {
        final listener = _imageStreamListener;
        final description = _currentCamera ?? controller.description;
        listener?.call(image, description);
      });
      debugPrint('카메라 이미지 스트림 시작');
      await _reapplyFocusPoint();
    } catch (e) {
      debugPrint('Error starting image stream: $e');
    }
  }

  Future<void> stopImageStream() async {
    final controller = _controller;
    if (controller == null || !_isInitialized) return;

    try {
      if (controller.value.isStreamingImages) {
        await controller.stopImageStream();
        debugPrint('카메라 이미지 스트림 중지');
      }
    } catch (e) {
      debugPrint('Error stopping image stream: $e');
    }
  }

  Future<void> _restartImageStreamIfNeeded() async {
    if (_imageStreamListener == null) return;
    await stopImageStream();
    await _startImageStreamInternal();
  }

  Future<void> switchCamera() async {
    if (cameras.length < 2) {
      debugPrint('카메라가 하나만 있어서 전환할 수 없습니다');
      return;
    }

    try {
      await stopImageStream();
      await _controller?.dispose();

      final targetDirection =
          _currentCamera?.lensDirection == CameraLensDirection.back
              ? CameraLensDirection.front
              : CameraLensDirection.back;

      final newCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == targetDirection,
        orElse: () => cameras.first,
      );

      _currentCamera = newCamera;
      _controller = CameraController(
        newCamera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.nv21,
      );

      await _controller!.initialize();

      await _controller!.setFocusMode(FocusMode.auto);
      await _controller!.setExposureMode(ExposureMode.auto);
      debugPrint('카메라 전환 후 오토포커스/노출 설정 완료');

      _minZoom = 0.5;
      _maxZoom = 2.0;
      _currentZoom = _currentZoom.clamp(_minZoom, _maxZoom);
      await _controller!.setZoomLevel(_currentZoom);

      await _reapplyFocusPoint();

      notifyListeners();
      debugPrint(
        '카메라 전환 완료: ${
          targetDirection == CameraLensDirection.back ? "후면" : "전면"
        }',
      );

      await _restartImageStreamIfNeeded();
    } catch (e) {
      debugPrint('카메라 전환 오류: $e');
      _isInitialized = false;
      await initializeCamera();
    }
  }

  @override
  void dispose() {
    _imageStreamListener = null;
    if (_controller?.value.isStreamingImages ?? false) {
      _controller!.stopImageStream();
    }
    _controller?.dispose();
    super.dispose();
  }

  Future<void> setFocusPoint(Offset normalizedPoint) async {
    final controller = _controller;
    if (controller == null || !_isInitialized) return;

    final clamped = Offset(
      normalizedPoint.dx.clamp(0.0, 1.0),
      normalizedPoint.dy.clamp(0.0, 1.0),
    );

    final adjusted = isBackCamera
        ? clamped
        : Offset(1.0 - clamped.dx, clamped.dy);

    try {
      await controller.setFocusMode(FocusMode.auto);
      await controller.setFocusPoint(adjusted);
      await controller.setExposureMode(ExposureMode.auto);
      await controller.setExposurePoint(adjusted);
      _lastFocusPointRaw = clamped;
      debugPrint('포커스/노출 포인트 설정: $adjusted');
    } catch (e) {
      debugPrint('포커스 포인트 설정 실패: $e');
    }
  }

  Future<void> _applyCenterFocus() async {
    try {
      await setFocusPoint(const Offset(0.5, 0.5));
    } catch (_) {}
  }

  Future<void> _reapplyFocusPoint() async {
    if (_lastFocusPointRaw != null) {
      await setFocusPoint(_lastFocusPointRaw!);
    } else {
      await _applyCenterFocus();
    }
  }
}
