import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // kIsWeb 사용
import 'package:camera/camera.dart';
import 'dart:math' as math;
import '../models/app_icon.dart';
import '../utils/constants.dart';
import '../utils/app_colors.dart';
import '../widgets/icon_selector.dart';
import '../widgets/mode_toggle.dart';
import '../widgets/capture_button.dart';
import '../services/hand_tracking_service.dart';

/// AR 아이콘 오버레이 데이터 클래스
class ARIconOverlay {
  final Offset position;
  final String iconName;
  final double size;
  final double opacity;
  final double rotation;
  final bool isCleanMode;
  
  ARIconOverlay({
    required this.position,
    required this.iconName,
    required this.size,
    required this.opacity,
    required this.rotation,
    required this.isCleanMode,
  });
}


/// 메인 카메라 화면
/// 전면 카메라를 사용하여 손씻기 AR 기능을 제공합니다
class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> 
    with WidgetsBindingObserver {
  
  // 카메??관??
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  
  // 손 추적 서비스
  final HandTrackingService _handTrackingService = HandTrackingService();
  List<Offset> _trackedHandPositions = [];
  List<Offset> _trackedFacePositions = [];
  
  // AR 아이콘 오버레이용 데이터
  List<ARIconOverlay> _arIcons = [];
  
  // 앱 상태
  bool _isCleanMode = false; // false: 더러운 모드, true: 깨끗한 모드
  AppIcon? _selectedIcon;
  
  // 더러운 모드 아이콘들
  final List<AppIcon> _dirtyIcons = [
    AppIcon.dirty('bacteria_1', '세균'),
    AppIcon.dirty('bacteria_2', '바이러스'),
    AppIcon.dirty('virus_1', '균'),
    AppIcon.dirty('germs_1', '오염물질'),
  ];
  
  // 깨끗한 모드 아이콘들
  final List<AppIcon> _cleanIcons = [
    AppIcon.clean('sparkle_1', '반짝임'),
    AppIcon.clean('star_1', '별'),
    AppIcon.clean('bubble_1', '거품'),
    AppIcon.clean('heart_1', '하트'),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
    _selectedIcon = _dirtyIcons.first; // 기본 선택 아이콘
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    _handTrackingService.dispose(); // 손 추적 서비스 정리
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _cameraController;
    
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }
    
    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
      _cameraController = null; // null로 설정
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  /// 카메라 초기화(전면 카메라 우선)
  Future<void> _initializeCamera() async {
    try {
      // 기존 컨트롤러가 있으면 먼저 dispose
      if (_cameraController != null) {
        await _cameraController!.dispose();
        _cameraController = null;
      }
      
      _cameras = await availableCameras();
      
      if (_cameras!.isEmpty) {
        debugPrint('사용 가능한 카메라가 없습니다.');
        return;
      }
      
      // 전면 카메라 우선 선택 (손씻기 특성)
      final frontCamera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras!.first,
      );
      
      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.high,
        enableAudio: false, // 손씻기 앱에서는 오디오 불필요
      );
      
      await _cameraController!.initialize();
      
      // mounted 체크 후 상태 업데이트
      if (mounted && _cameraController != null && _cameraController!.value.isInitialized) {
        // 손 추적 서비스 초기화
        await _handTrackingService.initialize();
        
        // 카메라 스트림 시작 (모바일에서만)
        if (!kIsWeb) {
          _cameraController!.startImageStream(_processImage);
        }
        
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('카메라 초기화 오류: $e');
      if (mounted) {
        setState(() {
          _isCameraInitialized = false;
        });
      }
    }
  }
  
  /// 카메라 이미지 스트림 처리 (손 추적)
  bool _isProcessing = false;
  
  Future<void> _processImage(CameraImage image) async {
    // 이미 처리 중이면 스킵
    if (_isProcessing) return;
    _isProcessing = true;
    
    try {
      // 손과 얼굴 위치 감지
      final detectionResults = await _handTrackingService.detectHandsAndFaces(image);
      
      // UI 업데이트 (메인 스레드에서)
      if (mounted) {
        setState(() {
          _trackedHandPositions = detectionResults['hands'] ?? [];
          _trackedFacePositions = detectionResults['faces'] ?? [];
          
          // 🎨 AR 아이콘들을 감지된 위치 주변에 생성
          _generateARIcons();
        });
      }
    } catch (e) {
      debugPrint('🔍 이미지 처리 오류: $e');
    } finally {
      _isProcessing = false;
    }
  }
  
  /// 🎨 감지된 손/얼굴 주변에 AR 아이콘들을 자연스럽게 배치
  void _generateARIcons() {
    if (_selectedIcon == null) return;
    
    _arIcons.clear();
    final random = math.Random();
    
    // 손 위치 주변에 아이콘 배치
    for (final handPos in _trackedHandPositions) {
      // 각 손 주변에 3-5개의 아이콘 배치
      final iconCount = 3 + random.nextInt(3);
      for (int i = 0; i < iconCount; i++) {
        final angle = (i / iconCount) * 2 * math.pi + random.nextDouble() * 0.5;
        final distance = 40 + random.nextDouble() * 60; // 40-100px 거리
        
        final iconPos = Offset(
          handPos.dx + math.cos(angle) * distance,
          handPos.dy + math.sin(angle) * distance,
        );
        
        _arIcons.add(ARIconOverlay(
          position: iconPos,
          iconName: _selectedIcon!.name,
          size: 20 + random.nextDouble() * 15, // 20-35px 크기
          opacity: 0.6 + random.nextDouble() * 0.4, // 60-100% 투명도
          rotation: random.nextDouble() * 2 * math.pi,
          isCleanMode: _isCleanMode,
        ));
      }
    }
    
    // 얼굴 위치 주변에도 아이콘 배치 (더러운 모드에서만)
    if (!_isCleanMode) {
      for (final facePos in _trackedFacePositions) {
        final iconCount = 2 + random.nextInt(2); // 2-3개
        for (int i = 0; i < iconCount; i++) {
          final angle = random.nextDouble() * 2 * math.pi;
          final distance = 80 + random.nextDouble() * 40; // 얼굴에서 더 멀리
          
          final iconPos = Offset(
            facePos.dx + math.cos(angle) * distance,
            facePos.dy + math.sin(angle) * distance,
          );
          
          _arIcons.add(ARIconOverlay(
            position: iconPos,
            iconName: _selectedIcon!.name,
            size: 15 + random.nextDouble() * 10, // 조금 더 작게
            opacity: 0.4 + random.nextDouble() * 0.3,
            rotation: random.nextDouble() * 2 * math.pi,
            isCleanMode: _isCleanMode,
          ));
        }
      }
    }
  }

  /// 모드 전환 (더러운→깨끗한)
  void _toggleMode(bool isCleanMode) {
    setState(() {
      _isCleanMode = isCleanMode;
      // 모드 변경시 첫번째 아이콘으로 자동 선택
      _selectedIcon = isCleanMode ? _cleanIcons.first : _dirtyIcons.first;
    });
  }
  
  /// 아이콘 선택
  void _selectIcon(AppIcon icon) {
    setState(() {
      _selectedIcon = icon;
    });
  }
  
  /// 아이콘 이름에 따른 IconData 반환
  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'bacteria_1':
      case 'bacteria_2':
        return Icons.coronavirus;
      case 'virus_1':
        return Icons.bug_report;
      case 'sparkle_1':
      case 'sparkle_2':
        return Icons.auto_awesome;
      case 'star_1':
        return Icons.star;
      case 'bubble_1':
        return Icons.bubble_chart;
      default:
        return Icons.help;
    }
  }
  
  /// 사진 촬영
  Future<void> _takePicture() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    
    try {
      final XFile photo = await _cameraController!.takePicture();
      debugPrint('?�진 촬영 ?�료: ${photo.path}');
      
      // TODO: ?�진 ?�??�??�용 ?�수 추적 구현
      _showCaptureSuccess();
    } catch (e) {
      debugPrint('?�진 촬영 ?�류: $e');
    }
  }
  
  /// 촬영 ?�공 메시지 ?�시
  void _showCaptureSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_isCleanMode ? "깨끗한" : "더러운"} 손 사진이 저장되었습니다!'),
        backgroundColor: _isCleanMode ? AppColors.cleanPrimary : AppColors.dirtyPrimary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 600; // 모바??기�?
    
    // 반응???�기 계산
    final iconGridHeight = isSmallScreen ? screenHeight * 0.25 : 200.0;
    final arOverlaySize = isSmallScreen ? screenWidth * 0.3 : 120.0;
    final captureButtonSize = isSmallScreen ? 70.0 : 80.0;
    
    return Scaffold(
      backgroundColor: _isCleanMode ? AppColors.cleanBackground : AppColors.dirtyBackground,
      body: SafeArea(
        child: Column(
          children: [
            // 1. 아이콘 선택 그리드(상단)
            Container(
              height: iconGridHeight,
              padding: const EdgeInsets.all(16.0),
              child: IconSelector(
                icons: _isCleanMode ? _cleanIcons : _dirtyIcons,
                selectedIcon: _selectedIcon,
                onIconSelected: _selectIcon,
                isCleanMode: _isCleanMode,
              ),
            ),
            
            // 2. 카메라 뷰 + AR 오버레이 (중앙)
            Expanded(
              child: Stack(
                children: [
                  // 카메라 뷰
                  _buildCameraView(),
                  
                  // 🎨 자연스럽게 배치된 AR 아이콘들
                  ..._buildARIconOverlays(),
                  
                  // 🎯 디버그: 감지된 위치 표시 (개발 중 확인용)
                  ..._buildDebugMarkers(),
                ],
              ),
            ),
            
            // 3. 하단 컨트롤 영역
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // 모드 전환 버튼
                  ModeToggle(
                    isCleanMode: _isCleanMode,
                    onModeChanged: _toggleMode,
                  ),
                  
                  // 촬영 버튼 (반응???�기)
                  SizedBox(
                    width: captureButtonSize,
                    height: captureButtonSize,
                    child: CaptureButton(
                      onPressed: _takePicture,
                      isCleanMode: _isCleanMode,
                    ),
                  ),
                  
                  // ?�정 버튼 (?�중??구현)
                  IconButton(
                    onPressed: () {
                      // TODO: ?�정 ?�면?�로 ?�동
                    },
                    icon: Icon(
                      Icons.settings,
                      color: _isCleanMode ? AppColors.cleanIconColor : AppColors.dirtyIconColor,
                      size: 32,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// 카메??�?빌드
  Widget _buildCameraView() {
    if (!_isCameraInitialized || 
        _cameraController == null || 
        !_cameraController!.value.isInitialized ||
        _cameraController!.value.hasError) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(
            color: AppColors.primaryColor,
          ),
        ),
      );
    }
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      child: CameraPreview(_cameraController!),
    );
  }
  
  /// 추적?????�치??AR ?�버?�이 ?�성
  List<Widget> _buildHandOverlays(double overlaySize) {
    return _trackedHandPositions.map((handPosition) {
      return Positioned(
        left: handPosition.dx - (overlaySize / 2),
        top: handPosition.dy - (overlaySize / 2),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          width: overlaySize,
          height: overlaySize,
          decoration: BoxDecoration(
            color: (_isCleanMode ? AppColors.cleanAccent : AppColors.dirtyAccent)
                .withValues(alpha: 0.8),
            shape: BoxShape.circle,
            border: Border.all(
              color: _isCleanMode ? AppColors.cleanPrimary : AppColors.dirtyPrimary,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: (_isCleanMode ? AppColors.cleanPrimary : AppColors.dirtyPrimary)
                    .withValues(alpha: 0.6),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(
            _getIconData(_selectedIcon!.name),
            size: overlaySize * 0.5,
            color: Colors.white,
          ),
        ),
      );
    }).toList();
  }
  
  /// 추적된 얼굴 위치에 AR 오버레이 생성 (더러운 모드만)
  List<Widget> _buildFaceOverlays(double overlaySize) {
    return _trackedFacePositions.map((facePosition) {
      return Positioned(
        left: facePosition.dx - (overlaySize / 2),
        top: facePosition.dy - (overlaySize / 2),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          width: overlaySize * 0.8, // 얼굴보다 작게
          height: overlaySize * 0.8,
          decoration: BoxDecoration(
            color: AppColors.dirtyAccent.withValues(alpha: 0.7),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.dirtyPrimary,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.dirtyPrimary.withValues(alpha: 0.5),
                blurRadius: 6,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Icon(
            Icons.coronavirus, // ?�굴?�는 ?�균 ?�이�?
            size: overlaySize * 0.3,
            color: Colors.white,
          ),
        ),
      );
    }).toList();
  }
  
  /// 🎯 디버그: 감지된 위치 표시 (개발 중 확인용)
  List<Widget> _buildDebugMarkers() {
    List<Widget> markers = [];
    
    // 손 위치 마커 (빨간색 점)
    for (final handPos in _trackedHandPositions) {
      markers.add(
        Positioned(
          left: handPos.dx - 8,
          top: handPos.dy - 8,
          child: Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.8),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
        ),
      );
    }
    
    // 얼굴 위치 마커 (파란색 점)
    for (final facePos in _trackedFacePositions) {
      markers.add(
        Positioned(
          left: facePos.dx - 12,
          top: facePos.dy - 12,
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.8),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
        ),
      );
    }
    
    return markers;
  }
  
  /// 🎨 자연스럽게 배치된 AR 아이콘들 렌더링
  List<Widget> _buildARIconOverlays() {
    return _arIcons.map((arIcon) {
      return Positioned(
        left: arIcon.position.dx - (arIcon.size / 2),
        top: arIcon.position.dy - (arIcon.size / 2),
        child: Transform.rotate(
          angle: arIcon.rotation,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: arIcon.opacity,
            child: Container(
              width: arIcon.size,
              height: arIcon.size,
              decoration: BoxDecoration(
                color: (arIcon.isCleanMode ? AppColors.cleanAccent : AppColors.dirtyAccent)
                    .withValues(alpha: 0.9),
                shape: BoxShape.circle,
                border: Border.all(
                  color: arIcon.isCleanMode ? AppColors.cleanPrimary : AppColors.dirtyPrimary,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (arIcon.isCleanMode ? AppColors.cleanPrimary : AppColors.dirtyPrimary)
                        .withValues(alpha: 0.4),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Icon(
                _getIconData(arIcon.iconName),
                size: arIcon.size * 0.6,
                color: Colors.white,
              ),
            ),
          ),
        ),
      );
    }).toList();
  }
}
