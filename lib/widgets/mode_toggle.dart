import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

/// 더러운/깨끗한 모드 전환 토글 버튼
/// 시각적으로 현재 모드를 표시하고 터치로 전환 가능
class ModeToggle extends StatelessWidget {
  final bool isCleanMode;
  final Function(bool) onModeChanged;

  const ModeToggle({
    super.key,
    required this.isCleanMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.grey.shade200,
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 더러운 모드 버튼
          _buildModeButton(
            label: '더러움',
            icon: Icons.coronavirus,
            isSelected: !isCleanMode,
            color: AppColors.dirtyPrimary,
            backgroundColor: AppColors.dirtyBackground,
            onTap: () => onModeChanged(false),
          ),
          const SizedBox(width: 4),
          // 깨끗한 모드 버튼
          _buildModeButton(
            label: '깨끗한',
            icon: Icons.auto_awesome,
            isSelected: isCleanMode,
            color: AppColors.cleanPrimary,
            backgroundColor: AppColors.cleanBackground,
            onTap: () => onModeChanged(true),
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required Color color,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          color: isSelected ? color : Colors.transparent,
          boxShadow: isSelected ? [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 4.0,
              spreadRadius: 1.0,
            ),
          ] : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : color,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
