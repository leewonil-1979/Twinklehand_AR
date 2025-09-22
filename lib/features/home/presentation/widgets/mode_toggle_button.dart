import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../providers/app_state_provider.dart';
import '../../../../providers/ar_effects_provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';

class ModeToggleButton extends StatefulWidget {
  const ModeToggleButton({Key? key}) : super(key: key);

  @override
  State<ModeToggleButton> createState() => _ModeToggleButtonState();
}

class _ModeToggleButtonState extends State<ModeToggleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
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
  
  void _toggleMode() {
    // Haptic feedback
    HapticFeedback.lightImpact();
    
    // Animate button
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
    
    // Toggle mode
    final appState = context.read<AppStateProvider>();
    appState.toggleMode();
    
    // Regenerate AR effects with new mode
    final arProvider = context.read<AREffectsProvider>();
    arProvider.generateEffects(
      icon: appState.currentIcon,
      count: appState.currentMode == AppMode.clean ? 12 : 20,
      mode: appState.currentMode,
    );
    
    // Show mode change message
    _showModeChangeMessage(appState.currentMode);
  }
  
  void _showModeChangeMessage(AppMode mode) {
    if (!mounted) return;
    
    final message = mode == AppMode.clean 
      ? '✨ 반짝반짝! 깨끗해졌어요!' 
      : '🦠 어머나! 세균이 보여요!';
    
    final color = mode == AppMode.clean 
      ? AppColors.cleanMode 
      : AppColors.dirtyMode;
    
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              message,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        margin: const EdgeInsets.only(bottom: 100, left: 50, right: 50),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        final isCleanMode = appState.currentMode == AppMode.clean;
        
        return GestureDetector(
          onTap: _toggleMode,
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Transform.rotate(
                  angle: _rotationAnimation.value,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isCleanMode
                            ? [Colors.orange.shade600, Colors.deepOrange]
                            : [Colors.green.shade500, Colors.lightGreen],
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: (isCleanMode
                                  ? Colors.orange
                                  : Colors.green)
                              .withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 5),
                          spreadRadius: 2,
                        ),
                      ],
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Text(
                            isCleanMode ? '🦠' : '✨',
                            key: ValueKey(isCleanMode),
                            style: const TextStyle(fontSize: 22),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          isCleanMode
                              ? AppStrings.switchToDirty
                              : AppStrings.switchToClean,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
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