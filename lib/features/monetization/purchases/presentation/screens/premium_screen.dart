import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../../providers/app_state_provider.dart';
import '../../../../../services/storage_service.dart';
import '../../../../../app/injection_container.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/themes/text_styles.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({Key? key}) : super(key: key);

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen>
    with TickerProviderStateMixin {
  late AnimationController _crownController;
  late AnimationController _featureController;
  late Animation<double> _crownAnimation;
  late Animation<double> _featureAnimation;
  
  final List<PremiumFeature> _features = [
    PremiumFeature(
      icon: '🚫',
      title: '광고 제거',
      description: '모든 광고를 제거하고 깔끔하게 사용하세요',
    ),
    PremiumFeature(
      icon: '🎨',
      title: '모든 아이콘 잠금 해제',
      description: '100개 이상의 특별한 아이콘을 사용하세요',
    ),
    PremiumFeature(
      icon: '✨',
      title: '프리미엄 효과',
      description: '더욱 화려한 AR 효과를 경험하세요',
    ),
    PremiumFeature(
      icon: '🎵',
      title: '특별한 효과음',
      description: '재미있는 효과음으로 즐거움을 더하세요',
    ),
    PremiumFeature(
      icon: '☁️',
      title: '클라우드 백업',
      description: '소중한 사진을 안전하게 보관하세요',
    ),
    PremiumFeature(
      icon: '👨‍👩‍👧‍👦',
      title: '가족 공유',
      description: '최대 6명까지 함께 사용할 수 있어요',
    ),
  ];
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }
  
  void _initializeAnimations() {
    _crownController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _featureController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
    
    _crownAnimation = Tween<double>(
      begin: 0.9,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _crownController,
      curve: Curves.easeInOut,
    ));
    
    _featureAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _featureController,
      curve: Curves.easeOutBack,
    ));
  }
  
  @override
  void dispose() {
    _crownController.dispose();
    _featureController.dispose();
    super.dispose();
  }
  
  Future<void> _purchasePremium() async {
    // TODO: Implement actual in-app purchase
    HapticFeedback.heavyImpact();
    
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      ),
    );
    
    // Simulate purchase
    await Future.delayed(const Duration(seconds: 2));
    
    // Update state
    final appState = context.read<AppStateProvider>();
    appState.setPremium(true);
    
    final storageService = getIt<StorageService>();
    await storageService.setPremium(true);
    
    // Close loading and show success
    if (mounted) {
      Navigator.pop(context);
      _showSuccessDialog();
    }
  }
  
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '🎉',
              style: TextStyle(fontSize: 60),
            ),
            const SizedBox(height: 20),
            Text(
              '프리미엄 구매 완료!',
              style: TextStyles.heading2,
            ),
            const SizedBox(height: 10),
            Text(
              '모든 기능을 사용할 수 있습니다',
              style: TextStyles.bodyMedium.copyWith(
                color: Colors.white70,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.pop();
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primaryDark,
              AppColors.background,
            ],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => context.pop(),
                ),
              ),
              
              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Crown Animation
                      AnimatedBuilder(
                        animation: _crownAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _crownAnimation.value,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.yellow.shade600,
                                    Colors.orange.shade600,
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.orange.withValues(alpha: 0.5),
                                    blurRadius: 30,
                                    spreadRadius: 10,
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Text(
                                  '👑',
                                  style: TextStyle(fontSize: 60),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 30),
                      
                      // Title
                      Text(
                        '손반짝 프리미엄',
                        style: TextStyles.heading1.copyWith(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      
                      const SizedBox(height: 10),
                      
                      // Subtitle
                      Text(
                        '더 많은 기능으로 더 재미있게!',
                        style: TextStyles.bodyLarge.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Features List
                      AnimatedBuilder(
                        animation: _featureAnimation,
                        builder: (context, child) {
                          return Column(
                            children: _features.asMap().entries.map((entry) {
                              final index = entry.key;
                              final feature = entry.value;
                              final delay = index * 0.1;
                              
                              return FadeTransition(
                                opacity: _featureAnimation,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: Offset(0, 0.5 + delay),
                                    end: Offset.zero,
                                  ).animate(_featureAnimation),
                                  child: _buildFeatureTile(feature),
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Price Options
                      _buildPriceOptions(),
                      
                      const SizedBox(height: 20),
                      
                      // Terms
                      Text(
                        '구매 후 7일 이내 환불 가능',
                        style: TextStyles.caption,
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 10),
                      
                      // Restore Purchases
                      TextButton(
                        onPressed: _restorePurchases,
                        child: Text(
                          '구매 복원',
                          style: TextStyles.bodyMedium.copyWith(
                            color: AppColors.primary,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildFeatureTile(PremiumFeature feature) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                feature.icon,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature.title,
                  style: TextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  feature.description,
                  style: TextStyles.bodySmall.copyWith(
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPriceOptions() {
    return Column(
      children: [
        // Monthly
        _buildPriceCard(
          title: '월간 구독',
          price: '₩1,900',
          period: '/월',
          isPopular: false,
          onTap: () => _purchasePremium(),
        ),
        const SizedBox(height: 15),
        // Yearly
        _buildPriceCard(
          title: '연간 구독',
          price: '₩14,900',
          period: '/년',
          savings: '35% 할인',
          isPopular: true,
          onTap: () => _purchasePremium(),
        ),
        const SizedBox(height: 15),
        // Lifetime
        _buildPriceCard(
          title: '평생 이용권',
          price: '₩29,900',
          period: '단 한 번',
          isPopular: false,
          onTap: () => _purchasePremium(),
        ),
      ],
    );
  }
  
  Widget _buildPriceCard({
    required String title,
    required String price,
    required String period,
    String? savings,
    required bool isPopular,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: isPopular
              ? AppColors.primaryGradient
              : null,
          color: isPopular ? null : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
      color: isPopular
        ? Colors.transparent
        : AppColors.primary.withValues(alpha: 0.3),
            width: 2,
          ),
          boxShadow: isPopular
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            if (isPopular)
              Positioned(
                top: -5,
                right: -5,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    '인기',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (savings != null) ...[
                      const SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          savings,
                          style: TextStyle(
                            color: AppColors.success,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      price,
                      style: TextStyles.heading2.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      period,
                      style: TextStyles.bodySmall.copyWith(
                        color: Colors.white60,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _restorePurchases() async {
    // TODO: Implement restore purchases
    HapticFeedback.lightImpact();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('구매 복원 중...'),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}

class PremiumFeature {
  final String icon;
  final String title;
  final String description;
  
  PremiumFeature({
    required this.icon,
    required this.title,
    required this.description,
  });
}