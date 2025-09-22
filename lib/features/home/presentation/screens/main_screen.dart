import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'package:go_router/go_router.dart';
import '../../../../providers/app_state_provider.dart';
import '../../../../providers/camera_provider.dart';
import '../../../../providers/ar_effects_provider.dart';
import '../../../../providers/mediapipe_provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../widgets/mode_toggle_button.dart';
import '../widgets/capture_button.dart';
import '../widgets/camera_switch_button.dart';
import '../../../ar_effects/presentation/widgets/ar_overlay.dart';
import '../../../ar_effects/presentation/widgets/icon_selector.dart';
import '../../../camera/presentation/widgets/camera_preview_widget.dart';
import '../../../camera/presentation/widgets/zoom_slider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _pulseController;
  late AnimationController _sparkleController;
  double _lastZoomLevel = 1.0; // 마지막 줌 레벨 추적
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeCamera();
    _generateInitialEffects();
    
    // 줌 변경 감지를 위한 리스너 추가
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cameraProvider = context.read<CameraProvider>();
      cameraProvider.addListener(_onCameraChanged);
    });
  }
  
  void _onCameraChanged() {
    final cameraProvider = context.read<CameraProvider>();
    if (cameraProvider.currentZoom != _lastZoomLevel) {
      _lastZoomLevel = cameraProvider.currentZoom;
      // AR 효과 크기 업데이트
      context.read<AREffectsProvider>().updateZoomLevel(_lastZoomLevel);
    }
  }
  
  void _initializeAnimations() {
    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _sparkleController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();
    
    // Update AR effects animation values
    _floatController.addListener(() {
      context.read<AREffectsProvider>().updateAnimationValues(
        float: _floatController.value * 20 - 10,
        pulse: 1.0,
        rotation: 0.0,
      );
    });
    
    _pulseController.addListener(() {
      context.read<AREffectsProvider>().updateAnimationValues(
        float: _floatController.value * 20 - 10,
        pulse: 0.8 + _pulseController.value * 0.4,
        rotation: 0.0,
      );
    });
    
    _sparkleController.addListener(() {
      context.read<AREffectsProvider>().updateAnimationValues(
        float: _floatController.value * 20 - 10,
        pulse: 0.8 + _pulseController.value * 0.4,
        rotation: _sparkleController.value * 6.28,
      );
    });
  }
  
  void _initializeCamera() {
    final cameraProvider = context.read<CameraProvider>();
    if (!cameraProvider.isInitialized) {
      cameraProvider.initializeCamera();
    }
    
    // Start image stream for MediaPipe processing
    if (cameraProvider.controller != null) {
      cameraProvider.startImageStream((CameraImage image) {
        context.read<MediaPipeProvider>().processImage(image);
      });
    }
  }
  
  void _generateInitialEffects() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      final arProvider = context.read<AREffectsProvider>();
      final appState = context.read<AppStateProvider>();
      
      arProvider.setScreenSize(size);
      arProvider.generateEffects(
        icon: appState.currentIcon,
        count: appState.currentMode == AppMode.clean ? 12 : 20,
        mode: appState.currentMode,
      );
    });
  }
  
  @override
  void dispose() {
    // 카메라 리스너 제거
    final cameraProvider = context.read<CameraProvider>();
    cameraProvider.removeListener(_onCameraChanged);
    
    _floatController.dispose();
    _pulseController.dispose();
    _sparkleController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview Layer
          const CameraPreviewWidget(),
          
          // AR Effects Overlay
          const AROverlay(),
          
          // Top UI Controls - 간소화
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 20,
            right: 20,
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 10,
                sigmaY: 10,
              ),
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: AppColors.overlayDark.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    // Status Message
                    _buildStatusMessage(),
                    const SizedBox(height: 15),
                    // Icon Selector
                    const IconSelector(),
                  ],
                ),
              ),
            ),
          ),
          
          // Settings Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.settings, color: Colors.white),
              onPressed: () => context.push('/settings'),
            ),
          ),
          
          // Zoom Slider
          const Positioned(
            right: 20,
            top: 200,
            bottom: 200,
            child: ZoomSlider(),
          ),
          
          // Bottom Controls
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // Camera Controls Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Capture Button
                    const CaptureButton(),
                    const SizedBox(width: 20),
                    // Camera Switch Button (오른쪽에 배치)
                    const CameraSwitchButton(),
                  ],
                ),
                const SizedBox(height: 20),
                // Mode Toggle Button
                const ModeToggleButton(),
              ],
            ),
          ),
          
          // Detection Indicator - 감지 상태 표시
          Positioned(
            top: MediaQuery.of(context).padding.top + 150,
            left: 20,
            child: Consumer<MediaPipeProvider>(
              builder: (context, mediapipe, child) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: mediapipe.hasDetectedBody() 
                      ? Colors.green.withValues(alpha: 0.7)
                      : Colors.orange.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        mediapipe.hasDetectedBody() 
                          ? Icons.visibility
                          : Icons.visibility_off,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        mediapipe.hasDetectedBody() 
                          ? '감지됨'
                          : '감지 중...',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatusMessage() {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        String message;
        Color backgroundColor;
        
        if (appState.currentMode == AppMode.clean) {
          backgroundColor = AppColors.cleanMode.withValues(alpha: 0.3);
          message = AppStrings.cleanMessage;
        } else {
          backgroundColor = AppColors.dirtyMode.withValues(alpha: 0.3);
          message = AppStrings.dirtyMessage;
        }
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: appState.currentMode == AppMode.clean
                  ? AppColors.cleanMode
                  : AppColors.dirtyMode,
              width: 2,
            ),
          ),
          child: Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }
}