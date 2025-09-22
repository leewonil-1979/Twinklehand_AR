import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../providers/app_state_provider.dart';
import '../../../../services/storage_service.dart';
import '../../../../app/injection_container.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/themes/text_styles.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final StorageService _storageService = getIt<StorageService>();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          AppStrings.settings,
          style: TextStyles.heading2,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: Consumer<AppStateProvider>(
        builder: (context, appState, child) {
          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Premium Section
                if (!appState.isPremium) ...[
                  _buildPremiumCard(context),
                  const SizedBox(height: 20),
                ],
                
                // General Settings
                _buildSectionTitle('일반 설정'),
                const SizedBox(height: 10),
                _buildSettingTile(
                  icon: Icons.volume_up,
                  title: AppStrings.soundEffects,
                  trailing: Switch(
                    value: appState.soundEnabled,
                    onChanged: (value) {
                      HapticFeedback.selectionClick();
                      appState.toggleSound();
                      _storageService.setSoundEnabled(value);
                    },
                    activeColor: AppColors.primary,
                  ),
                ),
                _buildSettingTile(
                  icon: Icons.vibration,
                  title: AppStrings.vibration,
                  trailing: Switch(
                    value: appState.vibrationEnabled,
                    onChanged: (value) {
                      HapticFeedback.selectionClick();
                      appState.toggleVibration();
                      _storageService.setVibrationEnabled(value);
                    },
                    activeColor: AppColors.primary,
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Statistics
                _buildSectionTitle('통계'),
                const SizedBox(height: 10),
                _buildSettingTile(
                  icon: Icons.photo_library,
                  title: '촬영한 사진',
                  trailing: Text(
                    '${_storageService.photoCount}장',
                    style: TextStyles.bodyLarge.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildSettingTile(
                  icon: Icons.timer,
                  title: '총 씻기 시간',
                  trailing: Text(
                    '${_storageService.totalCleanTime ~/ 60}분',
                    style: TextStyles.bodyLarge.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // App Info
                _buildSectionTitle('앱 정보'),
                const SizedBox(height: 10),
                _buildSettingTile(
                  icon: Icons.info_outline,
                  title: AppStrings.about,
                  onTap: () => _showAboutDialog(context),
                ),
                _buildSettingTile(
                  icon: Icons.privacy_tip_outlined,
                  title: AppStrings.privacy,
                  onTap: () => _showPrivacyPolicy(context),
                ),
                _buildSettingTile(
                  icon: Icons.description_outlined,
                  title: AppStrings.terms,
                  onTap: () => _showTermsOfService(context),
                ),
                _buildSettingTile(
                  icon: Icons.system_update,
                  title: AppStrings.version,
                  trailing: const Text(
                    '1.0.0',
                    style: TextStyles.bodyMedium,
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Reset Button
                Center(
                  child: TextButton(
                    onPressed: () => _showResetDialog(context),
                    child: Text(
                      '설정 초기화',
                      style: TextStyles.bodyMedium.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildPremiumCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.purple.shade600,
            Colors.pink.shade400,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text('✨', style: TextStyle(fontSize: 35)),
              SizedBox(width: 10),
              Text('👑', style: TextStyle(fontSize: 50)),
              SizedBox(width: 10),
              Text('✨', style: TextStyle(fontSize: 35)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'TwinkleHands Premium',
            style: TextStyles.heading3.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 5),
          Text(
            '광고 제거 & 모든 기능 사용',
            style: TextStyles.bodyMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 15),
          ElevatedButton(
            onPressed: () => context.push('/premium'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
            ),
            child: const Text('자세히 보기'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyles.heading3.copyWith(
        color: AppColors.primary,
      ),
    );
  }
  
  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: AppColors.primary,
        ),
        title: Text(
          title,
          style: TextStyles.bodyLarge,
        ),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
  
  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Row(
          children: const [
            Text('🌟', style: TextStyle(fontSize: 30)),
            SizedBox(width: 10),
            Text(
              'TwinkleHands AR',
              style: TextStyles.heading3,
            ),
          ],
        ),
        content: const Text(
          'TwinkleHands는 아이들이 즐겁게 씻기를 배울 수 있도록 '
          'AR 기술을 활용한 교육용 앱입니다.\n\n'
          '카메라로 비춘 신체 부위에 재미있는 효과를 보여주어 '
          '아이들이 자연스럽게 씻는 습관을 기를 수 있도록 도와줍니다.\n\n'
          '✨ 반짝반짝 깨끗한 몸으로 건강하게!',
          style: TextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
  
  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          '개인정보 처리방침',
          style: TextStyles.heading3,
        ),
        content: const SingleChildScrollView(
          child: Text(
            'TwinkleHands AR은 사용자의 개인정보를 소중히 여기며, '
            '다음과 같이 처리합니다:\n\n'
            '📷 카메라 접근\n'
            '• AR 효과 제공을 위해서만 사용\n'
            '• 실시간 처리 후 즉시 폐기\n'
            '• 서버로 전송하지 않음\n\n'
            '💾 저장 정보\n'
            '• 촬영한 사진: 기기 갤러리에만 저장\n'
            '• 설정 정보: 기기 내부에만 저장\n\n'
            '🚫 수집하지 않는 정보\n'
            '• 개인 식별 정보\n'
            '• 위치 정보\n'
            '• 연락처 정보\n\n'
            '아이들의 안전과 프라이버시를 최우선으로 합니다.',
            style: TextStyles.bodyMedium,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
  
  void _showTermsOfService(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          '이용약관',
          style: TextStyles.heading3,
        ),
        content: const SingleChildScrollView(
          child: Text(
            'TwinkleHands AR 이용약관\n\n'
            '1. 서비스 이용\n'
            '• 본 앱은 교육 목적으로 제공됩니다\n'
            '• 부모님의 지도하에 사용을 권장합니다\n\n'
            '2. 사용자 책임\n'
            '• 카메라 사용 시 안전에 주의하세요\n'
            '• 타인의 프라이버시를 존중해주세요\n\n'
            '3. 콘텐츠\n'
            '• 모든 AR 효과는 아동 친화적입니다\n'
            '• 부적절한 콘텐츠 발견 시 신고해주세요\n\n'
            '4. 구매 및 환불\n'
            '• 인앱 구매는 스토어 정책을 따릅니다\n'
            '• 프리미엄 기능은 구매 계정에 귀속됩니다\n\n'
            '건강한 습관 만들기, TwinkleHands와 함께!',
            style: TextStyles.bodyMedium,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
  
  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          '설정 초기화',
          style: TextStyles.heading3,
        ),
        content: const Text(
          '모든 설정을 초기값으로 되돌립니다.\n'
          '(촬영한 사진은 삭제되지 않습니다)\n\n'
          '이 작업은 취소할 수 없습니다.',
          style: TextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              _storageService.clearAll();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ 설정이 초기화되었습니다'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: Text(
              '초기화',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}