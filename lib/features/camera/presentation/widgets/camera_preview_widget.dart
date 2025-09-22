import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import '../../../../providers/camera_provider.dart';
import '../../../../providers/app_state_provider.dart';
import '../../../../core/constants/app_colors.dart';

class CameraPreviewWidget extends StatelessWidget {
  const CameraPreviewWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<CameraProvider, AppStateProvider>(
      builder: (context, cameraProvider, appState, child) {
        if (!cameraProvider.isInitialized || cameraProvider.controller == null) {
          return Container(
            color: Colors.black,
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                  SizedBox(height: 20),
                  Text(
                    '카메라 준비 중...',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          );
        }
        
        return Stack(
          fit: StackFit.expand,
          children: [
            // Camera Preview
            Transform.scale(
              scale: cameraProvider.currentZoom,
              child: Center(
                child: CameraPreview(cameraProvider.controller!),
              ),
            ),
            
            // Color Filter Overlay
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.5,
                  colors: appState.currentMode == AppMode.clean
                      ? [
                          Colors.transparent,
                          AppColors.cleanMode.withValues(alpha: 0.1),
                        ]
                      : [
                          Colors.transparent,
                          AppColors.dirtyMode.withValues(alpha: 0.15),
                        ],
                ),
              ),
            ),
            
            // Vignette Effect
            Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.8,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.3),
                  ],
                ),
              ),
            ),
            
            // Flash Effect for Capture
            if (appState.isCapturing)
              AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                color: Colors.white.withValues(alpha: 0.3),
              ),
          ],
        );
      },
    );
  }
}