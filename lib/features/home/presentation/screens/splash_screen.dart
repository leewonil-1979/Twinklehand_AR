import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/themes/text_styles.dart';
import '../../../../providers/camera_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _twinkleController;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _twinkleAnimation;
  late Animation<double> _textFadeAnimation;
  
  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeApp();
  }
  
  void _setupAnimations() {
    // Logo animation
    _logoController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _logoScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));
    
    // Twinkle animation
    _twinkleController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
    
    _twinkleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _twinkleController,
      curve: Curves.easeInOut,
    ));
    
    _textFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.5, 1.0),
    ));
    
    // Start animations
    _logoController.forward();
  }
  
  Future<void> _initializeApp() async {
    // Initialize camera
    final cameraProvider = context.read<CameraProvider>();
    await cameraProvider.initializeCamera();
    
    // Wait minimum splash duration
    await Future.delayed(const Duration(seconds: 3));
    
    // Navigate to main screen
    if (mounted) {
      context.go('/main');
    }
  }
  
  @override
  void dispose() {
    _logoController.dispose();
    _twinkleController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primaryDark,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Logo with Twinkle Effect
                AnimatedBuilder(
                  animation: Listenable.merge([_logoController, _twinkleController]),
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _logoScaleAnimation.value,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Glow effect
                          Container(
                            width: 180,
                            height: 180,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.yellow.withOpacity(_twinkleAnimation.value * 0.6),
                                  blurRadius: 40,
                                  spreadRadius: 20,
                                ),
                              ],
                            ),
                          ),
                          // Main icon container
                          Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  const Text(
                                    '🧼',
                                    style: TextStyle(fontSize: 70),
                                  ),
                                  // Twinkle stars
                                  Transform.translate(
                                    offset: const Offset(-30, -30),
                                    child: Opacity(
                                      opacity: _twinkleAnimation.value,
                                      child: const Text('✨', style: TextStyle(fontSize: 30)),
                                    ),
                                  ),
                                  Transform.translate(
                                    offset: const Offset(30, -20),
                                    child: Opacity(
                                      opacity: 1 - _twinkleAnimation.value,
                                      child: const Text('🌟', style: TextStyle(fontSize: 25)),
                                    ),
                                  ),
                                  Transform.translate(
                                    offset: const Offset(35, 30),
                                    child: Opacity(
                                      opacity: _twinkleAnimation.value,
                                      child: const Text('💫', style: TextStyle(fontSize: 20)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 40),
                // Animated Title
                FadeTransition(
                  opacity: _textFadeAnimation,
                  child: Column(
                    children: [
                      Text(
                        'TwinkleHands',
                        style: TextStyles.heading1.copyWith(
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.3),
                              offset: const Offset(2, 2),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        AppStrings.appTagline,
                        style: TextStyles.bodyLarge.copyWith(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 80),
                // Loading indicator
                FadeTransition(
                  opacity: _textFadeAnimation,
                  child: Column(
                    children: [
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white.withOpacity(0.8),
                          ),
                          strokeWidth: 3,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        AppStrings.splashLoading,
                        style: TextStyles.bodyMedium.copyWith(
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}