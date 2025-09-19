import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../providers/app_state_provider.dart';
import '../../../../providers/camera_provider.dart';
import '../../../../providers/ar_effects_provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../services/storage_service.dart';
import '../../../../app/injection_container.dart';
import '../../../gallery/data/services/gallery_service.dart';

class CaptureButton extends StatefulWidget {
  const CaptureButton({Key? key}) : super(key: key);

  @override
  State<CaptureButton> createState() => _CaptureButtonState();
}

class _CaptureButtonState extends State<CaptureButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  Future<void> _capturePhoto() async {
    // Haptic feedback
    HapticFeedback.mediumImpact();
    
    final appState = context.read<AppStateProvider>();
    final cameraProvider = context.read<CameraProvider>();
    final arEffectsProvider = context.read<AREffectsProvider>();
    
    // Set capturing state
    appState.setCapturing(true);
    
    // Flash effect
    arEffectsProvider.scaleAllEffects(1.2);
    
    try {
      // Take picture
      final photo = await cameraProvider.takePicture();
      
      if (photo != null) {
        // Save to gallery
        final galleryService = getIt<GalleryService>();
        final saved = await galleryService.savePhoto(photo.path);
        
        if (saved && mounted) {
          // Update photo count
          final storageService = getIt<StorageService>();
          await storageService.incrementPhotoCount();
          
          // Show success message
          _showSuccessMessage();
        }
      }
    } catch (e) {
      debugPrint('Error capturing photo: $e');
      _showErrorMessage();
    } finally {
      // Reset effects
      await Future.delayed(const Duration(milliseconds: 300));
      arEffectsProvider.scaleAllEffects(0.83); // 1/1.2 to restore
      appState.setCapturing(false);
    }
  }
  
  void _showSuccessMessage() {
    if (!mounted) return;
    
    final appState = context.read<AppStateProvider>();
    String message;
    
    if (appState.currentMode == AppMode.clean) {
      message = '✨ 반짝반짝 깨끗한 사진이 저장되었어요!';
    } else {
      message = '🦠 세균이 보여요! 빨리 씻으세요!';
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              appState.currentMode == AppMode.clean
                  ? Icons.check_circle
                  : Icons.warning,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: appState.currentMode == AppMode.clean
            ? AppColors.cleanMode
            : AppColors.dirtyMode,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        margin: const EdgeInsets.all(20),
        duration: const Duration(seconds: 2),
      ),
    );
  }
  
  void _showErrorMessage() {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.error, color: Colors.white),
            SizedBox(width: 10),
            Text('사진 저장에 실패했어요'),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        margin: const EdgeInsets.all(20),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        return GestureDetector(
          onTapDown: (_) {
            setState(() => _isPressed = true);
            _animationController.forward();
          },
          onTapUp: (_) {
            setState(() => _isPressed = false);
            _animationController.reverse();
            _capturePhoto();
          },
          onTapCancel: () {
            setState(() => _isPressed = false);
            _animationController.reverse();
          },
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: appState.currentMode == AppMode.clean
                          ? [AppColors.cleanMode, AppColors.cleanModeLight]
                          : [AppColors.dirtyMode, AppColors.dirtyModeDark],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (appState.currentMode == AppMode.clean
                                ? AppColors.cleanMode
                                : AppColors.dirtyMode)
                            .withOpacity(0.5),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                    border: Border.all(
                      color: Colors.white,
                      width: 4,
                    ),
                  ),
                  child: Center(
                    child: appState.isCapturing
                        ? const SizedBox(
                            width: 30,
                            height: 30,
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                              strokeWidth: 3,
                            ),
                          )
                        : Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 35,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.3),
                                offset: const Offset(1, 1),
                                blurRadius: 3,
                              ),
                            ],
                          ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}