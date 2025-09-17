import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // kIsWeb 사용
import 'package:camera/camera.dart';
import '../models/app_icon.dart';
import '../utils/constants.dart';
import '../utils/app_colors.dart';
import '../widgets/icon_selector.dart';
import '../widgets/mode_toggle.dart';
import '../widgets/capture_button.dart';
import '../services/hand_tracking_service.dart';


/// 메인 카메라 화면
/// 전면 카메라를 사용하여 손씻기 AR 기능을 제공합니다.
class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> 
    with WidgetsBindingObserver {
  
  // 카메라 관련
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  
  // 손 추적 서비스
  final HandTrackingService _handTrackingService = HandTrackingService();
  List<Offset> _trackedHandPositions = [];
  List<Offset> _trackedFacePositions = [];
  
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

  /// 카메라 초기화 (전면 카메라 우선)
  Future<void> _initializeCamera() async {
    try {
      // 기존 컨트롤러가 있으면 먼저 dispose
      if (_cameraController != null) {
        await _cameraController!.dispose();
        _cameraController = null;
      }
      
      _cameras = await availableCameras();
      
      if (_cameras!.isEmpty) {
        print('사용 가능한 카메라가 없습니다.');
        return;
      }
      
      // 전면 카메라 우선 선택 (손씻기 앱 특성)
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
      print('카메라 초기화 오류: $e');
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
      final result = await _handTrackingService.detectHandsAndFaces(image);
      
      if (mounted) {
        setState(() {
          _trackedHandPositions = result['hands'] ?? [];
          _trackedFacePositions = result['faces'] ?? [];
        });
      }
    } catch (e) {
      print('이미지 처리 오류: $e');
    } finally {
      _isProcessing = false;
    }
  }
  
  /// 모드 전환 (더러운 ↔ 깨끗한)
  void _toggleMode(bool isCleanMode) {
    setState(() {
      _isCleanMode = isCleanMode;
      // 모드 변경시 첫 번째 아이콘으로 자동 선택
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
      case 'Bacteria':
        return Icons.coronavirus;
      case 'Virus':
        return Icons.bug_report;
      case 'Sparkle':
        return Icons.auto_awesome;
      case 'Star':
        return Icons.star;
      case 'Bubble':
        return Icons.bubble_chart;
      case 'Heart':
        return Icons.favorite;
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
      print('사진 촬영 완료: ${photo.path}');
      
      // TODO: 사진 저장 및 사용 횟수 추적 구현
      _showCaptureSuccess();
    } catch (e) {
      print('사진 촬영 오류: $e');
    }
  }
  
  /// 촬영 성공 메시지 표시
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
    final isSmallScreen = screenWidth < 600; // 모바일 기준
    
    // 반응형 크기 계산
    final iconGridHeight = isSmallScreen ? screenHeight * 0.25 : 200.0;
    final arOverlaySize = isSmallScreen ? screenWidth * 0.3 : 120.0;
    final captureButtonSize = isSmallScreen ? 70.0 : 80.0;
    
    return Scaffold(
      backgroundColor: _isCleanMode ? AppColors.cleanBackground : AppColors.dirtyBackground,
      body: SafeArea(
        child: Column(
          children: [
            // 1. 아이콘 선택 그리드 (상단)
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
                  
                  // 추적된 손 위치에 AR 오버레이 표시
                  if (_selectedIcon != null) ..._buildHandOverlays(arOverlaySize),
                  
                  // 추적된 얼굴 위치에 AR 오버레이 표시 (더러운 모드일 때만)
                  if (_selectedIcon != null && !_isCleanMode) ..._buildFaceOverlays(arOverlaySize),
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
                  
                  // 촬영 버튼 (반응형 크기)
                  SizedBox(
                    width: captureButtonSize,
                    height: captureButtonSize,
                    child: CaptureButton(
                      onPressed: _takePicture,
                      isCleanMode: _isCleanMode,
                    ),
                  ),
                  
                  // 설정 버튼 (나중에 구현)
                  IconButton(
                    onPressed: () {
                      // TODO: 설정 화면으로 이동
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
  
  /// 카메라 뷰 빌드
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
  
  /// 추적된 손 위치에 AR 오버레이 생성
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
                .withOpacity(0.8),
            shape: BoxShape.circle,
            border: Border.all(
              color: _isCleanMode ? AppColors.cleanPrimary : AppColors.dirtyPrimary,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: (_isCleanMode ? AppColors.cleanPrimary : AppColors.dirtyPrimary)
                    .withOpacity(0.6),
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
  
  /// 추적된 얼굴 위치에 AR 오버레이 생성 (더러운 모드용)
  List<Widget> _buildFaceOverlays(double overlaySize) {
    return _trackedFacePositions.map((facePosition) {
      return Positioned(
        left: facePosition.dx - (overlaySize / 2),
        top: facePosition.dy - (overlaySize / 2),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          width: overlaySize * 0.8, // 얼굴용은 약간 작게
          height: overlaySize * 0.8,
          decoration: BoxDecoration(
            color: AppColors.dirtyAccent.withOpacity(0.7),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.dirtyPrimary,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.dirtyPrimary.withOpacity(0.5),
                blurRadius: 6,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Icon(
            Icons.coronavirus, // 얼굴에는 세균 아이콘
            size: overlaySize * 0.3,
            color: Colors.white,
          ),
        ),
      );
    }).toList();
  }
}