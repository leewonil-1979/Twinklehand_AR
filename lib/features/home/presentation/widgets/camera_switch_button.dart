import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../providers/camera_provider.dart';
import '../../../../core/constants/app_colors.dart';

class CameraSwitchButton extends StatefulWidget {
  const CameraSwitchButton({Key? key}) : super(key: key);

  @override
  State<CameraSwitchButton> createState() => _CameraSwitchButtonState();
}

class _CameraSwitchButtonState extends State<CameraSwitchButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;
  bool _isSwitching = false;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
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
  
  Future<void> _switchCamera() async {
    if (_isSwitching) return;
    
    setState(() {
      _isSwitching = true;
    });
    
    // Haptic feedback
    HapticFeedback.lightImpact();
    
    // Start rotation animation
    _animationController.forward();
    
    try {
      final cameraProvider = context.read<CameraProvider>();
      await cameraProvider.switchCamera();
      
      // Show feedback message
      _showSwitchMessage(cameraProvider.isBackCamera);
      
    } catch (e) {
      debugPrint('Error switching camera: $e');
      _showErrorMessage();
    } finally {
      // Reset animation
      await Future.delayed(const Duration(milliseconds: 100));
      _animationController.reset();
      
      setState(() {
        _isSwitching = false;
      });
    }
  }
  
  void _showSwitchMessage(bool isBackCamera) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isBackCamera ? Icons.camera_rear : Icons.camera_front,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              isBackCamera ? '후면 카메라로 전환' : '전면 카메라로 전환',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        backgroundColor: AppColors.overlayDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        margin: const EdgeInsets.all(20),
        duration: const Duration(seconds: 1),
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
            Text('카메라 전환에 실패했어요'),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        margin: const EdgeInsets.all(20),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Consumer<CameraProvider>(
      builder: (context, cameraProvider, child) {
        return GestureDetector(
          onTap: _switchCamera,
          child: AnimatedBuilder(
            animation: _rotationAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotationAnimation.value * 3.14159, // 180 degrees
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.overlayDark.withValues(alpha: 0.8),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Center(
                    child: _isSwitching
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                              strokeWidth: 2,
                            ),
                          )
                        : Icon(
                            Icons.flip_camera_ios,
                            color: Colors.white,
                            size: 24,
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