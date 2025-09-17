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
      
      // ?�면 카메???�선 ?�택 (?�씻�????�성)
      final frontCamera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras!.first,
      );
      
      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.high,
        enableAudio: false, // ?�씻�??�에?�는 ?�디??불필??
      );
      
      await _cameraController!.initialize();
      
      // mounted 체크 ???�태 ?�데?�트
      if (mounted && _cameraController != null && _cameraController!.value.isInitialized) {
        // ??추적 ?�비??초기??
        await _handTrackingService.initialize();
        
        // 카메???�트�??�작 (모바?�에?�만)
        if (!kIsWeb) {
          _cameraController!.startImageStream(_processImage);
        }
        
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
              debugPrint('카메??초기???�류: $e');
      if (mounted) {
        setState(() {
          _isCameraInitialized = false;
        });
      }
    }
  }
  
  /// 카메???��?지 ?�트�?처리 (??추적)
  bool _isProcessing = false;
  
  Future<void> _processImage(CameraImage image) async {
    // ?��? 처리 중이�??�킵
    if (_isProcessing) return;
    _isProcessing = true;
    
    try {
      // ?�과 ?�굴 ?�치 감�?
      final result = await _handTrackingService.detectHandsAndFaces(image);
      
      if (mounted) {
        setState(() {
          _trackedHandPositions = result['hands'] ?? [];
          _trackedFacePositions = result['faces'] ?? [];
        });
      }
    } catch (e) {
              debugPrint('?��?지 처리 ?�류: $e');
    } finally {
      _isProcessing = false;
    }
  }
  
  /// 모드 ?�환 (?�러????깨끗??
  void _toggleMode(bool isCleanMode) {
    setState(() {
      _isCleanMode = isCleanMode;
      // 모드 변경시 �?번째 ?�이콘으�??�동 ?�택
      _selectedIcon = isCleanMode ? _cleanIcons.first : _dirtyIcons.first;
    });
  }
  
  /// ?�이�??�택
  void _selectIcon(AppIcon icon) {
    setState(() {
      _selectedIcon = icon;
    });
  }
  
  /// ?�이�??�름???�른 IconData 반환
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
  
  /// ?�진 촬영
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
            // 1. ?�이�??�택 그리??(?�단)
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
            
            // 2. 카메??�?+ AR ?�버?�이 (중앙)
            Expanded(
              child: Stack(
                children: [
                  // 카메??�?
                  _buildCameraView(),
                  
                  // 추적?????�치??AR ?�버?�이 ?�시
                  if (_selectedIcon != null) ..._buildHandOverlays(arOverlaySize),
                  
                  // 추적???�굴 ?�치??AR ?�버?�이 ?�시 (?�러??모드???�만)
                  if (_selectedIcon != null && !_isCleanMode) ..._buildFaceOverlays(arOverlaySize),
                ],
              ),
            ),
            
            // 3. ?�단 컨트�??�역
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // 모드 ?�환 버튼
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
  
  /// 추적???�굴 ?�치??AR ?�버?�이 ?�성 (?�러??모드??
  List<Widget> _buildFaceOverlays(double overlaySize) {
    return _trackedFacePositions.map((facePosition) {
      return Positioned(
        left: facePosition.dx - (overlaySize / 2),
        top: facePosition.dy - (overlaySize / 2),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          width: overlaySize * 0.8, // ?�굴?��? ?�간 ?�게
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
}
