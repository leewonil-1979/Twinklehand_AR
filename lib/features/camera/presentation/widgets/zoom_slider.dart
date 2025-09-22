import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/camera_provider.dart';
import '../../../../core/constants/app_colors.dart';

class ZoomSlider extends StatelessWidget {
  const ZoomSlider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CameraProvider>(
      builder: (context, cameraProvider, child) {
        if (!cameraProvider.isInitialized) {
          return const SizedBox.shrink();
        }
        
        return Container(
          width: 50,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              // Zoom In Icon
              Icon(
                Icons.add,
                color: Colors.white.withValues(alpha: 0.7),
                size: 20,
              ),
              // Slider
              Expanded(
                child: RotatedBox(
                  quarterTurns: 3,
                  child: SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 3,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 8,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 16,
                      ),
                      activeTrackColor: AppColors.primary,
                      inactiveTrackColor: Colors.white.withValues(alpha: 0.3),
                      thumbColor: Colors.white,
                      overlayColor: AppColors.primary.withValues(alpha: 0.3),
                    ),
                    child: Slider(
                      value: cameraProvider.currentZoom,
                      min: cameraProvider.minZoom,
                      max: cameraProvider.maxZoom,
                      onChanged: (value) {
                        cameraProvider.setZoomLevel(value);
                      },
                    ),
                  ),
                ),
              ),
              // Zoom Out Icon
              Icon(
                Icons.remove,
                color: Colors.white.withValues(alpha: 0.7),
                size: 20,
              ),
              const SizedBox(height: 10),
              // Current Zoom Level
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${cameraProvider.currentZoom.toStringAsFixed(1)}x',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}