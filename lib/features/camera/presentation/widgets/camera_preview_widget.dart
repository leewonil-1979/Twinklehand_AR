import 'dart:async';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import '../../../../providers/camera_provider.dart';
import '../../../../providers/app_state_provider.dart';
import '../../../../core/constants/app_colors.dart';

class CameraPreviewWidget extends StatefulWidget {
  const CameraPreviewWidget({Key? key}) : super(key: key);

  @override
  State<CameraPreviewWidget> createState() => _CameraPreviewWidgetState();
}

class _CameraPreviewWidgetState extends State<CameraPreviewWidget> {
  Offset? _focusIndicatorPosition;
  Timer? _focusIndicatorTimer;

  @override
  void dispose() {
    _focusIndicatorTimer?.cancel();
    super.dispose();
  }

  void _showFocusIndicator(Offset position) {
    setState(() {
      _focusIndicatorPosition = position;
    });
    _focusIndicatorTimer?.cancel();
    _focusIndicatorTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _focusIndicatorPosition = null;
        });
      }
    });
  }

  Future<void> _handleTapToFocus(
    TapDownDetails details,
    CameraProvider cameraProvider,
    Size previewSize,
  ) async {
    if (!cameraProvider.isInitialized || cameraProvider.controller == null) {
      return;
    }

    final Offset position = details.localPosition;
    final normalized = Offset(
      (position.dx / previewSize.width).clamp(0.0, 1.0),
      (position.dy / previewSize.height).clamp(0.0, 1.0),
    );

    await cameraProvider.setFocusPoint(normalized);
    _showFocusIndicator(position);
  }

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

        return LayoutBuilder(
          builder: (context, constraints) {
            final previewSize = Size(constraints.maxWidth, constraints.maxHeight);
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (details) =>
                  _handleTapToFocus(details, cameraProvider, previewSize),
              child: Stack(
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

                  // Focus Indicator
                  if (_focusIndicatorPosition != null)
                    Positioned(
                      left: _focusIndicatorPosition!.dx - 30,
                      top: _focusIndicatorPosition!.dy - 30,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.9),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white.withValues(alpha: 0.05),
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
              ),
            );
          },
        );
      },
    );
  }
}